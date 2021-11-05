#ifndef GLOBAL_FUNCTIONS_H
#define GLOBAL_FUNCTIONS_H

#include <Trade\SymbolInfo.mqh>

class GlobalFunctions
{
public:
   //--- Get Singleton Instance
   static GlobalFunctions *GetInstance(void);
   
   //--- Debug Functions
   string GetDebugMsg(void);
   
   //--- OnTick Functions
   void Update(void);
   
   //--- Conversion
   int    PriceToPointCvt(const double &InputPrice) const;
   int    PriceToPointCvt(const double  InputPrice) const;
   double PointToPriceCvt(const int &InputPoint)    const;
   double PointToPriceCvt(const int  InputPoint)    const;
   
private:
   //--- Trade Class Instances
   CSymbolInfo SymbolInfo;
   
   //--- Singleton Instance
   static GlobalFunctions *Instance;
   
   //--- Main Constructor
   GlobalFunctions(void);
};

GlobalFunctions *GlobalFunctions::Instance = NULL;

#endif