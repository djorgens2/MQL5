//+------------------------------------------------------------------+
//|                                                      stdutil.mqh |
//|                                 Copyright 2024, Dennis Jorgenson |
//|                                               Standard Utilities |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Dennis Jorgenson"
#property link      ""
#property strict

#import "user32.dll"
   int MessageBoxW(int Ignore, string Caption, string Title, int Icon);
#import


//-- Macros for MQL4->5 Compatibility
MqlRates rates[];
 
#define _Open(b) rates[b].open
#define _High(b) rates[b].high
#define _Low(b) rates[b].low
#define _Close(b) rates[b].close
#define _Time(b) rates[b].time
#define _Volume(b) rates[b].tick_volume
 
#define _Bars Bars(_Symbol, _Period)
#define _Day(b) TimeDayMQL4(rates[b].time)
#define _Hour(b) TimeHourMQL4(rates[b].time)

//--- Declaration of constants
#define OP_BUY 0           //Buy 
#define OP_SELL 1          //Sell 
#define OP_BUYLIMIT 2      //Pending order of BUY LIMIT type No
#define OP_SELLLIMIT 3     //Pending order of SELL LIMIT type 
#define OP_BUYSTOP 4       //Pending order of BUY STOP type 
#define OP_SELLSTOP 5      //Pending order of SELL STOP type 
//---
#define MODE_OPEN 0
#define MODE_CLOSE 3
#define MODE_VOLUME 4 
#define MODE_REAL_VOLUME 5
#define MODE_TRADES 0
#define MODE_HISTORY 1
#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1
//---
#define DOUBLE_VALUE 0
#define FLOAT_VALUE 1
#define LONG_VALUE INT_VALUE
//---
#define CHART_BAR 0
#define CHART_CANDLE 1
//---
#define MODE_ASCEND 0
#define MODE_DESCEND 1
//---
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE__Digits 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_SWAPTYPE 26
#define MODE_PROFITCALCMODE 27
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33
//---
#define EMPTY -1

//--- Standard diectional defines
#define DirectionDown        -1
#define NoDirection           0      //---No Direction
#define DirectionUp           1

//--- Null value defines
#define NoValue              -1

//--- additional op/action codes
#define NoAction             -1      //--- Updated Nomenclature
#define NoBias               -1      //--- New Nomen for Bias (Directional Action)

//--- Numeric format defines
#define InInteger             0      //--- Double conversion to int
#define InPercent             1      //--- Double conversion to int+1
#define InDecimal             2      //--- Return in decimal, raw calculation
#define InDollar              3      //--- Stated in dollars
#define InEquity              4      //--- Stated as a percent of equity
#define InDirection           5      //--- Stated as a Direction
#define InAction              6      //--- Stated as an Action
#define InState               7      //--- State definition

//--- logical defines
#define InTrueFalse          11      //--- Stated as True or False
#define InYesNo              12      //--- Stated as Yes or No
#define Always             true
#define Never             false

//--- Option type defs
#define InContrarian       true      //--- Return as contrarian direction/action
#define NoUpdate          false      //--- Return without update
#define On                 true      //--- Turn Feature On
#define Off               false      //--- Turn Feature Off

//---- Format Constants
#define IN_DIRECTION          8
#define IN_ACTION             9
#define IN_PROXIMITY         10
#define IN_DARK_DIR          11
#define IN_CHART_DIR         12
#define IN_CHART_ACTION      13
#define IN_DARK_PANEL        14

#define clrBoxOff    C'60,60,60'

//---- Screen Locations
#define SCREEN_UL             0
#define SCREEN_UR             1
#define SCREEN_LL             2
#define SCREEN_LR             3

//--- Global enums
enum ArrowType
     {
       ArrowUp       = 241,
       ArrowDown     = 242,
       ArrowDash     = 4,
       ArrowHold     = 73,
       ArrowCheck    = 252,
       ArrowStop     = 251,
       ArrowHalt     = 78
     };

enum StyleType
     {
       Wide,
       Narrow,
       StyleTypes
     };

enum GammaType
     {
       Bright,
       Dark
     };

enum YesNoType
     {
       Yes,
       No
     };

enum FeatureType
     {
       Disabled,        // Disabled
       Enabled          // Enabled
     };

enum OutputFormat
     {
       Display,         // Formatted for Screen
       Logfile          // Formatted for Log
     };

//--- Quantitative measure types
enum SummaryType
     { 
       Loss,     //--
       Net,      //-- Hard Sequence
       Profit,   //-- ** DO NOT MODIFY
       Total,    //--            
       Count,
       Highest,
       Lowest,
       SummaryTypes
     };
             
enum MeasureType
     {
       Now,
       Min,    
       Max,    
       MeasureTypes      //--- must be last
     };


int TimeDayMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day);
  }

int TimeDayOfWeekMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
  }

int TimeDayOfYearMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_year);
  }

int TimeHourMQL4(datetime date)
  {
    MqlDateTime tm;
    TimeToStruct(date,tm);
    return(tm.hour);
  }

//+------------------------------------------------------------------+
//| LoadRates - Updates the MQL rate array                           |
//+------------------------------------------------------------------+
long LoadRates(void)
  {
    ArraySetAsSeries(rates,true);

    return(CopyRates(_Symbol,_Period,0,_Bars,rates));
  }

//+------------------------------------------------------------------+
//| Pause - pauses execution and waits for user input                |
//+------------------------------------------------------------------+
int Pause(string Message, string Title, int Style=64)
  {
    //if (IsTesting())
    //  return (MessageBoxW(0, Message, Title, Style));

    Alert(Symbol()+"> "+Title+"\n"+Message);
    
    return (0);
  }

//+------------------------------------------------------------------+
//| rpad - right pads a value with the character and length supplied |
//+------------------------------------------------------------------+
string rpad(string Value, string Pad, int Length)
  {
    if (StringLen(Value)<Length)
      for (int idx=Length-StringLen(Value);idx>0;idx--)
        Value += Pad;
    
    return Value;
  }

//+------------------------------------------------------------------+
//| lpad - returns a numeric string padded for negative sign         |
//+------------------------------------------------------------------+
string lpad(double Value, int Precision, int Length=NoValue)
  {
    string text = BoolToStr(Value<0.00,""," ")+DoubleToString(Value,Precision);
    
    return lpad(text," ",fmax(StringLen(text),Length));
  }

//+------------------------------------------------------------------+
//| lpad - left pads a value with the character and length supplied  |
//+------------------------------------------------------------------+
string lpad(string Value, string Pad, int Length)
  {
    if (StringLen(Value)<Length)
      for (int idx=Length-StringLen(Value);idx>0;idx--)
        Value = Pad+Value;
    
    return Value;
  }

//+------------------------------------------------------------------+
//| quote - wraps text in double quotes                              |
//+------------------------------------------------------------------+
string quote(string Text)
  {
    return "\""+Text+"\"";
  }

//+------------------------------------------------------------------+
//| SplitStr - returns element count after parsing by supplied delim |
//+------------------------------------------------------------------+
int SplitStr(string Text, string Delim, string &Split[])
  {
    StringTrimLeft(Text);
    StringTrimRight(Text);

    ArrayResize(Split,0,12);
    
    if (StringLen(Text)==0)
      return NoValue;
    
    if (StringFind(Text,Delim)==NoValue)
      Text = Text+Delim;

    if (StringSubstr(Text,StringLen(Text)-StringLen(Delim))!=Delim)
      Text = Text+Delim;
    
    while (StringLen(Text)>0)
    {
      ArrayResize(Split,ArraySize(Split)+1,12);

      if (StringSubstr(Text,0,1)=="\"")
      {
        if (StringFind(Text,"\"",1)==NoValue)
        {
          Print("Unterminated string");
          return NoValue;
        }
        
        if (StringSubstr(Text,StringFind(Text,"\"",1)+StringLen(Delim),StringLen(Delim))!=Delim)
        {
          Print("Malformed string; \""+StringSubstr(Text,StringFind(Text,"\"",1)+1,StringLen(Delim))+"\" <> \""+Delim+"\":"+Text);
          return NoValue;
        }
        
        Split[ArraySize(Split)-1] = StringSubstr(Text,1,StringFind(Text,"\"",1)-1);
        Text                      = StringSubstr(Text,StringLen(Split[ArraySize(Split)-1])+StringLen(Delim)+2);
      }
      else
      {
        Split[ArraySize(Split)-1] = upper(StringSubstr(Text,0,StringFind(Text,Delim)));
        Text                      = StringSubstr(Text,StringFind(Text,Delim)+StringLen(Delim));
      }
    }

    return ArraySize(Split);
  }

//+------------------------------------------------------------------+
//| Operation - translates Pending Order Types to Market Actions     |
//+------------------------------------------------------------------+
int Operation(int Action, bool Contrarian=false)
  {
    if (IsEqual(Action,OP_BUY)||IsEqual(Action,OP_BUYLIMIT)||IsEqual(Action,OP_BUYSTOP))
      return (BoolToInt(Contrarian,OP_SELL,OP_BUY));

    if (IsEqual(Action,OP_SELL)||IsEqual(Action,OP_SELLLIMIT)||IsEqual(Action,OP_SELLSTOP))
      return (BoolToInt(Contrarian,OP_BUY,OP_SELL));
    
    return (NoValue);  //-- << clean up for another day
  }

