#include "RecursionRemoval.hpp"

#include "Parameter.hpp"
#include "application_manager.hpp"
#include "behavioral_helper.hpp"
#include "call_graph_manager.hpp"
#include "dbgPrintHelper.hpp"
#include "function_behavior.hpp"
#include "hls_manager.hpp"
#include "op_graph.hpp"
#include "string_manipulation.hpp"
#include "token_interface.hpp"
#include "tree_basic_block.hpp"
#include "tree_helper.hpp"
#include "tree_manager.hpp"
#include "tree_manipulation.hpp"
#include "tree_node.hpp"

RecursionRemoval::RecursionRemoval(const ParameterConstRef params, const application_managerRef AM,
                                                 unsigned int fun_id, const DesignFlowManagerConstRef dfm)
    : FunctionFrontendFlowStep(AM, fun_id, RECURSION_REMOVAL, dfm, params)
{
   debug_level = parameters->get_class_debug_level(GET_CLASS(*this), DEBUG_LEVEL_NONE);
   std::cout << "RecursionRemoval constructor\n";
}

RecursionRemoval::~RecursionRemoval() = default;

CustomUnorderedSet<std::pair<FrontendFlowStepType, FrontendFlowStep::FunctionRelationship>>
RecursionRemoval::ComputeFrontendRelationships(const DesignFlowStep::RelationshipType relationship_type) const
{
   CustomUnorderedSet<std::pair<FrontendFlowStepType, FunctionRelationship>> relationships;
   switch(relationship_type)
   {
      case(DEPENDENCE_RELATIONSHIP):
      {
         //relationships.insert(std::make_pair(BLOCK_FIX, SAME_FUNCTION)); // it seems like it'd be useful for this to run first, but w/e
         //relationships.insert(std::make_pair(STRING_CST_FIX, WHOLE_APPLICATION));
         relationships.insert(std::make_pair(RECURSION_REMOVAL, CALLING_FUNCTIONS));
         //relationships.insert(std::make_pair(REBUILD_INITIALIZATION, CALLING_FUNCTIONS));
         break;
      }
      case(PRECEDENCE_RELATIONSHIP):
      {
         //relationships.insert(std::make_pair(INTERFACE_INFER, ALL_FUNCTIONS));
         break;
      }
      case(INVALIDATION_RELATIONSHIP):
      {
         break;
      }
      default:
      {
         THROW_UNREACHABLE("");
      }
   }
   return relationships;
}


