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
input int      appliedPeriod=30;
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

    //checkProfit(100);
    double currentValueOfMaShort = iMA(Symbol(),appliedPeriod, shortMa, 0, averageType, PRICE_CLOSE, 0);
    double currentValueOfMaLong  = iMA(Symbol(),appliedPeriod, longMa, 0, averageType, PRICE_CLOSE, 0);
    
    double valueOfMaShort = iMA(Symbol(),appliedPeriod, shortMa, 0, averageType, PRICE_CLOSE, 0);
    double valueOfMaLong  = iMA(Symbol(),appliedPeriod, longMa, 0, averageType, PRICE_CLOSE, 0);
    
    double preValueOfMaShort = iMA(Symbol(),appliedPeriod, shortMa, 0, averageType, PRICE_CLOSE, 1);
    double preValueOfMaLong  = iMA(Symbol(),appliedPeriod, longMa, 0, averageType, PRICE_CLOSE, 1);
       
    
    //buy
    if(valueOfMaShort > valueOfMaLong && preValueOfMaShort < preValueOfMaLong ){
        //if(orderOperate(OP_BUY, Ask, OP_SELL, Bid) != -1){
        orderOperate(OP_BUY, Ask, OP_SELL, Bid);
            //Print("Buy Success!");
        //}
    }
        
    //sell
    if(valueOfMaShort < valueOfMaLong && preValueOfMaShort > preValueOfMaLong ){
        //if(orderOperate(OP_SELL, Bid, OP_BUY, Ask) != -1){
        orderOperate(OP_SELL, Bid, OP_BUY, Ask);
            //Print("Sell Success!");
        //}
    }
}

void checkProfit(int diff){
    for(int i = 0; i < OrdersTotal(); i++){
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
            if(MathAbs(OrderProfit()) > diff * lots){
                bool x = OrderClose(OrderTicket(),lots,OrderType() == OP_BUY ? Bid : Ask, 50,clrNONE);
            }
        }
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
          //if(OrderComment() == Symbol() + IntegerToString(operation,0,' '))
          {
              open = 1;
              break;
          }
          else if(OrderSymbol() == Symbol() && OrderType() == abOperation){
              bool x = OrderClose(OrderTicket(),lots,abPrice,50,clrNONE);
          }
       }
       
    }
    if(open == 0){
        while(ticket == -1){
            ticket = OrderSend(Symbol(), operation, lots, price, 3, 0, 0, Symbol()+IntegerToString(operation,0,' '), 0, 0, clrNONE);
        }
    }
    return ticket;
}
//+------------------------------------------------------------------+