//+------------------------------------------------------------------+
//| Action - translates price direction into order action            |
//+------------------------------------------------------------------+
int Action(double Value, int ValueType=InDirection, bool Contrarian=false)
  {
    int       dContrarian     = BoolToInt(Contrarian,-1,1);
    
    switch (ValueType)
    {
      case InDirection:   Value         *= dContrarian;
                          break;

      case InAction:      if (Value==OP_BUY||Value==OP_BUYLIMIT||Value==OP_BUYSTOP)
                            Value        = DirectionUp*dContrarian;
                          else
                          if (Value==OP_SELL||Value==OP_SELLLIMIT||Value==OP_SELLSTOP)
                            Value        = DirectionDown*dContrarian;
                          else
                            Value        = NoDirection;
    }
    
    if (IsLower(NoDirection,Value))  return (OP_BUY);
    if (IsHigher(NoDirection,Value)) return (OP_SELL);
    
    return (NoAction);
  }

//+------------------------------------------------------------------+
//| Direction - order action translates into price direction         |
//+------------------------------------------------------------------+
int Direction(double Value, int ValueType=InDirection, bool Contrarian=false)
  {
    int       dContrarian     = BoolToInt(Contrarian,-1,1);
    
    switch (ValueType)
    {
      case InDirection:   Value         *= dContrarian;
                          break;
      case InAction:      if (Value==OP_BUY||Value==OP_BUYLIMIT||Value==OP_BUYSTOP)
                            Value        = DirectionUp*dContrarian;
                          else
                          if (Value==OP_SELL||Value==OP_SELLLIMIT||Value==OP_SELLSTOP)
                            Value        = DirectionDown*dContrarian;
                          else
                            Value        = NoDirection;
    }
    
    if (IsLower(NoDirection,Value,false,8))  return (DirectionUp);
    if (IsHigher(NoDirection,Value,false,8)) return (DirectionDown);
    
    return (NoDirection);
  }

//+------------------------------------------------------------------+
//| ActionText - returns the text of an ActionCode                   |
//+------------------------------------------------------------------+
string ActionText(int Action)
  {
    switch (Action)
    {
      case OP_BUY           : return("BUY");
      case OP_BUYLIMIT      : return("BUY LIMIT");
      case OP_BUYSTOP       : return("BUY STOP");
      case OP_SELL          : return("SELL");
      case OP_SELLLIMIT     : return("SELL LIMIT");
      case OP_SELLSTOP      : return("SELL STOP");
      case NoAction         : return("NO ACTION");
      default               : return("BAD ACTION CODE");
    }
  }

//+------------------------------------------------------------------+
//| ActionChanged - Sets Action on change; filters NoAction          |
//+------------------------------------------------------------------+
bool ActionChanged(int &Change, int Compare, bool Update=true)
  {
    if (Compare==NoAction)
      return (false);
      
    return (IsChanged(Change,Compare,Update));
  }

//+------------------------------------------------------------------+
//| DirectionChanged - Sets Direction on change; filters NoDirection |
//+------------------------------------------------------------------+
bool DirectionChanged(int &Change, int Compare, bool Update=true)
  {
    if (IsBetween(Compare,DirectionUp,DirectionDown))
    {
      if (Compare==NoDirection)
        return (false);
    }
    else return (false);
      
    if (Change==NoDirection)
      if (IsChanged(Change,Compare,Update))
        return (false);
    
    return (IsChanged(Change,Compare,Update));
  }

//+------------------------------------------------------------------+
//| pip - returns the Value in pips based on the current Symbol()    |
//+------------------------------------------------------------------+
double pip(double Value)
  {
    return (NormalizeDouble(Value * pow(10, _Digits-1), _Digits));
  }


//+------------------------------------------------------------------+
//| point - returns the Value in points based on the current Symbol()|
//+------------------------------------------------------------------+
double point(double Value, int Precision=0)
  {
    return (NormalizeDouble(Value/pow(10,_Digits-1),BoolToInt(IsEqual(Precision,0),_Digits,Precision)));
  }

//+------------------------------------------------------------------+
//| proper - a proper case string                                    |
//+------------------------------------------------------------------+
string proper(string Value)
{
  bool     check;
  string   upper  = Value;
  
  check = StringToLower(Value);
  check = StringToUpper(upper);
  
  for (int idx=1; idx<StringLen(Value); idx++)    
    if (StringSubstr(Value,idx-1,1) == " ")
      StringReplace(Value,StringSubstr(Value,idx-1,2),StringSubstr(upper,idx-1,2));

  return(StringSubstr(upper,0,1)+StringSubstr(Value,1,StringLen(Value)-1));
}

