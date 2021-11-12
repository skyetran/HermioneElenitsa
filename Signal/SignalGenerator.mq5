#property strict

#include "../Signal/SignalGenerator.mqh"

//--- Main Constructor
SignalGenerator::SignalGenerator(void) {
   SymbolInfo.Name(Symbol());
   GF = GlobalFunctions::GetInstance();
   IP = IndicatorProcessor::GetInstance();
   InitTrackingVariables();
   ATRMultiplier = DEFAULT_ATR_MULTIPLIER;
}

//--- Helper Functions: Constructor
void SignalGenerator::InitTrackingVariables(void) {
   CurrentDateTime                 = iTime(SymbolInfo.Name(), PERIOD_D1, CURRENT_BAR);
   TailingDateTime                 = iTime(SymbolInfo.Name(), PERIOD_D1, CURRENT_BAR);
   LastDateTime                    = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_BAR);
   LastLastDateTime                = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_LAST_BAR);
   LongStartDateTime               = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_LAST_BAR);
   ShortStartDateTime              = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_LAST_BAR);
   LastMarketSwitchDateTime        = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_LAST_BAR);
   TailingLastMarketSwitchDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_LAST_BAR);
   LastLastDateTime                = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_LAST_BAR);
   ResetLongTrackingVariables();
   ResetShortTrackingVariables();
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
   Msg += "LastLastMarketSwitchDateTime: "         + TimeToString(LastLastMarketSwitchDateTime)                 + "\n";
   Msg += "LastMarketSwitchDateTime: "             + TimeToString(LastMarketSwitchDateTime)                     + "\n";
   Msg += "LongStartDateTime: "                    + TimeToString(LongStartDateTime)                            + "\n";
   Msg += "ShortStartDateTime: "                   + TimeToString(ShortStartDateTime)                           + "\n";
   Msg += "NewCandleFlag: "                        + (NewCandleFlag                             ? "Yes" : "No") + "\n";
   Msg += "FirstClosedLongCandleFlag: "            + (FirstClosedLongCandleFlag                 ? "Yes" : "No") + "\n";
   Msg += "SecondClosedLongCandleFlag: "           + (SecondClosedLongCandleFlag                ? "Yes" : "No") + "\n";
   Msg += "LongBridgeTooFarFlag: "                 + (LongBridgeTooFarFlag                      ? "Yes" : "No") + "\n";
   Msg += "LookingForBaselineLongEntryFlag: "      + (LookingForBaselineLongEntryFlag           ? "Yes" : "No") + "\n";
   Msg += "BaselineLongEntryFlag: "                + (BaselineLongEntryFlag                     ? "Yes" : "No") + "\n";
   Msg += "LookingForPullBackLongEntryFlag: "      + (LookingForPullBackLongEntryFlag           ? "Yes" : "No") + "\n";
   Msg += "PullBackLongEntryFlag: "                + (PullBackLongEntryFlag                     ? "Yes" : "No") + "\n";
   Msg += "LookingForStandardLongEntryFlag: "      + (LookingForStandardLongEntryFlag           ? "Yes" : "No") + "\n";
   Msg += "StandardLongEntryFlag: "                + (StandardLongEntryFlag                     ? "Yes" : "No") + "\n";
   Msg += "LookingForContinuationLongEntryFlag: "  + (LookingForContinuationLongEntryFlag       ? "Yes" : "No") + "\n";
   Msg += "ContinuationLongEntryFlag: "            + (ContinuationLongEntryFlag                 ? "Yes" : "No") + "\n";
   Msg += "FirstLongEntrySignalFlag: "             + (FirstLongEntrySignalFlag                  ? "Yes" : "No") + "\n";
   Msg += "LongEntrySignalFlag: "                  + (LongEntrySignalFlag                       ? "Yes" : "No") + "\n";
   Msg += "HasTradedThisCandleLongFlag: "          + (HasTradedThisCandleLongFlag               ? "Yes" : "No") + "\n";
   Msg += "CurrentDateTime: "                      + TimeToString(CurrentDateTime)                              + "\n";
   Msg += "TailingDateTime: "                      + TimeToString(TailingDateTime)                              + "\n";
   Msg += "LastDateTime: "                         + TimeToString(LastDateTime)                                 + "\n";
   Msg += "LastLastDateTime: "                     + TimeToString(LastLastDateTime)                             + "\n";

   static int i = 0;
   if (LongOrderExitFlag) {
      //ObjectCreate(0, IntegerToString(i++), OBJ_ARROW_BUY, 0, CurrentDateTime, IP.GetAskPrice(CURRENT_BAR));
      //ObjectCreate(0, IntegerToString(i++), OBJ_VLINE    , 0, CurrentDateTime, IP.GetAskPrice(CURRENT_BAR));
   }
   if (ShortOrderExitFlag) {
      //ObjectCreate(0, IntegerToString(i++), OBJ_ARROW_SELL, 0, CurrentDateTime, IP.GetBidPrice(CURRENT_BAR));
      //ObjectCreate(0, IntegerToString(i++), OBJ_HLINE     , 0, CurrentDateTime, IP.GetBidPrice(CURRENT_BAR));
   }
   if (LongOrderExitFlag && NewCandleFlag) {
      //ObjectCreate(0, IntegerToString(i++), OBJ_ARROW_SELL, 0, CurrentDateTime, IP.GetBidPrice(CURRENT_BAR));
      //ObjectCreate(0, IntegerToString(i++), OBJ_VLINE    , 0, CurrentDateTime, IP.GetAskPrice(CURRENT_BAR));
   }
   if (ShortOrderExitFlag && NewCandleFlag) {
      //ObjectCreate(0, IntegerToString(i++), OBJ_ARROW_BUY, 0, CurrentDateTime, IP.GetAskPrice(CURRENT_BAR));
      //ObjectCreate(0, IntegerToString(i++), OBJ_HLINE     , 0, CurrentDateTime, IP.GetBidPrice(CURRENT_BAR));
   }
   return Msg;
}

