#property strict

#include "../General/IndicatorProcessor.mqh"

//--- Main Constructor
IndicatorProcessor::IndicatorProcessor(void) {
   GF = GlobalFunctions::GetInstance();
   
   SymbolInfo.Name(Symbol());
   
   ArraySetAsSeries(SuperSmootherValueBuffer  , true);
   ArraySetAsSeries(EhlerFisherValueBuffer    , true);
   ArraySetAsSeries(EhlerFisherDirectionBuffer, true);
   ArraySetAsSeries(VortexBullishValueBuffer  , true);
   ArraySetAsSeries(VortexBearishValueBuffer  , true);
   ArraySetAsSeries(WAEVolumeValueBuffer      , true);
   ArraySetAsSeries(WAESignalValueBuffer      , true);
   ArraySetAsSeries(WAEDeathZoneBuffer        , true);
   ArraySetAsSeries(JurikFilterValueBuffer    , true);
   ArraySetAsSeries(JurikFilterDirectionBuffer, true);
   ArraySetAsSeries(ATRValueBuffer            , true);
   ArraySetAsSeries(OpenSpreadBuffer          , true);
   ArraySetAsSeries(HighSpreadBuffer          , true);
   ArraySetAsSeries(LowSpreadBuffer           , true);
   ArraySetAsSeries(CloseSpreadBuffer         , true);
   ArraySetAsSeries(AverageSpreadBuffer       , true);
}

//--- Get Singleton Instance
IndicatorProcessor *IndicatorProcessor::GetInstance(void) {
   if (!Instance) {
      Instance = new IndicatorProcessor();
   }
   return Instance;
}

//--- Debug Functions
string IndicatorProcessor::GetDebugMsg(void) const {
   string Msg = "";
   Msg += "Baseline Value: "                    + DoubleToString(GetBaselineValue(CURRENT_BAR))                  + "\n";
   Msg += "Is Above Baseline: "                 + (IsAboveBaseline(CURRENT_BAR) ? "Yes" : "No")                  + "\n";
   Msg += "Is Below Baseline: "                 + (IsBelowBaseline(CURRENT_BAR) ? "Yes" : "No")                  + "\n";
   Msg += "Is Primary Confirmation Bullish: "   + (IsPrimaryConfirmationBullish(CURRENT_BAR) ? "Yes" : "No")     + "\n";
   Msg += "Is Primary Confirmation Bearish: "   + (IsPrimaryConfirmationBearish(CURRENT_BAR) ? "Yes" : "No")     + "\n";
   Msg += "Is Secondary Confirmation Bullish: " + (IsSecondaryConfirmationBullish(CURRENT_BAR) ? "Yes" : "No")   + "\n";
   Msg += "Is Secondary Confirmation Bearish: " + (IsSecondaryConfirmationBearish(CURRENT_BAR) ? "Yes" : "No")   + "\n";
   Msg += "Is Dead Market: "                    + (IsDeadMarket(CURRENT_BAR) ? "Yes" : "No")                     + "\n";
   Msg += "Is Active Market: "                  + (IsActiveMarket(CURRENT_BAR) ? "Yes" : "No")                   + "\n";
   Msg += "Should Exit Long: "                  + (ShouldExitLongFromExitIndicator(CURRENT_BAR) ? "Yes" : "No")  + "\n";
   Msg += "Should Exit Short: "                 + (ShouldExitShortFromExitIndicator(CURRENT_BAR) ? "Yes" : "No") + "\n";
   Msg += "ATR Value: "                         + DoubleToString(GetATRValue(CURRENT_BAR))                       + "\n";
   Msg += "Close Spread: "                      + IntegerToString(GetCloseSpreadInPts(CURRENT_BAR))              + "\n";
   Msg += "Average Spread: "                    + IntegerToString(GetAverageSpreadInPts(CURRENT_BAR))            + "\n";
   Msg += "Average Spread In Price: "           + DoubleToString(GetAverageSpreadInPrice(CURRENT_BAR))           + "\n";
   return Msg;
}

