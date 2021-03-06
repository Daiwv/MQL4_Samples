//+------------------------------------------------------------------+
//|                                            SupremacyBOExpert.mq4 |
//|                                                         UncleSam |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "UncleSam"
#property link      ""
#property version   "1.00"
#property strict

input int magic=20181031; //magic
input string currency = ""; //symbol's name
input double fixedLot=1; // fix lot
input double lotPercent=5; // depo percent for lot
input double minLot = 1; //min lot
input int minTopPercent = 65; // min top diff
input int expTime=1380; // BO time
input bool openSecondOrder = true; //open second order
input string txt1="Martin"; //--- divider ---
input bool martin=true; // use martin
input double winPercent=70; // win percent
input double plusProfit=0.5; // plus profit
input int startStep=1; // start step
input int maxStep=2; // max step

int step;
static int prevtime = 0;
double Lots;
double lot;
int eTime;
double lPercent;
double plProfit;
int ticket;
bool isShow;
const string fileName = "myfxbook";
int oType;
bool secondIsopen;
double beforeBid;
double beforeAsk;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ticket = 0;
   oType = 0;
   isShow = false;
   eTime = expTime;
   secondIsopen = false;
   RefreshRates();
   beforeAsk = Ask;
   beforeBid = Bid;
   if(eTime < 0){
      eTime = 1;
   }
   
   if(lotPercent > 0){
       lPercent = lotPercent;
       if(lPercent > 100){
         lPercent = 100;
       }  
       
       lot = (AccountInfoDouble(ACCOUNT_MARGIN_FREE) * lPercent) / 100;
       lot = NormalizeDouble(lot, 2);
       
    }else{
      lot = fixedLot;
    }
    
    if(lot < minLot){
      lot = minLot;
    }
    
    plProfit = NormalizeDouble(lot * plusProfit, 2);
    
    prevtime =Time[0];
    step=startStep;
    int tmpstep = calculateStep(step, ticket, martin, maxStep);
    double tmpLots = calculateLot(tmpstep, lot, plProfit, winPercent);
    Comment("Start step: ",startStep, "\nMax step: ", maxStep,"\nNext step: ", tmpstep, "\nNext lot: ", tmpLots, "\nWin percent: ", winPercent, "\nPlus-profit: ", plProfit); 
   /* int ooType = getDataFromHTML();
    Print(ooType);*/
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
   
   if(oType != 0 && openSecondOrder && OrdersTotalSymb() > 0 && !secondIsopen){
      if(oType == -1){
         RefreshRates();
         if(beforeBid <= High[1] && Bid >= High[1]){
            step++;  
            Lots = calculateLot(step, lot, plProfit, winPercent);
         
            if(Lots<=AccountInfoDouble(ACCOUNT_MARGIN_FREE) && AccountInfoDouble(ACCOUNT_MARGIN_FREE)>0){
               datetime dt = TimeCurrent();
               int sETime = 23 * 60 - (TimeHour(dt) * 60 + TimeMinute(dt));
               
               if(sETime > 0){
                  RefreshRates();
                  ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,5,0,0,sETime,magic);
                  if(ticket<0)
                  {
                     Print(Symbol(), ": OrderSend error #",GetLastError());
                          
                  }else{
                     Print("Second order SELL ",Lots," ",Symbol()," ",ticket," is open!");
                     isShow = false;
                     secondIsopen = true;
                  } 
               }else{
                  Print(Symbol(), ": second order - time is gone");
               }
            }else{
               ticket = 0;

               Alert(Symbol(), ": No money!");

            } 
         }
      }
      
      if(oType == 1){
         RefreshRates();
         if(beforeAsk >= Low[1] && Ask <= Low[1]){
            step++;  
            Lots = calculateLot(step, lot, plProfit, winPercent);
         
            if(Lots<=AccountInfoDouble(ACCOUNT_MARGIN_FREE) && AccountInfoDouble(ACCOUNT_MARGIN_FREE)>0){
               datetime dt = TimeCurrent();
               int sETime = 23 * 60 - (TimeHour(dt) * 60 + TimeMinute(dt));
               
               if(sETime > 0){
                  RefreshRates();
                  ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,5,0,0,sETime,magic);
                  if(ticket<0)
                  {
                     Print(Symbol(), ": OrderSend error #",GetLastError());
                          
                  }else{
                     Print("Second order Buy ",Lots," ",Symbol()," ",ticket," is open!");
                     isShow = false;
                     secondIsopen = true;
                  } 
               }else{
                  Print(Symbol(), ": second order - time is gone");
               }
            }else{
               ticket = 0;

               Alert(Symbol(), ": No money!");

            } 
         }
      }
   }
   
   int tmpstep = calculateStep(step, ticket, martin, maxStep);
   double tmpLots = calculateLot(tmpstep, lot, plProfit, winPercent);
   Comment("Start step: ",startStep, "\nMax step: ", maxStep,"\nNext step: ", tmpstep, "\nNext lot: ", tmpLots, "\nWin percent: ", winPercent, "\nPlus-profit: ", plProfit);
   
   
   if(Time[0] != prevtime){
      oType = getDataFromHTML();
      secondIsopen = false;
      if(oType == -1){ // sell
         step = calculateStep(step, ticket, martin, maxStep);
         Lots = calculateLot(step, lot, plProfit, winPercent);
         
         if(Lots<=AccountInfoDouble(ACCOUNT_MARGIN_FREE) && AccountInfoDouble(ACCOUNT_MARGIN_FREE)>0){
            RefreshRates();
            ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,5,0,0,eTime,magic);
            if(ticket<0)
            {
               Print(Symbol(), ": OrderSend error #",GetLastError());
                          
            }else{
                Print("Order SELL ",Lots," ",Symbol()," ",ticket," is open!");
                isShow = false;
            } 
         }else{
            ticket = 0;

            Alert(Symbol(), ": No money!");

         }
      }
      
      if(oType == 1){ //buy
         step = calculateStep(step, ticket, martin, maxStep);
         Lots = calculateLot(step, lot, plProfit, winPercent);
         
         if(Lots<=AccountInfoDouble(ACCOUNT_MARGIN_FREE) && AccountInfoDouble(ACCOUNT_MARGIN_FREE)>0){
            RefreshRates();
            ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,5,0,0,eTime,magic);
            if(ticket<0)
            {
               Print(Symbol(), ": OrderSend error #",GetLastError());
                          
            }else{
                Print("Order BUY ",Lots," ",Symbol()," ",ticket," is open!");
                isShow = false;
            } 
         }else{
            ticket = 0;

            Alert(Symbol(), ": No money!");

         }
      
      }
   
      prevtime = Time[0];
   }
   
   beforeAsk = Ask;
   beforeBid = Bid;
   
  }
