#ifndef INDICATOR_PROCESSOR_H
#define INDICATOR_PROCESSOR_H

#include <Trade\SymbolInfo.mqh>

#include "GlobalConstants.mqh"
#include "GlobalFunctions.mqh"

//--- Base Line Indicator
#define SUPER_SMOOTHER_VALUE_BUFFER          0

//--- Primary Confirmation Indicator
#define EHLER_FISHER_VALUE_BUFFER            0
#define EHLER_FISHER_DIRECTION_BUFFER        1

//--- Secondary Confirmation Indicator
#define VORTEX_BULLISH_VALUE_BUFFER          0
#define VORTEX_BEARISH_VALUE_BUFFER          1

//--- Volume Indicator
#define DAMIANI_VOLATMETER_TREND_BUFFER      0
#define DAMIANI_VOLATMETER_RANGE_BUFFER      1

//--- Exit Indicator
#define JURIK_FILTER_VALUE_BUFFER            0
#define JURIK_FILTER_DIRECTION_BUFFER        1

//--- ATR Indicator
#define ATR_VALUE_BUFFER                     0

//--- Continuous Indicator
#define EHLER_FISHER_CONT_VALUE_BUFFER       0
#define EHLER_FISHER_CONT_DIRECTION_BUFFER   1

//--- Spread Indicator
#define OPEN_SPREAD_BUFFER                   0
#define HIGH_SPREAD_BUFFER                   1
#define LOW_SPREAD_BUFFER                    2
#define CLOSE_SPREAD_BUFFER                  3
#define AVERAGE_SPREAD_BUFFER                4

//--- Parameters Bound
#define MIN_PERIOD                           2
#define ZERO                                 0
#define MIN_PHASE                            0
#define MAX_PHASE                            359

//--- Buffer Boundary
#define INDICATOR_BUFFER_SIZE                8

//--- Ehler Fisher Constants
#define EHLER_FISHER_BULLISH_DIRECTION       1
#define EHLER_FISHER_BEARISH_DIRECTION       2

//--- Jurik Filter Constants
#define JURIK_BULLISH_DIRECTION              0
#define JURIK_BEARISH_DIRECTION              1

class IndicatorProcessor
{
public:
   //--- Get Singleton Instance
   static IndicatorProcessor *GetInstance(void);
   
   //--- Debug Functions
   string GetDebugMsg(void) const;
   
   //--- OnInit Functions
   void Init(void);
   
   //--- Setters --- OnInit Functions
   bool SetBaselineParameters(const int &InputPeriod);
   bool SetPrimaryConfirmationParameters(const int &InputPeriod);
   bool SetSecondaryConfirmationParameters(const int &InputPeriod);
   bool SetVolumeIndicatorParameters(const int &InputVisosity, const int &InputSedimentation, const double &InputThreshold);
   bool SetExitIndicatorParameters(const int &InputPeriod, const int &InputPhase);
   bool SetATRParameters(const int &InputPeriod);
   bool SetContinuousParameters(const int &InputPeriod);

   //--- OnTick Functions
   void Update(void);
   
   //--- Getters --- Baseline Indicator
   bool   HasCandleCrossedBaseline(const int InputShift)          const;
   bool   HasCandleCrossedBaselineFromAbove(const int InputShift) const;
   bool   HasCandleCrossedBaselineFromBelow(const int InputShift) const;
   double GetBaselineValue(const int InputShift)                  const;
   bool   IsAboveBaseline(const int InputShift)                   const;
   bool   IsBelowBaseline(const int InputShift)                   const;
   
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
   bool   IsDeadMarket(const int InputShift)        const;
   bool   IsActiveMarket(const int InputShift)      const;
   double GetVolumeTrendValue(const int InputShift) const;
   double GetVolumeRangeValue(const int InputShift) const;
   
   //--- Getters --- Exit Indicator
   bool   ShouldExitLongFromExitIndicator(const int InputShift)  const;
   bool   ShouldExitShortFromExitIndicator(const int InputShift) const;
   double GetExitBullishValue(const int InputShift)              const;
   double GetExitBearishValue(const int InputShift)              const;
   double GetExitValue(const int InputShift)                     const;
   double GetExitDirection(const int InputShift)                 const;
   bool   IsExitBullish(const int InputShift)                    const;
   bool   IsExitBearish(const int InputShift)                    const;
   
   //--- Getters --- ATR Indicator
   double GetATRValue(const int InputShift)                                const;
   double GetXATRValue(const int InputShift, const double InputMultiplier) const;
   
   bool IsWithInOneXATRValue(const int InputShift)  const;
   bool IsOutsideOneXATRValue(const int InputShift) const;
   
   bool IsWithInXATRValue(const int InputShift, const double InputMultiplier)  const;
   bool IsOutsideXATRValue(const int InputShift, const double InputMultiplier) const;
   