//--- OnInit Functions
bool SignalGenerator::SetATRMultiplier(const double InputATRMultiplier) {
   if (IsATRMultiplierValid(InputATRMultiplier)) {
      ATRMultiplier = InputATRMultiplier;
      return true;
   }
   return false;
}

//--- Helper Functions: SetATRMultiplier --- OnInit Functions
bool SignalGenerator::IsATRMultiplierValid(const double InputATRMultiplier) const {
   return InputATRMultiplier > MIN_ATR_MULTIPLIER;
}

//--- OnTick Functions
void SignalGenerator::Update(void) {
   UpdateBothSide();
   UpdateLongSide();
   UpdateShortSide();
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateBothSide(void) {
   ResetLongTrackingVariables();
   ResetShortTrackingVariables();
   UpdateNewCandleFlag();
   ResetHasTradedThisCandleLongFlag();
   ResetHasTradedThisCandleShortFlag();
   UpdateDateTimeVariables();
   UpdateLongOrderExitFlag();
   UpdateShortOrderExitFlag();
}

//--- Helper Functions: UpdateBothSide --- OnTick Functions
void SignalGenerator::ResetLongTrackingVariables(void) {
   if (ResetLongTrackingVariablesFlag) {
      ResetLongTrackingVariablesFlag      = false;
      LongOrderExitFlag                   = false;
      FirstClosedLongCandleFlag           = false;
      SecondClosedLongCandleFlag          = false;
      LongBridgeTooFarFlag                = false;
      LookingForBaselineLongEntryFlag     = false;
      BaselineLongEntryFlag               = false;
      LookingForPullBackLongEntryFlag     = false;
      PullBackLongEntryFlag               = false;
      LookingForStandardLongEntryFlag     = false;
      StandardLongEntryFlag               = false;
      LookingForContinuationLongEntryFlag = false;
      ContinuationLongEntryFlag           = false;
      FirstLongEntrySignalFlag            = false;
      LongEntrySignalFlag                 = false;
   }
}

//--- Helper Functions: UpdateBothSide --- OnTick Functions
void SignalGenerator::ResetShortTrackingVariables(void) {
   if (ResetShortTrackingVariablesFlag) {
      ResetShortTrackingVariablesFlag      = false;
      ShortOrderExitFlag                   = false;
      FirstClosedShortCandleFlag           = false;
      SecondClosedShortCandleFlag          = false;
      ShortBridgeTooFarFlag                = false;
      LookingForBaselineShortEntryFlag     = false;
      BaselineShortEntryFlag               = false;
      LookingForPullBackShortEntryFlag     = false;
      PullBackShortEntryFlag               = false;
      LookingForStandardShortEntryFlag     = false;
      StandardShortEntryFlag               = false;
      LookingForContinuationShortEntryFlag = false;
      ContinuationShortEntryFlag           = false;
      FirstShortEntrySignalFlag            = false;
      ShortEntrySignalFlag                 = false;
   }
}

//--- Helper Functions: UpdateBothSide --- OnTick Functions
void SignalGenerator::UpdateNewCandleFlag(void) {
   NewCandleFlag = (TailingDateTime < CurrentDateTime);
}

//--- Helper Functions: UpdateBothSide --- OnTick Functions
void SignalGenerator::ResetHasTradedThisCandleLongFlag(void) {
   if (NewCandleFlag) {
      HasTradedThisCandleLongFlag = false;
   }
}

//--- Helper Functions: UpdateBothSide --- OnTick Functions
void SignalGenerator::ResetHasTradedThisCandleShortFlag(void) {
   if (NewCandleFlag) {
      HasTradedThisCandleShortFlag = false;
   }
}

//--- Helper Functions: UpdateBothSide --- OnTick Functions
void SignalGenerator::UpdateDateTimeVariables(void) {
   UpdateCurrentDateTime();
   UpdateTailingDateTime();
   UpdateLastDateTime();
   UpdateLastLastDateTime();
   UpdateLongStartDateTime();
   UpdateShortStartDateTime();
   UpdateMarketSwitchDateTime();
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
void SignalGenerator::UpdateLastDateTime(void) {
   LastDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_BAR);
}

//--- Helper Functions: UpdateDateTimeVariables --- OnTick Functions
void SignalGenerator::UpdateLastLastDateTime(void) {
   LastLastDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_LAST_BAR);
}

