#ifndef TRADE_EXECUTOR_H
#define TRADE_EXECUTOR_H

#include <Generic\ArrayList.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>
#include <Trade\Trade.mqh>

#include "../General/GlobalConstants.mqh"
#include "../General/GlobalFunctions.mqh"
#include "../General/IndicatorProcessor.mqh"
#include "../Signal/SignalGenerator.mqh"
#include "../Wrapper/MqlTradeRequestWrapper.mqh"

#define MIN_MAGIC_NUMBER   0
#define MAX_MAGIC_NUMBER   INT_MAX
#define MIN_DEVIATION      0
#define MAX_DEVIATION      1

class TradeExecutor
{
public:
   //--- Get Singleton Instance
   static TradeExecutor *GetInstance(void);
   
   //--- Debug Functions
   string GetDebugMsg(void) const;
   
   //--- OnInit Functions
   bool SetExpertAdvisorMagicNumber(const int InputMagicNumber);
   bool SetDeviation(const int InputDeviation);
   void Init(void);
   
   //--- OnTick Functions
   void Update(void);
   
private:
   //--- Trade Class Instances
   CSymbolInfo       SymbolInfo;
   CHistoryOrderInfo HistoryOrderInfo;
   CTrade            Trade;
   
   //--- External Entities
   GlobalFunctions    *GF;
   IndicatorProcessor *IP;
   SignalGenerator    *SG;
   
   //--- Trade Settings
   int MagicNumber;
   int Deviation;
   
   //--- Trade Buffers
   CArrayList<MqlTradeRequestWrapper*> LongRequestList, ShortRequestList;
   
   //--- Singleton Instance
   static TradeExecutor *Instance;
   
   //--- Main Constructor
   TradeExecutor(void);
   
   //--- Validation For Setters --- OnInit Functions
   bool IsExpertAdvisorMagicNumberValid(const int InputMagicNumber) const;
   bool IsDeviation(const int InputDeviation)                       const;
   
   //--- Helper Functions: Update --- OnTick Functions
   void ExecuteExitLongSignal(const bool ExitFlag);
   void ExecuteExitShortSignal(const bool ExitFlag);
   void LogEntrySignal(void);
   void ExecuteEntrySignal(void);
   
   //--- Helper Functions: LogEntrySignal --- OnTick Functions
   void LogLongEntrySignal(MqlTradeRequestWrapper *InputRequest);
   void LogShortEntrySignal(MqlTradeRequestWrapper *InputRequest);
   
   //--- Helper Functions: ExecuteEntrySignal --- OnTick Functions
   void ExecuteLongEntrySignal(void);
   void ExecuteShortEntrySignal(void);
};

TradeExecutor *TradeExecutor::Instance = NULL;

#endif