//--- OnInit Functions
void IndicatorProcessor::Init(void) {
   BaselineHandle              = iCustom(SymbolInfo.Name(), PERIOD_D1, "twopolesupersmootherfilter", SuperSmootherPeriod);
   PrimaryConfirmationHandle   = iCustom(SymbolInfo.Name(), PERIOD_D1, "Ehlers Fisher transform (original)", EhlerFisherPeriod);
   SecondaryConfirmationHandle = iCustom(SymbolInfo.Name(), PERIOD_D1, "Vortex", VortexPeriod);
   VolumeHandle                = iCustom(SymbolInfo.Name(), PERIOD_D1, "waddah_attar_explosion", FastMACDPeriod, SlowMACDPeriod, BollingerPeriod, BollingerDeviation, Sensitive, DeathZone, ExplosionPower, TrendPower);
   ExitHandle                  = iCustom(SymbolInfo.Name(), PERIOD_D1, "jurik_filter", JurikPeriod, JurikPhase);
   ATRHandle                   = iCustom(SymbolInfo.Name(), PERIOD_D1, "Examples/ATR", ATRPeriod);
   SpreadHandle                = iCustom(SymbolInfo.Name(), PERIOD_D1, "Spread_Record");
}

//--- Setters --- OnInit Functions
bool IndicatorProcessor::SetBaselineParameters(const int &InputPeriod) {
   if (IsBaselineParametersValid(InputPeriod)) {
      SuperSmootherPeriod = InputPeriod;
      return true;
   }
   return false;
}

//--- Baseline Indicator Parameters Validation Checks
bool IndicatorProcessor::IsBaselineParametersValid(const int &InputPeriod) const { return IsPeriodValid(InputPeriod); }

//--- Setters --- OnInit Functions
bool IndicatorProcessor::SetPrimaryConfirmationParameters(const int &InputPeriod) {
   if (IsPrimaryConfirmationIndicatorParametersValid(InputPeriod)) {
      EhlerFisherPeriod = InputPeriod;
      return true;
   }
   return false;
}

//--- Primary Confirmation Indicator Parameters Validation Checks
bool IndicatorProcessor::IsPrimaryConfirmationIndicatorParametersValid(const int &InputPeriod) const { return IsPeriodValid(InputPeriod); }

//--- Setters --- OnInit Functions
bool IndicatorProcessor::SetSecondaryConfirmationParameters(const int &InputPeriod) {
   if (IsSecondaryConfirmationIndicatorParametersValid(InputPeriod)) {
      VortexPeriod = InputPeriod;
      return true;
   }
   return false;
}

//--- Secondary Confirmation Indicator Parameters Validation Checks
bool IndicatorProcessor::IsSecondaryConfirmationIndicatorParametersValid(const int &InputPeriod) const { return IsPeriodValid(InputPeriod); }

//--- Setters --- OnInit Functions
bool IndicatorProcessor::SetVolumeIndicatorParameters(const int &InputFastMACDPeriod, const int &InputSlowMACDPeriod,
                                                      const int &InputBollingerPeriod, const double &InputBollingerDeviation,
                                                      const int &InputSensitive, const int &InputDeadZone,
                                                      const int &InputExplosionPower, const int &InputTrendPower) {
   if (IsVolumeIndicatorParametersValid(InputFastMACDPeriod, InputSlowMACDPeriod, InputBollingerPeriod, InputBollingerDeviation,
                                        InputSensitive, InputDeadZone, InputExplosionPower, InputTrendPower)) {
      FastMACDPeriod     = InputFastMACDPeriod;
      SlowMACDPeriod     = InputSlowMACDPeriod;
      BollingerPeriod    = InputBollingerPeriod;
      BollingerDeviation = InputBollingerDeviation;
      Sensitive          = InputSensitive;
      DeathZone          = InputDeadZone;
      ExplosionPower     = InputExplosionPower;
      TrendPower         = InputTrendPower;
      return true;
   }
   return false;
}

