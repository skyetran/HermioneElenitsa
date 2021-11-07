#property strict

#include "../Signal/SignalGenerator.mqh"

//--- Main Constructor
SignalGenerator::SignalGenerator(void) {
   SymbolInfo.Name(Symbol());
   GF = GlobalFunctions::GetInstance();
   IP = IndicatorProcessor::GetInstance();
   InitTrackingVariables();
}

//--- Helper Functions: Constructor
void SignalGenerator::InitTrackingVariables(void) {
   CurrentDateTime  = iTime(SymbolInfo.Name(), PERIOD_D1, CURRENT_BAR);
   TailingDateTime  = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_LAST_BAR);
   LastLastDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, CURRENT_BAR);
   StartDateTime    = iTime(SymbolInfo.Name(), PERIOD_D1, CURRENT_BAR);
   ResetTrackingVariables();
}

//--- Get Singleton Instance
SignalGenerator *SignalGenerator::GetInstance(void) {
   if (!Instance) {
      Instance = new SignalGenerator();
   }
   return Instance;
}

//--- Debug Functions
string SignalGenerator::GetDebugMsg(void) const {
   string Msg = "";
   Msg += TimeToString(CurrentDateTime)  + "\n";
   Msg += TimeToString(TailingDateTime)  + "\n";
   Msg += TimeToString(LastLastDateTime) + "\n";
   Msg += TimeToString(StartDateTime)    + "\n";
   
   static int i = 0;
   if (PullBackEntryFlag) {
      ObjectCreate(0, IntegerToString(i++), OBJ_VLINE, 0, iTime(SymbolInfo.Name(), Period(), 0), SymbolInfoDouble(Symbol(), SYMBOL_BID));
   }
   return Msg;
}

//--- OnTick Functions
void SignalGenerator::Update(void) {
   UpdateNewCandleFlag();
   UpdateDateTimeVariables();
   UpdateFirstClosedCandleFlag();
   UpdateSecondClosedCandleFlag();
   UpdateBridgeTooFarFlag();
   UpdateLookingForBaselineEntryFlag();
   UpdateBaselineEntryFlag();
   UpdateLookingForPullBackEntryFlag();
   UpdatePullBackEntryFlag();
   UpdateLookingForStandardEntryFlag();
   UpdateStandardEntryFlag();
   UpdateLookingForContinuationEntryFlag();
   UpdateContinuationEntryFlag();
   UpdateFirstEntrySignalFlag();
   UpdateLongOrderExitFlag();
   UpdateShortOrderExitFlag();
}

//--- Getters --- OnTick Functions
MqlTradeRequestWrapper *SignalGenerator::GetNextSignal(void) {
   return NULL;
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateNewCandleFlag(void) {
   if (TailingDateTime < CurrentDateTime) {
      NewCandleFlag = true;
   } else {
      NewCandleFlag = false;
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateDateTimeVariables(void) {
   UpdateCurrentDateTime();
   UpdateTailingDateTime();
   UpdateLastLastDateTime();
   UpdateStartDateTime();
}

//--- Helper Functions: UpdateDateTimeVariables --- OnTick Functions
void SignalGenerator::UpdateCurrentDateTime(void) {
   CurrentDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, CURRENT_BAR);
}

//--- Helper Functions: UpdateDateTimeVariables --- OnTick Functions
void SignalGenerator::UpdateTailingDateTime(void) {
   if (NewCandleFlag) {
      TailingDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, CURRENT_BAR);
   }
}

//--- Helper Functions: UpdateDateTimeVariables --- OnTick Functions
void SignalGenerator::UpdateLastLastDateTime(void) {
   LastLastDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_LAST_BAR);
}

