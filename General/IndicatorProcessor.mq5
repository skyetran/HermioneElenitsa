#property strict

#include "../General/IndicatorProcessor.mqh"

//--- Main Constructor
IndicatorProcessor::IndicatorProcessor(void) {
   SymbolInfo.Name(Symbol());
   
   ArraySetAsSeries(SuperSmootherValueBuffer  , true);
   ArraySetAsSeries(SchaffValueBuffer         , true);
   ArraySetAsSeries(SchaffDirectionBuffer     , true);
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
string IndicatorProcessor::GetDebugMsg(void) {
   string Msg = "";
   
   return Msg;
}

//--- OnInit Functions
void IndicatorProcessor::InitAllIndicators(void) {
   BaselineHandle              = iCustom(SymbolInfo.Name(), Period(), "twopolesupersmootherfilter", SuperSmootherPeriod);
   PrimaryConfirmationHandle   = iCustom(SymbolInfo.Name(), Period(), "Scaff Trend Cycle", SchaffPeriod, FastEMAPeriod, SlowEMAPeriod, SmoothingPeriod);
   SecondaryConfirmationHandle = iCustom(SymbolInfo.Name(), Period(), "Vortex", VortexPeriod);
   VolumeHandle                = iCustom(SymbolInfo.Name(), Period(), "Waddah Attar Explosion", FastMACDPeriod, SlowMACDPeriod, BollingerPeriod, BollingerDeviation, Sensitive, DeathZone, ExplosionPower, TrendPower);
   ExitHandle                  = iCustom(SymbolInfo.Name(), Period(), "jurik_filter", JurikPeriod, JurikPhase);
   ATRHandle                   = iCustom(SymbolInfo.Name(), Period(), "ATR", ATRPeriod);
   SpreadHandle                = iCustom(SymbolInfo.Name(), Period(), "Spread_Record");
}

//--- Setters --- OnInit Functions
bool IndicatorProcessor::SetBaselineParameters(const int &InputPeriod) {
   if (IsBaselineParametersValid(InputPeriod)) {
      SuperSmootherPeriod = InputPeriod;
      return true;
   }
   return false;
}

//--- Setters --- OnInit Functions
bool IndicatorProcessor::SetPrimaryConfirmationParameters(const int &InputSchaffPeriod, const int &InputFastEMAPeriod, const int &InputSlowEMAPeriod, const int &InputSmoothingPeriod) {
   if (IsPrimaryConfirmationIndicatorParametersValid(InputSchaffPeriod, InputFastEMAPeriod, InputSlowEMAPeriod, InputSmoothingPeriod)) {
      SchaffPeriod    = InputSchaffPeriod;
      FastEMAPeriod   = InputFastEMAPeriod;
      SlowEMAPeriod   = InputSlowEMAPeriod;
      SmoothingPeriod = InputSmoothingPeriod;
      return true;
   }
   return false;
}

//--- Setters --- OnInit Functions
bool IndicatorProcessor::SetSecondaryConfirmationParameters(const int &InputPeriod) {
   if (IsSecondaryConfirmationIndicatorParametersValid(InputPeriod)) {
      VortexPeriod = InputPeriod;
      return true;
   }
   return false;
}

//--- Setters --- OnInit Functions
bool IndicatorProcessor::SetVolumeIndicatorParameters(const int &InputFastMACDPeriod, const int &InputSlowMACDPeriod, const int &InputBollingerPeriod, const double &InputBollingerDeviation, const int &InputSensitive, const int &InputDeadZone, const int &InputExplosionPower, const int &InputTrendPower) {
   if (IsVolumeIndicatorParametersValid(InputFastMACDPeriod, InputSlowMACDPeriod, InputBollingerPeriod, InputBollingerDeviation, InputSensitive, InputDeadZone, InputExplosionPower, InputTrendPower)) {
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

//--- Setters --- OnInit Functions
bool IndicatorProcessor::SetExitIndicatorParameters(const int &InputPeriod, const int &InputPhase) {
   if (IsExitIndicatorParametersValid(InputPeriod, InputPhase)) {
      JurikPeriod = InputPeriod;
      JurikPhase  = InputPhase;
      return true;
   }
   return false;
}

//--- Setters --- OnInit Functinos
bool IndicatorProcessor::SetATRParameters(const int &InputPeriod) {
   if (IsATRIndicatorParametersValid(InputPeriod)) {
      ATRPeriod = InputPeriod;
      return true;
   }
   return false;
}

//--- OnTick Functinos
void IndicatorProcessor::UpdateAllIndicators(void) {
   CopyBuffer(BaselineHandle             , SUPER_SMOOTHER_VALUE_BUFFER  , 0, INDICATOR_BUFFER_SIZE, SuperSmootherValueBuffer);
   CopyBuffer(PrimaryConfirmationHandle  , SCHAFF_VALUE_BUFFER          , 0, INDICATOR_BUFFER_SIZE, SchaffValueBuffer);
   CopyBuffer(PrimaryConfirmationHandle  , SCHAFF_DIRECTION_BUFFER      , 0, INDICATOR_BUFFER_SIZE, SchaffDirectionBuffer);
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