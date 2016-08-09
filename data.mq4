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
input int      profit = 1200;
input double   lots = 1;
input int      diff = 150;
input bool     schedule = false;

int order = true;
int riseLossPrice = 200;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    if(!schedule){
        Print("test");
        int buy = OrderSend(Symbol(), OP_BUYSTOP, lots, Bid + diff*Point, 3, Bid,
                            Ask + profit * Point, Symbol() + "OP_BUYSTOP" ,0, clrNONE);
        int sell = OrderSend(Symbol(), OP_SELLSTOP, lots, Ask - diff*Point, 3, Ask,
                            Bid - profit * Point, Symbol() + "OP_SELLSTOP", 0 ,clrNONE);
    }

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
//------------------------
//| Buy Stop && Sell Stop
//------------------------
    datetime now = TimeCurrent();
    if(schedule && order){
        if(TimeDay(TimeCurrent()) == 9 && TimeHour(TimeCurrent()) == 7
                   && TimeMinute(TimeCurrent()) == 59 && TimeSeconds(TimeCurrent()) > 20){
            Print("xxxx");
            int buy = OrderSend(Symbol(), OP_BUYSTOP, lots, Bid + diff*Point, 3, Bid,
                            Ask + profit * Point, Symbol() + "OP_BUYSTOP" ,0, clrNONE);
            int sell = OrderSend(Symbol(), OP_SELLSTOP, lots, Ask - diff*Point, 3, Ask,
                            Bid - profit * Point, Symbol() + "OP_SELLSTOP", 0 ,clrNONE);
            order = false;
        }
    }
//--------------------------------------------
//| check profit and modify orders' stop loss
//--------------------------------------------
    for(int i = 0; i < OrdersTotal(); i++){
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
            if(OrderSymbol() == Symbol()){
                int orderType = OrderType();
                if(orderType == OP_BUY){
                    double buyPrice = OrderOpenPrice();
                    double gitProfit = Bid - buyPrice;
                    if(gitProfit > riseLossPrice * Point){
                        if(OrderModify(OrderTicket(), buyPrice, buyPrice + gitProfit*2/3, OrderTakeProfit(),0,clrNONE)){
                            riseLossPrice = riseLossPrice * 2;
                        }
                    }
                }
                if(orderType == OP_SELL){
                    double sellPrice = OrderOpenPrice();
                    double gitProfit = sellPrice - Bid;
                    if(gitProfit > riseLossPrice * Point){
                        if(OrderModify(OrderTicket(), sellPrice, sellPrice - gitProfit*2/3, OrderTakeProfit(),0,clrNONE)){
                            riseLossPrice = riseLossPrice * 2;
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
//------------------------
//| Delete order of stop
//------------------------
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

