#property strict

#include "../Wrapper/MqlTradeResultWrapper.mqh"

//--- Default Constructor
MqlTradeResultWrapper::MqlTradeResultWrapper(void) { }

//--- Main Constructor
MqlTradeResultWrapper::MqlTradeResultWrapper(const MqlTradeResult &InputResult) {
   retcode          = InputResult.retcode;
   deal             = InputResult.deal;
   order            = InputResult.order;
   volume           = InputResult.volume;
   price            = InputResult.price;
   bid              = InputResult.bid;
   ask              = InputResult.ask;
   comment          = InputResult.comment;
   request_id       = InputResult.request_id;
   retcode_external = InputResult.retcode_external;
}

//--- Copy Constructor
MqlTradeResultWrapper::MqlTradeResultWrapper(const MqlTradeResultWrapper *InputResultWrapper) {
   retcode          = InputResultWrapper.retcode;
   deal             = InputResultWrapper.deal;
   order            = InputResultWrapper.order;
   volume           = InputResultWrapper.volume;
   price            = InputResultWrapper.price;
   bid              = InputResultWrapper.bid;
   ask              = InputResultWrapper.ask;
   comment          = InputResultWrapper.comment;
   request_id       = InputResultWrapper.request_id;
   retcode_external = InputResultWrapper.retcode_external;
}

//--- Revert Back To Struct Format
void MqlTradeResultWrapper::Unwrap(MqlTradeResult &OutputResult) const {
   OutputResult.retcode          = retcode;
   OutputResult.deal             = deal;
   OutputResult.order            = order;
   OutputResult.volume           = volume;
   OutputResult.price            = price;
   OutputResult.bid              = bid;
   OutputResult.ask              = ask;
   OutputResult.comment          = comment;
   OutputResult.request_id       = request_id;
   OutputResult.retcode_external = (int) retcode_external;
}