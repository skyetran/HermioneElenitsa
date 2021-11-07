#property strict

#include "../Wrapper/MqlTradeRequestWrapper.mqh"

//--- Default Constructor
MqlTradeRequestWrapper::MqlTradeRequestWrapper(void) {
   UpdateCreateDateTime();
}

//--- Main Constructor
MqlTradeRequestWrapper::MqlTradeRequestWrapper(const MqlTradeRequest &InputRequest) {
   UpdateCreateDateTime();
   
   action       = InputRequest.action;
   magic        = InputRequest.magic;
   order        = InputRequest.order;
   symbol       = InputRequest.symbol;
   volume       = InputRequest.volume;
   price        = InputRequest.price;
   stoplimit    = InputRequest.stoplimit;
   sl           = InputRequest.sl;
   tp           = InputRequest.tp;
   deviation    = InputRequest.deviation;
   type         = InputRequest.type;
   type_filling = InputRequest.type_filling;
   type_time    = InputRequest.type_time;
   expiration   = InputRequest.expiration;
   comment      = InputRequest.comment;
   position     = InputRequest.position;
   position_by  = InputRequest.position_by;
}

//--- Copy Constructor
MqlTradeRequestWrapper::MqlTradeRequestWrapper(const MqlTradeRequestWrapper *InputRequestWrapper) {
   UpdateCreateDateTime();
   
   action       = InputRequestWrapper.action;
   magic        = InputRequestWrapper.magic;
   order        = InputRequestWrapper.order;
   symbol       = InputRequestWrapper.symbol;
   volume       = InputRequestWrapper.volume;
   price        = InputRequestWrapper.price;
   stoplimit    = InputRequestWrapper.stoplimit;
   sl           = InputRequestWrapper.sl;
   tp           = InputRequestWrapper.tp;
   deviation    = InputRequestWrapper.deviation;
   type         = InputRequestWrapper.type;
   type_filling = InputRequestWrapper.type_filling;
   type_time    = InputRequestWrapper.type_time;
   expiration   = InputRequestWrapper.expiration;
   comment      = InputRequestWrapper.comment;
   position     = InputRequestWrapper.position;
   position_by  = InputRequestWrapper.position_by;
}

//--- Revert Back To Struct Format
void MqlTradeRequestWrapper::Unwrap(MqlTradeRequest &OutputRequest) const {
   OutputRequest.action       = action;
   OutputRequest.magic        = magic;
   OutputRequest.order        = order;
   OutputRequest.symbol       = symbol;
   OutputRequest.volume       = volume;
   OutputRequest.price        = price;
   OutputRequest.stoplimit    = stoplimit;
   OutputRequest.sl           = sl;
   OutputRequest.tp           = tp;
   OutputRequest.deviation    = deviation;
   OutputRequest.type         = type;
   OutputRequest.type_filling = type_filling;
   OutputRequest.type_time    = type_time;
   OutputRequest.expiration   = expiration;
   OutputRequest.comment      = comment;
   OutputRequest.position     = position;
   OutputRequest.position_by  = position_by;
}

//--- Update --- NOT OnTick Function
void MqlTradeRequestWrapper::UpdateCreateDateTime(void) {
   CreateDateTime = TimeTradeServer();
}

//--- Required ADT Functions
int  MqlTradeRequestWrapper::Compare(MqlTradeRequestWrapper *Other) {
   //--- Ranking Importance Of Request To Determine Which To Execute First
   return 0;
}

//--- Required ADT Functions
bool MqlTradeRequestWrapper::Equals(MqlTradeRequestWrapper *Other) {
   return action       == Other.action       &&
          magic        == Other.magic        &&
          order        == Other.order        &&
          symbol       == Other.symbol       &&
          volume       == Other.volume       &&
          price        == Other.price        &&
          stoplimit    == Other.stoplimit    &&
          sl           == Other.sl           &&
          tp           == Other.tp           &&
          deviation    == Other.deviation    &&
          type         == Other.type         &&
          type_filling == Other.type_filling &&
          type_time    == Other.type_time    &&
          expiration   == Other.expiration   &&
          comment      == Other.comment      &&
          position     == Other.position     &&
          position_by  == Other.position_by   ;
}

//--- Required ADT Functions
int  MqlTradeRequestWrapper::HashCode() {
   string HashString = DoubleToString(10 * action + order) + DoubleToString(volume) + DoubleToString(price) + DoubleToString(stoplimit) + comment + TimeToString(CreateDateTime);
   int    Length     = StringLen(HashString);
   int    HashValue  = 0;
   
   if (Length > 0) {
      for (int i = 0; i < Length; i++) {
         HashValue = 31 * HashValue + HashString[i];
      }
   } 
   return HashValue;
}

//--- Getters
bool MqlTradeRequestWrapper::IsRawMarketRequest() const { return type == ORDER_TYPE_BUY            || type == ORDER_TYPE_SELL;            }
bool MqlTradeRequestWrapper::IsLimitRequest()     const { return type == ORDER_TYPE_BUY_LIMIT      || type == ORDER_TYPE_SELL_LIMIT;      }
bool MqlTradeRequestWrapper::IsStopLimitRequest() const { return type == ORDER_TYPE_BUY_STOP_LIMIT || type == ORDER_TYPE_SELL_STOP_LIMIT; }
bool MqlTradeRequestWrapper::IsStopRequest()      const { return type == ORDER_TYPE_BUY_STOP       || type == ORDER_TYPE_SELL_STOP;       }
   
bool MqlTradeRequestWrapper::IsMarketRequest()    const { return action == TRADE_ACTION_DEAL;    }
bool MqlTradeRequestWrapper::IsPendingRequest()   const { return action == TRADE_ACTION_PENDING; }

bool MqlTradeRequestWrapper::IsBuyRequest() const { 
   return IsBuyMarketRequest()   ||
          IsBuyLimitRequest()    ||
          IsBuyStopRequest()     ||
          IsBuyStopLimitRequest();
}

bool MqlTradeRequestWrapper::IsBuyMarketRequest()    const { return type == ORDER_TYPE_BUY;            }
bool MqlTradeRequestWrapper::IsBuyLimitRequest()     const { return type == ORDER_TYPE_BUY_LIMIT;      }
bool MqlTradeRequestWrapper::IsBuyStopRequest()      const { return type == ORDER_TYPE_BUY_STOP;       }
bool MqlTradeRequestWrapper::IsBuyStopLimitRequest() const { return type == ORDER_TYPE_BUY_STOP_LIMIT; }

bool MqlTradeRequestWrapper::IsSellRequest() const {
   return IsSellMarketRequest()   ||
          IsSellLimitRequest()    ||
          IsSellStopRequest()     ||
          IsSellStopLimitRequest();
}

bool MqlTradeRequestWrapper::IsSellMarketRequest()    const { return type == ORDER_TYPE_SELL;            }
bool MqlTradeRequestWrapper::IsSellLimitRequest()     const { return type == ORDER_TYPE_SELL_LIMIT;      }
bool MqlTradeRequestWrapper::IsSellStopRequest()      const { return type == ORDER_TYPE_SELL_STOP;       }
bool MqlTradeRequestWrapper::IsSellStopLimitRequest() const { return type == ORDER_TYPE_SELL_STOP_LIMIT; }

//--- Merge Same Request
void MqlTradeRequestWrapper::AddVolume(const double InputVolume) {
   volume += InputVolume;
}