//--- Volume Indicator Parameters Validation Checks
bool IndicatorProcessor::IsVolumeIndicatorParametersValid(const int &InputFastMACDPeriod, const int &InputSlowMACDPeriod,
                                                          const int &InputBollingerPeriod, const double &InputBollingerDeviation,
                                                          const int &InputSensitive, const int &InputDeadZone,
                                                          const int &InputExplosionPower, const int &InputTrendPower) const {
   return IsPeriodValid(InputFastMACDPeriod) && IsPeriodValid(InputSlowMACDPeriod) &&
          IsFastSlowPeriodValid(InputFastMACDPeriod, InputSlowMACDPeriod) &&
          IsPeriodValid(InputBollingerPeriod) && IsParameterGreaterThanZero(InputBollingerDeviation) &&
          IsParameterGreaterThanZero(InputSensitive) && IsParameterGreaterThanZero(InputExplosionPower) &&
          IsParameterGreaterThanZero(InputTrendPower);
}

//--- Setters --- OnInit Functions
bool IndicatorProcessor::SetExitIndicatorParameters(const int &InputPeriod, const int &InputPhase) {
   if (IsExitIndicatorParametersValid(InputPeriod, InputPhase)) {
      JurikPeriod = InputPeriod;
      JurikPhase  = InputPhase;
      return true;
   }
   return false;
}

//--- Exit Indicator Parameters Validation Checks
bool IndicatorProcessor::IsExitIndicatorParametersValid(const int &InputPeriod, const int &InputPhase) const {
   return IsPeriodValid(InputPeriod) && IsPhaseValid(InputPhase);
}

//--- Setters --- OnInit Functions
bool IndicatorProcessor::SetATRParameters(const int &InputPeriod) {
   if (IsATRIndicatorParametersValid(InputPeriod)) {
      ATRPeriod = InputPeriod;
      return true;
   }
   return false;
}

//--- ATR Indicator Parameters Validation Checks
bool IndicatorProcessor::IsATRIndicatorParametersValid(const int &InputPeriod) const { return IsPeriodValid(InputPeriod); }

//--- Helper Functions: Parameters Validation Checks
bool IndicatorProcessor::IsPeriodValid(const int &InputPeriod)                                         const { return InputPeriod >= MIN_PERIOD;                             }
bool IndicatorProcessor::IsFastSlowPeriodValid(const int &InputFastPeriod, const int &InputSlowPeriod) const { return InputFastPeriod < InputSlowPeriod;                     }
bool IndicatorProcessor::IsParameterGreaterThanZero(const int &InputAnyParameter)                      const { return InputAnyParameter > ZERO;                              }
bool IndicatorProcessor::IsParameterGreaterThanZero(const double &InputAnyParameter)                   const { return InputAnyParameter > ZERO;                              }
bool IndicatorProcessor::IsPhaseValid(const int &InputPhase)                                           const { return MIN_PHASE <= InputPhase && InputPhase <= MAX_PHASE;    }

//--- OnTick Functions
void IndicatorProcessor::Update(void) {
   UpdateAllIndicators();
   SymbolInfo.Refresh();
   SymbolInfo.RefreshRates();
}