//--- Helper Functions: UpdateDateTimeVariables --- OnTick Functions
void SignalGenerator::UpdateStartDateTime(void) {
   if (NewCandleFlag && IP.HasCandleCrossedBaseline(LAST_BAR)) {
      StartDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_BAR);
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateFirstClosedCandleFlag(void) {
   FirstClosedCandleFlag = (FirstClosedCandleFlag || (NewCandleFlag && IP.HasCandleCrossedBaseline(LAST_BAR)));
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateSecondClosedCandleFlag(void) {
   SecondClosedCandleFlag = (SecondClosedCandleFlag || (FirstClosedCandleFlag && StartDateTime == LastLastDateTime));
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateBridgeTooFarFlag(void) {
   if (!FirstClosedCandleFlag && !FirstEntrySignalFlag) {
      UpdateBridgeTooFarFlagFromAbove();
      UpdateBridgeTooFarFlagFromBelow();
   }
}

//--- Helper Functions: UpdateBrideTooFarFlag --- OnTick Functions
void SignalGenerator::UpdateBridgeTooFarFlagFromAbove(void) {
   if (IP.HasCandleCrossedBaselineFromAbove(CURRENT_BAR)) {
      int SignalCount = 0;
      for (int Shift = 1; Shift <= BRIDGE_TOO_FAR_LOOK_BACK; Shift++) {
         if (IP.IsPrimaryConfirmationBearish(Shift)) {
            SignalCount++;
         }
      }
      BridgeTooFarFlag = (SignalCount == BRIDGE_TOO_FAR_LOOK_BACK);
   }
}

//--- Helper Functions: UpdateBrideTooFarFlag --- OnTick Functions
void SignalGenerator::UpdateBridgeTooFarFlagFromBelow(void) {
   if (IP.HasCandleCrossedBaselineFromBelow(CURRENT_BAR)) {
      int SignalCount = 0;
      for (int Shift = 1; Shift <= BRIDGE_TOO_FAR_LOOK_BACK; Shift++) {
         if (IP.IsPrimaryConfirmationBullish(Shift)) {
            SignalCount++;
         }
      }
      BridgeTooFarFlag = (SignalCount == BRIDGE_TOO_FAR_LOOK_BACK);
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateLookingForBaselineEntryFlag(void) {
   LookingForBaselineEntryFlag = (!FirstClosedCandleFlag && !FirstEntrySignalFlag && !BridgeTooFarFlag &&
                                  IP.HasCandleCrossedBaseline(CURRENT_BAR));
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateBaselineEntryFlag(void) {
   UpdateBaselineLongEntryFlag();
   UpdateBaselineShortEntryFlag();
}

//--- Helper Functions: UpdateBaselineEntryFlag --- OnTick Functions
void SignalGenerator::UpdateBaselineLongEntryFlag(void) {
   if (LookingForBaselineEntryFlag && IP.HasCandleCrossedBaselineFromBelow(CURRENT_BAR) &&
       IndicatorsGiveStandardLongSignal(CURRENT_BAR)) {
      LongEntrySignalFlag  = true;
      BaselineEntryFlag    = true;
   }
}

//--- Helper Functions: UpdateBaselineEntryFlag --- OnTick Functions
void SignalGenerator::UpdateBaselineShortEntryFlag(void) {
   if (LookingForBaselineEntryFlag && IP.HasCandleCrossedBaselineFromAbove(CURRENT_BAR) &&
       IndicatorsGiveStandardShortSignal(CURRENT_BAR)) {
      ShortEntrySignalFlag = true;
      BaselineEntryFlag    = true;
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateLookingForPullBackEntryFlag(void) {
   LookingForPullBackEntryFlag = (FirstClosedCandleFlag && !SecondClosedCandleFlag && !FirstEntrySignalFlag   &&
                                  IP.HasCandleCrossedBaseline(LAST_BAR) && IP.IsOutsideOneXATRValue(LAST_BAR) && 
                                  IP.IsWithInOneXATRValue(CURRENT_BAR));
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdatePullBackEntryFlag(void) {
   UpdatePullBackLongEntryFlag();
   UpdatePullBackShortEntryFlag();
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdatePullBackLongEntryFlag(void) {
   if (LookingForPullBackEntryFlag && IP.IsAboveBaseline(CURRENT_BAR) &&
       IndicatorsGiveStandardLongSignal(CURRENT_BAR)) {
      LongEntrySignalFlag = true;
      PullBackEntryFlag   = true; 
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdatePullBackShortEntryFlag(void) {
   if (LookingForPullBackEntryFlag && IP.IsBelowBaseline(CURRENT_BAR) &&
       IndicatorsGiveStandardShortSignal(CURRENT_BAR)) {
      ShortEntrySignalFlag = true;
      PullBackEntryFlag    = true;    
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateLookingForStandardEntryFlag(void) {
    
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateStandardEntryFlag(void) {
   UpdateStandardLongEntryFlag();
   UpdateStandardShortEntryFlag();
}

//--- Helper Functions: UpdateStandardEntryFlag --- OnTick Functions
void SignalGenerator::UpdateStandardLongEntryFlag(void) {
   //if (LookingForStandardEntryFlag)
}

//--- Helper Functions: UpdateStandardEntryFlag --- OnTick Functions
void SignalGenerator::UpdateStandardShortEntryFlag(void) {

}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateLookingForContinuationEntryFlag(void) {

}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateContinuationEntryFlag(void) {
   UpdateContinuationLongEntryFlag();
   UpdateContinuationShortEntryFlag();
}

//--- Helper Functions: UpdateContinuationEntryFlag --- OnTick Functions
void SignalGenerator::UpdateContinuationLongEntryFlag(void) {

}

//--- Helper Functions: UpdateContinuationEntryFlag --- OnTick Functions
void SignalGenerator::UpdateContinuationShortEntryFlag(void) {

}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateFirstEntrySignalFlag(void) {
   FirstEntrySignalFlag = (FirstEntrySignalFlag || BaselineEntryFlag || PullBackEntryFlag || StandardEntryFlag || ContinuationEntryFlag);
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateLongOrderExitFlag(void) {
   
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateShortOrderExitFlag(void) {

}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::ResetTrackingVariables(void) {
   LongEntrySignalFlag             = false;
   ShortEntrySignalFlag            = false;
   NewCandleFlag                   = false;
   FirstClosedCandleFlag           = false;
   SecondClosedCandleFlag          = false;
   BridgeTooFarFlag                = false;
   LookingForBaselineEntryFlag     = false;
   BaselineEntryFlag               = false;
   LookingForPullBackEntryFlag     = false;
   PullBackEntryFlag               = false;
   LookingForStandardEntryFlag     = false;
   StandardEntryFlag               = false;
   LookingForContinuationEntryFlag = false;
   ContinuationEntryFlag           = false;
   FirstEntrySignalFlag            = false;
   LongOrderExitFlag               = false;
   ShortOrderExitFlag              = false;
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::ResetEntrySignalTrackingVariables(void) {
   LongEntrySignalFlag   = false;
   ShortEntrySignalFlag  = false;
   BaselineEntryFlag     = false;
   PullBackEntryFlag     = false;
   StandardEntryFlag     = false;
   ContinuationEntryFlag = false;
}

//--- Helper Functions: Line Up Indicator Signals
bool SignalGenerator::IndicatorsGiveStandardLongSignal(const int InputShift) const {
   return IP.IsAboveBaseline(InputShift)                &&
          IP.IsPrimaryConfirmationBullish(InputShift)   &&
          IP.IsSecondaryConfirmationBullish(InputShift) &&
          IP.IsActiveMarket(InputShift)                 &&
          IP.IsWithInOneXATRValue(InputShift)           ;
}

//--- Helper Functions: Line Up Indicator Signals
bool SignalGenerator::IndicatorsGiveStandardShortSignal(const int InputShift) const {
   return IP.IsBelowBaseline(InputShift)                &&
          IP.IsPrimaryConfirmationBearish(InputShift)   &&
          IP.IsSecondaryConfirmationBearish(InputShift) &&
          IP.IsActiveMarket(InputShift)                 &&
          IP.IsWithInOneXATRValue(InputShift)           ;
}

//--- Helper Functions: Line Up Indicator Signals
bool SignalGenerator::IndicatorsGiveContinuationLongSignal(const int InputShift) const {
   return IP.IsAboveBaseline(InputShift)                  &&
          IP.IsPrimaryConfirmationBullish(InputShift)     &&
          IP.IsPrimaryConfirmationBearish(InputShift - 1) &&
          IP.IsSecondaryConfirmationBullish(InputShift)   ;
}

//--- Helper Functions: Line Up Indicator Signals
bool SignalGenerator::IndicatorsGiveContinuationShortSignal(const int InputShift) const {
   return IP.IsBelowBaseline(InputShift)                  &&
          IP.IsPrimaryConfirmationBearish(InputShift)     &&
          IP.IsPrimaryConfirmationBullish(InputShift - 1) &&
          IP.IsSecondaryConfirmationBearish(InputShift)   ;
}

//--- Helper Functions: Line Up Indicator Signals
bool SignalGenerator::IndicatorsGiveExitLongSignal(const int InputShift) const {
   return IP.IsPrimaryConfirmationBearish(InputShift)   ||
          IP.ShouldExitLongFromExitIndicator(InputShift);
}

//--- Helper Functions: Line Up Indicator Signals
bool SignalGenerator::IndicatorsGiveExitShortSignal(const int InputShift) const {
   return IP.IsPrimaryConfirmationBullish(InputShift)    ||
          IP.ShouldExitShortFromExitIndicator(InputShift);
}