//+------------------------------------------------------------------+
//|                                                      Session.mqh |
//|                                 Copyright 2024, Dennis Jorgenson |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Dennis Jorgenson"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Classes/Fractal.mqh>

const color          AsiaColor       = C'0,32,0';    // Asia session box color
const color          EuropeColor     = C'48,0,0';    // Europe session box color
const color          USColor         = C'0,0,56';    // US session box color
const color          DailyColor      = C'64,64,0';   // US session box color

         //-- Period Types
         enum PeriodType
         {
           OffSession,    // Off-Session
           PriorSession,  // Prior (Closed) Session
           ActiveSession, // Active (Open) Session
           PeriodTypes    // None
         };

         //-- Session Types
         enum SessionType
         {
           Daily,
           Asia,
           Europe,
           US,
           SessionTypes  // None
         };

         struct SessionRec
         {
           int            Direction;
           int            Bias;
           int            Lead;
           double         High;
           double         Low;
         };

         struct BufferRec
         {
           double        Price[];
         };

class CSession : public CFractal
  {

    private:

         //--- Panel Indicators
         string           indSN;
         int              indWinId;

         //--- Private Class properties
         SessionType      sType;

         bool             sIsOpen;
         bool             sShowRanges;
         string           sObjectStr;

         int              sHourOpen;
         int              sHourClose;
         int              sHourOffset;

         long             sBar;
         long             sBars;
         int              sBarDay;
         int              sBarHour;
         
         void             CreateRange(void);
         void             UpdateRange(void);
         void             UpdateBuffers(void);

         void             InitSession(EventType Event);
         void             UpdatePanel(void);
         void             UpdateSession(void);
         void             OpenSession(void);
         void             CloseSession(void);

         SessionRec       srec[PeriodTypes];
         BufferRec        sbuf[PeriodTypes];
         
    public:

                          CSession(SessionType Type, int HourOpen, int HourClose, int HourOffset, bool ShowRange, FractalType ShowFlags);
                         ~CSession();

         void             Update(void);
         void             Update(double &PriorBuffer[], double &OffBuffer[]);

         MqlDateTime      ServerTime(void);
         int              SessionHour(void);
         int              HourOpen(void)    {return sHourOpen;};
         int              HourClose(void)   {return sHourClose;};
      
         bool             IsOpen(void);
         color            Color(SessionType Type, GammaType Gamma);

         double           Pivot(const PeriodType Period)       {return fdiv(srec[Period].High+srec[Period].Low,2,_Digits);};
         BufferRec        Buffer(PeriodType Period)            {return sbuf[Period];};

         SessionRec       operator[](const PeriodType Period)  {return srec[Period];};

         string           BufferStr(PeriodType Period);
         string           SessionStr(string Title="");
  };

//+------------------------------------------------------------------+
//| CreateRange - Creates active session frames on Session Open      |
//+------------------------------------------------------------------+
void CSession::CreateRange(void)
 {
   if (sShowRanges)
   {
     string range       = sObjectStr+EnumToString(sType)+":"+TimeToString(_Time(sBar),TIME_DATE);

     ObjectCreate(0,range,OBJ_RECTANGLE,0,_Time(sBar),srec[ActiveSession].High,_Time(sBar),srec[ActiveSession].Low);

     ObjectSetInteger(0,range, OBJPROP_STYLE,STYLE_SOLID);
     ObjectSetInteger(0,range, OBJPROP_COLOR,Color(sType,Dark));
     ObjectSetInteger(0,range, OBJPROP_BACK,true);
     ObjectSetInteger(0,range, OBJPROP_FILL,true);
   }
 }

//+------------------------------------------------------------------+
//| UpdateRange - Repaints active session frame                      |
//+------------------------------------------------------------------+
void CSession::UpdateRange(void)
  {
    if (sShowRanges)
    {
      string range       = sObjectStr+EnumToString(sType)+":"+TimeToString(_Time(sBar),TIME_DATE);

      if (CEvent::Event(NewHour))
        if (sIsOpen||CEvent::Event(SessionClose))
          ObjectSetInteger(0,range,OBJPROP_TIME,1,_Time(sBar));

      if (sIsOpen)
      {
        if (CEvent::Event(NewHigh))
          ObjectSetDouble(0,range,OBJPROP_PRICE,srec[ActiveSession].High);

        if (CEvent::Event(NewLow))
          ObjectSetDouble(0,range,OBJPROP_PRICE,1,srec[ActiveSession].Low);
      }
    }
  }

