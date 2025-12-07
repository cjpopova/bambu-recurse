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

static const blocRef getFirstBlock(const statement_list *const sl){
   unsigned int bb_index = BB_ENTRY;
   const auto entry_block = sl->list_of_bloc.at(BB_ENTRY);
   const auto succ_blocks = entry_block->list_of_succ;
   bb_index = *(succ_blocks.begin());
   return sl->list_of_bloc.at(bb_index);
}

// Add ty as a field to rec_type
static void add_fld(const tree_managerRef& TM, const tree_manipulationRef& tree_man,
      record_type *rec_type, const std::string& fld_name, const tree_nodeConstRef& ty,
      std::map<TreeVocabularyTokenTypes_TokenEnum, std::string>& IR_schema) {
   std::cout << "[+] adding field" << "\n";
   unsigned fld_nid = TM->new_tree_node_id();
   const auto id_node = tree_man->create_identifier_node(fld_name);
   IR_schema.clear();
   //IR_schema[TOK(TOK_NAME)] = STR(id_node);
   //IR_schema[TOK(TOK_TYPE)] = STR(ty);
   IR_schema[TOK(TOK_SRCP)] = BUILTIN_SRCP;
   auto fld_raw = TM->create_tree_node(fld_nid, field_decl_K, IR_schema);
   auto fld = GetPointer<field_decl>(fld_raw);
   fld->name = id_node;
   fld->type = std::const_pointer_cast<tree_node>(ty);
   fld->algn = tree_helper::AllocatedMemorySize(ty);
   rec_type->add_flds(fld_raw);
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
   //const auto sl = GetPointer<const statement_list>(fd->body);
   const auto sl = GetPointer<statement_list>(fd->body);
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
   std::cout << "===== IR BEFORE manipulation" << std::endl;
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

      // Add global variable top to denote top of the stack
      /*
      const std::string TOP_var_name = "top_stack_ptr";
      auto TOP_var_identifier = tree_man->create_identifier_node(TOP_var_name);
      auto TOP_var_type = tree_man->GetSignedIntegerType();
      const auto* type_sc = GetPointer<const type_node>(TOP_var_type);
      auto TOP_var_init = TM->CreateUniqueIntegerCst((integer_cst_t) -1, TOP_var_type);
      auto global_scpe = tree_man->create_translation_unit_decl();
      auto TOP_var_decl = tree_man->create_var_decl(TOP_var_identifier, TOP_var_type, global_scpe, type_sc->size, 
        tree_nodeRef(), TOP_var_init, BUILTIN_SRCP, type_sc->algn, 1);
      */

      // Calculate stack frame size for all arguments + active variables
      unsigned int param_n = 0;
      unsigned int stack_size = 0;
      auto p_decl_it = fd->list_of_args.begin();
      auto p_type_head = ftype->prms;
      const auto has_param_types = static_cast<bool>(p_type_head);
            
      // create the record (struct) type node
      std::map<TreeVocabularyTokenTypes_TokenEnum, std::string> IR_schema; // Should this be empty?
      //IR_schema[TOK(TOK_NAME)] = STR(id_node);
      //IR_schema[TOK(TOK_TYPE)] = STR(ty);
      IR_schema[TOK(TOK_SRCP)] = BUILTIN_SRCP;
      unsigned rec_nid  = TM->new_tree_node_id();
      auto rec_node_raw = TM->create_tree_node(rec_nid, record_type_K, IR_schema);
      auto rec_type = GetPointer<record_type>(rec_node_raw);

      for(; p_decl_it != fd->list_of_args.cend(); p_decl_it++, param_n++)
      {
         const auto p_decl = *p_decl_it;
         const auto p_type = tree_helper::CGetType(p_decl);
         std::cout << "[+] Parameter: " << STR(p_decl) << " Type: " << STR(p_type) << " Size: " << tree_helper::AllocatedMemorySize(p_type) << std::endl;
         stack_size += tree_helper::AllocatedMemorySize(p_type);
         add_fld(TM, tree_man, rec_type, STR(p_decl), p_type, IR_schema);
      }
      auto return_type = tree_helper::GetFunctionReturnType(tn);
      add_fld(TM, tree_man, rec_type, "return", tree_helper::GetFunctionReturnType(tn), IR_schema);
      stack_size += tree_helper::AllocatedMemorySize(return_type);
      std::cout << "[+] Number of args: " << param_n << std::endl;
      std::cout << "[+] Return Type: " << return_type << " Return Type Size: " << tree_helper::AllocatedMemorySize(return_type) << std::endl;
      std::cout << "[+] Stack Size: " << stack_size << std::endl;

      // Initialize stack frames
      const auto first_block = getFirstBlock(sl);
      // top  = -1;
      auto intTy = tree_man->GetSignedIntegerType();
      const auto intTy_node = GetPointerS<const type_node>(intTy);
      const auto top_var_identifier = tree_man->create_identifier_node("bambu_artificial_top");
      const auto top_var_decl =
            tree_man->create_var_decl(top_var_identifier, intTy, tn, intTy_node->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, intTy_node->algn, 0, false);
      
      const auto neg1Cst =
                     TM->CreateUniqueIntegerCst((integer_cst_t)-1, intTy);
      const auto assignNeg1 =
            tree_man->CreateGimpleAssign(intTy, top_var_identifier, tree_nodeRef(), neg1Cst, function_id, BUILTIN_SRCP);
      first_block->PushBack(assignNeg1, AppM);

      // Build for loop to simulate recursion
      //TODO Not sure if all the basic blocks are linked correctly. BB_start_block may not be necessary if we use BB1 
      /*
      const auto BB1 = sl->list_of_bloc.at(1); // Get basic block which points to first_block
   
      // Create basic block and add to start 
      const auto BB_start_block = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      std::cout << "[+] Newly Added block: " << BB_start_block->number << ", for start of IR" << std::endl;
      sl->add_bloc(BB_start_block);

      // Insert BB_start_block into the top of IR TODO
      BB_start_block->add_pred(BB1->number);
      BB_start_block->add_succ(first_block->number);
      BB1->add_succ(BB_start_block->number);
      first_block->add_pred(BB_start_block->number);

      // Create basic bloc for if statement which check top != 1
      const auto BBN1_block = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      std::cout << "[+] Newly Added block: " << BBN1_block->number << ", for while loop condition" << std::endl;
      sl->add_bloc(BBN1_block); 

      // Create basic bloc for returning value
      const auto BBN2_block = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      std::cout << "[+] Newly Added block: " << BBN2_block->number << ", for returning value" << std::endl;
      sl->add_bloc(BBN2_block);
      
      // Insert BBN1 and BBN2 into IR TODO
      BBN1_block->true_edge = BB_start_block->number;
      BBN1_block->false_edge = BBN2_block->number;
      BBN1_block->add_succ(BBN2_block->number);
      BBN2_block->add_pred(BBN1_block->number);

      // Create if top != 1 condition (while condition)
      const auto boolean_type = tree_man->GetBooleanType();
      const tree_nodeRef cond = tree_man->create_binary_operation(boolean_type, top_var_identifier, neg1Cst, BUILTIN_SRCP, ne_expr_K);
      const auto whileCond = tree_man->create_gimple_cond(cond, function_id, BUILTIN_SRCP);
      BBN1_block->PushBack(whileCond, AppM);
      */

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
   
   // DEBUG PRINT IR
   std::cout << "\n===== IR after manipulation" << std::endl;
   for(const auto& block : sl->list_of_bloc) {
      std::cout << "[+] Examining basic block: " << block.first << "\n";
      for(const auto& stmt : block.second->CGetStmtList()) {
         std::cout << "   [+] Examining statement: " << stmt->ToString() << "; " << stmt->get_kind_text() << "\n";
      }
   } 
   // END DEBUG

   std::cout << "[+] Write BB Graph" << std::endl;
   std::string filename = "BBGraph.dot";
   WriteBBGraphDot(filename);

   std::cout << "========== Recursion Removal Complete ==========\n\n";
   return DesignFlowStep_Status::UNCHANGED;
}
