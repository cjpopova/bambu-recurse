#include "RecursionRemoval.hpp"
#include "design_flow_graph.hpp"
#include "design_flow_manager.hpp"
#include "sdc_scheduling.hpp"

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

static void identifyRecursivePatterns(std::vector<std::pair<unsigned int, tree_nodeConstRef>> &call_sites, // (bb_index, stmt)
   const application_managerRef AppM, function_decl *const fd, const statement_list *const sl) {
   //std::cout << "[+] Starting identifyRecursivePatterns\n ";
   for (const auto &bb_pair : sl->list_of_bloc) {              // Scan over blocks
      const unsigned int bb_idx = bb_pair.first;
      const auto bb = bb_pair.second;
      for (const auto &stmt : bb->CGetStmtList()) {            // Scan over block's statements
         // Assuming that we're looking for gimple_assign statements whose op1 is call_expr
         if (stmt->get_kind() != gimple_assign_K) continue;
         const auto op1_node =  GetPointer<gimple_assign>(stmt)->op1;
         if (op1_node->get_kind() != call_expr_K) continue;
         const auto call = GetPointer<call_expr>(op1_node);
         const auto fn_node = call->fn;
         if(fn_node->get_kind() != addr_expr_K) continue; 
         const auto ae = GetPointerS<const addr_expr>(fn_node);
         if (ae->op->get_kind() != function_decl_K) continue;
         const auto local_fd = GetPointerS<const function_decl>(ae->op);
         if (local_fd != fd) continue;                // not a recursive call
         call_sites.emplace_back(bb_idx, stmt);
      }
   }

   // Report found call sites
   /*for (auto &cs : call_sites) {
      std::cout << "  [+] Found call in BB " << cs.first << " stmt: " << cs.second->ToString() << "\n";
   }*/
}


static void analyzeRecursivePatterns(std::vector<std::pair<unsigned int, tree_nodeConstRef>> &call_sites) {
   for (const auto &cs : call_sites) {
      const auto stmt_node = GetPointerS< const gimple_assign>(cs.second);
      // recursive result - we need to analyze what WILL BE done to this
      const auto op0_node = stmt_node->op0;
      std::cout << "  [+] Recursive result: " << op0_node->ToString() << " | " << op0_node->get_kind_text() << "\n";
      const auto sa = GetPointer<ssa_name>(op0_node);
      for(const auto& stmt_use : sa->CGetUseStmts()) // TODO: why aren't we getting any uses out of this?
      {
         const auto use = stmt_use.first;
         std::cout << "    [+] Recursive result uses: " << use->ToString() << " | " << use->get_kind_text() << "\n";
      }

      // argument: we need to analyze what WAS done to this
      const auto ce = GetPointer<call_expr>(stmt_node->op1);
      for(auto& arg : ce->args) //std::vector<tree_nodeRef> args = ce->args;
      {
         std::cout << "  [+] Recursive argument: " << arg->ToString() << " | " << arg->get_kind_text() << "\n";
         const auto sa = GetPointer<ssa_name>(arg);
         if (!sa) continue;
         const auto def_stmt = sa->CGetDefStmt();
         std::cout << "      Def stmt: " << def_stmt->ToString() << " | " << def_stmt->get_kind_text() <<"\n";

         // we need to work all the way back to the argument (eg n_9083) but we could assume we need to traverse only 1 operation back for now
         
         // TODO: ReplaceTreeNode
      }
   }
}

