#ifndef RECURSION_REMOVAL_HPP
#define RECURSION_REMOVAL_HPP

#include "function_frontend_flow_step.hpp"

class RecursionRemoval : public FunctionFrontendFlowStep
{
 protected:
   /**
    * Execute the step
    * @return the exit status of this step
    */
   DesignFlowStep_Status InternalExec() override;

   /**
    * Return the set of analyses in relationship with this design step
    * @param relationship_type is the type of relationship to be considered
    */
   CustomUnorderedSet<std::pair<FrontendFlowStepType, FunctionRelationship>>
   ComputeFrontendRelationships(const DesignFlowStep::RelationshipType relationship_type) const override;

 public:
   /**
    * Constructor
    */
   RecursionRemoval(const ParameterConstRef params, const application_managerRef AM, unsigned int fun_id,
                           const DesignFlowManagerConstRef dfm);

   /**
    * Destructor
    */
   ~RecursionRemoval() override;
};

#endif
