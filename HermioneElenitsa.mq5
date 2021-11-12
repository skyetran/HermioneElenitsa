//+------------------------------------------------------------------+
//|                                             HermioneElenitsa.mq5 |
//|                                    Copyright 2021, Skye Leblanc. |
//|                        https://www.linkedin.com/in/skye-leblanc/ |
//+------------------------------------------------------------------+

#include "General/GlobalFunctions.mqh"
#include "General/IndicatorProcessor.mqh"
#include "Manager/TradeExecutor.mqh"
#include "Signal/SignalGenerator.mqh"

#define DEFAULT_ATR_MULTIPLIER   1
#define DEFAULT_MAGIC_NUMBER     264897654
#define DEFAULT_DEVIATION        5

extern string              Text1                            = "All Indicators Settings";
extern string              Text2                            = "Baseline Indicator Settings";
input  int                 SuperSmootherPeriod              = 20;

extern string              Text3                            = "Primary Indicator Settings";
input  int                 RSIPeriod                        = 14;
input  int                 RSISmoothingFactor               = 5;
input  double              QQEFastPeriod                    = 2.618;
input  double              QQESlowPeriod                    = 4.236;

extern string              Text4                            = "Secondary Indicator Settings";
input  int                 VortexPeriod                     = 10;

extern string              Text5                            = "Volume Indicator Settings";
input  int                 FastMACDPeriod                   = 20;
input  int                 SlowMACDPeriod                   = 40;
input  int                 BollingerPeriod                  = 20;
input  double              BollingerDeviation               = 2.0;
input  int                 Sensitive                        = 150;
input  int                 DeadZone                         = 2000;
input  int                 ExplosionPower                   = 15;
input  int                 TrendPower                       = 400;

input  int                 Viscosity                        = 7;
input  int                 Sedimentation                    = 25;
input  double              Threshold                        = 1.3;

extern string              Text6                            = "Exit Indicator Settings";
input  int                 JurikPeriod                      = 14;
input  int                 JurikPhase                       = 180;

extern string              Text7                            = "ATR Indicator Settings";
input  int                 ATRPeriod                        = 14;

extern string              Text8                            = "Continuous Indicator Settings";
input  int                 EhlerFisherContinuousPeriod      = 10;

extern string              Text9                            = "Flexible NNFX Trade Settings";
input  double              ATRMultiplier                    = 1.0;

extern string              Text10                            = "Expert Advisor Trade Settings";
input  int                 MagicNumber                      = 196735465;
input  int                 Deviation                        = 5;

//--- Global Variables
GlobalFunctions    *GF = GlobalFunctions::GetInstance();
IndicatorProcessor *IP = IndicatorProcessor::GetInstance();
SignalGenerator    *SG = SignalGenerator::GetInstance();
TradeExecutor      *TE = TradeExecutor::GetInstance();

int OnInit() {
   if (!InitIndicators()) {
      return INIT_FAILED;
   }
   return INIT_SUCCEEDED;
}

//--- Set Indicators' Parameters
bool InitIndicators(void) {
   if (IP.SetBaselineParameters(SuperSmootherPeriod)                                                                                                         &&
       IP.SetPrimaryConfirmationParameters(RSIPeriod, RSISmoothingFactor, QQEFastPeriod, QQESlowPeriod)                                                      &&
       IP.SetSecondaryConfirmationParameters(VortexPeriod)                                                                                                   &&
       IP.SetVolumeIndicatorParameters(FastMACDPeriod, SlowMACDPeriod, BollingerPeriod, BollingerDeviation, Sensitive, DeadZone, ExplosionPower, TrendPower) &&
       IP.SetSecondVolumeIndicatorParameters(Viscosity, Sedimentation, Threshold)                                                                            &&
       IP.SetExitIndicatorParameters(JurikPeriod, JurikPhase)                                                                                                &&
       IP.SetATRParameters(ATRPeriod)                                                                                                                        &&
       IP.SetContinuousParameters(EhlerFisherContinuousPeriod)                                                                                               ) {
      IP.Init();
      return true;
    }
    return false;
}

