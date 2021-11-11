#ifndef SIGNAL_GENERATOR_H
#define SIGNAL_GENERATOR_H

#include <Trade\SymbolInfo.mqh>

#include "../General/GlobalConstants.mqh"
#include "../General/GlobalFunctions.mqh"
#include "../General/IndicatorProcessor.mqh"
#include "../Wrapper/MqlTradeRequestWrapper.mqh"

#define MIN_ATR_MULTIPLIER       0

#define BRIDGE_TOO_FAR_LOOK_BACK 7

class SignalGenerator
{
public:
   //--- Get Singleton Instance
   static SignalGenerator *GetInstance(void);
   
   //--- Debug Functions
   string GetDebugMsg(void) const;
   
   //--- OnInit Functions
   bool SetATRMultiplier(const double InputATRMultiplier);
   
   //--- OnTick Functions
   void Update(void);
   
   //--- Getters --- OnTick Functions
   MqlTradeRequestWrapper *GetNextSignal(void);
   bool                    GetExitLongSignal(void);
   bool                    GetExitShortSignal(void);
   
   //--- Auxilary Functions
   datetime GetLastMarketSwitchDateTime(void)     const;
   datetime GetLastLastMarketSwitchDateTime(void) const;
   
private:
   //--- Trade Class Instances
   CSymbolInfo SymbolInfo;
   
   //--- External Entities
   GlobalFunctions    *GF;
   IndicatorProcessor *IP;
   
   //--- NNFX Settings
   double ATRMultiplier;
   
   //--- Tracking DateTime Variables
   datetime CurrentDateTime;
   datetime TailingDateTime;
   datetime LastDateTime;
   datetime LastLastDateTime;
   datetime LongStartDateTime;
   datetime ShortStartDateTime;   
   
   //--- Auxilary Variables
   datetime LastMarketSwitchDateTime;
   datetime TailingLastMarketSwitchDateTime;
   datetime LastLastMarketSwitchDateTime;
   
   //--- Tracking Time Flag Variables
   bool NewCandleFlag;
   
   //--- Tracking Long Flag Variables
   bool ResetLongTrackingVariablesFlag;
   bool LongOrderExitFlag;
   bool FirstClosedLongCandleFlag;
   bool SecondClosedLongCandleFlag;
   bool LongBridgeTooFarFlag;
   bool LookingForBaselineLongEntryFlag;
   bool BaselineLongEntryFlag;
   bool LookingForPullBackLongEntryFlag;
   bool PullBackLongEntryFlag;
   bool LookingForStandardLongEntryFlag;
   bool StandardLongEntryFlag;
   bool LookingForContinuationLongEntryFlag;
   bool ContinuationLongEntryFlag;
   bool FirstLongEntrySignalFlag;
   bool LongEntrySignalFlag;
   bool HasTradedThisCandleLongFlag;
   
   //--- Tracking Short Flag Variables
   bool ResetShortTrackingVariablesFlag;
   bool ShortOrderExitFlag;
   bool FirstClosedShortCandleFlag;
   bool SecondClosedShortCandleFlag;
   bool ShortBridgeTooFarFlag;
   bool LookingForBaselineShortEntryFlag;
   bool BaselineShortEntryFlag;
   bool LookingForPullBackShortEntryFlag;
   bool PullBackShortEntryFlag;
   bool LookingForStandardShortEntryFlag;
   bool StandardShortEntryFlag;
   bool LookingForContinuationShortEntryFlag;
   bool ContinuationShortEntryFlag;
   bool FirstShortEntrySignalFlag;
   bool ShortEntrySignalFlag;
   bool HasTradedThisCandleShortFlag;
   
   //--- Singleton Instance
   static SignalGenerator *Instance;
   
   //--- Main Constructor
   SignalGenerator(void);
   
   //--- Helper Functions: Constructor
   void InitTrackingVariables(void);
   
   //--- Helper Functions: SetATRMultiplier --- OnInit Functions
   bool IsATRMultiplierValid(const double InputATRMultiplier) const;
   