//+------------------------------------------------------------------+
//| dollar - returns dollar formatted string by pad/precision        |
//+------------------------------------------------------------------+
string dollar(double Value, int Length, bool WithCents=false)
{
  int    precision   = BoolToInt(WithCents,2,0);
  int    scale       = 0;
  string invalue     = DoubleToString(fabs(Value),0);
  string outvalue    = "";

  for (int pos=StringLen(invalue);pos>0;pos--)
    if (fmod(scale++,3)==0&&scale>1)
      outvalue       = StringSubstr(invalue,pos-1,1)+","+outvalue;
    else
      outvalue       =  StringSubstr(invalue,pos-1,1)+outvalue;

  if (Value<0)
    outvalue         = "-"+outvalue;

  return(lpad(outvalue," ",Length));
}

//+------------------------------------------------------------------+
//| center - center a string                                         |
//+------------------------------------------------------------------+
string center(string Text, int Length, string Filler=" ")
{
  string text    = "";
  double pad     = BoolToDouble(StringLen(Text)<Length,fdiv(Length-StringLen(Text),2),0,2);

  for (int pos=0;pos<pad;pos++)
    text        += Filler;
  
  return text+" "+Text+" "+text;
}

//+------------------------------------------------------------------+
//| upper - a uppercase string                                       |
//+------------------------------------------------------------------+
string upper(string Value)
{
  string   uUpper  = Value;
  
  if (StringToUpper(uUpper))
    return(uUpper);
 
  return(NULL);
}

//+------------------------------------------------------------------+
//| lower - a lowercase string                                       |
//+------------------------------------------------------------------+
string lower(string Value)
{
  string   lLower  = Value;
  
  if (StringToLower(lLower))
    return(lLower);
 
  return(NULL);
}

//+------------------------------------------------------------------+
//| DirText - returns the text of a DirectionCode                    |
//+------------------------------------------------------------------+
string DirText(int Direction, bool Contrarian=false)
{
  if (Contrarian)
    Direction *= NoValue;
    
  switch (Direction)
  {
    case DirectionUp:    return("Long");
    case NoDirection:    return("Flat");
    case DirectionDown:  return("Short");
//    case NewDirection:   return("Pending");
    case -2:   return("Pending");
  }

  return("BAD DIRECTION CODE");
}

//+------------------------------------------------------------------+
//| Color - returns the color based on the supplied Value            |
//+------------------------------------------------------------------+
color Color(double Value, int Method=IN_DIRECTION, bool Contrarian=false)
{
  if (Contrarian)
    Value       *= -1.0;  
  
  switch (Method)
  {
    case IN_PROXIMITY:     if (IsEqual(Value,0.00))       return(clrDarkGray);
                           if (_Close(0)>Value+point(6))   return(clrLawnGreen);
                           if (_Close(0)>Value+point(3))   return(clrYellowGreen);
                           if (_Close(0)>Value+point(0.2)) return(clrMediumSeaGreen);
                           if (_Close(0)>Value-point(0.2)) return(clrYellow);
                           if (_Close(0)>Value-point(3))   return(clrGoldenrod);
                           if (_Close(0)>Value-point(6))   return(clrChocolate);
                           return (clrRed);
    case IN_DIRECTION:     if (Value<0.00) return (clrRed);
                           if (Value>0.00) return (clrLawnGreen);
    case IN_DARK_DIR:      if (Value<0.00) return (clrMaroon);
                           if (Value>0.00) return (clrDarkGreen);
    case IN_CHART_DIR:     if (Value<0.00) return (clrRed);
                           if (Value>0.00) return (clrYellow);
                           return (clrDarkGray);
    case IN_DARK_PANEL:    if (Value<0.00) return (C'42,0,0');
                           if (Value>0.00) return (C'0,42,0');
                           return (clrDarkGray);
    case IN_ACTION:        if (Action(Value,InAction)==OP_BUY)  return (clrLawnGreen);
                           if (Action(Value,InAction)==OP_SELL) return (clrRed);
                           return (clrYellow);
    case IN_CHART_ACTION:  if (Action(Value,InAction)==OP_BUY)  return (clrYellow);
                           if (Action(Value,InAction)==OP_SELL) return (clrRed);
  }
  
  return (clrDarkGray);
}

//+------------------------------------------------------------------+
//| Append - appends text string to supplied string with separator   |
//+------------------------------------------------------------------+
void Append(string &Source, string Text, string Separator=" ")
  {
    if (StringLen(Source)>0 && StringLen(Text)>0)
      Source += Separator;
      
    Source += Text;
  }

//+------------------------------------------------------------------+
//| InStr - Returns true if pattern is found in source string        |
//+------------------------------------------------------------------+
bool InStr(string Source, string Search, int MinLen=1)
  {
    if (StringLen(Search)>=MinLen)
      if (StringSubstr(Source,StringFind(Source,Search),StringLen(Search))==Search)
        return (true);
     
    return (false);
  }

