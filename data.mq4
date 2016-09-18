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
input int      profit = 1500;
input double   lots = 1;
input int      diff = 150;
input bool     schedule = false;

input string scheduleTime = "2016.09.13 20:20:20";

int order = true;
int riseLossPrice = 200;

int Profit = profit;
int Diff   = diff;
string symbol = Symbol();
int needCancel = 0;
int orderTicket[2];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    if(symbol == "US_OIL"){
        riseLossPrice = riseLossPrice / 10;
        Profit = Profit / 10;
        Diff   = Diff / 10;
    }
    if(!schedule){
        sendOrder(Diff, Profit);
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
//-------------------------------+
//| Buy Stop && Sell Stop        |
//-------------------------------+
    if(schedule && order){
        datetime now = TimeCurrent();
        datetime timeDiff = StrToTime(scheduleTime) - now;
        if( TimeMinute(timeDiff) == 0 && TimeSeconds(timeDiff) < 15 ){
           sendOrder(Diff, Profit);
           order = false;
        }
    }
    
//------------------------------------------------+
//| check profit and modify orders' stop loss     |
//------------------------------------------------+
    for(int i = 0; i < OrdersTotal(); i++){
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
            if(OrderSymbol() == symbol){
                int orderType = OrderType();
                if(orderType == OP_BUY){
                    OrderCancel(orderTicket[1]);
                    needCancel = 1;
                    double buyPrice = OrderOpenPrice();
                    double gitProfit = Bid - buyPrice;
                    if(gitProfit > riseLossPrice * Point){
                        if(OrderModify(OrderTicket(), buyPrice, buyPrice + gitProfit*2/3, OrderTakeProfit(),0,clrNONE)){
                            riseLossPrice = riseLossPrice * 2;
                        }
                    }
                }
                if(orderType == OP_SELL){
                    OrderCancel(orderTicket[0]);
                    needCancel = 1;
                    double sellPrice = OrderOpenPrice();
                    double gitProfit = sellPrice - Bid;
                    if(gitProfit > riseLossPrice * Point){
                        if(OrderModify(OrderTicket(), sellPrice, sellPrice - gitProfit*2/3, OrderTakeProfit(),0,clrNONE)){
                            riseLossPrice = riseLossPrice * 2;
                        }
                    }
                }
                /*                
                if(orderType == OP_BUYSTOP && OrderStopLoss() - Bid > diff * Point){
                    OrderCancel(OrderTicket());
                }
                if(orderType == OP_SELLSTOP && Bid - OrderStopLoss() > diff * Point){
                    OrderCancel(OrderTicket());
                }
                */
            }
        }
    }
    expiration(10);
}
//----------------------------------------+
//| send buy stop and sell stop order     |
//----------------------------------------+
void sendOrder(int di, int pro){
    int buy  = -1;
    int sell = -1;
    int times = 0;
    while(buy == -1){
        times = times + 1;
        if(times > 3){
            return;
        }
        buy = OrderSend(symbol, OP_BUYSTOP, lots, Bid + di*Point, 30, Bid,
                            Ask + pro * Point, symbol + "OP_BUYSTOP", 198, 0, clrNONE);
        
    }
    orderTicket[0] = buy;
    times = 0;
    while(sell == -1){
        times = times + 1;
        if(times > 3){
            if(buy != -1){
                OrderCancel(buy);
            }
            return;
        }
        sell = OrderSend(symbol, OP_SELLSTOP, lots, Ask - di*Point, 30, Ask,
                            Bid - pro * Point, symbol + "OP_SELLSTOP", 198, 0,clrNONE);
        
    }
    orderTicket[1] = sell;
}

//------------------------------------+
//| Delete order of stop              |
//------------------------------------+
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

void expiration(int expirationTime){
    datetime now = TimeCurrent();
    datetime timeDiff = StrToTime(scheduleTime) - now;
    if(needCancel == 0 && order == false && TimeSeconds(timeDiff) > expirationTime ){
        for(int i = 0; i < 2; i++){
            OrderCancel(orderTicket[i]);
        }
    }
}

//+------------------------------------------------------------------+