   //--- Helper Functions: Update --- OnTick Functions
   void UpdateBothSide(void);
   void UpdateLongSide(void);
   void UpdateShortSide(void);
   
   //--- Helper Functions: UpdateBothSide --- OnTick Functions
   void ResetLongTrackingVariables(void);
   void ResetShortTrackingVariables(void);
   void UpdateNewCandleFlag(void);
   void ResetHasTradedThisCandleLongFlag(void);
   void ResetHasTradedThisCandleShortFlag(void);
   void UpdateDateTimeVariables(void);
   void UpdateLongOrderExitFlag(void);
   void UpdateShortOrderExitFlag(void);
   
   //--- Helper Functions: UpdateLongSide --- OnTick Functions
   void UpdateFirstClosedLongCandleFlag(void);
   void UpdateSecondClosedLongCandleFlag(void);
   void UpdateLongBridgeTooFarFlag(void);
   void UpdateLookingForBaselineLongEntryFlag(void);
   void UpdateBaselineLongEntryFlag(void);
   void UpdateLookingForPullBackLongEntryFlag(void);
   void UpdatePullBackLongEntryFlag(void);
   void UpdateLookingForStandardLongEntryFlag(void);
   void UpdateStandardLongEntryFlag(void);
   void UpdateLookingForContinuationLongEntryFlag(void);
   void UpdateContinuationLongEntryFlag(void);
   void UpdateFirstLongEntrySignalFlag(void);
   void UpdateLongEntrySignalFlag(void);
   void UpdateHasTradedThisCandleLongFlag(void);
   
   //--- Helper Functions: UpdateShortSide --- OnTick Functions
   void UpdateFirstClosedShortCandleFlag(void);
   void UpdateSecondClosedShortCandleFlag(void);
   void UpdateShortBridgeTooFarFlag(void);
   void UpdateLookingForBaselineShortEntryFlag(void);
   void UpdateBaselineShortEntryFlag(void);
   void UpdateLookingForPullBackShortEntryFlag(void);
   void UpdatePullBackShortEntryFlag(void);
   void UpdateLookingForStandardShortEntryFlag(void);
   void UpdateStandardShortEntryFlag(void);
   void UpdateLookingForContinuationShortEntryFlag(void);
   void UpdateContinuationShortEntryFlag(void);
   void UpdateFirstShortEntrySignalFlag(void);
   void UpdateShortEntrySignalFlag(void);
   void UpdateHasTradedThisCandleShortFlag(void);
   
   //--- Helper Functions: GetNextSignal
   void ResetLongEntrySignalTrackingVariables(void);
   void ResetShortEntrySignalTrackingVariables(void);
   
   //--- Helper Functions: UpdateDateTimeVariables --- OnTickFunctions
   void UpdateCurrentDateTime(void);
   void UpdateTailingDateTime(void);
   void UpdateLastDateTime(void);
   void UpdateLastLastDateTime(void);
   void UpdateLongStartDateTime(void);
   void UpdateShortStartDateTime(void);
   
   //--- Helper Functions: Update Auxilary Vairables --- OnTickFunctions
   void UpdateMarketSwitchDateTime(void);
   
   //--- Helper Functions: Line Up Indicator Signals
   bool IndicatorsGiveStandardLongSignal(const int InputShift)      const;
   bool IndicatorsGiveStandardShortSignal(const int InputShift)     const;
   bool IndicatorsGiveContinuationLongSignal(const int InputShift)  const;
   bool IndicatorsGiveContinuationShortSignal(const int InputShift) const;
   bool IndicatorsGiveExitLongSignal(const int InputShift)          const;
   bool IndicatorsGiveExitShortSignal(const int InputShift)         const;
   
   //--- Helper Functions: GetNextSignal --- OnTick Functions
   MqlTradeRequestWrapper *GetNextLongSignal(void) const;
   MqlTradeRequestWrapper *GetNextShortSignal(void) const;   
};

SignalGenerator *SignalGenerator::Instance = NULL;

#endif