// static tree_nodeConstRef identifyBaseCase(const statement_list *const sl) {
static std::pair<tree_nodeConstRef, tree_nodeRef> identifyBaseCase(const statement_list *const sl) {
   // Find the pre-exit block where the return node lives
   //const tree_nodeRef return_node;
   blocRef pre_exitBB = nullptr;
   for (const auto& B : sl->list_of_bloc) {
      for (const tree_nodeRef &stmt : B.second->CGetStmtList()) {
         if (stmt->get_kind() == gimple_return_K) {
               //return_node = stmt;
               pre_exitBB = B.second;
               break;
         }
      }
      if (pre_exitBB) break;
   }          

   // Return the phi node def that is NOT SSA_NAME (eg is an integer)
   const std::list<tree_nodeRef>& phi_nodes = pre_exitBB->CGetPhiList(); //GetPointer<blocRef(pre_exitBB)->CGetPhiList();
   THROW_ASSERT(phi_nodes.size() == 1, "Expected exactly 1 phi in pre exit block");
   const auto phi_node = GetPointer<gimple_phi>(phi_nodes.front());
   const auto defs = phi_node->CGetDefEdgesList();
   for (const auto def : defs) {
      std::cout << "  [+] Base case def: " << def.first->ToString() << "|" << def.first->get_kind_text() << "\n";
      if (def.first->get_kind() != ssa_name_K) {
         const auto baseCaseVal = def.first; // return the non-SSA_NAME node
	 const auto baseCaseCondBlock = sl->list_of_bloc.at(def.second);
         return {baseCaseVal, baseCaseCondBlock->CGetStmtList().back()};
      }
   }

   //return nullptr; // TODO: come up with backup when all defs are ssa_names
   //scan over each of the phi's defs, and tranverse the defs back to find which BB they're in, 
   // if it's a BB w/ a reucrsive call, then it's not a base case
   // NOTE: use ->bb_index to get basic block index from an instruction
}

void fix_sdc_motion(DesignFlowManagerConstRef design_flow_manager, unsigned int function_id,
    tree_nodeRef removedStmt) {
    const auto design_flow_graph = design_flow_manager->CGetDesignFlowGraph();
    const auto sdc_scheduling_step = design_flow_manager->GetDesignFlowStep(HLSFunctionStep::ComputeSignature(
        HLSFlowStep_Type::SDC_SCHEDULING, HLSFlowStepSpecializationConstRef(), function_id));
    if(sdc_scheduling_step != DesignFlowGraph::null_vertex()) {
        const auto sdc_scheduling = GetPointer<SDCScheduling>(design_flow_graph->CGetNodeInfo(sdc_scheduling_step)->design_flow_step);
        const auto removed_index = removedStmt->index;
        sdc_scheduling->movements_list.remove_if([&](const std::vector<unsigned int>& mv) { return mv[0] == removed_index; });
    }
}

// Returns stack declaration of the form: int32_t stack_name[depth];
const tree_nodeRef createStackDecl(const tree_managerRef& TM, const tree_manipulationRef& tree_man, unsigned int function_id,
                                    const std::string& stack_name, const int depth) {
      const auto tn = TM->GetTreeNode(function_id);
      std::map<TreeVocabularyTokenTypes_TokenEnum, std::string> IR_schema; 
      IR_schema[TOK(TOK_SRCP)] = BUILTIN_SRCP;
      unsigned array_nid  = TM->new_tree_node_id();
      auto array_node_raw = TM->create_tree_node(array_nid, array_type_K, IR_schema);
      auto array_ty = GetPointer<array_type>(array_node_raw);
      array_ty->elts = tree_man->GetSignedIntegerType(); // NOTE: assume array type is int32_t
      // Set size to depth
      IR_schema.clear();
      IR_schema[TOK(TOK_SRCP)] = BUILTIN_SRCP;
      unsigned domn_nid = TM->new_tree_node_id();
      auto domn_node_raw = TM->create_tree_node(domn_nid, integer_type_K, IR_schema);
      auto domn_type = GetPointer<integer_type>(domn_node_raw);
      domn_type->min = TM->CreateUniqueIntegerCst(0, tree_man->GetSignedIntegerType());
      domn_type->max = TM->CreateUniqueIntegerCst(depth, tree_man->GetSignedIntegerType());
      array_ty->domn = domn_node_raw;
      // create declaration
      const auto stack_var_identifier = tree_man->create_identifier_node(stack_name);
      auto stackDecl = tree_man->create_var_decl(stack_var_identifier, array_node_raw, tn, domn_node_raw, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, GetPointerS<const type_node>(array_ty->elts)->algn, 0, false);       
     return stackDecl;
}

