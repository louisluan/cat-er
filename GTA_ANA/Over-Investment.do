cd C:\programs\data\GTA
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

merge 1:1 stkcd FY using year_ret
drop if _merge~=3

xtset stkcd FY
//xtbalance,range(1,7)

list stkcd if b_TA==0

gen growth=D.i_TOPincome/L.i_TOPincome
gen lev=b_TLiab/b_TA
gen cash=b_cash/b_TA
gen age=FY+2005-listdate
gen size=ln(b_TA)


gen inv=(-cd_Tnetinvest-ci_amort-ci_intangileamort)/b_TA 

winsor2 size cash lev growth inv, cut(1 99)

xtreg inv L.inv L.size L.age L.cash L.lev L.growth  L.yrt d_ind* d_fy* if soetag==1,fe
