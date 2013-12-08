cd C:\programs\data\GTA
use GTA_FS,clear
keep if substr(accper,6,2)=="12"
drop if statco~=1
drop date
drop if sttag==1
gen indc=substr(GIC,1,1)
replace indc=substr(GIC,1,2) if indc=="C"

encode indc,gen(dindc)
encode accper,gen(FY)



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
gen LN_SUBPL1=i_PL4nonControl/L.b_LTEquityinvest
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
winsor LN_SUBPL1,gen(SUB_roe) p(0.05)
winsor LN_LTI1,gen(ln_LTI) p(0.05)
winsor LN_O_RCV1,gen(ln_O_RCV) p(0.05)
winsor O_RCV_RO2,gen(O_RCV_stock) p(0.05)
winsor O_RCV_RO2,gen(d_O_RCV) p(0.05)

xtbalance,range(2,7)


logout, save(o_rcv_descriptives) excel replace: ///tabstat O_RCV_stock  O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to SUB_roe,s(min max mean median sd) c(s) f(%6.2f)
logout, save(o_rcv_corr) excel replace: ///
pwcorr O_RCV_stock  O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to SUB_roe, sig


//SOE  O_RCV Stock model
xi:reg O_RCV_stock LTI_ro  ln_TA TA_to DEBT_ro RCV_to i.FY i.dindc if i_PL4nonControl~=0 & soetag==1,robust
est store OLS_SOE_STOCK
xtreg O_RCV_stock LTI_ro  ln_TA TA_to DEBT_ro RCV_to  if i_PL4nonControl~=0 & soetag==1,fe
est store FE_SOE_STOCK
xtreg O_RCV_stock LTI_ro  ln_TA TA_to DEBT_ro RCV_to soetag if i_PL4nonControl~=0 & soetag==1,re 
est store RE_SOE_STOCK
hausman FE_SOE_STOCK RE_SOE_STOCK


//SOE  O_RCV FLOW  model
xi:reg O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to i.FY i.soetag if i_PL4nonControl~=0 & soetag==1
est store OLS_SOE_FLOW_YEAR
xi:reg O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to i.dindc i.soetag if i_PL4nonControl~=0 & soetag==1
est store OLS_SOE_FLOW_IND

reg O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to if i_PL4nonControl~=0 & soetag==1
est store OLS_SOE_FLOW
xtreg O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to  if i_PL4nonControl~=0 & soetag==1,fe
est store FE_SOE_FLOW
xtreg O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to  if i_PL4nonControl~=0 & soetag==1,re 
est store REFE_SOE_FLOW
hausman FE_SOE_FLOW RE_SOE_FLOW

//NONSOE D_O_RCV STOCK model 
xi:reg O_RCV_stock LTI_ro  ln_TA TA_to DEBT_ro RCV_to i.FY i.dindc if i_PL4nonControl~=0 & soetag==0,robust
est store OLS_NONSOE_STOCK
xtreg O_RCV_stock LTI_ro  ln_TA TA_to DEBT_ro RCV_to  if i_PL4nonControl~=0 & soetag==0,fe
est store FE_NONSOE_STOCK
xtreg O_RCV_stock LTI_ro  ln_TA TA_to DEBT_ro RCV_to soetag if i_PL4nonControl~=0 & soetag==0,re 
est store RE_NONSOE_STOCK
hausman FE_NONSOE_STOCK RE_NONSOE_STOCK

//NONSOE D_O_RCV FLOW model

xi:reg O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to i.FY i.soetag if i_PL4nonControl~=0 & soetag==0
est store OLS_NONSOE_FLOW_YEAR
xi:reg O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to i.dindc i.soetag if i_PL4nonControl~=0 & soetag==0
est store OLS_NONSOE_FLOW_YEAR_IND

reg O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to if i_PL4nonControl~=0 & soetag==0
est store OLS_NONSOE_FLOW_YEAR
xtreg O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to  if i_PL4nonControl~=0 & soetag==0,fe
est store FE_NONSOE_FLOW_YEAR
xtreg O_RCV_flow LTI_ro  ln_TA TA_to DEBT_ro RCV_to  if i_PL4nonControl~=0 & soetag==0,re 
est store RE_NONSOE_FLOW_YEAR
hausman FE_NONSOE_FLOW_YEAR RE_NONSOE_FLOW_YEAR

tab dindc,gen(dum_dind)
tab FY,gen(dum_FY)
drop dum_FY1
drop dum_dind1

ivreg2 SUB_roe   ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) dum_dind* dum_FY* if i_PL4nonControl~=0 & soetag==0,gmm2s robust
ivreg2  SUB_roe  ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) dum_dind* dum_FY* if i_PL4nonControl~=0 & soetag==0,gmm2s robust
ivreg2 SUB_roe   ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) dum_dind* dum_FY* if i_PL4nonControl~=0 & soetag==1,gmm2s robust
ivreg2  SUB_roe  ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) dum_dind* dum_FY* if i_PL4nonControl~=0 & soetag==1,gmm2s robust


xtivreg SUB_roe  ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) i.dindc if i_PL4nonControl~=0 & soetag==0,re
est store re
xtivreg SUB_roe  ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) if i_PL4nonControl~=0 & soetag==0,fe
est store fe
hausman fe re

xtivreg SUB_roe  ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) i.dindc i.soetag if i_PL4nonControl~=0 ,re
est store re
xtivreg SUB_roe  ln_TA  DEBT_ro TA_to RCV_to (L.O_RCV_stock=L.ln_LTI ) i.soetag if i_PL4nonControl~=0 ,fe
est store fe
hausman fe re

xtreg SUB_roe O_RCV_flow L.O_RCV_flow  ln_TA TA_to DEBT_ro ln_LTI  if i_PL4nonControl~=0 & soetag==0,fe 


