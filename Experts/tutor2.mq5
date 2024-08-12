//+------------------------------------------------------------------+
//|                                                       tutor2.mq5 |
//|                                 Copyright 2024, Dennis Jorgenson |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Dennis Jorgenson"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <stdutil.mqh>

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if (LoadRates()>NoValue)
     UpdateRay("Test",50,0.54750);
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  { 
    if (LoadRates()>NoValue)
    {
      NewRay("Test",clrYellow,STYLE_SOLID);
    }
    
    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   
  }