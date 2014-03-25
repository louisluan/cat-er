cap xtset,clear
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
//xtbalance,range(1,7)

list stkcd if b_TA==0

gen growth=D.i_TOPincome/L.i_TOPincome
gen lev=b_TLiab/b_TA
gen cash=b_cash
gen age=FY+2005-listdate
gen size=b_TA
gen inv=cd_Tnetinvest
