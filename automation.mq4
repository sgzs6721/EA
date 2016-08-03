//+------------------------------------------------------------------+
//|                                                   automation.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input int      averageType=MODE_SMA;
input int      appliedPeriod=1;
input int      shortMa=5;
input int      longMa= 20;
input double   lots=0.1;
int test = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
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
    double valueOfMaShort = iMA(Symbol(),appliedPeriod, shortMa, 0, averageType, PRICE_CLOSE, 0);
    double valueOfMaLong  = iMA(Symbol(),appliedPeriod, longMa, 0, averageType, PRICE_CLOSE, 0);
    
    double preValueOfMaShort = iMA(Symbol(),appliedPeriod, shortMa, 0, averageType, PRICE_CLOSE, 1);
    double preValueOfMaLong  = iMA(Symbol(),appliedPeriod, longMa, 0, averageType, PRICE_CLOSE, 1);
    
    //buy
    if(valueOfMaShort > valueOfMaLong && preValueOfMaShort < valueOfMaLong){
        //if(orderOperate(OP_BUY, Ask, OP_SELL, Bid) != -1){
            Print("Buy Success!");
        //}
    }
    
    orderOperate(OP_SELL, Bid, OP_BUY, Ask);
    //sell
    if(valueOfMaShort < valueOfMaLong && preValueOfMaShort > valueOfMaLong){
        //if(orderOperate(OP_SELL, Bid, OP_BUY, Ask) != -1){
            Print("Sell Success!");
        //}
    }
}

int orderOperate(int operation, double price, int abOperation, double abPrice)
{
    int ticket = -1;
    int open = 0;
    for(int i = 0; i < OrdersTotal(); i++)
    {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
          if(OrderSymbol() == Symbol() && OrderType() == operation)
          {
              //Do nothing
              open = 1;
          }
          else if(OrderSymbol() == Symbol() && OrderType() == abOperation){
              while(true){
                   if(OrderClose(OrderTicket(),lots,abPrice,3,clrNONE)){
                        break;
                   }
              }
          }
          else
          {
              while(true)
              {            
                   ticket = OrderSend(Symbol(), operation, lots, price, 3,
                                      0, 0, Symbol()+"-goldenCross", 0, 0, clrNONE);
                   if(ticket > 0)
                   {
                       break;
                   }
              }
          }
       }
       
    }
    if(open == 0){
        ticket = OrderSend(Symbol(), operation, lots, price, 3, 0, 0, Symbol()+"-"+IntegerToString(operation,0,' '), 0, 0, clrNONE);
    }
    return ticket;
}
//+------------------------------------------------------------------+
