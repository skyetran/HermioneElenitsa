#ifndef SIGNAL_GENERATOR_H
#define SIGNAL_GENERATOR_H

#include <Trade\SymbolInfo.mqh>

#include "../General/GlobalConstants.mqh"
#include "../General/GlobalFunctions.mqh"
#include "../General/IndicatorProcessor.mqh"
#include "../Wrapper/MqlTradeRequestWrapper.mqh"

#define BRIDGE_TOO_FAR_LOOK_BACK 7

class SignalGenerator
{
public:
   //--- Get Singleton Instance
   static SignalGenerator *GetInstance(void);
   
   //--- Debug Functions
   string GetDebugMsg(void) const;
   
   //--- OnTick Functions
   void Update(void);
   
   //--- Getters --- OnTick Functions
   MqlTradeRequestWrapper *GetNextSignal(void);
   
   
private:
   //--- Trade Class Instances
   CSymbolInfo SymbolInfo;
   
   //--- External Entities
   GlobalFunctions    *GF;
   IndicatorProcessor *IP;
   
   //--- Tracking DateTime Variables
   datetime CurrentDateTime;
   datetime TailingDateTime;
   datetime LastLastDateTime;
   datetime StartDateTime;   
   
   //--- Tracking Flag Variables
   bool LongEntrySignalFlag;
   bool ShortEntrySignalFlag;
   bool NewCandleFlag;
   bool FirstClosedCandleFlag;
   bool SecondClosedCandleFlag;
   bool BridgeTooFarFlag;
   bool LookingForBaselineEntryFlag;
   bool BaselineEntryFlag;
   bool LookingForPullBackEntryFlag;
   bool PullBackEntryFlag;
   bool LookingForStandardEntryFlag;
   bool StandardEntryFlag;
   bool LookingForContinuationEntryFlag;
   bool ContinuationEntryFlag;
   bool FirstEntrySignalFlag;
   bool LongOrderExitFlag;
   bool ShortOrderExitFlag;
   
   //--- Singleton Instance
   static SignalGenerator *Instance;
   
   //--- Main Constructor
   SignalGenerator(void);
   
   //--- Helper Functions: Constructor
   void InitTrackingVariables(void);
   
   //--- Helper Functions: Update --- OnTick Functions
   void UpdateNewCandleFlag(void);
   void UpdateDateTimeVariables(void);
   void UpdateFirstClosedCandleFlag(void);
   void UpdateSecondClosedCandleFlag(void);
   void UpdateBridgeTooFarFlag(void);
   void UpdateLookingForBaselineEntryFlag(void);
   void UpdateBaselineEntryFlag(void);
   void UpdateLookingForPullBackEntryFlag(void);
   void UpdatePullBackEntryFlag(void);
   void UpdateLookingForStandardEntryFlag(void);
   void UpdateStandardEntryFlag(void);
   void UpdateLookingForContinuationEntryFlag(void);
   void UpdateContinuationEntryFlag(void);
   void UpdateFirstEntrySignalFlag(void);
   void UpdateLongOrderExitFlag(void);
   void UpdateShortOrderExitFlag(void);
   void ResetTrackingVariables(void);
   void ResetEntrySignalTrackingVariables(void);
   
   //--- Helper Functions: UpdateDateTimeVariables --- OnTickFunctions
   void UpdateCurrentDateTime(void);
   void UpdateTailingDateTime(void);
   void UpdateLastLastDateTime(void);
   void UpdateStartDateTime(void);
   
   //--- Helper Functions: UpdateBrideTooFarFlag --- OnTick Functions
   void UpdateBridgeTooFarFlagFromAbove(void);
   void UpdateBridgeTooFarFlagFromBelow(void);
   
   //--- Helper Functions: UpdateBaselineEntryFlag --- OnTick Functions
   void UpdateBaselineLongEntryFlag(void);
   void UpdateBaselineShortEntryFlag(void);
   
   //--- Helper Functions: UpdatePullBackEntryFlag --- OnTick Functions
   void UpdatePullBackLongEntryFlag(void);
   void UpdatePullBackShortEntryFlag(void);
   
   //--- Helper Functions: UpdateStandardEntryFlag --- OnTick Functions
   void UpdateStandardLongEntryFlag(void);
   void UpdateStandardShortEntryFlag(void);
   
   //--- Helper Functions: UpdateContinuationEntryFlag --- OnTick Functions
   void UpdateContinuationLongEntryFlag(void);
   void UpdateContinuationShortEntryFlag(void);
   
   //--- Helper Functions: Line Up Indicator Signals
   bool IndicatorsGiveStandardLongSignal(const int InputShift)      const;
   bool IndicatorsGiveStandardShortSignal(const int InputShift)     const;
   bool IndicatorsGiveContinuationLongSignal(const int InputShift)  const;
   bool IndicatorsGiveContinuationShortSignal(const int InputShift) const;
   bool IndicatorsGiveExitLongSignal(const int InputShift)          const;
   bool IndicatorsGiveExitShortSignal(const int InputShift)         const;
};

SignalGenerator *SignalGenerator::Instance = NULL;

#endif