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
   for(const auto i : AppM->CGetCallGraphManager()->get_called_by(function_id))
   {
      const auto curr_tn = TM->GetTreeNode(i);
      const auto fdCalled = GetPointerS<const function_decl>(curr_tn);
      if (fd == fdCalled) {
         is_recursive = true;
         break;
      }
   }

   // DEBUG PRINT IR
   for(const auto& block : sl->list_of_bloc) {
      std::cout << "[+] Examining basic block: " << block.first << "\n";
      for(const auto& stmt : block.second->CGetStmtList()) {
         std::cout << "   [+] Examining statement: " << stmt->ToString() << "\n";
      }
   } 

   if (is_recursive)
   {
      std::cout << "[+] Recursion Removal Function Is Recursive" << std::endl;
      std::cerr << "Is recursive: " 
         + HLSMgr->CGetFunctionBehavior(function_id)->CGetBehavioralHelper()->get_function_name()
         + "\n";

      // Initialize stack for each argument
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
	 
	 // create the stack // TODO
         /*const auto gimple_call_memcpy = tree_man->create_gimple_call(memcpy_function, args, function_id, srcp);
         auto gn = GetPointer<gimple_node>(gimple_call_memcpy);

         first_block->PushFront(gimple_call_memcpy, AppM); // insert the instruction*/
      }
      stack_size += tree_helper::AllocatedMemorySize(return_type);
      std::cout << "[+] Number of args: " << param_n << std::endl;
      std::cout << "[+] Return Type: " << return_type << " Return Type Size: " << tree_helper::AllocatedMemorySize(return_type) << std::endl;
      std::cout << "[+] Stack Size: " << stack_size << std::endl;

      // Build for loop to simulate recursion
      //TODO

      // Rewrite operations around recursive call
      // TODO

      // Remove recursive calls 
      // TODO
   }

   if(changed)
   {
      function_behavior->UpdateBBVersion();
      return DesignFlowStep_Status::SUCCESS;
   }

   std::cout << "========== Recursion Removal Complete ==========\n\n";
   return DesignFlowStep_Status::UNCHANGED;
}