DesignFlowStep_Status RecursionRemoval::InternalExec()
{
   std::cout << "\n========== RecursionRemoval is running ==========\n"; 

   bool changed = false;
   const auto TM = AppM->get_tree_manager();
   const auto tree_man = tree_manipulationRef(new tree_manipulation(TM, parameters, AppM));
   const auto tn = TM->GetTreeNode(function_id);
   const auto fd = GetPointer<function_decl>(tn);
   THROW_ASSERT(fd && fd->body, "Node " + STR(tn) + "is not a function_decl or has no body");
   const auto sl = GetPointer<const statement_list>(fd->body);
   THROW_ASSERT(sl, "Body is not a statement_list");
   const auto fname = function_behavior->GetBehavioralHelper()->GetMangledFunctionName();
   const auto ftype = GetPointer<const function_type>(tree_helper::CGetType(tn));
   THROW_ASSERT(!ftype->varargs_flag, "function " + fname + " is varargs"); // CJP i am not sure we need all these asserts, but W/E
   const auto HLSMgr = GetPointer<HLS_manager>(AppM);
   const auto func_arch = HLSMgr ? HLSMgr->module_arch->GetArchitecture(fname) : nullptr;
   

   //std::cerr << "RecursionRemoval is running\n"; 

   bool is_recursive = false; // look for calls to self
   std::set<tree_nodeConstRef> callerNodes; // set of nodes representing calls to self
   for(const auto i : AppM->CGetCallGraphManager()->get_called_by(function_id))
   {
      const auto curr_tn = TM->GetTreeNode(i);
      const auto fdCalled = GetPointerS<const function_decl>(curr_tn);
      if (fd == fdCalled) {
         is_recursive = true;
         callerNodes.insert(curr_tn);
      }
   }

   // DEBUG PRINT IR
   for(const auto& block : sl->list_of_bloc) {
      std::cout << "[+] Examining basic block: " << block.first << "\n";
      for(const auto& stmt : block.second->CGetStmtList()) {
         std::cout << "   [+] Examining statement: " << stmt->ToString() << "; " << stmt->get_kind_text();
         if(stmt->get_kind() == gimple_assign_K)
         {
            tree_nodeConstRef lhs = GetPointerS<const gimple_assign>(stmt)->op0;
            const auto type_node = tree_helper::CGetType(lhs);
            std::cout << " (" << STR(type_node) << " " << type_node->get_kind_text() << ")";
            
            // attempt to print out type of StackFrame* from factorial_iterative
            if (type_node->get_kind() == pointer_type_K)
            {
               const auto pt = GetPointerS<const pointer_type>(type_node);
               auto rec_type_node = pt->ptd; // get pointed-to
               if (rec_type_node->get_kind() == record_type_K) {
                  auto rt = GetPointerS<const record_type>(rec_type_node);
                  if(rt->unql)
                  {
                     rt = GetPointerS<const record_type>(rt->unql);
                  }
                  for(auto& list_of_fld : rt->list_of_flds)
                  {
                     const auto fd = GetPointer<const field_decl>(list_of_fld);
                     std::cout << "    " << STR(fd) << "\n";
                  }
               }
            }
         //const auto type_size = tree_helper::SizeAlloc(type_node);
         //auto type = tree_helper::PrintType(TM, type_node);
         }
         std::cout << "\n";
      }
   } 
   // END DEBUG

   // MODIFY RECURSIVE FUNCTIONS
   if (is_recursive)
   {
      std::cout << "[+] Recursion Removal Function Is Recursive" << std::endl;
      std::cerr << "Is recursive: " 
         + HLSMgr->CGetFunctionBehavior(function_id)->CGetBehavioralHelper()->get_function_name()
         + "\n";

      // Calculate stack frame size for all arguments + active variables
      unsigned int param_n = 0;
      unsigned int stack_size = 0;
      auto p_decl_it = fd->list_of_args.begin();
      auto p_type_head = ftype->prms;
      const auto has_param_types = static_cast<bool>(p_type_head);
      const auto first_block = sl->list_of_bloc.at(BB_ENTRY);
      const auto return_type = tree_helper::GetFunctionReturnType(tn);

      for(; p_decl_it != fd->list_of_args.cend(); p_decl_it++, param_n++)
      {
         const auto p_decl = *p_decl_it;
         const auto p_type = tree_helper::CGetType(p_decl);
         std::cout << "[+] Parameter: " << STR(p_decl) << " Type: " << STR(p_type) << " Size: " << tree_helper::AllocatedMemorySize(p_type) << std::endl;
         stack_size += tree_helper::AllocatedMemorySize(p_type);
      }
      stack_size += tree_helper::AllocatedMemorySize(return_type);
      std::cout << "[+] Number of args: " << param_n << std::endl;
      std::cout << "[+] Return Type: " << return_type << " Return Type Size: " << tree_helper::AllocatedMemorySize(return_type) << std::endl;
      std::cout << "[+] Stack Size: " << stack_size << std::endl;

      // Construct stack frame type // based on tree_nodeRef tree_manipulation::GetBooleanType() const
      tree_nodeRef frame_type_node;

      tree_nodeRef frame_identifier_node = tree_man->create_identifier_node("_StackFrame");
      unsigned int frame_identifier_nid = frame_identifier_node->index; 
      unsigned int type_decl_nid = TM->new_tree_node_id();
      unsigned int frame_type_nid = TM->new_tree_node_id();
      const auto size_node = TM->CreateUniqueIntegerCst((integer_cst_t) stack_size, tree_man->GetBitsizeType());

      std::map<TreeVocabularyTokenTypes_TokenEnum, std::string> IR_schema;
      IR_schema[TOK(TOK_NAME)] = STR(frame_identifier_nid);
      IR_schema[TOK(TOK_TYPE)] = STR(frame_type_nid);
      IR_schema[TOK(TOK_SRCP)] = BUILTIN_SRCP;
      const auto td = TM->create_tree_node(type_decl_nid, type_decl_K, IR_schema);
      std::cout << "Created node " + STR(type_decl_nid) + " (type_decl frame)\n";

      IR_schema.clear();
      IR_schema[TOK(TOK_NAME)] = STR(td->index);
      IR_schema[TOK(TOK_SIZE)] = STR(size_node->index);
      IR_schema[TOK(TOK_ALGN)] = STR(ALGN_BOOLEAN); // TODO: what alignment do we use?
      frame_type_node = TM->create_tree_node(frame_type_nid, record_type_K, IR_schema);

      // Initialize stack frames
      // maybe use create_var_decl ?
      auto intTy = tree_man->GetSignedIntegerType();
      const auto neg1Cst =
                     TM->CreateUniqueIntegerCst((integer_cst_t)-1, intTy);
      const auto assignNeg1 =
            tree_man->CreateGimpleAssign(intTy, tree_nodeRef(), tree_nodeRef(), neg1Cst, function_id, BUILTIN_SRCP);
      
      first_block->PushFront(assignNeg1, AppM);

      // tree_helper::SizeAlloc(struct_type)

      // Build for loop to simulate recursion
      //TODO

      // Rewrite operations around recursive call
      // TODO

      // Remove recursive calls 
      /*for(const auto& block : sl->list_of_bloc)
      {
         for(const auto& stmt : block.second->CGetStmtList())
         {
            TM->ReplaceTreeNode(stmt, p_decl, new_local_var_decl);
         }
      }*/
   }

   if(changed)
   {
      function_behavior->UpdateBBVersion();
      return DesignFlowStep_Status::SUCCESS;
   }

   std::cout << "========== Recursion Removal Complete ==========\n\n";
   return DesignFlowStep_Status::UNCHANGED;
}
