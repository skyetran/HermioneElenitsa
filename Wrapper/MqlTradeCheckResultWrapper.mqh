#ifndef MQL_TRADE_CHECK_RESULT_H
#define MQL_TRADE_CHECK_RESULT_H

#include "../General/GlobalConstants.mqh"

class MqlTradeCheckResultWrapper
{
public:
   //--- Default Constructor
   MqlTradeCheckResultWrapper(void);
   
   //--- Main Constructor
   MqlTradeCheckResultWrapper(const MqlTradeCheckResult &InputCheckResult);
   
   //--- Copy Constructor
   MqlTradeCheckResultWrapper(const MqlTradeCheckResultWrapper *InputCheckResultWrapper);
   
   //--- Convert To Struct Format
   void Unwrap(MqlTradeCheckResult &OutputCheckResult) const;
   
   //--- Attributes
   uint   retcode;
   double balance;
   double equity;
   double profit;
   double margin;
   double margin_free;
   double margin_level;
   string comment;
};

#endif