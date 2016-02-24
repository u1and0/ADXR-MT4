//+------------------------------------------------------------------+
//|                    Average Directional Movement Index Rating.mq4 
//|                    ver3.1
//|                    +Signal作成
//+------------------------------------------------------------------+

#property link "http://www.imt4.com/"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Lime
#property indicator_color4 Magenta
#property indicator_color5 Silver
#property indicator_color6 Lime
#property indicator_color7 Yellow
#property indicator_level1 25
#property indicator_level2 50
#property indicator_levelcolor Silver
#property indicator_levelstyle STYLE_DOT

extern int per_ADX=14;
extern int per_ADXR=14;
extern int shift=1;
extern int sig=2;
extern int porog1_ADX = 25;
extern int porog2_ADX = 50;

int AlertFlag = 0;

double PDI,MDI,ADX,ADXs,ADXR,DIV,SUB;//+DI,-DI,ADX,遅行ADX,ADX移動平均,ADXと遅行ADX移動平均の差,ADXと遅行ADXの差
double exPDI[],exMDI[],exADX[],exADXs[],exADXR[],exDIV[],exSUB[];
//+------------------------------------------------------------------+
//---- buffers
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
SetIndexStyle(0,DRAW_LINE,2);
SetIndexBuffer(0,exPDI);
SetIndexLabel(0,"+DI");
SetIndexStyle(1,DRAW_LINE,2);
SetIndexBuffer(1,exMDI);
SetIndexLabel(1,"-DI");
SetIndexStyle(2,DRAW_LINE);
SetIndexBuffer(2,exADX);
SetIndexLabel(2,"ADX");
SetIndexStyle(3,DRAW_LINE);
SetIndexBuffer(3,exADXR);
SetIndexLabel(3,"ADXR");
SetIndexStyle(4,DRAW_HISTOGRAM,0,4);
SetIndexBuffer(4,exDIV);
SetIndexLabel(4,"ADX-ADXR");
SetIndexStyle(5,DRAW_LINE,2);
SetIndexBuffer(5,exADXs);
SetIndexLabel(5,"ADXs");
SetIndexStyle(6,DRAW_HISTOGRAM,0,4);
SetIndexBuffer(6,exSUB);
SetIndexLabel(6,"ADX-ADXs");
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
	// }
	// for(i=0; i<limit; i++){
	// 	ADXR[i]=iMAOnArray(ADX,0,per_ADXR,0,MODE_SMA,i);
	// 	DIV[i]=ADX[i]-ADXR[i];
	// }
	// for (i=0; i < limit;i++){
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
		SUB=ADX-ADXs;
		exSUB[i]=SUB;
	}




	//Signal & Alert
	if(AlertFlag==0){// Never Alerted
		//buy entry signal
		if(exADX[1]>porog1_ADX && exADX[1]<porog2_ADX && exDIV[1]>0 && exSUB[1]>0) {
			if(exPDI[1]>exMDI[1]){// 25<ADX<50　かつ　ADXがADXRより大きい　かつ　ADXと遅行ADX
				Alert(Symbol(),Period()," Buy Signal!");
			}
			//sell entry signal
			else{//(exPDI[1]<exMDI[1]) {
				Alert(Symbol(),Period()," Sell Signal!");
			}
			Print("ADX","=",exADX[1]," / ","ADX-ADXR","=",exDIV[1]," / ","ADX-ADXs","=",exSUB[1]);
			AlertFlag=1;
		}
		else{
			AlertFlag=0;
		}
	}
	else if(AlertFlag==1){
		//exit signal
		if(exSUB[1]<0 && exSUB[sig]>0) {// 1本前の足の終値ADXと遅行ADXの差が0未満　かつ　 2本前の足の終値ADXと遅行ADXの差が0以上　つまり、ADXが遅行ADXを下抜けした瞬間
			Alert(Symbol(),Period()," Close Signal!");
			Print("ADX-ADXs","=",exSUB[1],"-->",exSUB[sig]);
			AlertFlag=2;
		}
		else AlertFlag=1;
	}
	else{
		AlertFlag=0;
	}
//----
return(0);
}
//+------------------------------------------------------------------+