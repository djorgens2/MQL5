//+------------------------------------------------------------------+
//|                                                       tutor1.mq5 |
//|                                 Copyright 2024, Dennis Jorgenson |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Dennis Jorgenson"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//MqlRates rates[];
// 
//#define _Open(r)   rates[r].open
//#define _High(r)   rates[r].high
//#define _Low(r)    rates[r].low
//#define _Close(r)  rates[r].close
//#define _Time(r)   rates[r].time
//#define _Volume(r) rates[r].tick_volume
// 
//#define _Bars Bars(_Symbol,_Period)
 
#include <stdutil.mqh>

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
    ArraySetAsSeries(rates,true);
    int copied=CopyRates(NULL,0,0,100,rates);
    if(copied<=0)
       Print("Error copying price data ",GetLastError());
    else Print("Copied ",ArraySize(rates)," bars");

     return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
    int copied=CopyRates(NULL,0,0,_Bars,rates);
    int fhandle = FileOpen("EURODATA.csv",FILE_CSV|FILE_WRITE|FILE_ANSI);
    string ftext = "";
    
    Print((string)copied+":"+
      TimeToString(_Time(1))+":"+
      DoubleToString(_Open(0),_Digits)+":"+
      DoubleToString(_High(0),_Digits)+":"+
      DoubleToString(_Low(0),_Digits)+":"+
      DoubleToString(_Close(0),_Digits)+":"+
      (string)_Volume(0));
    
    for (int bar=_Bars-1;bar>0;bar--)
    { 
      ftext=TimeToString(_Time(bar),TIME_DATE)+","+
            TimeToString(_Time(bar),TIME_MINUTES)+","+
            DoubleToString(_Open(bar),_Digits)+","+
            DoubleToString(_High(bar),_Digits)+","+
            DoubleToString(_Low(bar),_Digits)+","+
            DoubleToString(_Close(bar),_Digits)+","+
            (string)_Volume(bar);

       FileWrite(fhandle,ftext);
    }
    
    FileClose(fhandle);
  }
