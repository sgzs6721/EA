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
//input int      loss = 200;
input int      profit = 1000;
input double   lots = 1;
input int      diff = 200;

int riseLossPrice = 200;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//------------
//| Buy Stop && Sell Stop
//------------

    int buy = OrderSend(Symbol(), OP_BUYSTOP, lots, Bid + diff*Point,3,Bid,
                        Ask + profit * Point, Symbol() + "OP_BUYSTOP" ,0, clrNONE);
    int sell = OrderSend(Symbol(), OP_SELLSTOP, lots, Ask - diff*Point, 3, Ask,
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
            if(OrderSymbol() == Symbol()){
                int orderType = OrderType();
                if(orderType == OP_BUY){
                    double buyPrice = OrderOpenPrice();
                    double gitProfit = Bid - buyPrice;
                    if(gitProfit > riseLossPrice * Point){
                        if(OrderModify(OrderTicket(), buyPrice, buyPrice + profit*2/3, OrderTakeProfit(),0,clrNONE)){
                            riseLossPrice = riseLossPrice * 2 / 3;
                        }
                    }
                }
                if(orderType == OP_SELL){
                    double sellPrice = OrderOpenPrice();
                    double gitProfit = sellPrice - Bid;
                    if(gitProfit > riseLossPrice * Point){
                        if(OrderModify(OrderTicket(), sellPrice, sellPrice - profit*2/3, OrderTakeProfit(),0,clrNONE)){
                            riseLossPrice = riseLossPrice * 2 / 3;
                        }
                    }
                }
                if(orderType == OP_BUYSTOP && OrderStopLoss() - Bid > diff * Point){
                    OrderCancel(OrderTicket());
                }
                if(orderType == OP_SELLSTOP && Bid - OrderStopLoss() > diff * Point){
                    OrderCancel(OrderTicket());
                }
            }
        }
    }
}

bool OrderCancel(int ticket){
    int counter = 0;
    bool result = false;
    while(true){
        counter++;
        if(OrderDelete(ticket, clrNONE)){
            result = true;
            break;
        }
        if(counter > 3){
            result = false;
            break;
        }
    }
    return result;
}

//+------------------------------------------------------------------+

