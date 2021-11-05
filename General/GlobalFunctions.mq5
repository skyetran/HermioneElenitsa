#property strict

#include "../General/GlobalFunctions.mqh"

//--- Main Constructor
GlobalFunctions::GlobalFunctions(void) {
   SymbolInfo.Name(Symbol());
}

//--- Get Singleton Instance
GlobalFunctions *GlobalFunctions::GetInstance(void) {
   if (!Instance) {
      Instance = new GlobalFunctions();
   }
   return Instance;
}

//--- Debug Functions
string GlobalFunctions::GetDebugMsg(void) {
   string Msg = "";
   
   return Msg;
}

//--- OnTick Functions
void GlobalFunctions::Update(void) {
   SymbolInfo.Refresh();
   SymbolInfo.RefreshRates();
}

//--- Conversion
int    GlobalFunctions::PriceToPointCvt(const double &InputPrice) const { return (int) (InputPrice / SymbolInfo.Point());    }
int    GlobalFunctions::PriceToPointCvt(const double  InputPrice) const { return (int) (InputPrice / SymbolInfo.Point());    }
double GlobalFunctions::PointToPriceCvt(const int &InputPoint)    const { return (double) (InputPoint * SymbolInfo.Point()); }
double GlobalFunctions::PointToPriceCvt(const int  InputPoint)    const { return (double) (InputPoint * SymbolInfo.Point()); }