//+------------------------------------------------------------------+
//| UpdateSession - Sets active state, bounds and alerts on the tick |
//+------------------------------------------------------------------+
void CSession::UpdateSession(void)
  {
    int direction          = Direction(_Close(sBar)-BoolToDouble(IsOpen(),Pivot(OffSession),Pivot(PriorSession)));

    SessionRec session     = srec[ActiveSession];
    AlertType  alert       = (AlertType)BoolToInt(IsEqual(srec[ActiveSession].Direction,direction),Nominal,Notify);

    if (IsHigher(_High(sBar),srec[ActiveSession].High))
    {
      SetEvent(NewHigh,alert,srec[ActiveSession].High);
      SetEvent(NewBoundary,alert,session.High);
    }

    if (IsLower(_Low(sBar),srec[ActiveSession].Low))
    {
      SetEvent(NewLow,alert,srec[ActiveSession].Low);
      SetEvent(NewBoundary,alert,session.Low);
    }

    if (CEvent::Event(NewBoundary))
    {
      if (DirectionChanged(srec[ActiveSession].Direction,Direction(Pivot(ActiveSession)-BoolToDouble(IsOpen(),Pivot(PriorSession),Pivot(OffSession)))))
        SetEvent(NewDirection,Nominal);
      
      if (CEvent::Event(NewHigh)&&CEvent::Event(NewLow))
      {
        SetEvent(AdverseEvent,BoolToAlert(_High(sBar)>srec[PriorSession].High&&_Low(sBar)<srec[PriorSession].Low,Major,Minor),
          BoolToDouble(IsEqual(srec[ActiveSession].Lead,OP_BUY),srec[ActiveSession].High,srec[ActiveSession].Low,_Digits));

        if (CEvent::Event(AdverseEvent,Major))
          Print(TimeToString(_Time(sBar))+":"+sObjectStr+":"+EnumToString(CEvent::Alert(AdverseEvent))+":Outside Reversal Anomaly; Please Verify");
      }
      else
        if (IsChanged(srec[ActiveSession].Lead,BoolToInt(CEvent::Event(NewHigh),OP_BUY,OP_SELL)))
          SetEvent(NewLead,Nominal,BoolToDouble(CEvent::Event(NewHigh),session.High,session.Low,_Digits));
    }

    if (ActionChanged(srec[ActiveSession].Bias,Action(direction)))
    {
      SetEvent(NewBias,alert,BoolToDouble(IsOpen(),Pivot(PriorSession),Pivot(OffSession)));
      SetEvent(BoolToEvent(IsEqual(alert,Notify),NewDivergence,NewConvergence),alert,BoolToDouble(IsOpen(),Pivot(PriorSession),Pivot(OffSession)));
    }
  }

//+------------------------------------------------------------------+
//| UpdateBuffers - updates indicator buffer values                  |
//+------------------------------------------------------------------+
void CSession::UpdateBuffers(void)
  {
    double insert[1]  = {0.00};
    
    for (sBars=sBars;sBars<_Bars;sBars++)
      for (PeriodType period=OffSession;period<PeriodTypes;period++)
        ArrayInsert(sbuf[period].Price,insert,0);
//      {
//        ArrayResize(sbuf[period].Price,(int)sBars,10);
//        ArrayCopy(sbuf[period].Price,sbuf[period].Price,1,0,WHOLE_ARRAY);
//        
//        sbuf[period].Price[0]             = 0.00;
//      }
  }

