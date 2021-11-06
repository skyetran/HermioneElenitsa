#ifndef SIGNAL_GENERATOR_H
#define SIGNAL_GENERATOR_H

#include "../General/GlobalConstants.mqh"
#include "../General/GlobalFunctions.mqh"
#include "../General/IndicatorProcessor.mqh"

class SignalGenerator
{
public:
   //--- Get Singleton Instance
   static SignalGenerator *GetInstance(void);
   
   //--- Debug Functions
   string GetDebugMsg(void);
   
   //--- OnTick Functions
   void Update(void);
   
private:
   //--- External Entities
   IndicatorProcessor *IP;

   //--- Singleton Instance
   static SignalGenerator *Instance;
   
   //--- Main Constructor
   SignalGenerator(void);
};

SignalGenerator *SignalGenerator::Instance = NULL;

#endif