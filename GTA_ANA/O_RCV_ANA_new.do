cd /Users/luisluan/data/GTA


*****************************************************Data Cleaning and Screening****************************************************************************
use GTA_FS,clear
keep if substr(accper,6,2)=="12"
drop if statco~=1
drop date
drop if sttag==1
gen indc=substr(GIC,1,1)
replace indc=substr(GIC,1,2) if indc=="C"

encode indc,gen(dindc)
encode accper,gen(FY)
tab dindc,gen(d_ind)
tab FY,gen(d_fy)
drop d_fy1
drop d_ind1

xtset stkcd FY
xtbalance,range(1,7)

gen T_RCV = b_noteRCV+b_accountRCV+ b_interestRCV +b_dividendRCV+ b_otherRCV
gen D_T_RCV = D.b_noteRCV+D.b_accountRCV+ D.b_interestRCV +D.b_dividendRCV+ D.b_otherRCV
gen RCV_TO1=2*i_OPincome/(b_noteRCV+b_accountRCV+L.b_noteRCV+L.b_accountRCV)
gen O_RCV_RO1 = D.b_otherRCV/D_T_RCV
gen LTI_RO1 = 2*b_LTEquityinvest/(L.b_TA+b_TA)
gen LN_TA1 = ln(b_TA)
gen DEBT_RO1 = 2*b_TLiab/(L.b_TA+b_TA)
gen ASSE_TO1 = 2*i_TOPincome/(L.b_TA+b_TA)
gen SUB_roe1=i_PL4nonControl/L.b_LTEquityinvest
gen LN_LTI1	=ln(L.b_LTEquityinvest)
gen LN_O_RCV1	=ln(L.b_otherRCV)
gen O_RCV_RO2	=b_otherRCV/T_RCV
gen D_RCV_RO1 = D.b_otherRCV

winsor LTI_RO1,gen(LTI_ro) p(0.05) 
winsor LN_TA1,gen(ln_TA) p(0.05)
winsor O_RCV_RO1,gen(O_RCV_flow) p(0.05)
winsor RCV_TO1,gen(RCV_to) p(0.05)
winsor DEBT_RO1,gen(DEBT_ro) p(0.05)
winsor ASSE_TO1,gen(TA_to) p(0.05)
winsor SUB_roe1,gen(SUB_roe) p(0.05)
winsor LN_LTI1,gen(ln_LTI) p(0.05)
winsor LN_O_RCV1,gen(ln_O_RCV) p(0.05)
winsor O_RCV_RO2,gen(O_RCV_stock) p(0.05)
winsor O_RCV_RO2,gen(d_O_RCV) p(0.05)

xtbalance,range(2,7)


*****************************************************Descriptive Stat & Correlations****************************************************************************

logout, save(o_rcv_descriptives) excel replace: ///tabstat O_RCV_stock  O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to SUB_roe,s(min max mean median sd skew kurt) c(s) f(%6.2f) by(soetag)
logout, save(o_rcv_corr) excel replace: ///
pwcorr O_RCV_stock  O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to SUB_roe, sig


**********************************************************Hypothesis 1***********************************************************************
*-------------------  ----------------------SOE Block--------------------   -------------------------------------
//SOE  O_RCV Stock model
xi:reg O_RCV_stock LTI_ro L.SUB_roe ln_TA TA_to DEBT_ro RCV_to i.FY i.dindc if soetag==1,robust
est store OLS_SOE_STOCK
xtreg O_RCV_stock LTI_ro L.SUB_roe ln_TA TA_to DEBT_ro RCV_to   if soetag==1,fe 
est store FE_SOE_STOCK
xtreg O_RCV_stock LTI_ro L.SUB_roe ln_TA TA_to DEBT_ro RCV_to   if soetag==1,re 
est store RE_SOE_STOCK
hausman FE_SOE_STOCK RE_SOE_STOCK


//SOE  O_RCV FLOW  model
xi:reg O_RCV_flow LTI_ro L.SUB_roe ln_TA TA_to DEBT_ro RCV_to i.FY i.dindc if soetag==1,robust
est store OLS_SOE_FLOW_
xtreg O_RCV_flow LTI_ro L.SUB_roe ln_TA TA_to DEBT_ro RCV_to if soetag==1,fe 
est store FE_SOE_FLOW
xtreg O_RCV_flow LTI_ro L.SUB_roe ln_TA TA_to DEBT_ro RCV_to  if soetag==1,re 
est store RE_SOE_FLOW
hausman FE_SOE_FLOW RE_SOE_FLOW

