//+------------------------------------------------------------------+
//|                                                       tutor2.mq5 |
//|                                 Copyright 2024, Dennis Jorgenson |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Dennis Jorgenson"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
     return(rates_total);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
    ObjectCreate(0,"MyArrow",OBJ_ARROW_UP,
    return(INIT_SUCCEEDED);
  }
