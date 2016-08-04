//+------------------------------------------------------------------+
//|                                                     data.mq4.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input int      loss = 300;
input int      profit = 1000;
input double   lots = 1;
input int      diff = 200;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//------------
//| Buy Stop && Sell Stop
//------------

    int buy = OrderSend(Symbol(), OP_BUYSTOP, lots, Bid + diff*Point,3,Bid - diff*Point,
                        NULL,"0",0,clrNONE);
    int sell = OrderSend(Symbol(), OP_SELLSTOP, lots, Ask - diff*Point,3,Ask + diff*Point,
                        NULL,"0",0,clrNONE);
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
    
}
//+------------------------------------------------------------------+