//--- Helper Functions: UpdateDateTimeVariables --- OnTick Functions
void SignalGenerator::UpdateLongStartDateTime(void) {
   if (IP.HasCandleCrossedBaselineFromBelow(LAST_BAR) ||
       IP.IsAboveBaseline(LAST_BAR)) {
      LongStartDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_BAR);
   }
}

//--- Helper Functions: UpdateDateTimeVariables --- OnTick Functions
void SignalGenerator::UpdateShortStartDateTime(void) {
   if (IP.HasCandleCrossedBaselineFromAbove(LAST_BAR) ||
       IP.IsBelowBaseline(LAST_BAR)) {
      ShortStartDateTime = iTime(SymbolInfo.Name(), PERIOD_D1, LAST_BAR);
   }
}

//--- Helper Functions: Update Auxilary Vairables --- OnTickFunctions
void SignalGenerator::UpdateMarketSwitchDateTime(void) {
   LastMarketSwitchDateTime = MathMin(LongStartDateTime, ShortStartDateTime);
   if (TailingLastMarketSwitchDateTime < LastMarketSwitchDateTime) {
      LastLastMarketSwitchDateTime    = TailingLastMarketSwitchDateTime;
      TailingLastMarketSwitchDateTime = LastMarketSwitchDateTime;
   }
}

//--- Helper Functions: UpdateBothSide --- OnTick Functions
void SignalGenerator::UpdateLongOrderExitFlag(void) {
   if (NewCandleFlag) {
      LongOrderExitFlag = (IP.HasCandleCrossedBaselineFromAbove(LAST_BAR)                        ||
                           IP.IsBelowBaseline(LAST_BAR)                                          ||
                           (IndicatorsGiveExitLongSignal(LAST_BAR) && IP.IsAboveBaseline(LAST_BAR)) );
   } else {
      LongOrderExitFlag = false;
   }
}