//+------------------------------------------------------------------+
//| UpdatePanel - updates control panel if loaded                    |
//+------------------------------------------------------------------+
void CSession::UpdatePanel(void)
  {
    static FractalType pivot  = Term;

    indSN     = "CPanel-v2";
    indWinId  = ChartWindowFind(0,indSN);

    if (CEvent::Event(NewFibonacci))
      pivot                   = (FractalType)BoolToInt(CEvent::Event(NewFibonacci,Critical),Origin,
                                             BoolToInt(CEvent::Event(NewFibonacci,Major),Trend,Term));

    if (indWinId>NoValue)
    {
      if (IsEqual(sType,Daily))
      {
        UpdateDirection("tmaSessionTrendDir"+(string)indWinId,frec[Trend].Direction,Color(frec[Trend].Direction),16);
        UpdateDirection("tmaSessionTermDir"+(string)indWinId,frec[Term].Direction,Color(frec[Term].Direction),32);
        UpdateLabel("tmaSessionState"+(string)indWinId,rpad(EnumToString(frec[Trend].State)," ",20),Color(frec[Trend].Direction),12,"Noto Sans Mono CJK HK");
        UpdateLabel("tmaSessionFractalState"+(string)indWinId,rpad(EnumToString(pivot)+" "+EnumToString(frec[pivot].State)," ",20),Color(frec[pivot].Direction),12,"Noto Sans Mono CJK HK");
        UpdateLabel("tmaSessionPivotRet"+(string)indWinId,StringSubstr(EnumToString(frec[pivot].Retrace.Level),4,4),Color(Direction(frec[pivot].Pivot.Lead,InAction)),10,"Noto Sans Mono CJK HK");
        UpdateLabel("tmaSessionPivotExt"+(string)indWinId,StringSubstr(EnumToString(frec[pivot].Extension.Level),4),Color(Direction(frec[pivot].Pivot.Bias,InAction)),10,"Noto Sans Mono CJK HK");
        UpdateDirection("tmaSessionPivotLead"+(string)indWinId,Direction(frec[pivot].Pivot.Lead,InAction),Color(Direction(frec[pivot].Pivot.Lead,InAction)),16);
        UpdateDirection("tmaSessionPivotBias"+(string)indWinId,Direction(frec[pivot].Pivot.Bias,InAction),Color(Direction(frec[pivot].Pivot.Bias,InAction)),16);
      }

      //-- Update Control Panel (Session)
       if (ObjectGetInteger(indWinId,"bxhAI-Session"+EnumToString(sType),OBJPROP_BGCOLOR)==clrBoxOff||CEvent::Event(NewTerm)||CEvent::Event(NewHour))
       {
         UpdateBox("bxhAI-Session"+EnumToString(sType),Color(frec[Term].Direction,IN_DARK_DIR));
         UpdateBox("bxbAI-OpenInd"+EnumToString(sType),BoolToInt(IsOpen(),clrYellow,clrBoxOff));
       }
    }
  }

//+------------------------------------------------------------------+
//| InitSession - Handle session changeovers; Open->Close;Close->Open|
//+------------------------------------------------------------------+
void CSession::InitSession(EventType Event)
  {
    //-- Catch session changeover Boundary Events
    UpdateSession();

    //-- Set ActiveSession support/resistance
    srec[ActiveSession].High              = _Open(sBar);
    srec[ActiveSession].Low               = _Open(sBar);

    SetEvent(Event,Notify);
  }

//+------------------------------------------------------------------+
//| OpenSession - Initializes active session start values on open    |
//+------------------------------------------------------------------+
void CSession::OpenSession(void)
  {
    //-- Update OffSession Record and Indicator Buffer      
    srec[OffSession]                      = srec[ActiveSession];
    sbuf[OffSession].Price[sBar]          = Pivot(OffSession);

    InitSession(SessionOpen);    
    CreateRange();
  }

//+------------------------------------------------------------------+
//| CloseSession - Closes active session start values on close       |
//+------------------------------------------------------------------+
void CSession::CloseSession(void)
  {        
    //-- Update Prior Record, range history, and Indicator Buffer
    srec[PriorSession]                    = srec[ActiveSession];
    sbuf[PriorSession].Price[sBar]        = Pivot(PriorSession);

    InitSession(SessionClose);
  }

//+------------------------------------------------------------------+
//| CSession Constructor                                             |
//+------------------------------------------------------------------+
CSession::CSession(SessionType Type, int HourOpen, int HourClose, int HourOffset, bool ShowRanges=false, FractalType ShowFlags=FractalTypes) : CFractal (ShowFlags)
  {
    double high[];
    double low[];

    //--- Initialize period operationals
    sBar                             = InitHistory(_Period,_Bars-1)-1;
    sBars                            = _Bars;
    sBarDay                          = ServerTime().day;
    sBarHour                         = NoValue;

    sType                            = Type;
    sHourOpen                        = HourOpen;
    sHourClose                       = HourClose;
    sHourOffset                      = HourOffset;

    sIsOpen                          = IsOpen();
    sShowRanges                      = ShowRanges;
    sObjectStr                       = "[session]";

    CopyHigh(NULL,PERIOD_D1,_Time(sBar)+1,1,high);
    CopyLow(NULL,PERIOD_D1,_Time(sBar)+1,1,low);

    //--- Initialize session records
    for (PeriodType period=OffSession;period<PeriodTypes;period++)
    {
      srec[period].Direction         = NewDirection;
      srec[period].High              = high[0];
      srec[period].Low               = low[0];

      ArraySetAsSeries(sbuf[period].Price,true);
      ArrayResize(sbuf[period].Price,_Bars);
      ArrayInitialize(sbuf[period].Price,0.00);
    }

    if (sIsOpen)
      CreateRange();

    for (sBar=sBar;sBar>0;sBar--)
      Update();
  }