//+------------------------------------------------------------------+
//| IsChanged - returns true if the updated value has changed        |
//+------------------------------------------------------------------+
bool IsChanged(datetime &Check, datetime Compare, bool Update=true)
  {
    if (Check == Compare)
      return (false);
  
    if (Update)
      Check   = Compare;
  
    return (true);
  }

//+------------------------------------------------------------------+
//| IsChanged - returns true if the updated value has changed        |
//+------------------------------------------------------------------+
bool IsChanged(string &Check, string Compare, bool Update=true)
  {
    if (Check == Compare)
      return (false);
  
    if (Update) 
      Check   = Compare;
  
    return (true);
  }

//+------------------------------------------------------------------+
//| IsChanged - returns true if the updated value has changed        |
//+------------------------------------------------------------------+
bool IsChanged(double &Check, double Compare, bool Update=true, int Precision=0)
  {
    if (Precision == 0)
      Precision  = _Digits;

    if (NormalizeDouble(Check,Precision) == NormalizeDouble(Compare,Precision))
      return (false);
  
    if (Update) 
      Check   = NormalizeDouble(Compare,Precision);
  
    return (true);
  }

//+------------------------------------------------------------------+
//| IsChanged - returns true if the updated value has changed        |
//+------------------------------------------------------------------+
bool IsChanged(double &Check, double Compare, double &Variance, bool Update=true, int Precision=0)
  {
    if (Precision == 0)
      Precision  = _Digits;
      
    Variance   = 0.00;

    if (IsChanged(Variance,Compare-Check,true,Precision))
    {  
      Check    = BoolToDouble(Update,Compare,Check,Precision);
      return (true);
    }
  
    return (false);
  }

//+------------------------------------------------------------------+
//| IsChanged - returns true if the updated value has changed        |
//+------------------------------------------------------------------+
bool IsChanged(int &Check, int Compare, bool Update=true)
  {
    if (Check == Compare)
      return (false);
   
    if (Update) 
      Check   = Compare;
  
    return (true);
  }

//+------------------------------------------------------------------+
//| IsChanged - returns true if the updated value has changed        |
//+------------------------------------------------------------------+
bool IsChanged(bool &Check, bool Compare, bool Update=true)
  {
    if (Check == Compare)
      return (false);
   
    if (Update) 
      Check   = Compare;
  
    return (true);
  }

//+------------------------------------------------------------------+
//| IsChanged - returns true if the updated value has changed        |
//+------------------------------------------------------------------+
bool IsChanged(uchar &Check, uchar Compare, bool Update=true)
  {
    if (Check == Compare)
      return (false);
   
    if (Update) 
      Check   = Compare;
  
    return (true);
  }

//+------------------------------------------------------------------+
//| IsBetween - returns true if supplied value in supplied range     |
//+------------------------------------------------------------------+
bool IsBetween(double Check, double Range1, double Range2, int Precision=0)
  {
    if (Precision == 0)
      Precision  = _Digits;
          
    if (NormalizeDouble(Check,Precision) >= NormalizeDouble(fmin(Range1,Range2),Precision))
      if (NormalizeDouble(Check,Precision) <= NormalizeDouble(fmax(Range1,Range2),Precision))
        return true;
     
    return false;
  }

//+------------------------------------------------------------------+
//| IsEqual - returns true if the values are equal                   |
//+------------------------------------------------------------------+
bool IsEqual(double Value1, double Value2, int Precision=0)
  {
    if (Precision == 0)
      Precision    = _Digits;
      
    if (NormalizeDouble(Value1,Precision) == NormalizeDouble(Value2,Precision))
      return (true);
     
    return (false);
  }

//+------------------------------------------------------------------+
//| trim - Returns string removed of leading/trailing blanks         |
//+------------------------------------------------------------------+
string trim(string Text)
  {
    StringTrimRight(Text);
    StringTrimLeft(Text);

    return Text;
  }

//+------------------------------------------------------------------+
//| IsLower - returns true if compare value lower than check         |
//+------------------------------------------------------------------+
bool IsLower(double Compare, double &Check, bool Update=true, int Precision=0)
  {
    if (Precision == 0)
      Precision  = _Digits;
      
    if (NormalizeDouble(Compare,Precision) < NormalizeDouble(Check,Precision))
    {
      if (Update)
        Check    = NormalizeDouble(Compare,Precision);

      return (true);
    }
    
    return (false);
  }

//+------------------------------------------------------------------+
//| IsHigher - returns true if compare value higher than check       |
//+------------------------------------------------------------------+
bool IsHigher(double Compare, double &Check, bool Update=true, int Precision=0)
  {
    if (Precision == 0)
      Precision  = _Digits;
      
    if (NormalizeDouble(Compare,Precision) > NormalizeDouble(Check,Precision))
    {    
      if (Update)
        Check    = NormalizeDouble(Compare,Precision);
        
      return (true);
    }
    return (false);
  }