//--- OnTick Functions
void IndicatorProcessor::UpdateAllIndicators(void) {
   CopyBuffer(BaselineHandle             , SUPER_SMOOTHER_VALUE_BUFFER  , 0, INDICATOR_BUFFER_SIZE, SuperSmootherValueBuffer);
   CopyBuffer(PrimaryConfirmationHandle  , EHLER_FISHER_VALUE_BUFFER    , 0, INDICATOR_BUFFER_SIZE, EhlerFisherValueBuffer);
   CopyBuffer(PrimaryConfirmationHandle  , EHLER_FISHER_DIRECTION_BUFFER, 0, INDICATOR_BUFFER_SIZE, EhlerFisherDirectionBuffer);
   CopyBuffer(SecondaryConfirmationHandle, VORTEX_BULLISH_VALUE_BUFFER  , 0, INDICATOR_BUFFER_SIZE, VortexBullishValueBuffer);
   CopyBuffer(SecondaryConfirmationHandle, VORTEX_BEARISH_VALUE_BUFFER  , 0, INDICATOR_BUFFER_SIZE, VortexBearishValueBuffer);
   CopyBuffer(VolumeHandle               , WAE_VOLUME_VALUE_BUFFER      , 0, INDICATOR_BUFFER_SIZE, WAEVolumeValueBuffer);
   CopyBuffer(VolumeHandle               , WAE_SIGNAL_LINE_BUFFER       , 0, INDICATOR_BUFFER_SIZE, WAESignalValueBuffer);
   CopyBuffer(VolumeHandle               , WAE_DEATH_ZONE_BUFFER        , 0, INDICATOR_BUFFER_SIZE, WAEDeathZoneBuffer);
   CopyBuffer(ExitHandle                 , JURIK_FILTER_VALUE_BUFFER    , 0, INDICATOR_BUFFER_SIZE, JurikFilterValueBuffer);
   CopyBuffer(ExitHandle                 , JURIK_FILTER_DIRECTION_BUFFER, 0, INDICATOR_BUFFER_SIZE, JurikFilterDirectionBuffer);
   CopyBuffer(ATRHandle                  , ATR_VALUE_BUFFER             , 0, INDICATOR_BUFFER_SIZE, ATRValueBuffer);
   CopyBuffer(SpreadHandle               , OPEN_SPREAD_BUFFER           , 0, INDICATOR_BUFFER_SIZE, OpenSpreadBuffer);
   CopyBuffer(SpreadHandle               , HIGH_SPREAD_BUFFER           , 0, INDICATOR_BUFFER_SIZE, HighSpreadBuffer);
   CopyBuffer(SpreadHandle               , LOW_SPREAD_BUFFER            , 0, INDICATOR_BUFFER_SIZE, LowSpreadBuffer);
   CopyBuffer(SpreadHandle               , CLOSE_SPREAD_BUFFER          , 0, INDICATOR_BUFFER_SIZE, CloseSpreadBuffer);
   CopyBuffer(SpreadHandle               , AVERAGE_SPREAD_BUFFER        , 0, INDICATOR_BUFFER_SIZE, AverageSpreadBuffer);
}

//--- Getters --- Baseline Indicator
bool IndicatorProcessor::HasCandleCrossedBaseline(const int InputShift) const {
   return HasCandleCrossedBaselineFromAbove(InputShift) || HasCandleCrossedBaselineFromBelow(InputShift);
}

//--- Getters --- Baseline Indicator
bool IndicatorProcessor::HasCandleCrossedBaselineFromAbove(const int InputShift) const {
   return HasCandleCrossedBaselineFromAboveRegularCase(InputShift) || HasCandleCrossedBaselineFromAbovePriceGapCase(InputShift);
}

//--- Helper Functions: HasCandleCrossedBaselineFromAbove
bool IndicatorProcessor::HasCandleCrossedBaselineFromAboveRegularCase(const int InputShift) const {
   return GetBaselineValue(InputShift) <= iOpen( SymbolInfo.Name(), PERIOD_D1, InputShift) &&
          GetBaselineValue(InputShift) >= GetBidPrice(InputShift)                          ;
}

//--- Helper Functions: HasCandleCrossedBaselineFromAbove
bool IndicatorProcessor::HasCandleCrossedBaselineFromAbovePriceGapCase(const int InputShift) const {
   return GetBaselineValue(InputShift + 1) <= iClose(SymbolInfo.Name(), PERIOD_D1, InputShift + 1) &&
          GetBaselineValue(InputShift)     >  iOpen( SymbolInfo.Name(), PERIOD_D1, InputShift)     ;
}

//--- Getters --- Baseline Indicator
bool IndicatorProcessor::HasCandleCrossedBaselineFromBelow(const int InputShift) const {
   return HasCandleCrossedBaselineFromBelowRegularCase(InputShift) || HasCandleCrossedBaselineFromBelowPriceGapCase(InputShift);
}

//--- Helper Functions: HasCandleCrossedBaselineFromBelow
bool IndicatorProcessor::HasCandleCrossedBaselineFromBelowRegularCase(const int InputShift) const {
   return GetBaselineValue(InputShift) >= iOpen(SymbolInfo.Name(), PERIOD_D1, InputShift) &&
          GetBaselineValue(InputShift) <= GetAskPrice(InputShift)                         ;
}