//+------------------------------------------------------------------+
//| CSession Destructor                                              |
//+------------------------------------------------------------------+
CSession::~CSession()
  {
    RemoveChartObjects(sObjectStr);
  }

//+------------------------------------------------------------------+
//| ServerTime - Returns offset-adjusted time detail                 |
//+------------------------------------------------------------------+
MqlDateTime CSession::ServerTime(void)
  {
    MqlDateTime date;
    TimeToStruct(_Time(sBar)+(PERIOD_H1*60*sHourOffset),date);
    return date;
  };
  
  
//+------------------------------------------------------------------+
//| ServerHour - Returns offset-adjusted time detail                 |
//+------------------------------------------------------------------+  
int CSession::SessionHour(void)
  {
    return BoolToInt(IsOpen(),ServerTime().hour-(sHourOpen+1),NoValue);
  };


//+------------------------------------------------------------------+
//| Update - Computes fractal using supplied fractal and price       |
//+------------------------------------------------------------------+
void CSession::Update(void)
  {
    //--- Tick Setup
    ClearEvents();
    UpdateBuffers();

    //--- Test for New Day; Force close
    if (IsChanged(sBarDay,ServerTime().day))
    {
      SetEvent(NewDay,Notify);
      
      if (IsChanged(sIsOpen,false))
        CloseSession();
    }
    
    if (IsChanged(sBarHour,ServerTime().hour))
      SetEvent(NewHour,Notify);

    //--- Calc events session open/close
    if (IsChanged(sIsOpen,IsOpen()))
      if (sIsOpen)
        OpenSession();
      else
        CloseSession();
        
    UpdateSession();
    UpdateRange();
    UpdateFractal(srec[PriorSession].Low,srec[PriorSession].High,Pivot(OffSession),(int)sBar);
    UpdatePanel();
  }

//+------------------------------------------------------------------+
//| Update - Computes fractal using supplied fractal and price       |
//+------------------------------------------------------------------+
void CSession::Update(double &PriorBuffer[], double &OffBuffer[])
  {
    Update();

    ArrayCopy(PriorBuffer,sbuf[PriorSession].Price,0,0,WHOLE_ARRAY);
    ArrayCopy(OffBuffer,sbuf[OffSession].Price,0,0,WHOLE_ARRAY);
  }

//+------------------------------------------------------------------+
//| IsOpen - Returns true if session is open for trade               |
//+------------------------------------------------------------------+
bool CSession::IsOpen(void)
  {
    if (ServerTime().day_of_week<6)
      if (ServerTime().hour>=sHourOpen && ServerTime().hour<sHourClose)
        return (true);

    return (false);
  }

//+------------------------------------------------------------------+
//| Color - Returns the color for session ranges                     |
//+------------------------------------------------------------------+
color CSession::Color(SessionType Type, GammaType Gamma)
  {
    switch (Type)
    {
      case Asia:    return (color)BoolToInt(Gamma==Dark,AsiaColor,clrForestGreen);
      case Europe:  return (color)BoolToInt(Gamma==Dark,EuropeColor,clrFireBrick);
      case US:      return (color)BoolToInt(Gamma==Dark,USColor,clrSteelBlue);
      case Daily:   return (color)BoolToInt(Gamma==Dark,DailyColor,clrDarkGray);
    }

    return (clrBlack);
  }

//+------------------------------------------------------------------+
//| BufferStr - Returns formatted Buffer data for supplied Period    |
//+------------------------------------------------------------------+
string CSession::BufferStr(PeriodType Period)
  {  
    string text            = EnumToString(Period);

    for (int bar=0;bar<_Bars;bar++)
      if (sbuf[Period].Price[bar]>0.00)
      {
        Append(text,(string)bar,"|");
        Append(text,TimeToString(_Time(bar)),"|");
        Append(text,DoubleToString(sbuf[Period].Price[bar],_Digits),"|");
      }

    return(text);
  }

//+------------------------------------------------------------------+
//| SessionStr - Returns formatted Session data for supplied type    |
//+------------------------------------------------------------------+
string CSession::SessionStr(string Title="")
  {  
    string text            = Title;

    Append(text,EnumToString(sType),"|");
    Append(text,BoolToStr(IsOpen(),"Open","Closed"),"|");
    Append(text,BoolToStr(IsOpen(),BoolToStr(SessionHour()>sHourClose-3,"Late",BoolToStr(SessionHour()>3,"Mid","Early")),"Closed"),"|");
    Append(text,(string)SessionHour(),"|");
    Append(text,BufferStr(PriorSession),"|");
    Append(text,BufferStr(OffSession),"|");

    return(text);
  }