//+------------------------------------------------------------------+

int getDataFromHTML(){
   int r = 0;
   string cur = Symbol();
   if(currency != ""){
        cur = currency;   
   }
   string startURL = "http://www.myfxbook.com/community/outlook/";
   string url = StringConcatenate(startURL,cur);
   ResetLastError();
   string cookie=NULL,headers;
   char post[],result[];
   int timeout=5000; //
   int res=WebRequest("GET",url,cookie,NULL,timeout,post,0,result,headers);
//--- проверка ошибок
   if(res==-1)
   {
      Print(Symbol(), ": WebRequest error. Error's code  =",GetLastError());

      Alert(Symbol(), ": Add address '",startURL,"' in list of urls in expert's settings");
   }
   else
   {
      //--- успешная загрузка
      Print(Symbol(), ": File was saved on disc, file size = ",ArraySize(result)," b");
      //--- сохраняем данные в файл
      string fname = StringConcatenate(fileName, cur, ".txt");
      int filehandle=FileOpen(fname,FILE_WRITE|FILE_BIN);
      //--- проверка ошибки
      if(filehandle!=INVALID_HANDLE)
        {
         //--- сохраняем содержимое массива result[] в файл
         FileWriteArray(filehandle,result,0,ArraySize(result));
         //--- закрываем файл
         FileClose(filehandle);
         
         r = findCurrStr(fname);
        }
      else Print(Symbol(), ": FileOpen error. Error's code =",GetLastError());

     }

   
   return r;
}

