;//+------------------------------------------------------------------+
//|                                                   Session-v1.mq5 |
//|                                 Copyright 2024, Dennis Jorgenson |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Dennis Jorgenson"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property strict

#property indicator_buffers   3
#property indicator_plots     3

#include <Classes/Session.mqh>

//--- plot Off & Prior Session points
#property indicator_label1  "indPriorMid"
#property indicator_type1   DRAW_LINE     
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "indOffMid"
#property indicator_type2   DRAW_LINE;
#property indicator_color2  clrYellow;
#property indicator_style2  STYLE_DOT;
#property indicator_width2  1

#property indicator_label3  "indFractal"
#property indicator_type3   DRAW_LINE;
#property indicator_color3  clrGoldenrod;
#property indicator_style3  STYLE_SOLID;
#property indicator_width3  1

double indPriorBuffer[];
double indOffBuffer[];
double indFractalBuffer[];

//-- Option Enums
enum ShowOptions
     {
       ShowNone,             // None
       ShowActiveSession,    // Active Session
       ShowPriorSession,     // Prior Session
       ShowOffSession,       // Off Session
       ShowOrigin,           // Origin
       ShowTrend,            // Trend
       ShowTerm              // Term
     };

//--- Indicator Inputs
input SessionType    inpType            = SessionTypes;    // Indicator session
input int            inpHourOpen        = NoValue;         // Session Opening Hour
input int            inpHourClose       = NoValue;         // Session Closing Hour
input int            inpHourOffset      = 0;               // Time offset EOD NY 5:00pm
input YesNoType      inpShowRange       = No;              // Show Session Ranges
input FractalType    inpShowFlags       = FractalTypes;    // Show Event Flags
input ShowOptions    inpShowOption      = ShowNone;        // Show Fibonacci/Session Pivots

CSession            *s                  = new CSession(inpType,inpHourOpen,inpHourClose,inpHourOffset,inpShowRange==Yes,inpShowFlags);

PeriodType    ShowSession = PeriodTypes; 
FractalType   ShowFractal = FractalTypes;
string        sObjectStr  = "[s2]";

//+------------------------------------------------------------------+
//| FibonacciStr - Repaint screen elements                           |
//+------------------------------------------------------------------+
string FibonacciStr(string Type, FibonacciRec &Fibonacci)
  {
    string text    = Type;

    Append(text,EnumToString(Fibonacci.Level));
    Append(text,DoubleToString(Fibonacci.Price,_Digits));
    Append(text,DoubleToString(Fibonacci.Percent[Now]*100,1)+"%");
    Append(text,DoubleToString(Fibonacci.Percent[Min]*100,1)+"%");
    Append(text,DoubleToString(Fibonacci.Percent[Max]*100,1)+"%");

    return text;
  }

