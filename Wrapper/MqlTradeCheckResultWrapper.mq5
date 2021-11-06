#property strict

#include "../Wrapper/MqlTradeCheckResultWrapper.mqh"

//--- Default Constructor
MqlTradeCheckResultWrapper::MqlTradeCheckResultWrapper(void) { }

//--- Main Constructor
MqlTradeCheckResultWrapper::MqlTradeCheckResultWrapper(const MqlTradeCheckResult &InputCheckResult) {
   retcode      = InputCheckResult.retcode;
   balance      = InputCheckResult.balance;
   equity       = InputCheckResult.equity;
   profit       = InputCheckResult.profit;
   margin       = InputCheckResult.margin;
   margin_free  = InputCheckResult.margin_free;
   margin_level = InputCheckResult.margin_level;
   comment      = InputCheckResult.comment;
}

//--- Copy Constructor
MqlTradeCheckResultWrapper::MqlTradeCheckResultWrapper(const MqlTradeCheckResultWrapper *InputCheckResultWrapper) {
   retcode      = InputCheckResultWrapper.retcode;
   balance      = InputCheckResultWrapper.balance;
   equity       = InputCheckResultWrapper.equity;
   profit       = InputCheckResultWrapper.profit;
   margin       = InputCheckResultWrapper.margin;
   margin_free  = InputCheckResultWrapper.margin_free;
   margin_level = InputCheckResultWrapper.margin_level;
   comment      = InputCheckResultWrapper.comment;
}

//--- Convert To Struct Format
void MqlTradeCheckResultWrapper::Unwrap(MqlTradeCheckResult &OutputCheckResult) const {
   OutputCheckResult.retcode      = retcode;
   OutputCheckResult.balance      = balance;
   OutputCheckResult.equity       = equity;
   OutputCheckResult.profit       = profit;
   OutputCheckResult.margin       = margin;
   OutputCheckResult.margin_free  = margin_free;
   OutputCheckResult.margin_level = margin_level;
   OutputCheckResult.comment      = comment;
}