//--- Helper Functions: HasCandleCrossedBaselineFromBelow
bool IndicatorProcessor::HasCandleCrossedBaselineFromBelowPriceGapCase(const int InputShift) const {
   return GetBaselineValue(InputShift + 1) >= iClose(SymbolInfo.Name(), PERIOD_D1, InputShift + 1) &&
          GetBaselineValue(InputShift)     <  iOpen( SymbolInfo.Name(), PERIOD_D1, InputShift)     ;
}

//--- Getters --- Baseline Indicator
bool   IndicatorProcessor::IsAboveBaseline(const int InputShift)  const { return GetAskPrice(InputShift) > GetBaselineValue(InputShift);                     }
bool   IndicatorProcessor::IsBelowBaseline(const int InputShift)  const { return GetBidPrice(InputShift) < GetBaselineValue(InputShift);                     }
double IndicatorProcessor::GetBaselineValue(const int InputShift) const { return NormalizeDouble(SuperSmootherValueBuffer[InputShift], SymbolInfo.Digits()); }

//--- Getters --- Primary Confirmation Indicator
double IndicatorProcessor::GetPrimaryConfirmationBullishValue(const int InputShift) const { return IsPrimaryConfirmationBullish(InputShift) ? GetPrimaryConfirmationValue(InputShift) : 0; }
double IndicatorProcessor::GetPrimaryConfirmationBearishValue(const int InputShift) const { return IsPrimaryConfirmationBearish(InputShift) ? GetPrimaryConfirmationValue(InputShift) : 0; }
double IndicatorProcessor::GetPrimaryConfirmationValue(const int InputShift)        const { return NormalizeDouble(EhlerFisherValueBuffer[InputShift], SymbolInfo.Digits());               }
double IndicatorProcessor::GetPrimaryConfirmationDirection(const int InputShift)    const { return EhlerFisherDirectionBuffer[InputShift];                                                 }
bool   IndicatorProcessor::IsPrimaryConfirmationBullish(const int InputShift)       const { return GetPrimaryConfirmationDirection(InputShift) == EHLER_FISHER_BULLISH_DIRECTION;          }
bool   IndicatorProcessor::IsPrimaryConfirmationBearish(const int InputShift)       const { return GetPrimaryConfirmationDirection(InputShift) == EHLER_FISHER_BEARISH_DIRECTION;          }

//--- Getters --- Secondary Confirmation Indicator
bool   IndicatorProcessor::IsSecondaryConfirmationBullish(const int InputShift)       const { return GetSecondaryConfirmationBullishValue(InputShift) > GetSecondaryConfirmationBearishValue(InputShift); }
bool   IndicatorProcessor::IsSecondaryConfirmationBearish(const int InputShift)       const { return GetSecondaryConfirmationBullishValue(InputShift) < GetSecondaryConfirmationBearishValue(InputShift); }
double IndicatorProcessor::GetSecondaryConfirmationBullishValue(const int InputShift) const { return NormalizeDouble(VortexBullishValueBuffer[InputShift], SymbolInfo.Digits());                          }
double IndicatorProcessor::GetSecondaryConfirmationBearishValue(const int InputShift) const { return NormalizeDouble(VortexBearishValueBuffer[InputShift], SymbolInfo.Digits());                          }

//--- Getters --- Volume Indicator
bool   IndicatorProcessor::IsDeadMarket(const int InputShift)      const { return !IsActiveMarket(InputShift);                                                                                              }
bool   IndicatorProcessor::IsActiveMarket(const int InputShift)    const { return GetVolumeValue(InputShift) >= GetWAESignalValue(InputShift) && GetVolumeValue(InputShift) >= GetWAEDeathZone(InputShift); }
double IndicatorProcessor::GetVolumeValue(const int InputShift)    const { return NormalizeDouble(WAEVolumeValueBuffer[InputShift], SymbolInfo.Digits());                                                   }
double IndicatorProcessor::GetWAESignalValue(const int InputShift) const { return NormalizeDouble(WAESignalValueBuffer[InputShift], SymbolInfo.Digits());                                                   }
double IndicatorProcessor::GetWAEDeathZone(const int InputShift)   const { return NormalizeDouble(WAEDeathZoneBuffer[InputShift]  , SymbolInfo.Digits());                                                   }

