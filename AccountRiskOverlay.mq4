//+------------------------------------------------------------------+
//|                                           AccountRiskOverlay.mq4 |
//|                                                 Jarvis-mql45-dev |
//|                                                                  |
//| A clean chart overlay displaying critical real-time account risk  |
//| metrics to protect trading capital from structural drawdowns.    |
//+------------------------------------------------------------------+
#property copyright "Jarvis-mql45-dev"
#property version   "1.00"
#property strict
#property indicator_chart_window

//--- Input parameters
input color  Text_Color       = clrCyan;       // Metric text color
input color  Warning_Color    = clrRed;        // Over-exposure warning color
input int    Max_Allowed_Lots = 10;            // Maximum total structural lot exposure
input int    Font_Size        = 11;            // UI Display Font Size

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "RiskOverlay_");
   Comment("");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   //--- Calculate current account parameters
   double balance      = AccountBalance();
   double equity       = AccountEquity();
   double freeMargin   = AccountFreeMargin();
   double openLots     = 0;
   
   //--- Loop through open positions to tally structural lot loads
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
         {
            openLots += OrderLots();
         }
      }
   }

   //--- Create clean on-screen dashboard presentation strings
   string balanceStr    = "Account Balance: $" + DoubleToString(balance, 2);
   string equityStr     = "Current Equity: $" + DoubleToString(equity, 2);
   string marginStr     = "Free Margin: $" + DoubleToString(freeMargin, 2);
   string exposureStr   = "Total Lot Exposure: " + DoubleToString(openLots, 2) + " / " + IntegerToString(Max_Allowed_Lots) + " Max";
   
   //--- Generate screen notifications
   string alertStr = "System Status: Nominal / Secure";
   color activeAlertColor = Text_Color;
   
   if(openLots > Max_Allowed_Lots)
   {
      alertStr = "CRITICAL WARNING: TOTAL LOT EXPOSURE EXCEEDS SAFE STRUCTURAL CAPACITY";
      activeAlertColor = Warning_Color;
   }

   //--- Render Dashboard Interface Items
   CreateLabel("RiskOverlay_Balance", balanceStr, 10, 20, Text_Color);
   CreateLabel("RiskOverlay_Equity", equityStr, 10, 40, Text_Color);
   CreateLabel("RiskOverlay_Margin", marginStr, 10, 60, Text_Color);
   CreateLabel("RiskOverlay_Exposure", exposureStr, 10, 80, (openLots > Max_Allowed_Lots ? Warning_Color : Text_Color));
   CreateLabel("RiskOverlay_Alert", alertStr, 10, 100, activeAlertColor);

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Helper function to safely render clean UI labels                 |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color textColor)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetString(0, name, OBJPROP_FONT, "Trebuchet MS");
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, Font_Size);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
}
