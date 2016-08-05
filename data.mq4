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
input int      loss = 200;
input int      profit = 1000;
input double   lots = 1;
input int      diff = 150;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//------------
//| Buy Stop && Sell Stop
//------------

    int buy = OrderSend(Symbol(), OP_BUYSTOP, lots, Bid + loss*Point,3,Bid,
                        Ask + profit * Point, Symbol() + "OP_BUYSTOP" ,0, clrNONE);
    int sell = OrderSend(Symbol(), OP_SELLSTOP, lots, Ask - loss*Point, 3, Ask,
                        Bid - profit * Point, Symbol() + "OP_SELLSTOP", 0 ,clrNONE);
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
    for(int i = 0; i < OrdersTotal(); i++){
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
            //Print("Loss Price:" + OrderStopLoss());
            //Print("Current Price" + Bid);
            //Print("Profit Price:" + OrderTakeProfit());
            if(OrderType() == OP_BUYSTOP && OrderStopLoss() - Bid > diff * Point){
                int counter = 0;
                while(true){
                counter++;
                    if(OrderDelete(OrderTicket(), clrNONE)){
                        break;
                    }
                    if(counter > 3) break;
                }                
            }
            if(OrderType() == OP_SELLSTOP && Bid - OrderStopLoss() > diff * Point){
                int counter = 0;
                while(true){
                counter++;
                    if(OrderDelete(OrderTicket(), clrNONE)){
                        break;
                    }
                    if(counter > 3) break;
                }              
            }
        }
    }
}
//+------------------------------------------------------------------+