void OnTick() {
   Update();
   string DebugMsg;
   //DebugMsg += GF.GetDebugMsg() + "\n";
   DebugMsg += IP.GetDebugMsg() + "\n";
   //DebugMsg += SG.GetDebugMsg() + "\n";
   
   datetime Time[];
   double   Price[], PriceLag1[], PriceLag2[], PriceLag3[], PriceLag4[];
   double   Baseline[], BaselineLag1[], BaselineLag2[], BaselineLag3[], BaselineLag4[];
   double   PrimaryConfirmationValue[], PrimaryConfirmationValueLag1[], PrimaryConfirmationValueLag2[], PrimaryConfirmationValueLag3[], PrimaryConfirmationValueLag4[];
   double   PrimaryConfirmationDirecton[], PrimaryConfirmationDirectonLag1[], PrimaryConfirmationDirectonLag2[], PrimaryConfirmationDirectonLag3[], PrimaryConfirmationDirectonLag4[];
   double   SecondaryConfirmationValue1[], SecondaryConfirmationValue1Lag1[], SecondaryConfirmationValue1Lag2[], SecondaryConfirmationValue1Lag3[], SecondaryConfirmationValue1Lag4[];
   double   SecondaryConfirmationValue2[], SecondaryConfirmationValue2Lag1[], SecondaryConfirmationValue2Lag2[], SecondaryConfirmationValue2Lag3[], SecondaryConfirmationValue2Lag4[];
   double   VolumeValue[], VolumeValueLag1[], VolumeValueLag2[], VolumeValueLag3[], VolumeValueLag4[];
   double   VolumeDirection[], VolumeDirectionLag1[], VolumeDirectionLag2[], VolumeDirectionLag3[], VolumeDirectionLag4[];
   double   VolumeSignal[], VolumeSignalLag1[], VolumeSignalLag2[], VolumeSignalLag3[], VolumeSignalLag4[];
   double   ATRValue[], ATRValueLag1[], ATRValueLag2[], ATRValueLag3[], ATRValueLag4[];
   double   EntryPrice[], TakeProfit[], StopLoss[];
   
   ArrayResize(Time, 2000);
   ArrayResize(Price, 2000);
   ArrayResize(PriceLag1, 2000);
   ArrayResize(PriceLag2, 2000);
   ArrayResize(PriceLag3, 2000);
   ArrayResize(PriceLag4, 2000);
   ArrayResize(Baseline, 2000);
   ArrayResize(BaselineLag1, 2000);
   ArrayResize(BaselineLag2, 2000);
   ArrayResize(BaselineLag4, 2000);
   ArrayResize(PrimaryConfirmationValue, 2000);
   ArrayResize(PrimaryConfirmationValueLag1, 2000);
   ArrayResize(PrimaryConfirmationValueLag2, 2000);
   ArrayResize(PrimaryConfirmationValueLag3, 2000);
   ArrayResize(PrimaryConfirmationValueLag4, 2000);
   ArrayResize(PrimaryConfirmationDirecton, 2000);
   ArrayResize(PrimaryConfirmationDirectonLag1, 2000);
   ArrayResize(PrimaryConfirmationDirectonLag2, 2000);
   ArrayResize(PrimaryConfirmationDirectonLag3, 2000);
   ArrayResize(PrimaryConfirmationDirectonLag4, 2000);
   ArrayResize(SecondaryConfirmationValue1, 2000);
   ArrayResize(SecondaryConfirmationValue1Lag1, 2000);
   ArrayResize(SecondaryConfirmationValue1Lag2, 2000);
   ArrayResize(SecondaryConfirmationValue1Lag3, 2000);
   ArrayResize(SecondaryConfirmationValue1Lag4, 2000);
   ArrayResize(SecondaryConfirmationValue2, 2000);
   ArrayResize(SecondaryConfirmationValue2Lag1, 2000);
   ArrayResize(SecondaryConfirmationValue2Lag2, 2000);
   ArrayResize(SecondaryConfirmationValue2Lag3, 2000);
   ArrayResize(SecondaryConfirmationValue2Lag4, 2000);
   ArrayResize(VolumeValue, 2000);
   ArrayResize(VolumeValueLag1, 2000);
   ArrayResize(VolumeValueLag2, 2000);
   ArrayResize(VolumeValueLag3, 2000);
   ArrayResize(VolumeValueLag4, 2000);
   ArrayResize(VolumeDirection, 2000);
   ArrayResize(VolumeDirectionLag1, 2000);
   ArrayResize(VolumeDirectionLag2, 2000);
   ArrayResize(VolumeDirectionLag3, 2000);
   ArrayResize(VolumeSignalLag4, 2000);
   ArrayResize(VolumeSignal, 2000);
   ArrayResize(VolumeSignalLag1, 2000);
   ArrayResize(VolumeSignalLag2, 2000);
   ArrayResize(VolumeSignalLag3, 2000);
   ArrayResize(VolumeSignalLag4, 2000);
   ArrayResize(ATRValue, 2000);
   ArrayResize(ATRValueLag1, 2000);
   ArrayResize(ATRValueLag2, 2000);
   ArrayResize(ATRValueLag3, 2000);
   ArrayResize(ATRValueLag4, 2000);
   ArrayResize(EntryPrice, 2000);
   ArrayResize(TakeProfit, 2000);
   ArrayResize(StopLoss, 2000);
   
   static int i = 0;
   MqlTradeRequestWrapper *Request = SG.GetNextSignal();
   if (Request) {
      Time[i] = iTime(Symbol(), PERIOD_D1, CURRENT_BAR);
      Price[i] = IP.GetBidPrice(CURRENT_BAR);
      PriceLag1[i] = IP.GetBidPrice(CURRENT_BAR + 1);
      PriceLag2[i] = IP.GetBidPrice(CURRENT_BAR + 2);
      PriceLag3[i] = IP.GetBidPrice(CURRENT_BAR + 3);
      PriceLag4[i] = IP.GetBidPrice(CURRENT_BAR + 4);
      Baseline[i] = IP.GetBaselineValue(CURRENT_BAR);
      BaselineLag1[i] = IP.GetBaselineValue(CURRENT_BAR + 1);
      BaselineLag2[i] = IP.GetBaselineValue(CURRENT_BAR + 2);
      BaselineLag3[i] = IP.GetBaselineValue(CURRENT_BAR + 3);
      BaselineLag4[i] = IP.GetBaselineValue(CURRENT_BAR + 4);
      //PrimaryConfirmationValue[i] = IP.GetPri
      i++;
   }
   
   Comment(DebugMsg);
}

//--- Run Only Once --- OnInit Is Too Early For Some Functions
void PostInit(void) {
   static bool OnlyOnceFlag = true;
   if (OnlyOnceFlag) {
      OnlyOnceFlag = false;
      InitSignalGenerator();
      InitTradeExecutor();
   }
}

//--- Init Signal Generator's Parameters
void InitSignalGenerator(void) {
   if (!SG.SetATRMultiplier(ATRMultiplier)) {
      SG.SetATRMultiplier(DEFAULT_ATR_MULTIPLIER);
   }
}

//--- Init Trade Executor's Parameters
void InitTradeExecutor(void) {
   if (!TE.SetExpertAdvisorMagicNumber(MagicNumber) &&
       !TE.SetDeviation(Deviation)) {
      TE.SetExpertAdvisorMagicNumber(DEFAULT_MAGIC_NUMBER);
      TE.SetDeviation(DEFAULT_DEVIATION);   
   }
   TE.Init();
}

//--- Assemble All OnTick Functions From All Entities
void Update(void) {
   GF.Update();
   IP.Update();
   SG.Update();
   TE.Update();
}