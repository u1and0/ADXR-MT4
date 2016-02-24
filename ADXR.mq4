//+------------------------------------------------------------------+
//|                    Average Directional Movement Index Rating.mq4 
//|                    ver3.0
//|                    +配列の中に計算したADXらの値を突っ込み表示させる試用にした(後につくるEAのため)
//|                    +後追いADX線"ADXs”を追加
//|                    +整数shiftの分だけ前の足のADXを計算する
//+------------------------------------------------------------------+

#property link "http://www.imt4.com/"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Lime
#property indicator_color4 Magenta
#property indicator_color5 Silver
#property indicator_color6 Lime
#property indicator_level1 25
#property indicator_level2 50
#property indicator_levelcolor Silver
#property indicator_levelstyle STYLE_DOT

extern int per_ADX=14;
extern int per_ADXR=14;
extern int shift=1;
extern int porog1_ADX = 25;
extern int porog2_ADX = 50;

int AlertFlag = 0;

double PDI,MDI,ADX,ADXs,ADXR,DIV;
double exPDI[],exMDI[],exADX[],exADXs[],exADXR[],exDIV[];
//+------------------------------------------------------------------+
//---- buffers
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
SetIndexStyle(0,DRAW_LINE,2);
SetIndexBuffer(0,exPDI);
SetIndexStyle(1,DRAW_LINE,2);
SetIndexBuffer(1,exMDI);
SetIndexStyle(2,DRAW_LINE);
SetIndexBuffer(2,exADX);
SetIndexStyle(3,DRAW_LINE);
SetIndexBuffer(3,exADXR);
SetIndexStyle(4,DRAW_HISTOGRAM);
SetIndexBuffer(4,exDIV);
SetIndexStyle(5,DRAW_LINE,2);
SetIndexBuffer(5,exADXs);
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
	
	int limit,counted_bars=IndicatorCounted();
	if(counted_bars < 0){
		return(-1);
	}
	else{//if(counted_bars > 0)
		counted_bars--;
	}
	limit=Bars - counted_bars;
	for (int i=0; i < limit;i++){
		PDI=iADX(NULL,0,per_ADX,PRICE_CLOSE,MODE_PLUSDI,i);
		exPDI[i]=PDI;
		MDI=iADX(NULL,0,per_ADX,PRICE_CLOSE,MODE_MINUSDI,i);
		exMDI[i]=MDI;
		ADX=iADX(NULL,0,per_ADX,PRICE_CLOSE,MODE_MAIN,i);
		exADX[i]=ADX;
		ADXs=iADX(NULL,0,per_ADX,PRICE_CLOSE,MODE_MAIN,i+shift);
		exADXs[i]=ADXs;
		// DIV[i]=PDI[i]-MDI[i];
	}
	// for(i=0; i<limit; i++){
	// 	ADXR[i]=iMAOnArray(ADX,0,per_ADXR,0,MODE_SMA,i);
	// 	DIV[i]=ADX[i]-ADXR[i];
	// }
	for (i=0; i < limit;i++){
		ADX=iADX(NULL,0,per_ADX,PRICE_CLOSE,MODE_MAIN,i);
		double sum=0;
		for(int j = 0; j<per_ADXR; j++ ){
			sum+=iADX(NULL,0,per_ADX,PRICE_CLOSE,0,i+j);
			// Print( "i=",i,"j=",j, "sum=",sum);
		}
		ADXR=sum/per_ADXR;
		exADXR[i]=ADXR;
		// Print( "i=",i, "ADXR=",ADXR, "exADXR[i]=",exADXR[i] );
		DIV=ADX-ADXR;
		exDIV[i]=DIV;
		// Print(i);
	}



// 調整中
// //Signal & Alert
// 	if(AlertFlag==0){// Never Alerted
// 		//buy entry signal
// 		if(ADX>porog1_ADX && ADX<porog2_ADX && DIV>0 && PDI>MDI) {
// 			Print(Symbol()," Buy Signal!");
// 			Alert(Symbol()," Buy Signal!");
// 			AlertFlag=1;
// 		}
// 		//sell entry signal
// 		else if(ADX>porog1_ADX && ADX<porog2_ADX && DIV>0 && PDI<MDI) {
// 			Print(Symbol()," Sell Signal!");
// 			Alert(Symbol()," Sell Signal!");
// 			AlertFlag=1;
// 		}
// 		else{
// 			AlertFlag=0;
// 		}
// 	}
// 	else if(AlertFlag==1){
// 		//exit signal
// 		if(exADX[i-1]>exADXs[i-1] && exADX[i]<exADXs[i]) {
// 			Print(Symbol()," Close Signal!");
// 			Alert(Symbol()," Close Signal!");
// 			AlertFlag=2;
// 		}
// 		else AlertFlag=1;
// 	}
// 	else{
// 		AlertFlag=0;
// 	}
//----
return(0);
}
//+------------------------------------------------------------------+ 