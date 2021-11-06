#ifndef MQL_TRADE_REQUEST_WRAPPER_H
#define MQL_TRADE_REQUEST_WRAPPER_H

#include <Generic/Interfaces/IComparable.mqh>

class MqlTradeRequestWrapper : public IComparable<MqlTradeRequestWrapper*>
{
public:
   //--- Default Constructor
   MqlTradeRequestWrapper(void);
   
   //--- Main Constructor
   MqlTradeRequestWrapper(const MqlTradeRequest &InputRequest);
   
   //--- Copy Constructor
   MqlTradeRequestWrapper(const MqlTradeRequestWrapper *InputRequest);
   
   //--- Revert Back To Struct Format
   void Unwrap(MqlTradeRequest &OutputRequest) const;
   
   //--- Required ADT Functions
   int  Compare(MqlTradeRequestWrapper *Other) override;
   bool Equals(MqlTradeRequestWrapper *Other)  override;
   int  HashCode(void)                         override;
   
   //--- Getters
   bool IsRawMarketRequest(void) const;
   bool IsLimitRequest(void)     const;
   bool IsStopLimitRequest(void) const;
   bool IsStopRequest(void)      const;
   
   bool IsMarketRequest(void)    const;
   bool IsPendingRequest(void)   const;
   
   bool IsBuyRequest(void)          const;
   bool IsBuyMarketRequest(void)    const;
   bool IsBuyLimitRequest(void)     const;
   bool IsBuyStopRequest(void)      const;
   bool IsBuyStopLimitRequest(void) const;
   
   bool IsSellRequest(void)          const;
   bool IsSellMarketRequest(void)    const;
   bool IsSellLimitRequest(void)     const;
   bool IsSellStopRequest(void)      const;
   bool IsSellStopLimitRequest(void) const;

   //--- Merge Same Request
   void AddVolume(const double InputVolume);
   
   //--- Attributes
   ENUM_TRADE_REQUEST_ACTIONS action;
   ulong                      magic;
   ulong                      order;
   string                     symbol;
   double                     volume;
   double                     price;
   double                     stoplimit;
   double                     sl;
   double                     tp;
   ulong                      deviation;
   ENUM_ORDER_TYPE            type;
   ENUM_ORDER_TYPE_FILLING    type_filling;
   ENUM_ORDER_TYPE_TIME       type_time;
   datetime                   expiration;
   string                     comment;
   ulong                      position;
   ulong                      position_by;
   
private:
   //--- Additional Attributes
   datetime CreateDateTime;
   
   //--- Helper Functions: Constructor
   //--- NOT OnTick Function
   void UpdateCreateDateTime(void);
};

#endif