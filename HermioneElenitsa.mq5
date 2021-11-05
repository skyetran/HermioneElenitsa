//+------------------------------------------------------------------+
//|                                             HermioneElenitsa.mq5 |
//|                                    Copyright 2021, Skye Leblanc. |
//|                        https://www.linkedin.com/in/skye-leblanc/ |
//+------------------------------------------------------------------+

#include "General/GlobalFunctions.mqh"
#include "General/IndicatorProcessor.mqh"

extern string              Text1                            = "All Indicators Settings";
extern string              Text2                            = "Baseline Indicator Settings";
input  int                 SuperSmootherPeriod              = 20;

extern string              Text3                            = "Primary Indicator Settings";
input  int                 EhlerFisherPeriod                = 32;

extern string              Text4                            = "Secondary Indicator Settings";
input  int                 VortexPeriod                     = 7;

extern string              Text5                            = "Volume Indicator Settings";
input  int                 FastMACDPeriod                   = 20;
input  int                 SlowMACDPeriod                   = 40;
input  int                 BollingerPeriod                  = 20;
input  double              BollingerDeviation               = 2.0;
input  int                 Sensitive                        = 150;
input  int                 DeadZone                         = 2000;
input  int                 ExplosionPower                   = 15;
input  int                 TrendPower                       = 400;

extern string              Text6                            = "Exit Indicator Settings";
input  int                 JurikPeriod                      = 14;
input  int                 JurikPhase                       = 180;

extern string              Text7                            = "ATR Indicator Settings";
input  int                 ATRPeriod                        = 14;

//--- Global Variables
GlobalFunctions    *GF = GlobalFunctions::GetInstance();
IndicatorProcessor *IP = IndicatorProcessor::GetInstance();

int OnInit() {
   if (!InitIndicators()) {
      return INIT_FAILED;
   }
   return INIT_SUCCEEDED;
}

//--- Set Indicators' Parameters
bool InitIndicators(void) {
   if (IP.SetBaselineParameters(SuperSmootherPeriod)                                                                                                         &&
       IP.SetPrimaryConfirmationParameters(EhlerFisherPeriod)                                                                                                &&
       IP.SetSecondaryConfirmationParameters(VortexPeriod)                                                                                                   &&
       IP.SetVolumeIndicatorParameters(FastMACDPeriod, SlowMACDPeriod, BollingerPeriod, BollingerDeviation, Sensitive, DeadZone, ExplosionPower, TrendPower) &&
       IP.SetExitIndicatorParameters(JurikPeriod, JurikPhase)                                                                                                &&
       IP.SetATRParameters(ATRPeriod)                                                                                                                         ) {
      IP.Init();
      return true;
    }
    return false;
}

void OnTick() {
   Update();
   string DebugMsg;
   DebugMsg += IP.GetDebugMsg() + "\n";
   
   Comment(DebugMsg);
}

//--- Assemble All OnTick Functions From All Entities
void Update(void) {
   GF.Update();
   IP.Update();
}