//--- Getters --- Exit Indicator
bool   IndicatorProcessor::ShouldExitLongFromExitIndicator(const int InputShift)      const { return IsExitBearish(InputShift);                                                    }
bool   IndicatorProcessor::ShouldExitShortFromExitIndicator(const int InputShift)     const { return IsExitBullish(InputShift);                                                    }
double IndicatorProcessor::GetExitBullishValue(const int InputShift) const { return IsExitBullish(InputShift) ? GetExitValue(InputShift) : 0;                     }
double IndicatorProcessor::GetExitBearishValue(const int InputShift) const { return IsExitBearish(InputShift) ? GetExitValue(InputShift) : 0;                     }
double IndicatorProcessor::GetExitValue(const int InputShift)        const { return NormalizeDouble(JurikFilterValueBuffer[InputShift], SymbolInfo.Digits());     }
double IndicatorProcessor::GetExitDirection(const int InputShift)    const { return JurikFilterDirectionBuffer[InputShift];                                       }
bool   IndicatorProcessor::IsExitBullish(const int InputShift)       const { return GetExitDirection(InputShift) == JURIK_BULLISH_DIRECTION;                      }
bool   IndicatorProcessor::IsExitBearish(const int InputShift)       const { return GetExitDirection(InputShift) == JURIK_BEARISH_DIRECTION;                      }

//--- Getters --- ATR Indicator
double IndicatorProcessor::GetATRValue(const int InputShift)                                const { return NormalizeDouble(ATRValueBuffer[InputShift]                  , SymbolInfo.Digits()); }
double IndicatorProcessor::GetXATRValue(const int InputShift, const double InputMultiplier) const { return NormalizeDouble(ATRValueBuffer[InputShift] * InputMultiplier, SymbolInfo.Digits()); }

//--- Getters --- ATR Indicator
bool IndicatorProcessor::IsWithInOneXATRValue(const int InputShift)  const { return IsWithInXATRValue(InputShift, 1.0);  }
bool IndicatorProcessor::IsOutsideOneXATRValue(const int InputShift) const { return IsOutsideXATRValue(InputShift, 1.0); }

//--- Getters --- ATR Indicator
bool IndicatorProcessor::IsWithInXATRValue(const int InputShift, const double InputMultiplier) const {
   if (IsAboveBaseline(InputShift)) {
      return GetAskPrice(InputShift) <= GetXATRUpderBand(InputShift, InputMultiplier);
   }
   if (IsBelowBaseline(InputShift)) {
      return GetBidPrice(InputShift) >= GetXATRLowerBand(InputShift, InputMultiplier);
   }
   return false;
}

//--- Getters --- ATR Indicator
bool IndicatorProcessor::IsOutsideXATRValue(const int InputShift, const double InputMultiplier) const {
   if (IsAboveBaseline(InputShift)) {
      return GetAskPrice(InputShift) > GetXATRUpderBand(InputShift, InputMultiplier);
   }
   if (IsBelowBaseline(InputShift)) {
      return GetBidPrice(InputShift) < GetXATRLowerBand(InputShift, InputMultiplier);
   }
   return false;
}

//--- Getters --- ATR Indicator
double IndicatorProcessor::GetZeroPointFiveXATRValueInPrice(const int InputShift)                  const { return GetXATRValueInPrice(InputShift, 0.5);                                            }
double IndicatorProcessor::GetOneXATRValueInPrice(const int InputShift)                            const { return GetXATRValueInPrice(InputShift, 1.0);                                            }
double IndicatorProcessor::GetOnePointFiveXATRValueInPrice(const int InputShift)                   const { return GetXATRValueInPrice(InputShift, 1.5);                                            }
double IndicatorProcessor::GetTwoXATRValueInPrice(const int InputShift)                            const { return GetXATRValueInPrice(InputShift, 2.0);                                            }
double IndicatorProcessor::GetXATRValueInPrice(const int InputShift, const double InputMultiplier) const { return NormalizeDouble(GetXATRValue(InputShift, InputMultiplier), SymbolInfo.Digits()); }