   double GetZeroPointFiveXATRValueInPrice(const int InputShift)                  const;
   double GetOneXATRValueInPrice(const int InputShift)                            const;
   double GetOnePointFiveXATRValueInPrice(const int InputShift)                   const;
   double GetTwoXATRValueInPrice(const int InputShift)                            const;
   double GetXATRValueInPrice(const int InputShift, const double InputMultiplier) const;
   
   int GetZeroPointFiveXATRValueInPoint(const int InputShift)                  const;
   int GetOneXATRValueInPoint(const int InputShift)                            const;
   int GetOnePointFiveXATRValueInPoint(const int InputShift)                   const;
   int GetTwoXATRValueInPoint(const int InputShift)                            const;
   int GetXATRValueInPoint(const int InputShift, const double InputMultiplier) const;
   
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
   
   //--- Getters --- Continuous Indicator
   double GetContinuousBullishValue(const int InputShift) const;
   double GetContinuousBearishValue(const int InputShift) const;
   double GetContinuousValue(const int InputShift)        const;
   double GetContinuousDirection(const int InputShift)    const;
   bool   IsContinuousBullish(const int InputShift)       const;
   bool   IsContinuousBearish(const int InputShift)       const;
   
   //--- Getters --- Approximate Past Tick Value
   double GetBidPrice(const int InputShift) const;
   double GetAskPrice(const int InputShift) const;
   
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
   int ContinuousHandle;
   
   //--- Indicator Buffers
   double SuperSmootherValueBuffer[];
   double EhlerFisherValueBuffer[], EhlerFisherDirectionBuffer[];
   double VortexBullishValueBuffer[], VortexBearishValueBuffer[];
   double VolumeTrendValueBuffer[], VolumeRangeValueBuffer[];
   double JurikFilterValueBuffer[], JurikFilterDirectionBuffer[];
   double ATRValueBuffer[];
   double OpenSpreadBuffer[], HighSpreadBuffer[], LowSpreadBuffer[], CloseSpreadBuffer[], AverageSpreadBuffer[];
   double EhlerFisherContinuousValueBuffer[], EhlerFisherContinuousDirectionBuffer[];
   
   //--- Baseline Indicator Parameters
   int SuperSmootherPeriod;
   
   //--- Primary Confirmation Parameters
   int EhlerFisherPeriod;
   
   //--- Secondary Confirmation Indicator Parameters
   int VortexPeriod;
   
   //--- Volume Indicator Parameters
   int    Viscosity, Sedimentation;
   double Threshold;
   
   //--- Exit Indicator Parameters
   int JurikPeriod, JurikPhase;
   
   //--- ATR Indicator Parameters
   int ATRPeriod;
   
   //--- Continuous Parameters
   int EhlerFisherContinuousPeriod;
   
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
   bool IsVolumeIndicatorParametersValid(const int &InputViscosity, const int &InputSedimentation, const double &InputThreshold) const;
   
   //--- Exit Indicator Parameters Validation Checks
   bool IsExitIndicatorParametersValid(const int &InputPeriod, const int &InputPhase) const;
   
   //--- ATR Indicator Parameters Validation Checks
   bool IsATRIndicatorParametersValid(const int &InputPeriod) const;
   
   //--- Continuous Indicator Parameters Validation Checks
   bool IsContinuousIndicatorParametersValid(const int &InputPeriod) const;
   
   //--- Helper Functions: Parameters Validation Checks
   bool IsPeriodValid(const int &InputPeriod)                                         const;
   bool IsFastSlowPeriodValid(const int &InputFastPeriod, const int &InputSlowPeriod) const;
   bool IsParameterGreaterThanZero(const int &InputAnyParameter)                      const;
   bool IsParameterGreaterThanZero(const double &InputAnyParameter)                   const;
   bool IsPhaseValid(const int &InputPhase)                                           const;
   
   //--- OnTick Functions
   void UpdateAllIndicators(void);
   
   //--- Helper Functions: HasCandleCrossedBaselineFromAbove
   bool HasCandleCrossedBaselineFromAboveNaiveCase(const int InputShift)    const;
   bool HasCandleCrossedBaselineFromAboveRegularCase(const int InputShift)  const;
   bool HasCandleCrossedBaselineFromAbovePriceGapCase(const int InputShift) const;
   
   //--- Helper Functions: HasCandleCrossedBaselineFromBelow
   bool HasCandleCrossedBaselineFromBelowNaiveCase(const int InputShift)    const;
   bool HasCandleCrossedBaselineFromBelowRegularCase(const int InputShift)  const;
   bool HasCandleCrossedBaselineFromBelowPriceGapCase(const int InputShift) const;
   
   //--- Helper Functions: Get 1X ATR Band
   double GetOneXATRUpperBand(const int InputShift) const;
   double GetOneXATRLowerBand(const int InputShift) const;
   
   //--- Helper Functions: Get X ATR Band
   double GetXATRUpderBand(const int InputShift, const double InputMultiplier) const;
   double GetXATRLowerBand(const int InputShift, const double InputMultiplier) const;
};

IndicatorProcessor *IndicatorProcessor::Instance = NULL;

#endif