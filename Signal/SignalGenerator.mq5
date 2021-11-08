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
   TailingDateTime  = iTime(SymbolInfo.Name(), PERIOD_D1, CURRENT_BAR);
   LastDateTime     = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_BAR);
   LastLastDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_LAST_BAR);
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
   Msg += "NewCandleFlag: "                   + (NewCandleFlag                   ? "Yes" : "No") + "\n";
   Msg += "HasTradedThisCandleFlag: "         + (HasTradedThisCandleFlag         ? "Yes" : "No") + "\n";
   Msg += "Current DateTime: "                + TimeToString(CurrentDateTime)                    + "\n";
   Msg += "Tailing DateTime: "                + TimeToString(TailingDateTime)                    + "\n";
   Msg += "Last DateTime:"                    + TimeToString(LastDateTime)                       + "\n";
   Msg += "LastLast DateTime: "               + TimeToString(LastLastDateTime)                   + "\n";
   Msg += "Start DateTime: "                  + TimeToString(StartDateTime)                      + "\n";
   Msg += "FirstClosedCandleFlag: "           + (FirstClosedCandleFlag           ? "Yes" : "No") + "\n";
   Msg += "FirstClosedLongCandleFlag: "       + (FirstClosedLongCandleFlag       ? "Yes" : "No") + "\n";
   Msg += "FirstClosedShortCandleFlag: "      + (FirstClosedShortCandleFlag      ? "Yes" : "No") + "\n";
   Msg += "SecondClosedCandleFlag: "          + (SecondClosedCandleFlag          ? "Yes" : "No") + "\n";
   Msg += "BridgeTooFarFlag: "                + (BridgeTooFarFlag                ? "Yes" : "No") + "\n";
   Msg += "LookingForBaselineEntryFlag: "     + (LookingForBaselineEntryFlag     ? "Yes" : "No") + "\n";
   Msg += "BaselineEntryFlag: "               + (BaselineEntryFlag               ? "Yes" : "No") + "\n";
   Msg += "LookingForPullBackEntryFlag: "     + (LookingForPullBackEntryFlag     ? "Yes" : "No") + "\n";
   Msg += "PullBackEntryFlag: "               + (PullBackEntryFlag               ? "Yes" : "No") + "\n";
   Msg += "LookingForStandardEntryFlag: "     + (LookingForStandardEntryFlag     ? "Yes" : "No") + "\n";
   Msg += "StandardEntryFlag: "               + (StandardEntryFlag               ? "Yes" : "No") + "\n";
   Msg += "LookingForContinuationEntryFlag: " + (LookingForContinuationEntryFlag ? "Yes" : "No") + "\n";
   Msg += "ContinuationEntryFlag: "           + (ContinuationEntryFlag           ? "Yes" : "No") + "\n";
   Msg += "FirstEntrySignalFlag: "            + (FirstEntrySignalFlag            ? "Yes" : "No") + "\n";
   Msg += "FirstLongEntrySignalFlag: "        + (FirstLongEntrySignalFlag        ? "Yes" : "No") + "\n";
   Msg += "FirstShortEntrySignalFlag: "       + (FirstShortEntrySignalFlag       ? "Yes" : "No") + "\n";
   Msg += "LongOrderExitFlag: "               + (LongOrderExitFlag               ? "Yes" : "No") + "\n";
   Msg += "ShortOrderExitFlag: "              + (ShortOrderExitFlag              ? "Yes" : "No") + "\n";
   Msg += "ResetTrackingVariablesFlag: "      + (ResetTrackingVariablesFlag      ? "Yes" : "No") + "\n";
   
   static int i = 0;
   if (LongEntrySignalFlag) {
      ObjectCreate(0, IntegerToString(i++), OBJ_ARROW_BUY, 0, CurrentDateTime, IP.GetAskPrice(CURRENT_BAR));
      //ObjectCreate(0, IntegerToString(i++), OBJ_HLINE    , 0, CurrentDateTime, IP.GetAskPrice(CURRENT_BAR));
   }
   if (ShortEntrySignalFlag) {
      ObjectCreate(0, IntegerToString(i++), OBJ_ARROW_SELL, 0, CurrentDateTime, IP.GetBidPrice(CURRENT_BAR));
      //ObjectCreate(0, IntegerToString(i++), OBJ_HLINE     , 0, CurrentDateTime, IP.GetBidPrice(CURRENT_BAR));
   }
   return Msg;
}