// Returns an instruction of the form: stack_var[idx_node] = val_node
// Also only works on int32_t
const tree_nodeRef createStackWrite(const tree_managerRef& TM, const tree_manipulationRef& tree_man, unsigned int function_id,
                                    const tree_nodeRef& stack_var, const tree_nodeRef& idx_node, const tree_nodeRef& val_node) {
   const auto elem_type = tree_man->GetSignedIntegerType(); // tree_helper::CGetElements(tree_helper::CGetType(array_node_raw)); // element type of array_node_ref
   std::map<TreeVocabularyTokenTypes_TokenEnum, std::string> idx_schema;
   idx_schema[TOK(TOK_OP0)] = STR(stack_var->index);
   idx_schema[TOK(TOK_OP1)] = STR(idx_node->index);      
   idx_schema[TOK(TOK_TYPE)] = STR(elem_type->index);
   idx_schema[TOK(TOK_SRCP)] = BUILTIN_SRCP;
   auto elem_nid = TM->new_tree_node_id();
   auto arr_elem = TM->create_tree_node(elem_nid, array_ref_K, idx_schema);
   return tree_man->create_gimple_modify_stmt(arr_elem, val_node, function_id, BUILTIN_SRCP);
}

// Returns an instruction of the form: var_node = stack_var[idx_node]
// Also only works on int32_t
const tree_nodeRef createStackRead(const tree_managerRef& TM, const tree_manipulationRef& tree_man, unsigned int function_id,
                                    const tree_nodeRef& stack_var, const tree_nodeRef& idx_node, const tree_nodeRef& var_node) {
   const auto elem_type = tree_man->GetSignedIntegerType(); // tree_helper::CGetElements(tree_helper::CGetType(array_node_raw)); // element type of array_node_ref
   std::map<TreeVocabularyTokenTypes_TokenEnum, std::string> idx_schema;
   idx_schema[TOK(TOK_OP0)] = STR(stack_var->index);
   idx_schema[TOK(TOK_OP1)] = STR(idx_node->index);      
   idx_schema[TOK(TOK_TYPE)] = STR(elem_type->index);
   idx_schema[TOK(TOK_SRCP)] = BUILTIN_SRCP;
   auto elem_nid = TM->new_tree_node_id();
   auto arr_elem = TM->create_tree_node(elem_nid, array_ref_K, idx_schema);
   return tree_man->create_gimple_modify_stmt(var_node, arr_elem, function_id, BUILTIN_SRCP);
}

