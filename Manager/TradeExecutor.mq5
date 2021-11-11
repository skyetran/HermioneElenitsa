#property strict

#include "../Manager/TradeExecutor.mqh"

//--- Main Constructor
TradeExecutor::TradeExecutor(void) {
   GF = GlobalFunctions::GetInstance();
   IP = IndicatorProcessor::GetInstance();
   SG = SignalGenerator::GetInstance();
   
   SymbolInfo.Name(Symbol());
}

//--- Get Singleton Instance
TradeExecutor *TradeExecutor::GetInstance(void) {
   if (!Instance) {
      Instance = new TradeExecutor();
   }
   return Instance;
}

//--- Debug Functions
string TradeExecutor::GetDebugMsg(void) const {
   string Msg = "";
   
   return Msg;
}

//--- OnInit Functions
bool TradeExecutor::SetExpertAdvisorMagicNumber(const int InputMagicNumber) {
   if (IsExpertAdvisorMagicNumberValid(InputMagicNumber)) {
      MagicNumber = InputMagicNumber;
      return true;
   }
   return false;
}

//--- OnInit Functions
bool TradeExecutor::SetDeviation(const int InputDeviation) {
   if (IsDeviation(InputDeviation)) {
      Deviation = InputDeviation;
      return true;
   }
   return false;
}

//--- OnInit Functions
void TradeExecutor::Init(void) {
   Trade.SetExpertMagicNumber(MagicNumber);
   Trade.SetDeviationInPoints(Deviation);
}

//--- Validation For Setters --- OnInit Functions
bool TradeExecutor::IsExpertAdvisorMagicNumberValid(const int InputMagicNumber) const {
   return MIN_MAGIC_NUMBER <= InputMagicNumber && InputMagicNumber <= MAX_MAGIC_NUMBER;
}

//--- Validation For Setters --- OnInit Functions
bool TradeExecutor::IsDeviation(const int InputDeviation) const {
   return MIN_DEVIATION <= InputDeviation && InputDeviation <= MAX_DEVIATION;
}

//--- OnTick Functions
void TradeExecutor::Update(void) {
   ExecuteExitLongSignal(SG.GetExitLongSignal());
   ExecuteExitShortSignal(SG.GetExitShortSignal());
   LogEntrySignal();
   ExecuteEntrySignal();
}

//--- Helper Functions: Update --- OnTick Functions
void TradeExecutor::ExecuteExitLongSignal(const bool ExitFlag) {
   if (ExitFlag) {
      HistorySelect(SG.GetLastLastMarketSwitchDateTime(), TimeCurrent());
      int TotalOrders = HistoryOrdersTotal();
      for (int i = TotalOrders - 1; i >= 0; i--) {
         HistoryOrderInfo.SelectByIndex(i);
         if (HistoryOrderInfo.OrderType() == ORDER_TYPE_BUY) {
            Trade.PositionClose(HistoryOrderInfo.Ticket());
         }
      }
   }
}

//--- Helper Functions: Update --- OnTick Functions
void TradeExecutor::ExecuteExitShortSignal(const bool ExitFlag) {
   if (ExitFlag) {
      HistorySelect(SG.GetLastLastMarketSwitchDateTime(), TimeCurrent());
      int TotalOrders = HistoryOrdersTotal();
      for (int i = TotalOrders - 1; i >= 0; i--) {
         HistoryOrderInfo.SelectByIndex(i);
         if (HistoryOrderInfo.OrderType() == ORDER_TYPE_SELL) {
            Trade.PositionClose(HistoryOrderInfo.Ticket());
         }
      }
   }
}

//--- Helper Functions: Update --- OnTick Functions
void TradeExecutor::LogEntrySignal(void) {
   MqlTradeRequestWrapper *NextRequest = SG.GetNextSignal();
   if (NextRequest) {
      LogLongEntrySignal(NextRequest);
      LogShortEntrySignal(NextRequest);
   }
}

//--- Helper Functions: LogEntrySignal --- OnTick Functions
void TradeExecutor::LogLongEntrySignal(MqlTradeRequestWrapper *InputRequest) {
   if (InputRequest.tp > InputRequest.sl) {
      LongRequestList.Add(InputRequest);
   }
}

//--- Helper Functions: LogEntrySignal --- OnTick Functions
void TradeExecutor::LogShortEntrySignal(MqlTradeRequestWrapper *InputRequest) {
   if (InputRequest.tp < InputRequest.sl) {
      ShortRequestList.Add(InputRequest);
   }
}

//--- Helper Functions: Update --- OnTick Functions
void TradeExecutor::ExecuteEntrySignal(void) {
   ExecuteLongEntrySignal();
   ExecuteShortEntrySignal();
}

//--- Helper Functions: ExecuteEntrySignal
void TradeExecutor::ExecuteLongEntrySignal(void) {
   MqlTradeRequestWrapper *TempRequestWrapper;
   MqlTradeRequest         TempRequest = {};
   for (int i = 0; i < LongRequestList.Count(); i++) {
      if (LongRequestList.TryGetValue(i, TempRequestWrapper)) {
         TempRequestWrapper.Unwrap(TempRequest);
         Trade.Buy(0.1, SymbolInfo.Name(), 0.0, TempRequest.sl, TempRequest.tp);
         LongRequestList.RemoveAt(i);
      }
   }
}

//--- Helper Functions: ExecuteEntrySignal
void TradeExecutor::ExecuteShortEntrySignal(void) {
   MqlTradeRequestWrapper *TempRequestWrapper;
   MqlTradeRequest         TempRequest = {};
   for (int i = 0; i < ShortRequestList.Count(); i++) {
      if (ShortRequestList.TryGetValue(i, TempRequestWrapper)) {
         TempRequestWrapper.Unwrap(TempRequest);
         Trade.Sell(0.1, SymbolInfo.Name(), 0.0, TempRequest.sl, TempRequest.tp);
         ShortRequestList.RemoveAt(i);
      }
   }
}