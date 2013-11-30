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


gen T_RCV = D.b_noteRCV+D.b_accountRCV+ D.b_interestRCV +D.b_dividendRCV+ D.b_otherRCV
gen RCV_TO1=2*i_OPincome/(b_noteRCV+b_accountRCV+L.b_noteRCV+L.b_accountRCV)
gen O_RCV_RO1 = D.b_otherRCV/T_RCV
gen LTI_RO1 = 2*b_LTEquityinvest/(L.b_TA+b_TA)
gen LN_TA1 = ln(b_TA)
gen DEBT_RO1 = 2*b_TLiab/(L.b_TA+b_TA)
gen ASSE_TO1 = 2*i_TOPincome/(L.b_TA+b_TA)
gen LN_SUBPL1=ln(i_PL4nonControl)
gen LN_LTI1	=ln(L.b_LTEquityinvest)
gen LN_O_RCV1	=ln(L.b_otherRCV)
gen LN_D_O_RCV1	=ln(D.b_otherRCV)

winsor LTI_RO1,gen(LTI_RO) p(0.05) 
winsor LN_TA1,gen(LN_TA) p(0.05)
winsor O_RCV_RO1,gen(O_RCV_RO) p(0.05)
winsor RCV_TO1,gen(RCV_TO) p(0.05)
winsor DEBT_RO1,gen(DEBT_RO) p(0.05)
winsor ASSE_TO1,gen(ASSE_TO) p(0.05)
winsor LN_SUBPL1,gen(LN_SUBPL) p(0.05)
winsor LN_LTI1,gen(LN_LTI) p(0.05)
winsor LN_O_RCV1,gen(LN_O_RCV) p(0.05)
winsor LN_D_O_RCV1,gen(LN_D_O_RCV) p(0.05)

xtbalance,range(2,7)

pwcorr O_RCV_RO LTI_RO  LN_TA ASSE_TO DEBT_RO RCV_TO,sig 
tabstat O_RCV_RO LTI_RO  LN_TA ASSE_TO DEBT_RO RCV_TO,s(min max mean p25 median p50 sd) c(s) f(%8.2f)



xi:reg LN_D_O_RCV LTI_RO  LN_TA ASSE_TO DEBT_RO RCV_TO i.FY if i_PL4nonControl~=0
est store OLS
xtreg LN_D_O_RCV LTI_RO  LN_TA ASSE_TO DEBT_RO RCV_TO if i_PL4nonControl~=0,fe
est store FE
xtreg LN_D_O_RCV LTI_RO  LN_TA ASSE_TO DEBT_RO RCV_TO if i_PL4nonControl~=0,re 
est store RE
hausman FE RE

//reg or (FY#dindc)##(c.LTI_RO c.LN_TA  c.ASSE_TO c.DEBT_RO),noconst
//predict lteor,res

xi:reg O_RCV_RO LTI_RO  LN_TA ASSE_TO DEBT_RO RCV_TO i.FY if i_PL4nonControl~=0
est store OLS_YEAR
xi:reg O_RCV_RO LTI_RO  LN_TA ASSE_TO DEBT_RO RCV_TO i.dindc if i_PL4nonControl~=0
est store OLS_IND

reg O_RCV_RO LTI_RO  LN_TA ASSE_TO DEBT_RO RCV_TO if i_PL4nonControl~=0
est store OLS
xtreg O_RCV_RO LTI_RO  LN_TA ASSE_TO DEBT_RO RCV_TO  if i_PL4nonControl~=0,fe
est store FE
xtreg O_RCV_RO LTI_RO  LN_TA ASSE_TO DEBT_RO RCV_TO  if i_PL4nonControl~=0,re 
est store RE
hausman FE RE


reg LN_SUBPL LN_O_RCV LN_TA ASSE_TO LN_LTI if i_PL4nonControl~=0

xtreg LN_SUBPL LN_O_RCV LN_TA ASSE_TO LN_LTI FY if i_PL4nonControl~=0,fe
est store fe
xtreg LN_SUBPL LN_O_RCV LN_TA ASSE_TO LN_LTI  FY if i_PL4nonControl~=0,re 
est store re
hausman fe re