static void DebugPrintIR(const statement_list *const sl) {
   for(const auto& block : sl->list_of_bloc) {
      std::cout << "[+] block: " << block.first << "\n";
      for(const auto& phi : block.second->CGetPhiList()) {
         std::cout << "   [+] phi: " << phi->ToString() << "\n";
      }
      for(const auto& stmt : block.second->CGetStmtList()) {
         std::cout << "   [+] statement: " << stmt->ToString() << "; " << stmt->get_kind_text() << "\n";
      }
   } 
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
   WriteBBGraphDot("BBGraph_Before.dot");


   std::cout << "\n===== IR BEFORE manipulation =====" << std::endl;
   DebugPrintIR(sl);
   std::cout << "==================================\n" << std::endl;
   // END DEBUG

   // MODIFY RECURSIVE FUNCTIONS
   if (is_recursive)
   {
      std::cout << "[+] Recursion Removal Function Is Recursive" << std::endl;
      std::cerr << "Is recursive: " 
         + HLSMgr->CGetFunctionBehavior(function_id)->CGetBehavioralHelper()->get_function_name()
         + "\n";

      // PARAMETERS
      const int max_depth = 512;

      // ANALYSIS
      std::vector<std::pair<unsigned int, tree_nodeConstRef>> call_sites; // (bb_index, stmt)
      identifyRecursivePatterns(call_sites, AppM, fd, sl);
      analyzeRecursivePatterns(call_sites);
      auto result = identifyBaseCase(sl);
      const auto baseCaseNode = result.first;
      const auto baseCaseCond = result.second;
      std::cout << "  [+] Base Case Cond: " << baseCaseCond->ToString() << "\n";
      // TODO: identify # of states (probably number of call_sites?)


      /////////////////////// Create stack declarations
      std::cout << "[+] Creating stack declarations\n";
      auto p_decl_it = fd->list_of_args.begin();
      std::vector<tree_nodeRef> argumentStackDecls;
      for(; p_decl_it != fd->list_of_args.cend(); p_decl_it++)
      {
         const auto p_decl = *p_decl_it;
         //const auto p_type = tree_helper::CGetType(p_decl);
         const auto stack_n_decl = createStackDecl(TM, tree_man, function_id, "stack_"+STR(p_decl), max_depth);
         argumentStackDecls.push_back(stack_n_decl);
      }
      const auto stack_state_decl = createStackDecl(TM, tree_man, function_id, "stack_n", max_depth);
      // NOTE: we may also need more intermediate stacks if there are multiple recursive calls

      /////////////////////////////////////////////////////////////////// TODO Build for loop to simulate recursion
      std::cout << "[+] Modify basic block to simulate recursion" << std::endl;
      const auto first_block = getFirstBlock(sl);
      auto remove_BB = [](std::vector<unsigned int> &v, int b){
          v.erase(std::remove(v.begin(), v.end(), b), v.end());
      };
      // BB0 = entry; BB1 = exit
      const auto BB_entry = sl->list_of_bloc.at(0); // Get entry block 
      const auto BB_exit = sl->list_of_bloc.at(1); // Get exit block

      // Remove all existing statements & blocks
      for(auto & block : sl->list_of_bloc) {
          block.second->list_of_pred.clear();
          block.second->list_of_succ.clear();
          int i = block.first;
          if(i == 0 || i == 1) { continue; }
	  // Copy statements first
          std::vector<tree_nodeRef> stmts;
          for (const auto& s : block.second->CGetStmtList()) { stmts.push_back(s); }
          std::vector<tree_nodeRef> phis;
          for (const auto& p : block.second->CGetPhiList()) { phis.push_back(p); }
          for(auto& stmt : stmts) {
              block.second->RemoveStmt(stmt, AppM);
              fix_sdc_motion(design_flow_manager.lock(), function_id, stmt);
          }
          for(auto& phi : phis) {
              block.second->RemovePhi(phi);
          }
      }
      for(auto it = sl->list_of_bloc.begin(); it != sl->list_of_bloc.end();) {
          if(it->first != 0 && it->first != 1) { it = sl->list_of_bloc.erase(it); }
          else { it++; }
      }
      BB_entry->add_succ(BB_exit->number);
      BB_exit->add_pred(BB_entry->number);
      BB_exit->add_pred(BB_exit->number);

      ///////////////////////////////////////// Create blocks TODO inlined push & pop will require several blocks
      const auto BB_block_2 = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      sl->add_bloc(BB_block_2);
      
      const auto BB_block_3 = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      sl->add_bloc(BB_block_3);
      
      const auto BB_block_4 = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      sl->add_bloc(BB_block_4);
      
      const auto BB_block_5 = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      sl->add_bloc(BB_block_5);
      
      const auto BB_block_6 = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      sl->add_bloc(BB_block_6);
      
      const auto BB_block_7 = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      sl->add_bloc(BB_block_7);
      
      const auto BB_block_8 = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      sl->add_bloc(BB_block_8);
      
      const auto BB_block_9 = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      sl->add_bloc(BB_block_9);

      const auto BB_block_10 = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      sl->add_bloc(BB_block_10);
      
      const auto BB_block_15 = blocRef(new bloc((sl->list_of_bloc.rbegin())->first + 1));
      sl->add_bloc(BB_block_15); 

      BB_entry->add_succ(BB_block_2->number);

      BB_block_2->add_pred(BB_entry->number);
      BB_block_2->add_succ(BB_block_4->number);

      BB_block_4->true_edge = BB_block_5->number;
      BB_block_4->false_edge = BB_block_8->number;
      BB_block_4->add_pred(BB_block_2->number);
      BB_block_4->add_pred(BB_block_3->number);
      BB_block_4->add_succ(BB_block_5->number);
      BB_block_4->add_succ(BB_block_8->number);

      BB_block_5->true_edge = BB_block_6->number;
      BB_block_5->false_edge = BB_block_7->number;
      BB_block_5->add_pred(BB_block_4->number);
      BB_block_5->add_succ(BB_block_6->number);
      BB_block_5->add_succ(BB_block_7->number);

      BB_block_6->true_edge = BB_block_15->number;
      BB_block_6->false_edge = BB_block_9->number;
      BB_block_6->add_pred(BB_block_5->number);
      BB_block_6->add_succ(BB_block_15->number);
      BB_block_6->add_succ(BB_block_9->number);

      BB_block_7->add_pred(BB_block_5->number);
      BB_block_7->add_succ(BB_block_3->number);

      BB_block_9->add_pred(BB_block_6->number);
      BB_block_9->add_succ(BB_block_3->number);

      BB_block_8->true_edge = BB_block_15->number;
      BB_block_8->false_edge = BB_block_10->number;
      BB_block_8->add_pred(BB_block_4->number);
      BB_block_8->add_succ(BB_block_10->number);
      BB_block_8->add_succ(BB_block_15->number);

      BB_block_10->add_pred(BB_block_8->number);
      BB_block_10->add_succ(BB_block_3->number);

      BB_block_3->add_pred(BB_block_9->number);
      BB_block_3->add_pred(BB_block_7->number);
      BB_block_3->add_pred(BB_block_10->number);
      BB_block_3->add_succ(BB_block_4->number);

      BB_block_15->add_pred(BB_block_6->number);
      BB_block_15->add_pred(BB_block_8->number);
      BB_block_15->add_succ(BB_exit->number);

      BB_exit->add_pred(BB_block_15->number);


      ///////////////////////////////////////// Insert Instructions 
      // Pseudocode & basic blocks #s roughly based on MLIR/man_fib at -O0
      std::cout << "[+] Inserting instructions\n";
      const auto intTy = tree_man->GetSignedIntegerType();
      const auto boolTy = tree_man->GetBooleanType();

      // BB15: return block ============================================================================================================================================================
      // retval = phi <retval_base, BB6> <retval_recur,BB8>
      auto retVar = tree_man->create_var_decl(tree_man->create_identifier_node("finalRetVar"), intTy, tn,  GetPointer<const type_node>(intTy)->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, GetPointerS<const type_node>(tree_man->GetSignedIntegerType())->algn, 0, false);       
      // note: setup possible ret vals there are. for now, assume 2. eventually this should probably iterate over a map of blocks & other info
      auto ret_base = tree_man->create_var_decl(tree_man->create_identifier_node("ret_base"), intTy, tn,  GetPointer<const type_node>(intTy)->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, GetPointerS<const type_node>(tree_man->GetSignedIntegerType())->algn, 0, false);       
      auto ret_recur = tree_man->create_var_decl(tree_man->create_identifier_node("ret_recur"), intTy, tn,  GetPointer<const type_node>(intTy)->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, GetPointerS<const type_node>(tree_man->GetSignedIntegerType())->algn, 0, false);                
      {
      std::vector<std::pair<tree_nodeRef, unsigned int>> list_of_def_edge; // NOTE # of incoming edges may depend on # of base cases
      list_of_def_edge.push_back(std::make_pair(ret_base, BB_block_6->number));
      list_of_def_edge.push_back(std::make_pair(ret_recur, BB_block_8->number));
      BB_block_15->AddPhi(tree_man->create_phi_node(retVar, list_of_def_edge, function_id));
      }
      // return retVar
      BB_block_15->PushBack(tree_man->create_gimple_return(intTy, retVar, function_id, BUILTIN_SRCP), AppM);   
      
      // BB3: phis; unconditionally loop back to 4 (while (1)) =====================================================================================================================
      // sp_bottom = phi <sp_base_non_empty, BB9> <sp_incr, BB7><sp_dec,BB10>
      auto sp_bottom = tree_man->create_var_decl(tree_man->create_identifier_node("sp_bottom"), intTy, tn,  GetPointer<const type_node>(intTy)->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, GetPointerS<const type_node>(tree_man->GetSignedIntegerType())->algn, 0, false);                
      auto sp_decr_base = tree_man->create_var_decl(tree_man->create_identifier_node("sp_decr_base"), intTy, tn,  GetPointer<const type_node>(intTy)->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, GetPointerS<const type_node>(tree_man->GetSignedIntegerType())->algn, 0, false);                
      auto sp_incr = tree_man->create_var_decl(tree_man->create_identifier_node("sp_incr"), intTy, tn,  GetPointer<const type_node>(intTy)->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, GetPointerS<const type_node>(tree_man->GetSignedIntegerType())->algn, 0, false);                
      auto sp_decr_recur = tree_man->create_var_decl(tree_man->create_identifier_node("sp_decr_recur"), intTy, tn,  GetPointer<const type_node>(intTy)->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, GetPointerS<const type_node>(tree_man->GetSignedIntegerType())->algn, 0, false);                
      {
      std::vector<std::pair<tree_nodeRef, unsigned int>> list_of_def_edge; // NOTE # of incoming edges may depend on # of base cases
      list_of_def_edge.push_back(std::make_pair(sp_decr_base, BB_block_9->number));
      list_of_def_edge.push_back(std::make_pair(sp_incr, BB_block_7->number));
      list_of_def_edge.push_back(std::make_pair(sp_decr_recur, BB_block_10->number));
      BB_block_3->AddPhi(tree_man->create_phi_node(sp_bottom, list_of_def_edge, function_id));
      }
      //retval_bottom = phi <retval_base, BB9> <retval_top,BB7><reval_recur,BB10>
      auto ret_bottom = tree_man->create_var_decl(tree_man->create_identifier_node("ret_bottom"), intTy, tn,  GetPointer<const type_node>(intTy)->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, GetPointerS<const type_node>(tree_man->GetSignedIntegerType())->algn, 0, false);                
      auto ret_top = tree_man->create_var_decl(tree_man->create_identifier_node("ret_top"), intTy, tn,  GetPointer<const type_node>(intTy)->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, GetPointerS<const type_node>(tree_man->GetSignedIntegerType())->algn, 0, false);                
      {
      std::vector<std::pair<tree_nodeRef, unsigned int>> list_of_def_edge; // NOTE # of incoming edges may depend on # of base cases
      list_of_def_edge.push_back(std::make_pair(ret_base, BB_block_9->number));
      list_of_def_edge.push_back(std::make_pair(ret_top, BB_block_7->number));
      list_of_def_edge.push_back(std::make_pair(ret_recur, BB_block_10->number));
      BB_block_3->AddPhi(tree_man->create_phi_node(ret_bottom, list_of_def_edge, function_id));
      }


      // BB2: initialize stacks of the argument (n) & state =========================================================================================================================
      p_decl_it = fd->list_of_args.begin();
      auto stack_decl_it = argumentStackDecls.begin();
      for(; p_decl_it != fd->list_of_args.cend(); p_decl_it++, stack_decl_it++)
      {
         const auto p_decl = *p_decl_it;
         const auto stack_n_decl = *stack_decl_it;
         BB_block_2->PushBack(createStackWrite(TM, tree_man, function_id, // stack_arg[0] = arg
            stack_n_decl, TM->CreateUniqueIntegerCst((integer_cst_t)0, intTy), p_decl), AppM);
      }
      BB_block_2->PushBack(createStackWrite(TM, tree_man, function_id, // stack_state[0] = 0
         stack_state_decl, TM->CreateUniqueIntegerCst((integer_cst_t)0, intTy) , TM->CreateUniqueIntegerCst((integer_cst_t)0, intTy)), AppM); 

      // BB4: phis; read stacks of argument (n) and state; conditional on new state == 0 (T=BB5; F=BB8) ============================================================================================
      //  retval_top = phi<retval_bottom, BB3><0,BB2>
      {
      std::vector<std::pair<tree_nodeRef, unsigned int>> list_of_def_edge; // NOTE # of incoming edges may depend on # of base cases
      list_of_def_edge.push_back(std::make_pair(ret_bottom, BB_block_3->number));
      list_of_def_edge.push_back(std::make_pair(TM->CreateUniqueIntegerCst((integer_cst_t)0, intTy), BB_block_2->number));
      BB_block_4->AddPhi(tree_man->create_phi_node(ret_top, list_of_def_edge, function_id));
      }
      // sp_top = phi<sp_bottom, BB3><0, BB2>
      auto sp_top = tree_man->create_var_decl(tree_man->create_identifier_node("sp_top"), intTy, tn,  GetPointer<const type_node>(intTy)->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, GetPointerS<const type_node>(tree_man->GetSignedIntegerType())->algn, 0, false);       
      {
      std::vector<std::pair<tree_nodeRef, unsigned int>> list_of_def_edge; // NOTE # of incoming edges may depend on # of base cases
      list_of_def_edge.push_back(std::make_pair(sp_bottom, BB_block_3->number));
      list_of_def_edge.push_back(std::make_pair(TM->CreateUniqueIntegerCst((integer_cst_t)0, intTy), BB_block_2->number));
      BB_block_4->AddPhi(tree_man->create_phi_node(sp_top, list_of_def_edge, function_id));
      }
      // state & argument reads: state=stack_state[sp]; arg=stack_arg[sp];
      p_decl_it = fd->list_of_args.begin();
      stack_decl_it = argumentStackDecls.begin();
      std::vector<tree_nodeRef> argsAtSp;
      for(; p_decl_it != fd->list_of_args.cend(); p_decl_it++, stack_decl_it++)
      {
         const auto p_decl = *p_decl_it;
         const auto stack_n_decl = *stack_decl_it;
         auto argAtSp = tree_man->create_var_decl(tree_man->create_identifier_node("arg_"+STR(p_decl)+"AtSp"), intTy, tn,  GetPointer<const type_node>(intTy)->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, GetPointerS<const type_node>(tree_man->GetSignedIntegerType())->algn, 0, false);       
         argsAtSp.push_back(argAtSp); // NOTE: use ordered map instead of vector
         BB_block_4->PushBack(createStackRead(TM, tree_man, function_id, stack_n_decl, sp_top, argAtSp), AppM);
         
      }
      auto stateAtSp = tree_man->create_var_decl(tree_man->create_identifier_node("stateAtSp"), intTy, tn,  GetPointer<const type_node>(intTy)->size, tree_nodeRef(),
                                    tree_nodeRef(), BUILTIN_SRCP, GetPointerS<const type_node>(tree_man->GetSignedIntegerType())->algn, 0, false);       
      BB_block_4->PushBack(createStackRead(TM, tree_man, function_id, stack_state_decl, sp_top, stateAtSp), AppM); 
      // if (stateatSp == 0)
      const tree_nodeRef stateEq0Cond = tree_man->create_binary_operation(
            boolTy, stateAtSp, TM->CreateUniqueIntegerCst((integer_cst_t)0, intTy), BUILTIN_SRCP, eq_expr_K);
      BB_block_4->PushBack(tree_man->create_gimple_cond(stateEq0Cond, function_id, BUILTIN_SRCP), AppM); 

      
      // BB5: check base case (T=BB6; F=BB7) =====================================================================================================================================
      // TODO: we need an analysis path to determine the base case condition
      // insert whatever argAtSp == baseCase conditional

      // BB6: retval=base case; break the loop if stack is empty; otherwise decrement sp =========================================================================================
      // this should set one of the retPhis to the base case value
      // For now only handling integer recursive base cases
      
      const auto int_cst_baseCase = GetPointer<const integer_cst>(baseCaseNode);
      const auto baseCaseValue = TM->CreateUniqueIntegerCst(int_cst_baseCase->value, int_cst_baseCase->type);
      BB_block_6->PushBack(tree_man->CreateGimpleAssign(intTy, ret_base, tree_nodeRef(), baseCaseValue, function_id, BUILTIN_SRCP), AppM);

      // if (sp_top == 0) then BB15 else BB9
      {
      const tree_nodeRef sp_topEq0Cond = tree_man->create_binary_operation(
            boolTy, sp_top, TM->CreateUniqueIntegerCst((integer_cst_t)0, intTy), BUILTIN_SRCP, eq_expr_K);
      BB_block_6->PushBack(tree_man->create_gimple_cond(sp_topEq0Cond, function_id, BUILTIN_SRCP), AppM);
      }

      // BB9
      // sp_decr_base = sp_top - 1
      {
      const tree_nodeRef sp_minus_1 = tree_man->create_binary_operation(
            intTy, sp_top, TM->CreateUniqueIntegerCst((integer_cst_t)1, intTy), BUILTIN_SRCP, minus_expr_K);
      BB_block_9->PushBack(tree_man->CreateGimpleAssign(intTy, sp_decr_base, tree_nodeRef(), sp_minus_1, function_id, BUILTIN_SRCP), AppM);
      }

      
      // BB7: do recursive call: set stack_state[sp]=1; increment sp; create next stack frame w/ recursive argument ==============================================================
      // stack_state[sp] = 1
      BB_block_7->PushBack(createStackWrite(TM, tree_man, function_id, 
         stack_state_decl, sp_top, TM->CreateUniqueIntegerCst((integer_cst_t)1, intTy)), AppM); 
      // sp_incr = sp_top + 1
      const tree_nodeRef sp_plus_1 = tree_man->create_binary_operation(
            intTy, sp_top, TM->CreateUniqueIntegerCst((integer_cst_t)1, intTy), BUILTIN_SRCP, plus_expr_K);
      BB_block_7->PushBack(tree_man->CreateGimpleAssign(intTy, sp_incr, tree_nodeRef(), sp_plus_1, function_id, BUILTIN_SRCP), AppM);
      //stack_state[sp]=0;
      BB_block_7->PushBack(createStackWrite(TM, tree_man, function_id, 
         stack_state_decl, sp_incr, TM->CreateUniqueIntegerCst((integer_cst_t)0, intTy)), AppM); 
      // stack_arg[sp]=recursive call arg using argAtSp;
      // TODO


      // BB8: compute retval with recursive results now available. break the loop if the stack is empty
      // retval_recur = computation on recursive result in retval_top
      // TODO: fancy analysis required
      // cond (sp_top == 0)
      const tree_nodeRef sp_topEq0Cond = tree_man->create_binary_operation(
            boolTy, sp_top, TM->CreateUniqueIntegerCst((integer_cst_t)0, intTy), BUILTIN_SRCP, eq_expr_K);
      BB_block_8->PushBack(tree_man->create_gimple_cond(sp_topEq0Cond, function_id, BUILTIN_SRCP), AppM);
      
      // BB10
      // sp_decr_recur=sp_top-1
      const tree_nodeRef sp_minus_1 = tree_man->create_binary_operation(
            intTy, sp_top, TM->CreateUniqueIntegerCst((integer_cst_t)1, intTy), BUILTIN_SRCP, minus_expr_K);
      BB_block_10->PushBack(tree_man->CreateGimpleAssign(intTy, sp_decr_recur, tree_nodeRef(), sp_minus_1, function_id, BUILTIN_SRCP), AppM);






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

     changed = true;
   }

   // DEBUG PRINT IR
   std::cout << "\n===== IR after manipulation =====" << std::endl;
   DebugPrintIR(sl);
   std::cout << "=================================\n" << std::endl;

   WriteBBGraphDot("BBGraph_After.dot");

   if(changed)
   {
      function_behavior->UpdateBBVersion();
      return DesignFlowStep_Status::SUCCESS;
   }
   
   std::cout << "========== Recursion Removal Complete ==========\n\n";
   return DesignFlowStep_Status::UNCHANGED;
}
