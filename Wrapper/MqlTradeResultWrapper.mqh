#ifndef MQL_TRADE_RESULT_H
#define MQL_TRADE_RESULT_H

#include "../General/GlobalConstants.mqh"

class MqlTradeResultWrapper
{
public:
   //--- Default Constructor
   MqlTradeResultWrapper(void);
   
   //--- Main Constructor
   MqlTradeResultWrapper(const MqlTradeResult &InputResult);
   
   //--- Copy Constructor
   MqlTradeResultWrapper(const MqlTradeResultWrapper *InputResultWrapper);
   
   //--- Revert Back To Struct Format
   void Unwrap(MqlTradeResult &OutputResult) const;
   
   //--- Attributes
   uint   retcode;
   ulong  deal;
   ulong  order;
   double volume;
   double price;
   double bid;
   double ask;
   string comment;
   uint   request_id;
   uint   retcode_external;
};

#endif