//+------------------------------------------------------------------+
//| RefreshScreen - Repaint screen elements                          |
//+------------------------------------------------------------------+
void RefreshScreen(void)
  {
    string text    = "";
    
    Append(text,EnumToString(inpType));
    Append(text,BoolToStr(s.IsOpen(),BoolToStr(s.SessionHour()>inpHourClose-3,"Late",BoolToStr(s.SessionHour()>3,"Mid","Early"))+" Session","Session Closed"));
    Append(text,(string)s.SessionHour()," [");
    Append(text,DirText(s[ActiveSession].Direction),"]");
    Append(text,ActionText(s[ActiveSession].Lead));
    Append(text,BoolToStr(s[ActiveSession].Lead==s[ActiveSession].Bias,"","Hedge ["+DirText(Direction(s[ActiveSession].Bias,InAction))+"]"));

    if (ShowSession<PeriodTypes)
    {
      UpdateLine(sObjectStr+"lnS_ActiveMid:"+EnumToString(inpType),s.Pivot(ShowSession),STYLE_SOLID,clrGoldenrod);
      UpdateLine(sObjectStr+"lnS_Low:"+EnumToString(inpType),s[ShowSession].Low,STYLE_DOT,clrMaroon);
      UpdateLine(sObjectStr+"lnS_High:"+EnumToString(inpType),s[ShowSession].High,STYLE_DOT,clrForestGreen);
      
      if (IsEqual(ShowSession,ActiveSession))
      {
        UpdateLine(sObjectStr+"lnS_Support:"+EnumToString(inpType),s[PriorSession].Low,STYLE_SOLID,clrMaroon);
        UpdateLine(sObjectStr+"lnS_Resistance:"+EnumToString(inpType),s[PriorSession].High,STYLE_SOLID,clrForestGreen);
      }
    } 
    else
    if (ShowFractal<FractalTypes)
    {
      int bar      = 80;

      UpdateRay(sObjectStr+"lnS_Origin:"+EnumToString(inpType),bar,s[ShowFractal].Fractal[fpOrigin],-4);
      UpdateRay(sObjectStr+"lnS_Base:"+EnumToString(inpType),bar,s[ShowFractal].Fractal[fpBase],-4);
      UpdateRay(sObjectStr+"lnS_Root:"+EnumToString(inpType),bar,s[ShowFractal].Fractal[fpRoot],-4,0,
                             BoolToInt(IsEqual(s[ShowFractal].Direction,DirectionUp),clrRed,clrLawnGreen));
      UpdateRay(sObjectStr+"lnS_Expansion:"+EnumToString(inpType),bar,s[ShowFractal].Fractal[fpExpansion],-4,0,
                             BoolToInt(IsEqual(s[ShowFractal].Direction,DirectionUp),clrLawnGreen,clrRed));
      UpdateRay(sObjectStr+"lnS_Retrace:"+EnumToString(inpType),bar,s[ShowFractal].Fractal[fpRetrace],-4,0);
      UpdateRay(sObjectStr+"lnS_Recovery:"+EnumToString(inpType),bar,s[ShowFractal].Fractal[fpRecovery],-4,0);

      for (FibonacciType fibo=Fibo161;fibo<FibonacciTypes;fibo++)
      {
        UpdateRay(sObjectStr+"lnS_"+EnumToString(fibo)+":"+EnumToString(inpType),bar,s.Price(fibo,ShowFractal,Extension),-4,0,Color(s[ShowFractal].Direction,IN_DARK_DIR));
        UpdateText(sObjectStr+"lnT_"+EnumToString(fibo)+":"+EnumToString(inpType),"",s.Price(fibo,ShowFractal,Extension),-2,Color(s[ShowFractal].Direction,IN_DARK_DIR));
      }

      for (FractalPoint point=fpBase;IsBetween(point,fpBase,fpRecovery);point++)
        UpdateText(sObjectStr+"lnT_"+fp[point]+":"+EnumToString(inpType),"",s[ShowFractal].Fractal[point],-3);
    }

    for (FractalType type=Origin;IsBetween(type,Origin,Term);type++)
    {
      Append(text,"------- Fibonacci ["+EnumToString(type)+"] ------------------------","\n\n");
      Append(text," "+DirText(s[type].Direction),"\n");
      Append(text,EnumToString(s[type].State));
      Append(text,"["+ActionText(s[type].Pivot.Lead)+"]");
      Append(text,BoolToStr(IsEqual(s[type].Pivot.Bias,s[type].Pivot.Lead),"","Hedge"));
      Append(text,BoolToStr(IsEqual(s[type].Event,NoEvent),""," **"+EventText(s[type].Event)));
      Append(text,FibonacciStr("   Ext: ",s[type].Extension),"\n");
      Append(text,FibonacciStr("   Ret: ",s[type].Retrace),"\n");
    }

    Append(text,s.ActiveEventStr(),"\n\n");

    Comment(text);
  }

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
    LoadRates();

    s.Update(indPriorBuffer,indOffBuffer);
    s.Fractal(indFractalBuffer);

    //for (int r=0;r<rates_total;r++)
    //  Print((string)r+":"+TimeToString(rates[r].time)+":"+
    //                      DoubleToString(rates[r].close,_Digits)+":"+
    //                      DoubleToString(indPriorBuffer[r],_Digits)+":"+
    //                      DoubleToString(indOffBuffer[r],_Digits)+":"+
    //                      DoubleToString(indFractalBuffer[r],_Digits)
    //       );

    RefreshScreen();

    return(rates_total);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
    SetIndexBuffer(0,indPriorBuffer,INDICATOR_DATA);
    PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.00);
    PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_SECTION);
    
    SetIndexBuffer(1,indOffBuffer,INDICATOR_DATA);
    PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.00);
    PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_SECTION);
    
    SetIndexBuffer(2,indFractalBuffer,INDICATOR_DATA);
    PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.00);
    PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_SECTION);

    if (inpShowOption>ShowNone)
    {
      if (inpShowOption<ShowOrigin)
      {
        if (inpShowOption==ShowActiveSession) ShowSession = ActiveSession;
        if (inpShowOption==ShowOffSession)    ShowSession = OffSession;
        if (inpShowOption==ShowPriorSession)  ShowSession = PriorSession;

        NewLine(sObjectStr+"lnS_ActiveMid:"+EnumToString(inpType));
        NewLine(sObjectStr+"lnS_High:"+EnumToString(inpType));
        NewLine(sObjectStr+"lnS_Low:"+EnumToString(inpType));    
        NewLine(sObjectStr+"lnS_Support:"+EnumToString(inpType));
        NewLine(sObjectStr+"lnS_Resistance:"+EnumToString(inpType));
      }
      else
      {    
        if (inpShowOption==ShowOrigin)        ShowFractal = Origin;
        if (inpShowOption==ShowTrend)         ShowFractal = Trend;
        if (inpShowOption==ShowTerm)          ShowFractal = Term;

        NewRay(sObjectStr+"lnS_Origin:"+EnumToString(inpType),clrWhite,STYLE_DOT);
        NewRay(sObjectStr+"lnS_Base:"+EnumToString(inpType),clrYellow,STYLE_SOLID);
        NewRay(sObjectStr+"lnS_Root:"+EnumToString(inpType),clrDarkGray,STYLE_SOLID);
        NewRay(sObjectStr+"lnS_Expansion:"+EnumToString(inpType),clrDarkGray,STYLE_SOLID);
        NewRay(sObjectStr+"lnS_Retrace:"+EnumToString(inpType),clrGoldenrod,STYLE_DOT);
        NewRay(sObjectStr+"lnS_Recovery:"+EnumToString(inpType),clrSteelBlue,STYLE_DOT);

        for (FractalPoint point=fpBase;IsBetween(point,fpBase,fpRecovery);point++)
          NewText(sObjectStr+"lnT_"+fp[point]+":"+EnumToString(inpType),fp[point]);

        for (FibonacciType fibo=Fibo161;fibo<FibonacciTypes;fibo++)
        {
          NewRay(sObjectStr+"lnS_"+EnumToString(fibo)+":"+EnumToString(inpType),clrDarkGray,STYLE_DOT);
          NewText(sObjectStr+"lnT_"+EnumToString(fibo)+":"+EnumToString(inpType),DoubleToString(fibonacci[fibo]*100,1)+"%");
        }
      }
    }

    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
    delete s;
  }