//--- Getters --- ATR Indicator
int IndicatorProcessor::GetZeroPointFiveXATRValueInPoint(const int InputShift)                  const { return GetXATRValueInPoint(InputShift, 0.5);                                 }
int IndicatorProcessor::GetOneXATRValueInPoint(const int InputShift)                            const { return GetXATRValueInPoint(InputShift, 1.0);                                 }
int IndicatorProcessor::GetOnePointFiveXATRValueInPoint(const int InputShift)                   const { return GetXATRValueInPoint(InputShift, 1.5);                                 }
int IndicatorProcessor::GetTwoXATRValueInPoint(const int InputShift)                            const { return GetXATRValueInPoint(InputShift, 2.0);                                 }
int IndicatorProcessor::GetXATRValueInPoint(const int InputShift, const double InputMultiplier) const { return GF.PriceToPointCvt(GetXATRValueInPrice(InputShift, InputMultiplier)); }

//--- Helper Functions: Get 1X ATR Band
double IndicatorProcessor::GetOneXATRUpperBand(const int InputShift) const { return GetXATRUpderBand(InputShift, 1.0); }
double IndicatorProcessor::GetOneXATRLowerBand(const int InputShift) const { return GetXATRLowerBand(InputShift, 1.0); }

//--- Helper Functions: Get X ATR Band
double IndicatorProcessor::GetXATRUpderBand(const int InputShift, const double InputMultiplier) const { return GetBaselineValue(InputShift) + GetXATRValue(InputShift, InputMultiplier); }
double IndicatorProcessor::GetXATRLowerBand(const int InputShift, const double InputMultiplier) const { return GetBaselineValue(InputShift) - GetXATRValue(InputShift, InputMultiplier); }

//--- Getters --- Spread Indicator
int IndicatorProcessor::GetOpenSpreadInPts(const int InputShift)    const { return (int) (OpenSpreadBuffer[InputShift]);            }
int IndicatorProcessor::GetHighSpreadInPts(const int InputShift)    const { return (int) (HighSpreadBuffer[InputShift]);            }
int IndicatorProcessor::GetLowSpreadInPts(const int InputShift)     const { return (int) (LowSpreadBuffer[InputShift]);             }
int IndicatorProcessor::GetCloseSpreadInPts(const int InputShift)   const { return (int) (CloseSpreadBuffer[InputShift]);           }
int IndicatorProcessor::GetAverageSpreadInPts(const int InputShift) const { return (int) MathCeil(AverageSpreadBuffer[InputShift]); }

//--- Getters --- Spread Indicator
double IndicatorProcessor::GetOpenSpreadInPrice(const int InputShift)    const { return GF.PointToPriceCvt(GetOpenSpreadInPts(InputShift));    }
double IndicatorProcessor::GetHighSpreadInPrice(const int InputShift)    const { return GF.PointToPriceCvt(GetHighSpreadInPts(InputShift));    }
double IndicatorProcessor::GetLowSpreadInPrice(const int InputShift)     const { return GF.PointToPriceCvt(GetLowSpreadInPts(InputShift));     }
double IndicatorProcessor::GetCloseSpreadInPrice(const int InputShift)   const { return GF.PointToPriceCvt(GetCloseSpreadInPts(InputShift));   }
double IndicatorProcessor::GetAverageSpreadInPrice(const int InputShift) const { return GF.PointToPriceCvt(GetAverageSpreadInPts(InputShift)); }

//--- Getters --- Approximate Past Tick Value
double IndicatorProcessor::GetBidPrice(const int InputShift) const {
   if (InputShift == CURRENT_BAR) {
      return SymbolInfo.Bid();
   }
   return iClose(SymbolInfo.Name(), PERIOD_D1, InputShift);
}

//--- Getters --- Approximate Past Tick Value
double IndicatorProcessor::GetAskPrice(const int InputShift) const {
   if (InputShift == CURRENT_BAR) {
      return SymbolInfo.Ask();
   }
   return NormalizeDouble(iClose(SymbolInfo.Name(), PERIOD_D1, InputShift) + GetAverageSpreadInPrice(InputShift), SymbolInfo.Digits());
}