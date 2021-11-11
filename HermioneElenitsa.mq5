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
input  int                 EhlerFisherPeriod                = 14;

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

extern string              Text6                            = "Exit Indicator Settings";
input  int                 JurikPeriod                      = 14;
input  int                 JurikPhase                       = 180;

extern string              Text7                            = "ATR Indicator Settings";
input  int                 ATRPeriod                        = 14;

extern string              Text8                            = "Flexible NNFX Trade Settings";
input  double              ATRMultiplier                    = 1.0;

extern string              Text9                            = "Expert Advisor Trade Settings";
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
   //DebugMsg += GF.GetDebugMsg() + "\n";
   //DebugMsg += IP.GetDebugMsg() + "\n";
   DebugMsg += SG.GetDebugMsg() + "\n";
   
   SG.GetExitLongSignal();
   SG.GetExitShortSignal();
   MqlTradeRequestWrapper *Request = SG.GetNextSignal();
   
   static int i = 0;
   if (Request) {
      if (Request.tp > Request.sl) {
         ObjectCreate(0, IntegerToString(i++), OBJ_ARROW_BUY, 0, TimeCurrent(), IP.GetAskPrice(CURRENT_BAR));
      } else {
         ObjectCreate(0, IntegerToString(i++), OBJ_ARROW_SELL, 0, TimeCurrent(), IP.GetBidPrice(CURRENT_BAR));
      }
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