*----------------         ------------------------- NonSOE BLOCK         -----------------------           ------------------------------------------
//NONSOE  O_RCV Stock model
xi:reg O_RCV_stock LTI_ro L.SUB_roe ln_TA TA_to DEBT_ro RCV_to i.FY i.dindc if soetag==0,robust
est store OLS_NONSOE_STOCK
xtreg O_RCV_stock LTI_ro L.SUB_roe ln_TA TA_to DEBT_ro RCV_to   if soetag==0,fe 
est store FE_NONSOE_STOCK
xtreg O_RCV_stock LTI_ro L.SUB_roe ln_TA TA_to DEBT_ro RCV_to   if soetag==0,re 
est store RE_NONSOE_STOCK
hausman FE_NONSOE_STOCK RE_NONSOE_STOCK


//NONSOE  O_RCV FLOW  model
xi:reg O_RCV_flow LTI_ro L.SUB_roe ln_TA TA_to DEBT_ro RCV_to i.FY i.dindc if soetag==0,robust
est store OLS_NONSOE_FLOW_
xtreg O_RCV_flow LTI_ro L.SUB_roe ln_TA TA_to DEBT_ro RCV_to  if  soetag==0,fe 
est store FE_NONSOE_FLOW
xtreg O_RCV_flow LTI_ro L.SUB_roe ln_TA TA_to DEBT_ro RCV_to  if  soetag==0,re 
est store RE_NONSOE_FLOW
hausman FE_NONSOE_FLOW RE_NONSOE_FLOW

*----------------         ------------------------- Hypothesis 1 regressions output        -----------------------           ------------------------------------------

outreg2 [OLS_SOE_STOCK FE_SOE_STOCK RE_SOE_STOCK OLS_NONSOE_STOCK FE_NONSOE_STOCK RE_NONSOE_STOCK] using H1STOCK, excel replace ///	title("Panel A: Stock model") /// 	drop(_I*)  addstat(Wald , e(chi2)) /// 	tdec(2) rdec(3) r2 e(F)  dec(3)
outreg2 [OLS_SOE_FLOW FE_SOE_FLOW RE_SOE_FLOW OLS_NONSOE_FLOW FE_NONSOE_FLOW RE_NONSOE_FLOW] using H1FLOW, excel replace ///	title("Panel B: Flow model") /// 	drop(_I*) addstat(Wald , e(chi2)) /// 	tdec(2) rdec(3) r2 e(F)  dec(3) 

********************************************************Hypothesis 2*************************************************************************
logout, save(mean_SUB_roe) excel replace: ///
	ttest SUB_roe,by(soetag)
logout, save(median_SUB_roe) excel replace: ///
	median SUB_roe,by(soetag)

*----------------         ------------------------- OLS BLOCK         -----------------------           ------------------------------------------
reg SUB_roe  L.O_RCV_stock ln_TA  DEBT_ro TA_to RCV_to  d_ind* d_fy* if  soetag==0,robust
est store ROE_OLS_NONSOE
reg SUB_roe  L.O_RCV_stock ln_TA  DEBT_ro TA_to RCV_to  d_ind* d_fy* if  soetag==1,robust
est store ROE_OLS_SOE
*----------------         ------------------------- Two stage GMM BLOCK        -----------------------           ------------------------------------------
ivreg2 SUB_roe   ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) d_ind* d_fy* if  soetag==0,gmm2s robust
est store ROE_GMM2S_NONSOE
ivreg2 SUB_roe   ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) d_ind* d_fy* if  soetag==1,gmm2s robust
est store ROE_GMM2S_SOE


outreg2 [ROE_OLS_SOE ROE_GMM2S_SOE ROE_OLS_NONSOE ROE_GMM2S_NONSOE] using H2, excel replace ///	title("H2") /// 	drop(d_*)  /// 	tdec(2) rdec(3) r2 e(F) dec(3)

/*
xtivreg SUB_roe  ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI )  if  soetag==0,re
est store NONSOE_IV_FE
xtivreg SUB_roe  ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI )  if  soetag==1,re
est store SOE_IV_FE

xtivreg SUB_roe  ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) i.dindc i.FY if  soetag==1,fe
est store SOE_IV_FE
xtivreg SUB_roe  ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) i.dindc i.FY if  soetag==1,re
est store SOE_IV_RE

xtivreg SUB_roe  ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) i.dindc i.soetag ,re
est store re
xtivreg SUB_roe  ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) i.soetag ,fe
est store fe
hausman fe re
*/



