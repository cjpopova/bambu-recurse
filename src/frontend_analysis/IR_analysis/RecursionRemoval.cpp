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

      // TODO Build for loop to simulate recursion
      std::cout << "[+] Modify basic block to simulate recursion" << std::endl;
      const auto first_block = getFirstBlock(sl);
      auto remove_BB = [](std::vector<unsigned int> &v, int b){
          v.erase(std::remove(v.begin(), v.end(), b), v.end());
      };
      // BB0 = entry; BB1 = exit
      const auto BB_entry = sl->list_of_bloc.at(0); // Get entry block 
      const auto BB_exit = sl->list_of_bloc.at(1); // Get exit block

      // Create start block
      const auto BB_start_block = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      sl->add_bloc(BB_start_block);
     
      // Create loop condition block
      const auto BB_loop_block = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      sl->add_bloc(BB_loop_block); 

      // Create last block
      const auto BB_last_block = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      sl->add_bloc(BB_last_block);

      // Insert BB_start_block into the top of IR 
      BB_start_block->add_pred(BB_entry->number);      // add entry as pred to start_block
      BB_start_block->add_succ(first_block->number);   // add first_block as succ to start_block
      BB_entry->add_succ(BB_start_block->number);      // add start_block as succ to entry
      first_block->add_pred(BB_start_block->number);   // add start_block as pred to first_block
      remove_BB(first_block->list_of_pred, 0);         // remove entry as pred to first_block
      remove_BB(BB_entry->list_of_succ, first_block->number); // remove first_block as succ to entry
      
      // Insert loop_block into IR
      BB_loop_block->true_edge = first_block->number;    // set true edge of loop_block to start_block
      BB_loop_block->false_edge = BB_last_block->number;    // set false edge of loop_block to last_block
      BB_loop_block->add_succ(BB_start_block->number);      // add start_block as succ to loop_block (true edge)
      BB_loop_block->add_succ(BB_last_block->number);       // add last_block as succ to loop_block (false edge)
      first_block->add_pred(BB_loop_block->number);      // add loop_block as pred to start_block
      
      // Find all blocks pointing to exit. All these blocks must now point to loop_block TODO might be incorrect
      for(auto& block : sl->list_of_bloc) {
          int i = block.first;
	  if(i == 0 || i == 1) { continue; }
          const auto BB_i = sl->list_of_bloc.at(i); // Get blocks which pt to exit
          if(std::find(BB_i->list_of_succ.begin(), BB_i->list_of_succ.end(), 1) == BB_i->list_of_succ.end()) {
              continue;
          }
	      remove_BB(BB_i->list_of_succ, 1);         // remove exit as succ to blocks which pt to exit
         remove_BB(BB_exit->list_of_pred, i);      // remove blocks which to pt to exit as pred of exit
         BB_loop_block->add_pred(i);               // add blocks which pt to exit as pred of loop_block
	      BB_i->add_succ(BB_loop_block->number);    // add loop_block as succ to blocks which pt to exit
      }

      BB_last_block->add_pred(BB_loop_block->number);       // add loop_block as pred to last_block
      BB_last_block->add_succ(1);                           // add exit as succ to last_block
      BB_exit->add_pred(BB_last_block->number);             // add last_block as pred to exit

      ///////////////////////////////////////////////////// Insert instructions
      // top  = -1;
      auto intTy = tree_man->GetSignedIntegerType();
      const auto intTy_node = GetPointerS<const type_node>(intTy);
      const auto top_var_identifier = tree_man->create_identifier_node("bambu_artificial_top");
      const auto top_var_decl =
            tree_man->create_var_decl(top_var_identifier, intTy, tn, intTy_node->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, intTy_node->algn, 0, false);
      
      const auto neg1Cst = TM->CreateUniqueIntegerCst((integer_cst_t)-1, intTy);
      const auto assignNeg1 = // Use decl over identifier for top_var ?
            tree_man->CreateGimpleAssign(intTy, top_var_identifier, tree_nodeRef(), neg1Cst, function_id, BUILTIN_SRCP);
      BB_start_block->PushBack(assignNeg1, AppM);

      // Add top != 1 condition to loop_block
      const auto boolean_type = tree_man->GetBooleanType();
      const tree_nodeRef cond = tree_man->create_binary_operation(
          boolean_type, top_var_decl, neg1Cst, BUILTIN_SRCP, ne_expr_K);
      const auto loopCond = tree_man->create_gimple_cond(cond, function_id, BUILTIN_SRCP);
      BB_loop_block->PushBack(loopCond, AppM);
      
      // TODO: add to BB_start_block: initialize first stack frame with n=n, return_value=0

      // TODO: analysis on existing code: operation on recursive result (n * factorial_result), operation on recursive argument (n-1), base case (result=1)
      // we will start by saving the placeholders for factorial & will do the real analysis later

      // TODO: insert basic blocks & instructions for base case

      // TODO: insert recursive case

      //DEBUG
      /*std::cout << "===== Dump all block's pred & succ =====" << std::endl;
      for(auto &block : sl->list_of_bloc) {
          const auto b = sl->list_of_bloc.at(block.first);
	  std::cout << "\n[+] block: " << block.first; 
          std::cout << "\n  [+] succs: ";
          for (auto s : b->list_of_succ) { std::cout << " " << s; }
          std::cout << "\n  [+] preds: ";
          for (auto p : b->list_of_pred) { std::cout << " " << p; }
      }*/

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
     changed = true;
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
   std::cout << "[+] Write Basic Block Graph" << std::endl;
   std::string filename = "BBGraph.dot";
   WriteBBGraphDot(filename);

   std::cout << "========== Recursion Removal Complete ==========\n\n";

   if(changed)
   {
      function_behavior->UpdateBBVersion();
      return DesignFlowStep_Status::SUCCESS;
   }
   
   return DesignFlowStep_Status::UNCHANGED;
}
