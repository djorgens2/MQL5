//+------------------------------------------------------------------+
//|                                                       tutor3.mq5 |
//|                                 Copyright 2024, Dennis Jorgenson |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Dennis Jorgenson"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Classes/Event.mqh>

  CEvent *ev    = new CEvent();

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    ev.SetEvent(NewBreakout,Nominal);
    ev.SetEvent(NewHigh,Nominal);
    ev.SetEvent(NewBoundary,Nominal);
    ev.SetEvent(NewBoundary,Minor);
    ev.SetEvent(NewBoundary,Major);

    if (ev.ActiveEvent())
    {
      Print(ev.EventStr());
      Print(ev.ActiveEventStr());
      Print(ev.EventLogStr());
    }
    
    ev.ClearEvents();    
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
    if (LoadRates()>NoValue)
    {
      ev.ClearEvents();
      ev.SetEvent(SessionOpen);
    }
    
    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
    delete ev;
   
  }

