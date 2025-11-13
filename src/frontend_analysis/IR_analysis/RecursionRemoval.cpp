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
    : FunctionFrontendFlowStep(AM, fun_id, FIX_STRUCTS_PASSED_BY_VALUE, dfm, params)
{
   debug_level = parameters->get_class_debug_level(GET_CLASS(*this), DEBUG_LEVEL_NONE);
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
        // CJP TODO FIX ME
         relationships.insert(std::make_pair(BLOCK_FIX, SAME_FUNCTION));
         relationships.insert(std::make_pair(STRING_CST_FIX, WHOLE_APPLICATION));
         //relationships.insert(std::make_pair(FIX_STRUCTS_PASSED_BY_VALUE, CALLING_FUNCTIONS));
         relationships.insert(std::make_pair(REBUILD_INITIALIZATION, CALLING_FUNCTIONS));
         break;
      }
      case(PRECEDENCE_RELATIONSHIP):
      {
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

static bool is_recursive(const function_decl* const fd, const function_type* const ft)
{
   bool is_recursive = false;
   for(const auto i : AppM->CGetCallGraphManager()->get_called_by(function_id))
   {
      const auto curr_tn = TM->GetTreeNode(i);
      const auto fdCalled = GetPointerS<const function_decl>(curr_tn);
      if (fd == fdCalled) {
         is_recursive = true;
         break;
      }
   }

   
   std::cerr << "Is recursive: " 
      + HLSMgr->CGetFunctionBehavior(function_id)->CGetBehavioralHelper()->get_function_name()
      + " = " + is_recursive
   return is_recursive;
}


DesignFlowStep_Status RecursionRemoval::InternalExec()
{
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
   
    // TODO interesting code goes here

   if(changed)
   {
      function_behavior->UpdateBBVersion();
      return DesignFlowStep_Status::SUCCESS;
   }
   return DesignFlowStep_Status::UNCHANGED;
}