//--- OnTick Functions
void SignalGenerator::Update(void) {
   ResetTrackingVariables();
   UpdateNewCandleFlag();
   ResetHasTradedThisCandleFlag();
   UpdateDateTimeVariables();
   UpdateLongOrderExitFlag();
   UpdateShortOrderExitFlag();
   UpdateFirstClosedCandleFlag();
   UpdateFirstClosedLongCandleFlag();
   UpdateFirstClosedShortCandleFlag();
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
   UpdateFirstLongEntrySignalFlag();
   UpdateFirstShortEntrySignalFlag();
   UpdateHasTradedThisCandleFlag();
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::ResetTrackingVariables(void) {
   if (ResetTrackingVariablesFlag) {
      LongEntrySignalFlag             = false;
      ShortEntrySignalFlag            = false;
      
      ResetTrackingVariablesFlag      = false;
      LongOrderExitFlag               = false;
      ShortOrderExitFlag              = false;
      FirstClosedCandleFlag           = false;
      FirstClosedLongCandleFlag       = false;
      FirstClosedShortCandleFlag      = false;
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
      FirstLongEntrySignalFlag        = false;
      FirstShortEntrySignalFlag       = false;
   }
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
void SignalGenerator::ResetHasTradedThisCandleFlag(void) {
   if (NewCandleFlag) {
      HasTradedThisCandleFlag = false;
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateDateTimeVariables(void) {
   UpdateCurrentDateTime();
   UpdateTailingDateTime();
   UpdateLastDateTime();
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

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateLastDateTime(void) {
   LastDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_BAR);
}

//--- Helper Functions: UpdateDateTimeVariables --- OnTick Functions
void SignalGenerator::UpdateLastLastDateTime(void) {
   LastLastDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_LAST_BAR);
}

//--- Helper Functions: UpdateDateTimeVariables --- OnTick Functions
void SignalGenerator::UpdateStartDateTime(void) {
   if (IP.HasCandleCrossedBaseline(LAST_BAR)) {
      StartDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_BAR);
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateLongOrderExitFlag(void) {
   LongOrderExitFlag =  (NewCandleFlag && (IP.HasCandleCrossedBaselineFromAbove(LAST_BAR)                            ||
                                           (IndicatorsGiveExitLongSignal(LAST_BAR) && IP.IsAboveBaseline(LAST_BAR))) );
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateShortOrderExitFlag(void) {
   ShortOrderExitFlag = (NewCandleFlag && (IP.HasCandleCrossedBaselineFromBelow(LAST_BAR)                             ||
                                           (IndicatorsGiveExitShortSignal(LAST_BAR) && IP.IsBelowBaseline(LAST_BAR))) );
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateFirstClosedCandleFlag(void) {
   FirstClosedCandleFlag = (FirstClosedCandleFlag || (StartDateTime == LastDateTime));
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateFirstClosedLongCandleFlag(void) {
   FirstClosedLongCandleFlag = (FirstClosedLongCandleFlag || (StartDateTime == LastDateTime && IP.IsAboveBaseline(CURRENT_BAR)));
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateFirstClosedShortCandleFlag(void) {
   FirstClosedShortCandleFlag = (FirstClosedShortCandleFlag || (StartDateTime == LastDateTime && IP.IsBelowBaseline(CURRENT_BAR)));
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateSecondClosedCandleFlag(void) {
   if (StartDateTime == LastLastDateTime) {
      SecondClosedCandleFlag = true;
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateBridgeTooFarFlag(void) {
   if (!FirstEntrySignalFlag) {
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
   LookingForBaselineEntryFlag = (!HasTradedThisCandleFlag && !FirstEntrySignalFlag &&
                                  !BridgeTooFarFlag && IP.HasCandleCrossedBaseline(CURRENT_BAR));
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
   LookingForPullBackEntryFlag = (!HasTradedThisCandleFlag && FirstClosedCandleFlag && !SecondClosedCandleFlag &&
                                  !FirstEntrySignalFlag && !BaselineEntryFlag && IP.IsOutsideOneXATRValue(LAST_BAR));
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdatePullBackEntryFlag(void) {
   UpdatePullBackLongEntryFlag();
   UpdatePullBackShortEntryFlag();
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdatePullBackLongEntryFlag(void) {
   if (LookingForPullBackEntryFlag && IP.IsAboveBaseline(CURRENT_BAR) &&
       FirstClosedLongCandleFlag                                      &&
       IndicatorsGiveStandardLongSignal(CURRENT_BAR)) {
      LongEntrySignalFlag = true;
      PullBackEntryFlag   = true; 
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdatePullBackShortEntryFlag(void) {
   if (LookingForPullBackEntryFlag && IP.IsBelowBaseline(CURRENT_BAR) &&
       FirstClosedShortCandleFlag                                     &&
       IndicatorsGiveStandardShortSignal(CURRENT_BAR)) {
      ShortEntrySignalFlag = true;
      PullBackEntryFlag    = true;    
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateLookingForStandardEntryFlag(void) {
   LookingForStandardEntryFlag = (!HasTradedThisCandleFlag && FirstClosedCandleFlag && !BaselineEntryFlag &&
                                  !PullBackEntryFlag && !FirstEntrySignalFlag); 
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateStandardEntryFlag(void) {
   UpdateStandardLongEntryFlag();
   UpdateStandardShortEntryFlag();
}

//--- Helper Functions: UpdateStandardEntryFlag --- OnTick Functions
void SignalGenerator::UpdateStandardLongEntryFlag(void) {
   if (LookingForStandardEntryFlag && IP.IsAboveBaseline(CURRENT_BAR) &&
       FirstClosedLongCandleFlag                                      &&
       IndicatorsGiveStandardLongSignal(CURRENT_BAR)) {
      LongEntrySignalFlag = true;
      StandardEntryFlag   = true;    
   }
}

//--- Helper Functions: UpdateStandardEntryFlag --- OnTick Functions
void SignalGenerator::UpdateStandardShortEntryFlag(void) {
   if (LookingForStandardEntryFlag && IP.IsBelowBaseline(CURRENT_BAR) &&
       FirstClosedShortCandleFlag                                     &&
       IndicatorsGiveStandardShortSignal(CURRENT_BAR)) {
      ShortEntrySignalFlag = true;
      StandardEntryFlag    = true;    
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateLookingForContinuationEntryFlag(void) {
   LookingForContinuationEntryFlag = (!HasTradedThisCandleFlag && FirstClosedCandleFlag && FirstEntrySignalFlag &&
                                      !BaselineEntryFlag && !PullBackEntryFlag && !StandardEntryFlag);
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateContinuationEntryFlag(void) {
   UpdateContinuationLongEntryFlag();
   UpdateContinuationShortEntryFlag();
}

//--- Helper Functions: UpdateContinuationEntryFlag --- OnTick Functions
void SignalGenerator::UpdateContinuationLongEntryFlag(void) {
   if (LookingForContinuationEntryFlag && IP.IsAboveBaseline(CURRENT_BAR) &&
       FirstClosedLongCandleFlag && FirstLongEntrySignalFlag              &&
       IndicatorsGiveContinuationLongSignal(CURRENT_BAR)) {
      LongEntrySignalFlag   = true;
      ContinuationEntryFlag = true;
   }
}

//--- Helper Functions: UpdateContinuationEntryFlag --- OnTick Functions
void SignalGenerator::UpdateContinuationShortEntryFlag(void) {
   if (LookingForContinuationEntryFlag && IP.IsBelowBaseline(CURRENT_BAR) &&
       FirstClosedShortCandleFlag && FirstShortEntrySignalFlag            &&
       IndicatorsGiveContinuationShortSignal(CURRENT_BAR)) {
      ShortEntrySignalFlag  = true;
      ContinuationEntryFlag = true;    
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateFirstEntrySignalFlag(void) {
   FirstEntrySignalFlag = (FirstEntrySignalFlag || BaselineEntryFlag || PullBackEntryFlag || StandardEntryFlag || ContinuationEntryFlag);
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateFirstLongEntrySignalFlag(void) {
   FirstLongEntrySignalFlag = (FirstLongEntrySignalFlag || (LongEntrySignalFlag && (BaselineEntryFlag || PullBackEntryFlag || StandardEntryFlag || ContinuationEntryFlag)));
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateFirstShortEntrySignalFlag(void) {
   FirstShortEntrySignalFlag = (FirstShortEntrySignalFlag || (ShortEntrySignalFlag && (BaselineEntryFlag || PullBackEntryFlag || StandardEntryFlag || ContinuationEntryFlag)));
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateHasTradedThisCandleFlag(void) {
   HasTradedThisCandleFlag = (HasTradedThisCandleFlag || BaselineEntryFlag || PullBackEntryFlag || StandardEntryFlag || ContinuationEntryFlag);
}

//--- Helper Functions: GetNextSignal
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
          IP.IsPrimaryConfirmationBearish(InputShift + 1) &&
          IP.IsSecondaryConfirmationBullish(InputShift)   ;
}

//--- Helper Functions: Line Up Indicator Signals
bool SignalGenerator::IndicatorsGiveContinuationShortSignal(const int InputShift) const {
   return IP.IsBelowBaseline(InputShift)                  &&
          IP.IsPrimaryConfirmationBearish(InputShift)     &&
          IP.IsPrimaryConfirmationBullish(InputShift + 1) &&
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

//--- Getters --- OnTick Functions
MqlTradeRequestWrapper *SignalGenerator::GetNextSignal(void) {
   if (BaselineEntryFlag || PullBackEntryFlag || StandardEntryFlag || ContinuationEntryFlag) {
      if (LongEntrySignalFlag) {
         ResetEntrySignalTrackingVariables();
         return GetNextLongSignal();
      }
      if (ShortEntrySignalFlag) {
         ResetEntrySignalTrackingVariables();
         return GetNextShortSignal();
      }
   }
   return NULL;
}

//--- Helper Functions: GetNextSignal --- OnTick Functions
MqlTradeRequestWrapper *SignalGenerator::GetNextLongSignal(void) const {
   MqlTradeRequest NextLongSignal = {};
   
   NextLongSignal.price = IP.GetAskPrice(CURRENT_BAR);
   NextLongSignal.tp    = IP.GetAskPrice(CURRENT_BAR) + IP.GetOneXATRValueInPrice(CURRENT_BAR);
   NextLongSignal.sl    = IP.GetAskPrice(CURRENT_BAR) - IP.GetOnePointFiveXATRValueInPrice(CURRENT_BAR);
   
   return new MqlTradeRequestWrapper(NextLongSignal);
}

//--- Helper Functions: GetNextSignal --- OnTick Functions
MqlTradeRequestWrapper *SignalGenerator::GetNextShortSignal(void) const {
   MqlTradeRequest NextShortSignal = {};
   
   NextShortSignal.price = IP.GetBidPrice(CURRENT_BAR);
   NextShortSignal.tp    = IP.GetBidPrice(CURRENT_BAR) - IP.GetOneXATRValueInPrice(CURRENT_BAR);
   NextShortSignal.sl    = IP.GetBidPrice(CURRENT_BAR) + IP.GetOnePointFiveXATRValueInPrice(CURRENT_BAR);
   
   return new MqlTradeRequestWrapper(NextShortSignal);
}

//--- Getters --- OnTick Functions
bool SignalGenerator::GetExitLongSignal(void) {
   if (LongOrderExitFlag) {
      if (IP.HasCandleCrossedBaseline(LAST_BAR)) {
         ResetTrackingVariablesFlag = true;
      }
      return true;
   }
   return false;
}

//--- Getters --- OnTick Functions
bool SignalGenerator::GetExitShortSignal(void) {
   if (ShortOrderExitFlag) {
      if (IP.HasCandleCrossedBaseline(LAST_BAR)) {
         ResetTrackingVariablesFlag = true;
      }
      return true;
   }
   return false;
}