//+------------------------------------------------------------------+
//| IsHigher - returns true if compare value higher than check       |
//+------------------------------------------------------------------+
bool IsHigher(datetime Compare, datetime &Check, bool Update=true)
  {
    if (Compare>Check)
    {    
      if (Update)
        Check    = Compare;
        
      return (true);
    }
    return (false);
  }

//+------------------------------------------------------------------+
//| fdiv - returns the result of the division of 2 double values     |
//+------------------------------------------------------------------+
double fdiv(double Dividend, double Divisor, int Precision=0)
  {
    if (Precision == 0)
      Precision  = _Digits;
      
    if (!IsEqual(Divisor,0.00,Precision))
      return (NormalizeDouble(Dividend/Divisor,Precision));

    return (NormalizeDouble(0.00,Precision));
  }

//+------------------------------------------------------------------+
//| BoolToDate - returns the datetime of a user-defined condition    |
//+------------------------------------------------------------------+
datetime BoolToDate(bool IsTrue, datetime TrueValue, datetime FalseValue)
  {
    if (IsTrue)
      return (TrueValue);

    return (FalseValue);
  }

//+------------------------------------------------------------------+
//| BoolToStr - returns the text description for the supplied value  |
//+------------------------------------------------------------------+
string BoolToStr(bool IsTrue, int Format=InTrueFalse)
  {
    switch (Format)
    {
      case InTrueFalse: if (IsTrue)
                          return ("True");
                        else
                          return ("False");
      case InYesNo:     if (IsTrue)
                          return ("Yes");
                        else
                          return ("No");
    }

    return ("Bad Boolean Format Type");
  }

//+------------------------------------------------------------------+
//| BoolToStr - returns user defined text for the supplied value     |
//+------------------------------------------------------------------+
string BoolToStr(bool IsTrue, string TrueValue, string FalseValue="")
  {
    if (IsTrue)
      return (TrueValue);

    return (FalseValue);
  }

//+------------------------------------------------------------------+
//| BoolToInt - returns user defined int for the supplied value      |
//+------------------------------------------------------------------+
int BoolToInt(bool IsTrue, int TrueValue, int FalseValue=0)
  {
    if (IsTrue)
      return (TrueValue);

    return (FalseValue);
  }

//+------------------------------------------------------------------+
//| BoolToDouble - returns user defined double for supplied value    |
//+------------------------------------------------------------------+
double BoolToDouble(bool IsTrue, double TrueValue, double FalseValue=0.00, int Precision=12)
  {
    if (IsTrue)
      return (NormalizeDouble(TrueValue,Precision));

    return (NormalizeDouble(FalseValue,Precision));
  }

//+------------------------------------------------------------------+
//| Coalesce - returns first non-zero value                          |
//+------------------------------------------------------------------+
double coalesce(double v1, double v2, double v3=0.00, double v4=0.00, double v5=0.00)
  {
    if (v1==0.00)
      if (v2==0.00)
        if (v3==0.00)
          if (v4==0.00)
            return(v5);
          else
            return (v4);
        else
          return (v3);
      else
        return (v2);

    return (v1);
  }

//+------------------------------------------------------------------+
//| Arrow - paints an arrow on the chart in the price area           |
//+------------------------------------------------------------------+
void Arrow(string ArrowName, ArrowType Type, int Color, int Bar=0, double Price=0.00, int Window=0)
  {      
    if (Bar>NoValue)
    {
      if (Price==0.00)
        Price = _Close(Bar);

      ObjectDelete(0, ArrowName);
      ObjectCreate(0, ArrowName, OBJ_ARROW, Window, _Time(Bar), Price);
      ObjectSetInteger(0, ArrowName, OBJPROP_ARROWCODE, Type);
      ObjectSetInteger(0, ArrowName, OBJPROP_COLOR, Color);
    }
  }

//+------------------------------------------------------------------+
//| Arrow - paints an arrow by Direction                             |
//+------------------------------------------------------------------+
void Arrow(string ArrowName, int Direction, int Color, int Bar=0, double Price=0.00)
  {      
    Arrow(ArrowName,
         (ArrowType)BoolToInt(IsEqual(Direction,DirectionUp),ArrowUp,
                    BoolToInt(IsEqual(Direction,DirectionDown),ArrowDown,ArrowHold)),
          Color,
          Bar,
          Price);
  }

