#ifndef INDICATOR_PROCESSOR_H
#define INDICATOR_PROCESSOR_H

#include <Trade\SymbolInfo.mqh>

#include "GlobalConstants.mqh"
#include "GlobalFunctions.mqh"

//--- Base Line Indicator
#define SUPER_SMOOTHER_VALUE_BUFFER       0

//--- Primary Confirmation Indicator
#define EHLER_FISHER_VALUE_BUFFER         0
#define EHLER_FISHER_DIRECTION_BUFFER     1

//--- Secondary Confirmation Indicator
#define VORTEX_BULLISH_VALUE_BUFFER       0
#define VORTEX_BEARISH_VALUE_BUFFER       1

//--- Volume Indicator
#define WAE_VOLUME_VALUE_BUFFER           0
#define WAE_SIGNAL_LINE_BUFFER            2
#define WAE_DEATH_ZONE_BUFFER             3

//--- Exit Indicator
#define JURIK_FILTER_VALUE_BUFFER         0
#define JURIK_FILTER_DIRECTION_BUFFER     1

//--- ATR Indicator
#define ATR_VALUE_BUFFER                  0

//--- Spread Indicator
#define OPEN_SPREAD_BUFFER                0
#define HIGH_SPREAD_BUFFER                1
#define LOW_SPREAD_BUFFER                 2
#define CLOSE_SPREAD_BUFFER               3
#define AVERAGE_SPREAD_BUFFER             4

//--- Parameters Bound
#define MIN_PERIOD                        2
#define ZERO                              0
#define MIN_PHASE                         0
#define MAX_PHASE                         359

//--- Buffer Boundary
#define INDICATOR_BUFFER_SIZE             3

//--- Schaff Trend Cycle Constants
#define EHLER_FISHER_BULLISH_DIRECTION    1
#define EHLER_FISHER_BEARISH_DIRECTION    2

//--- Jurik Filter Constants
#define JURIK_BULLISH_DIRECTION           0
#define JURIK_BEARISH_DIRECTION           1

class IndicatorProcessor
{
public:
   //--- Get Singleton Instance
   static IndicatorProcessor *GetInstance(void);
   
   //--- Debug Functions
   string GetDebugMsg(void);
   
   //--- OnInit Functions
   void Init(void);
   
   //--- Setters --- OnInit Functions
   bool SetBaselineParameters(const int &InputPeriod);
   bool SetPrimaryConfirmationParameters(const int &InputPeriod);
   bool SetSecondaryConfirmationParameters(const int &InputPeriod);
   bool SetVolumeIndicatorParameters(const int &InputFastMACDPeriod, const int &InputSlowMACDPeriod,
                                     const int &InputBollingerPeriod, const double &InputBollingerDeviation,
                                     const int &InputSensitive, const int &InputDeadZone,
                                     const int &InputExplosionPower, const int &InputTrendPower);
   bool SetExitIndicatorParameters(const int &InputPeriod, const int &InputPhase);
   bool SetATRParameters(const int &InputPeriod);

   //--- OnTick Functions
   void Update(void);
   
   //--- Getters --- Baseline Indicator
   double GetBaselineValue(const int InputShift) const;
   bool   IsAboveBaseline(const int InputShift) const;
   bool   IsBelowBaseline(const int InputShift) const;
   
   //--- Getters --- Primary Confirmation Indicator
   double GetPrimaryConfirmationBullishValue(const int InputShift) const;
   double GetPrimaryConfirmationBearishValue(const int InputShift) const;
   double GetPrimaryConfirmationValue(const int InputShift)        const;
   double GetPrimaryConfirmationDirection(const int InputShift)    const;
   bool   IsPrimaryConfirmationBullish(const int InputShift)       const;
   bool   IsPrimaryConfirmationBearish(const int InputShift)       const;
   
   //--- Getters --- Secondary Confirmation Indicator
   double GetSecondaryConfirmationBullishValue(const int InputShift) const;
   double GetSecondaryConfirmationBearishValue(const int InputShift) const;
   bool   IsSecondaryConfirmationBullish(const int InputShift)       const;
   bool   IsSecondaryConfirmationBearish(const int InputShift)       const;
   
   //--- Getters --- Volume Indicator
   bool   IsDeadMarket(const int InputShift)      const;
   bool   IsActiveMarket(const int InputShift)    const;
   double GetVolumeValue(const int InputShift)    const;
   double GetWAESignalValue(const int InputShift) const;
   double GetWAEDeathZone(const int InputShift)   const;
   
   //--- Getters --- Exit Indicator
   bool   ShouldExitLong(const int InputShift)      const;
   bool   ShouldExitShort(const int InputShift)     const;
   double GetExitBullishValue(const int InputShift) const;
   double GetExitBearishValue(const int InputShift) const;
   double GetExitValue(const int InputShift)        const;
   double GetExitDirection(const int InputShift)    const;
   bool   IsExitBullish(const int InputShift)       const;
   bool   IsExitBearish(const int InputShift)       const;
   
