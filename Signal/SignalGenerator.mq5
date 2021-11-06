#property strict

#include "../Signal/SignalGenerator.mqh"

//--- Main Constructor
SignalGenerator::SignalGenerator(void) {
   IP = IndicatorProcessor::GetInstance();
}

//--- Get Singleton Instance
SignalGenerator *SignalGenerator::GetInstance(void) {
   if (!Instance) {
      Instance = new SignalGenerator();
   }
   return Instance;
}

//--- Debug Functions
string SignalGenerator::GetDebugMsg(void) {
   string Msg = "";
   
   return Msg;
}

//--- OnTick Functions
void SignalGenerator::Update(void) {
   
}