//+------------------------------------------------------------------+
//| UpdateDirection - creates an arrow label to show indicator value |
//+------------------------------------------------------------------+
void UpdateDirection(string LabelName, int ArrowDirection, int ArrowColor=NoValue, int ArrowSize=NoValue, StyleType Style=Wide)
  { 
    uchar arrowcode = (uchar)BoolToInt(ArrowDirection==NoDirection,73,BoolToInt(Style==Wide,16)+BoolToInt(ArrowDirection>0,225,226));
    ArrowColor      = BoolToInt(ArrowColor>NoValue,ArrowColor,Color(ArrowDirection));
    ArrowSize       = BoolToInt(ArrowSize>NoValue,ArrowSize,(int)ObjectGetInteger(0,LabelName,OBJPROP_FONTSIZE));

              
    UpdateLabel(LabelName,CharToString(arrowcode),ArrowColor,ArrowSize,"Wingdings");
  }

//+------------------------------------------------------------------+
//| UpdateLabel                                                      |
//+------------------------------------------------------------------+
void UpdateLabel(string Name, string Text, int Color=NoValue, int Size=NoValue, string Font="")
  {
    ObjectSetString(0,Name,OBJPROP_TEXT,Text);

    if (Color>NoValue) ObjectSetInteger(0,Name,OBJPROP_COLOR,Color);
    if (Size>NoValue) ObjectSetInteger(0,Name,OBJPROP_FONTSIZE,Size);
    if (StringLen(Font)>0) ObjectSetString(0,Name,OBJPROP_FONT,Font);
  }
  
//+------------------------------------------------------------------+
//| NewLabel                                                         |
//+------------------------------------------------------------------+
void NewLabel(string Name, string Text, int PosX, int PosY, int Color=White, int Corner=0, int Window=0)
  {
    ObjectCreate(0,Name,OBJ_LABEL,Window,0,0.00);
    ObjectSetInteger(0,Name,OBJPROP_XDISTANCE,PosX);
    ObjectSetInteger(0,Name,OBJPROP_YDISTANCE,PosY);
    ObjectSetInteger(0,Name,OBJPROP_CORNER,Corner);
    
    UpdateLabel(Name,Text,Color);
  }

//+------------------------------------------------------------------+
//| UpdateText                                                       |
//+------------------------------------------------------------------+
void UpdateText(string Name, string Text, double Price, int Bar=NoValue, int Color=NoValue, int Size=NoValue, string Font="")
  {
    if (StringLen(Text)==0)
      Text   = ObjectGetString(0,Name,OBJPROP_TEXT);

    ObjectSetDouble(0,Name,OBJPROP_PRICE,Price);
    ObjectSetInteger(0,Name,OBJPROP_TIME,BoolToDate(Bar<0,_Time(0)+(_Period*fabs(Bar)),_Time(fmin(_Bars-1,fmax(Bar,0)))));

    UpdateLabel(Name,Text,Color,Size,Font);
  }
  
//+------------------------------------------------------------------+
//| NewText                                                         |
//+------------------------------------------------------------------+
void NewText(string Name, string Text, int Color=White, int Size=8, string Font="Tahoma", int Window=0)
  {
    ObjectCreate(0,Name,OBJ_TEXT,Window,0,0.00);
    UpdateLabel(Name,Text,Color,Size,Font);
  }

//+------------------------------------------------------------------+
//| UpdateLine                                                       |
//+------------------------------------------------------------------+
void UpdateLine(string LineName, double Price, int Style=STYLE_SOLID, int Color=White)
  {
    ObjectSetInteger(0,LineName,OBJPROP_STYLE,Style);
    ObjectSetInteger(0,LineName,OBJPROP_COLOR,Color);
    ObjectSetDouble(0,LineName,OBJPROP_PRICE,1,Price);    
  }
  
//+------------------------------------------------------------------+
//| NewLine - creates a line object                                  |
//+------------------------------------------------------------------+
void NewLine(string LineName, int Style=STYLE_SOLID, int Color=White, int Window=0)
  {
    ObjectCreate(0,LineName,OBJ_HLINE,Window,0,0.00);
  }

//+------------------------------------------------------------------+
//| UpdateRay                                                        |
//+------------------------------------------------------------------+
void UpdateRay(string Name, int BarStart, double PriceStart, int BarEnd=0, double PriceEnd=0.00, long RayColor=NoValue, ENUM_LINE_STYLE RayStyle=NoValue)
  {
    ObjectSetDouble(0,Name,OBJPROP_PRICE,PriceStart);
    ObjectSetDouble(0,Name,OBJPROP_PRICE,1,BoolToDouble(IsEqual(PriceEnd,0.00),PriceStart,PriceEnd,_Digits));
    
    ObjectSetInteger(0,Name,OBJPROP_TIME,_Time(BarStart));
    ObjectSetInteger(0,Name,OBJPROP_TIME,1,BoolToDate(BarEnd<0,_Time(0)+(_Period*fabs(BarEnd)),_Time(fmin(_Bars-1,fmax(BarEnd,0)))));

    if (RayColor>NoValue)
      ObjectSetInteger(0,Name,OBJPROP_COLOR,RayColor);

    if (RayStyle>NoValue)
      ObjectSetInteger(0,Name,OBJPROP_STYLE,RayStyle);
  }
  