   //--- Getters --- ATR Indicator
   double GetATRValue(const int InputShift) const;
   
   //--- Getters --- Spread Indicator
   int GetOpenSpreadInPts(const int InputShift)    const;
   int GetHighSpreadInPts(const int InputShift)    const;
   int GetLowSpreadInPts(const int InputShift)     const;
   int GetCloseSpreadInPts(const int InputShift)   const;
   int GetAverageSpreadInPts(const int InputShift) const;
   
   double GetOpenSpreadInPrice(const int InputShift)    const;
   double GetHighSpreadInPrice(const int InputShift)    const;
   double GetLowSpreadInPrice(const int InputShift)     const;
   double GetCloseSpreadInPrice(const int InputShift)   const;
   double GetAverageSpreadInPrice(const int InputShift) const;
   
private:
   //--- Trade Class Instances
   CSymbolInfo SymbolInfo;
   
   //--- External Entities
   GlobalFunctions *GF;
   
   //--- Indicator Handles
   int BaselineHandle;
   int PrimaryConfirmationHandle;
   int SecondaryConfirmationHandle;
   int VolumeHandle;
   int ExitHandle;
   int ATRHandle;
   int SpreadHandle;
   
   //--- Indicator Buffers
   double SuperSmootherValueBuffer[];
   double EhlerFisherValueBuffer[], EhlerFisherDirectionBuffer[];
   double VortexBullishValueBuffer[], VortexBearishValueBuffer[];
   double WAEVolumeValueBuffer[], WAESignalValueBuffer[], WAEDeathZoneBuffer[];
   double JurikFilterValueBuffer[], JurikFilterDirectionBuffer[];
   double ATRValueBuffer[];
   double OpenSpreadBuffer[], HighSpreadBuffer[], LowSpreadBuffer[], CloseSpreadBuffer[], AverageSpreadBuffer[];
   
   //--- Baseline Indicator Parameters
   int SuperSmootherPeriod;
   
   //--- Primary Confirmation Parameters
   int EhlerFisherPeriod;
   
   //--- Secondary Confirmation Indicator Parameters
   int VortexPeriod;
   
   //--- Volume Indicator Parameters
   int    FastMACDPeriod, SlowMACDPeriod, BollingerPeriod, Sensitive, DeathZone, ExplosionPower, TrendPower;
   double BollingerDeviation;
   
   //--- Exit Indicator Parameters
   int JurikPeriod, JurikPhase;
   
   //--- ATR Indicator Parameters
   int ATRPeriod;
   
   //--- Singleton Instance
   static IndicatorProcessor *Instance;
   
   //--- Main Constructor
   IndicatorProcessor(void);
   
   //--- Baseline Indicator Parameters Validation Checks
   bool IsBaselineParametersValid(const int &InputPeriod) const;
   
   //--- Primary Confirmation Indicator Parameters Validation Checks
   bool IsPrimaryConfirmationIndicatorParametersValid(const int &InputPeriod) const;
   
   //--- Secondary Confirmation Indicator Parameters Validation Checks
   bool IsSecondaryConfirmationIndicatorParametersValid(const int &InputPeriod) const;

   //--- Volume Indicator Parameters Validation Checks
   bool IsVolumeIndicatorParametersValid(const int &InputFastMACDPeriod, const int &InputSlowMACDPeriod,
                                         const int &InputBollingerPeriod, const double &InputBollingerDeviation,
                                         const int &InputSensitive, const int &InputDeadZone,
                                         const int &InputExplosionPower, const int &InputTrendPower) const;
   
   //--- Exit Indicator Parameters Validation Checks
   bool IsExitIndicatorParametersValid(const int &InputPeriod, const int &InputPhase) const;
   
   //--- ATR Indicator Parameters Validation Checks
   bool IsATRIndicatorParametersValid(const int &InputPeriod) const;
   
   //--- Helper Functions: Parameters Validation Checks
   bool IsPeriodValid(const int &InputPeriod)                                         const;
   bool IsFastSlowPeriodValid(const int &InputFastPeriod, const int &InputSlowPeriod) const;
   bool IsParameterGreaterThanZero(const int &InputAnyParameter)                      const;
   bool IsParameterGreaterThanZero(const double &InputAnyParameter)                   const;
   bool IsPhaseValid(const int &InputPhase)                                         const;
   
   //--- OnTick Functions
   void UpdateAllIndicators(void);
   
   //--- Helper Functions: Get Approximate Past Tick Value
   double GetBidPrice(const int InputShift) const;
   double GetAskPrice(const int InputShift) const;
};

IndicatorProcessor *IndicatorProcessor::Instance = NULL;

#endif