int findCurrStr(string fn){
   int s = 0;
   
   int file_handle=FileOpen(fn,FILE_READ|FILE_TXT);
   if(file_handle!=INVALID_HANDLE)
   {
      string str;
      int startStrFind = 0;
      string resStr = "";
      while(!FileIsEnding(file_handle)){
         str=FileReadString(file_handle);
         if(StringFind(str, "center paddTD10 dataTable maxWidth") >= 0 && startStrFind == 0){
            startStrFind = 1;
         }
         
         if(startStrFind == 1){
            resStr = StringConcatenate(resStr, StringTrimLeft(StringTrimRight(str)));
         }
         
         if(startStrFind == 1 && StringFind(str, "</table>") >= 0){
            break;
         }

         
      } 
      //Print(resStr);
      if(resStr != ""){
         string tdstr = "<td>Short</td><td>";
         string shortStr = StringSubstr(resStr, StringFind(resStr, tdstr) + StringLen(tdstr), 3);
         if(MathIsValidNumber(StrToInteger(shortStr))){
            int d = StrToInteger(shortStr);
            
            int maxBottomPercent = 100 - minTopPercent;
            string showStr = StringConcatenate(Symbol(), ": percent of short positions ", d, "%.");
            if(d >= minTopPercent && minTopPercent > 50){
               showStr = StringConcatenate(showStr, " BUY!!!");
               s = 1;
            }else if(d <= maxBottomPercent && maxBottomPercent >= 0 && maxBottomPercent < 50){
               showStr = StringConcatenate(showStr, " SELL!!!");
               s = -1;
            }else{
               showStr = StringConcatenate(showStr, " Wait next day...");
            }
            Print(showStr);
         }
      }
      FileClose(file_handle); 
   }else Print(Symbol(), ": Can't open file ",fn,", error's code = ",GetLastError());
   
   return s;
}

int calculateStep(int curStep, int t, bool m, int mst){
   int r = curStep;
   if(m){
      if(t > 0){
         if(OrderSelect(t, SELECT_BY_TICKET)){
            int ot=OrderType();
            double oOpen=OrderOpenPrice();
            double oClose=OrderClosePrice();
            
            if(ot==OP_BUY){
               if(oOpen>oClose){
                  r = curStep+1;
                  
               }else if(oOpen<oClose){
                  r = 1;
               }else{
                  r = curStep;
               }
            }
            
            if(ot==OP_SELL){
               if(oOpen<oClose){
                  r = curStep+1;
                  
               }else if(oOpen>oClose){
                  r = 1;
               }else{
                  r = curStep;
               }
            }
         }else{
            r = curStep;
         }
      }else{
         r = curStep;
      }
   }else{
      r = 1;
   }
   
   if(mst > 0 && r > mst){
      r = 1;
      if(!isShow){
         Print(Symbol(),": reset steps!");
         isShow = true;
      }
   }
   
   return r;
}

double calculateLot(int st, double l, double profit, double per){
   double summ = l;
   double lo = l;
   for(int ii=2; ii<=st; ii++){
      lo = (summ+profit)*100/per;
      summ=summ+lo;
   }
   lo = NormalizeDouble(lo,2); 
   
   return lo;  
   
}

int OrdersTotalSymb(){
   int ot=OrdersTotal();
   int resu=0;

   for(int ii=0; ii<ot; ii++){

      if(OrderSelect(ii, SELECT_BY_POS)==true){
         if(OrderSymbol()== Symbol() && OrderMagicNumber()==magic){
            
            resu++;

         }
      }
   }

   return resu;
}