//--- Helper Functions: UpdateBothSide --- OnTick Functions
void SignalGenerator::UpdateShortOrderExitFlag(void) {
   if (NewCandleFlag) {
      ShortOrderExitFlag = (IP.HasCandleCrossedBaselineFromBelow(LAST_BAR)                         ||
                            IP.IsAboveBaseline(LAST_BAR)                                           ||
                            (IndicatorsGiveExitShortSignal(LAST_BAR) && IP.IsBelowBaseline(LAST_BAR)) );
   } else {
      ShortOrderExitFlag = false;
   }
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateLongSide(void) {
   UpdateFirstClosedLongCandleFlag();
   UpdateSecondClosedLongCandleFlag();
   UpdateLongBridgeTooFarFlag();
   UpdateLookingForBaselineLongEntryFlag();
   UpdateBaselineLongEntryFlag();
   UpdateLookingForPullBackLongEntryFlag();
   UpdatePullBackLongEntryFlag();
   UpdateLookingForStandardLongEntryFlag();
   UpdateStandardLongEntryFlag();
   //UpdateLookingForContinuationLongEntryFlag();
   //UpdateContinuationLongEntryFlag();
   UpdateFirstLongEntrySignalFlag();
   UpdateLongEntrySignalFlag();
   UpdateHasTradedThisCandleLongFlag();
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdateFirstClosedLongCandleFlag(void) {
   if (IP.HasCandleCrossedBaselineFromAbove(LAST_BAR) ||
       IP.IsBelowBaseline(LAST_BAR)) {
      FirstClosedLongCandleFlag = false;
   } else {
      FirstClosedLongCandleFlag = (FirstClosedLongCandleFlag || (IP.HasCandleCrossedBaselineFromBelow(LAST_BAR) ||
                                                                 IP.IsAboveBaseline(LAST_BAR)                   ));
   }
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdateSecondClosedLongCandleFlag(void) {
   if (IP.HasCandleCrossedBaselineFromAbove(LAST_BAR) ||
       IP.IsBelowBaseline(LAST_BAR)) {
      SecondClosedLongCandleFlag = false;
   } else {
      SecondClosedLongCandleFlag = (SecondClosedLongCandleFlag || ((IP.HasCandleCrossedBaselineFromBelow(LAST_LAST_BAR) ||
                                                                    IP.IsAboveBaseline(LAST_LAST_BAR)                    ) && (IP.IsAboveBaseline(LAST_BAR))));
   }
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdateLongBridgeTooFarFlag(void) {
   if (IP.HasCandleCrossedBaselineFromBelow(CURRENT_BAR) ||
       IP.IsAboveBaseline(CURRENT_BAR)) {
      int SignalCount = 0;
      for (int Shift = LAST_BAR; Shift <= BRIDGE_TOO_FAR_LOOK_BACK; Shift++) {
         if (IP.IsPrimaryConfirmationBullish(Shift)) {
            SignalCount++;
         }
      }
      LongBridgeTooFarFlag = (SignalCount == BRIDGE_TOO_FAR_LOOK_BACK);
   }
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdateLookingForBaselineLongEntryFlag(void) {
   LookingForBaselineLongEntryFlag = (!FirstClosedLongCandleFlag     &&
                                      !LongBridgeTooFarFlag          &&
                                      !FirstLongEntrySignalFlag      &&
                                      !HasTradedThisCandleLongFlag   &&
                                      IP.IsAboveBaseline(CURRENT_BAR));
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdateBaselineLongEntryFlag(void) {
   BaselineLongEntryFlag = (LookingForBaselineLongEntryFlag              &&
                            IndicatorsGiveStandardLongSignal(CURRENT_BAR));
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdateLookingForPullBackLongEntryFlag(void) {
   LookingForPullBackLongEntryFlag = (FirstClosedLongCandleFlag          && 
                                      !SecondClosedLongCandleFlag        &&
                                      !FirstLongEntrySignalFlag          &&
                                      !LookingForBaselineLongEntryFlag   &&
                                      !HasTradedThisCandleLongFlag       &&
                                      IP.IsOutsideOneXATRValue(LAST_BAR) &&
                                      IP.IsAboveBaseline(LAST_BAR)       &&
                                      IP.IsAboveBaseline(CURRENT_BAR)    );
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdatePullBackLongEntryFlag(void) {
   PullBackLongEntryFlag = (LookingForPullBackLongEntryFlag              &&
                            IndicatorsGiveStandardLongSignal(CURRENT_BAR));
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdateLookingForStandardLongEntryFlag(void) {
   LookingForStandardLongEntryFlag = (FirstClosedLongCandleFlag        &&
                                      !FirstLongEntrySignalFlag        &&
                                      !LookingForPullBackLongEntryFlag &&
                                      !HasTradedThisCandleLongFlag     &&
                                      IP.IsAboveBaseline(CURRENT_BAR)  );
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdateStandardLongEntryFlag(void) {
   StandardLongEntryFlag = (LookingForStandardLongEntryFlag              &&
                            IndicatorsGiveStandardLongSignal(CURRENT_BAR));
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdateLookingForContinuationLongEntryFlag(void) {
   LookingForContinuationLongEntryFlag = (FirstClosedLongCandleFlag        &&
                                          SecondClosedLongCandleFlag       &&
                                          !LookingForBaselineLongEntryFlag &&
                                          !LookingForPullBackLongEntryFlag &&
                                          !LookingForStandardLongEntryFlag &&
                                          FirstLongEntrySignalFlag         &&
                                          !HasTradedThisCandleLongFlag     &&
                                          IP.IsAboveBaseline(CURRENT_BAR)  );
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdateContinuationLongEntryFlag(void) {
   ContinuationLongEntryFlag = (LookingForContinuationLongEntryFlag              &&
                                IndicatorsGiveContinuationLongSignal(CURRENT_BAR));
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdateFirstLongEntrySignalFlag(void) {
   FirstLongEntrySignalFlag = (FirstLongEntrySignalFlag ||
                               BaselineLongEntryFlag    ||
                               PullBackLongEntryFlag    ||
                               StandardLongEntryFlag    ||
                               ContinuationLongEntryFlag);
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdateLongEntrySignalFlag(void) {
   LongEntrySignalFlag = (BaselineLongEntryFlag    ||
                          PullBackLongEntryFlag    ||
                          StandardLongEntryFlag    ||
                          ContinuationLongEntryFlag);
}

//--- Helper Functions: UpdateLongSide --- OnTick Functions
void SignalGenerator::UpdateHasTradedThisCandleLongFlag(void) {
   HasTradedThisCandleLongFlag = (HasTradedThisCandleLongFlag ||
                                  BaselineLongEntryFlag       ||
                                  PullBackLongEntryFlag       ||
                                  StandardLongEntryFlag       ||
                                  ContinuationLongEntryFlag   );
}

//--- Helper Functions: Update --- OnTick Functions
void SignalGenerator::UpdateShortSide(void) {
   UpdateFirstClosedShortCandleFlag();
   UpdateSecondClosedShortCandleFlag();
   UpdateShortBridgeTooFarFlag();
   UpdateLookingForBaselineShortEntryFlag();
   UpdateBaselineShortEntryFlag();
   UpdateLookingForPullBackShortEntryFlag();
   UpdatePullBackShortEntryFlag();
   UpdateLookingForStandardShortEntryFlag();
   UpdateStandardShortEntryFlag();
   //UpdateLookingForContinuationShortEntryFlag();
   //UpdateContinuationShortEntryFlag();
   UpdateFirstShortEntrySignalFlag();
   UpdateShortEntrySignalFlag();
   UpdateHasTradedThisCandleShortFlag();
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdateFirstClosedShortCandleFlag(void) {
   if (IP.HasCandleCrossedBaselineFromBelow(LAST_BAR) ||
       IP.IsAboveBaseline(LAST_BAR)) {
      FirstClosedShortCandleFlag = false;
   } else {
      FirstClosedShortCandleFlag = (FirstClosedShortCandleFlag || (IP.HasCandleCrossedBaselineFromAbove(LAST_BAR) ||
                                                                   IP.IsBelowBaseline(LAST_BAR)                   ));
   }
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdateSecondClosedShortCandleFlag(void) {
   if (IP.HasCandleCrossedBaselineFromBelow(LAST_BAR) ||
       IP.IsAboveBaseline(LAST_BAR)) {
      SecondClosedShortCandleFlag = false;
   } else {
      SecondClosedShortCandleFlag = (SecondClosedShortCandleFlag || ((IP.HasCandleCrossedBaselineFromAbove(LAST_LAST_BAR) ||
                                                                      IP.IsBelowBaseline(LAST_LAST_BAR)                    ) && (IP.IsBelowBaseline(LAST_BAR))));
   }
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdateShortBridgeTooFarFlag(void) {
   if (IP.HasCandleCrossedBaselineFromAbove(CURRENT_BAR) ||
       IP.IsBelowBaseline(CURRENT_BAR)) {
      int SignalCount = 0;
      for (int Shift = LAST_BAR; Shift <= BRIDGE_TOO_FAR_LOOK_BACK; Shift++) {
         if (IP.IsPrimaryConfirmationBearish(Shift)) {
            SignalCount++;
         }
      }
      ShortBridgeTooFarFlag = (SignalCount == BRIDGE_TOO_FAR_LOOK_BACK);
   }
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdateLookingForBaselineShortEntryFlag(void) {
   LookingForBaselineShortEntryFlag = (!FirstClosedShortCandleFlag    &&
                                       !ShortBridgeTooFarFlag         &&
                                       !FirstShortEntrySignalFlag     &&
                                       !HasTradedThisCandleShortFlag  &&
                                       IP.IsBelowBaseline(CURRENT_BAR));
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdateBaselineShortEntryFlag(void) {
   BaselineShortEntryFlag = (LookingForBaselineShortEntryFlag              &&
                             IndicatorsGiveStandardShortSignal(CURRENT_BAR));
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdateLookingForPullBackShortEntryFlag(void) {
   LookingForPullBackShortEntryFlag = (FirstClosedShortCandleFlag         && 
                                       !SecondClosedShortCandleFlag       &&
                                       !FirstShortEntrySignalFlag         &&
                                       !LookingForBaselineShortEntryFlag  &&
                                       !HasTradedThisCandleShortFlag      &&
                                       IP.IsOutsideOneXATRValue(LAST_BAR) &&
                                       IP.IsBelowBaseline(LAST_BAR)       &&
                                       IP.IsBelowBaseline(CURRENT_BAR)    );
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdatePullBackShortEntryFlag(void) {
   PullBackShortEntryFlag = (LookingForPullBackShortEntryFlag              &&
                             IndicatorsGiveStandardShortSignal(CURRENT_BAR));
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdateLookingForStandardShortEntryFlag(void) {
   LookingForStandardShortEntryFlag = (FirstClosedShortCandleFlag        &&
                                       !FirstShortEntrySignalFlag        &&
                                       !LookingForPullBackShortEntryFlag &&
                                       !HasTradedThisCandleShortFlag     &&
                                       IP.IsBelowBaseline(CURRENT_BAR)   );
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdateStandardShortEntryFlag(void) {
   StandardShortEntryFlag = (LookingForStandardShortEntryFlag              &&
                             IndicatorsGiveStandardShortSignal(CURRENT_BAR));
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdateLookingForContinuationShortEntryFlag(void) {
   LookingForContinuationShortEntryFlag = (FirstClosedShortCandleFlag        &&
                                           SecondClosedShortCandleFlag       &&
                                           !LookingForBaselineShortEntryFlag &&
                                           !LookingForPullBackShortEntryFlag &&
                                           !LookingForStandardShortEntryFlag &&
                                           FirstShortEntrySignalFlag         &&
                                           !HasTradedThisCandleShortFlag     &&
                                           IP.IsBelowBaseline(CURRENT_BAR)   );
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdateContinuationShortEntryFlag(void) {
   ContinuationShortEntryFlag = (LookingForContinuationShortEntryFlag              &&
                                 IndicatorsGiveContinuationShortSignal(CURRENT_BAR));
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdateFirstShortEntrySignalFlag(void) {
   FirstShortEntrySignalFlag = (FirstShortEntrySignalFlag ||
                                BaselineShortEntryFlag    ||
                                PullBackShortEntryFlag    ||
                                StandardShortEntryFlag    ||
                                ContinuationShortEntryFlag);
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdateShortEntrySignalFlag(void) {
   ShortEntrySignalFlag = (BaselineShortEntryFlag    ||
                           PullBackShortEntryFlag    ||
                           StandardShortEntryFlag    ||
                           ContinuationShortEntryFlag);
}

//--- Helper Functions: UpdateShortSide --- OnTick Functions
void SignalGenerator::UpdateHasTradedThisCandleShortFlag(void) {
   HasTradedThisCandleShortFlag = (HasTradedThisCandleShortFlag ||
                                   BaselineShortEntryFlag       ||
                                   PullBackShortEntryFlag       ||
                                   StandardShortEntryFlag       ||
                                   ContinuationShortEntryFlag   );
}

//--- Helper Functions: Line Up Indicator Signals
bool SignalGenerator::IndicatorsGiveStandardLongSignal(const int InputShift) const {
   return IP.IsAboveBaseline(InputShift)                &&
          IP.IsAboveBaseline(InputShift)                &&
          IP.IsPrimaryConfirmationBullish(InputShift)   &&
          IP.IsSecondaryConfirmationBullish(InputShift) &&
          IP.IsActiveMarket(InputShift)                 &&
          IP.IsWithInXATRValue(InputShift, ATRMultiplier);
}

//--- Helper Functions: Line Up Indicator Signals
bool SignalGenerator::IndicatorsGiveStandardShortSignal(const int InputShift) const {
   return IP.IsBelowBaseline(InputShift)                &&
          IP.IsBelowBaseline(InputShift)                &&
          IP.IsPrimaryConfirmationBearish(InputShift)   &&
          IP.IsSecondaryConfirmationBearish(InputShift) &&
          IP.IsActiveMarket(InputShift)                 &&
          IP.IsWithInXATRValue(InputShift, ATRMultiplier);
}

//--- Helper Functions: Line Up Indicator Signals
bool SignalGenerator::IndicatorsGiveContinuationLongSignal(const int InputShift) const {
   return IP.IsAboveBaseline(InputShift)                  &&
          IP.IsPrimaryConfirmationBullish(InputShift)     &&
          IP.IsContinuousBearish(InputShift + 1)          &&
          IP.IsContinuousBullish(InputShift)               ;
}

//--- Helper Functions: Line Up Indicator Signals
bool SignalGenerator::IndicatorsGiveContinuationShortSignal(const int InputShift) const {
   return IP.IsBelowBaseline(InputShift)                  &&
          IP.IsPrimaryConfirmationBearish(InputShift)     &&
          IP.IsContinuousBullish(InputShift + 1)          &&
          IP.IsContinuousBearish(InputShift)               ;
}

//--- Helper Functions: Line Up Indicator Signals
bool SignalGenerator::IndicatorsGiveExitLongSignal(const int InputShift) const {
   return IP.IsPrimaryConfirmationBearish(InputShift);
}

//--- Helper Functions: Line Up Indicator Signals
bool SignalGenerator::IndicatorsGiveExitShortSignal(const int InputShift) const {
   return IP.IsPrimaryConfirmationBullish(InputShift);
}

//--- Getters --- OnTick Functions
MqlTradeRequestWrapper *SignalGenerator::GetNextSignal(void) {
   if (LongEntrySignalFlag) {
      ResetLongEntrySignalTrackingVariables();
      return GetNextLongSignal();
   }
   if (ShortEntrySignalFlag) {
      ResetShortEntrySignalTrackingVariables();
      return GetNextShortSignal();
   }
   return NULL;
}

//--- Helper Functions: GetNextSignal --- OnTick Functions
void SignalGenerator::ResetLongEntrySignalTrackingVariables(void) {
   BaselineLongEntryFlag     = false;
   PullBackLongEntryFlag     = false;
   StandardLongEntryFlag     = false;
   ContinuationLongEntryFlag = false;
   LongEntrySignalFlag       = false;
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
void SignalGenerator::ResetShortEntrySignalTrackingVariables(void) {
   BaselineShortEntryFlag     = false;
   PullBackShortEntryFlag     = false;
   StandardShortEntryFlag     = false;
   ContinuationShortEntryFlag = false;
   ShortEntrySignalFlag       = false;
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
      if (IP.HasCandleCrossedBaselineFromAbove(LAST_BAR) ||
          IP.IsBelowBaseline(LAST_BAR)) {
         ResetLongTrackingVariablesFlag = true;
      }
      return true;
   }
   return false;
}

//--- Getters --- OnTick Functions
bool SignalGenerator::GetExitShortSignal(void) {
   if (ShortOrderExitFlag) {
      if (IP.HasCandleCrossedBaselineFromBelow(LAST_BAR) ||
          IP.IsAboveBaseline(LAST_BAR)) {
         ResetShortTrackingVariablesFlag = true;
      }
      return true;
   }
   return false;
}

//--- Auxilary Functions
datetime SignalGenerator::GetLastMarketSwitchDateTime(void)     const { return LastMarketSwitchDateTime;     }
datetime SignalGenerator::GetLastLastMarketSwitchDateTime(void) const { return LastLastMarketSwitchDateTime; }