//+------------------------------------------------------------------+
//| NewRay - creates a ray object                                    |
//+------------------------------------------------------------------+
void NewRay(string Name, long RayColor=clrWhite, ENUM_LINE_STYLE RayStyle=STYLE_SOLID, int Window=0)
  {
    ObjectCreate(0,Name,OBJ_TREND,Window,0,0);

    ObjectSetInteger(0,Name,OBJPROP_WIDTH,1);
    ObjectSetInteger(0,Name,OBJPROP_COLOR,RayColor);
    ObjectSetInteger(0,Name,OBJPROP_STYLE,RayStyle);
  }

//+------------------------------------------------------------------+
//| UpdatePriceLabel                                                 |
//+------------------------------------------------------------------+
void UpdatePriceLabel(string Name, double Price, int Color=White, int Bar=0)
  {
    ObjectSetInteger(0,Name,OBJPROP_COLOR,Color);
    ObjectSetDouble(0,Name,OBJPROP_PRICE,1,Price);
    ObjectSetInteger(0,Name,OBJPROP_TIME,1,BoolToDate(Bar<0,_Time(0)+(fabs(Bar)*(_Period*60)),_Time(fabs(Bar))));
  }
  
//+------------------------------------------------------------------+
//| NewPriceLabel - creates a right price label object               |
//+------------------------------------------------------------------+
void NewPriceLabel(string Name, double Price=0.00, bool Left=false, int Window=0)
  {
    if (Left)
      ObjectCreate(0,Name,OBJ_ARROW_LEFT_PRICE,Window,0,Price);
    else
      ObjectCreate(0,Name,OBJ_ARROW_RIGHT_PRICE,Window,0,Price);

    ObjectSetInteger(0,Name,OBJPROP_TIME,1,_Time(0));
  }
  
//+------------------------------------------------------------------+
//| Flag - creates a right price label object                        |
//+------------------------------------------------------------------+
void Flag(string Name, int Color, int Bar=0, double Price=0.00, bool ShowFlag=Always, ENUM_OBJECT Style=OBJ_ARROW_RIGHT_PRICE)
  {
    static int fIdx  = 0;
    
    if (ShowFlag)
    {
      while (!ObjectCreate(0,Name+"-"+(string)fIdx,Style,0,_Time(Bar),BoolToDouble(IsEqual(Price,0.00),_Close(Bar),Price)))
        if (GetLastError()==4200) //-- Object Exists
          fIdx++;
        else
          break;

      ObjectSetInteger(0,Name+"-"+IntegerToString(fIdx),OBJPROP_COLOR,Color);
    }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveChartObjects(string Key)
  {
    //-- Clean Open Chart Objects
    int object             = 0;
    
    while (object<ObjectsTotal(0))
      if (InStr(ObjectName(0,object),Key))
        ObjectDelete(0,ObjectName(0,object));
      else object++;
  }

//+------------------------------------------------------------------+
//| DrawBox - Draws a box used to frame text                         |
//+------------------------------------------------------------------+
void DrawBox(string Name, int PosX, int PosY, int Width, int Height, int Color, int Border, int Corner=SCREEN_UL, int WinId=0)
  {
    ObjectCreate(0,Name,OBJ_RECTANGLE_LABEL,WinId,0,0,0,0);
    
    ObjectSetInteger(0,Name,OBJPROP_XDISTANCE,PosX);
    ObjectSetInteger(0,Name,OBJPROP_YDISTANCE,PosY);
    ObjectSetInteger(0,Name,OBJPROP_XSIZE,Width);
    ObjectSetInteger(0,Name,OBJPROP_YSIZE,Height);
    ObjectSetInteger(0,Name,OBJPROP_CORNER,Corner);
    ObjectSetInteger(0,Name,OBJPROP_STYLE,STYLE_SOLID);
    ObjectSetInteger(0,Name,OBJPROP_BORDER_TYPE,Border);
    ObjectSetInteger(0,Name,OBJPROP_BGCOLOR,Color);
    ObjectSetInteger(0,Name,OBJPROP_BACK,true);
  }

//+------------------------------------------------------------------+
//| UpdateBox - Updates some box properties (wip)                    |
//+------------------------------------------------------------------+
void UpdateBox(string Name, color Color)
  {
    ObjectSetInteger(0,Name,OBJPROP_BGCOLOR,Color);
    ObjectSetInteger(0,Name,OBJPROP_BORDER_COLOR,clrGold);
  }
