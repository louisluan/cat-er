cd /Users/luisluan/data/GTA
use GTA_FS,clear
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
drop _merge
merge 1:1 stkcd FY using SYNC
drop if _merge~=3
drop _merge

xtset stkcd FY
//xtbalance,range(1,7)

gen growth=D.i_TOPincome/L.i_TOPincome
gen lev=b_TLiab/b_TA
gen cash=b_cash/b_TA

gen age=FY+2005-listdate
gen size=ln(b_TA)
gen roa=i_netprofit/b_TA
gen subroe=i_PL4nonControl/b_LTEquityinvest




gen inv=(cd_Tnetinvest-ci_amort-ci_intangileamort)/b_TA


winsor2 size cash lev growth inv roa subroe sync, cut(1 99) replace
 
xtreg inv L.inv L.size L.age L.cash L.lev L.growth  L.yrt L.roa d_ind* d_fy* ,fe
predict invhat
gen overinv=inv-invhat

tabstat overinv,s(mean min p25 p50 p75 max sd) f(%6.2f) 




//blocks to test the mediation effect of overinv using other subroe-overinv-sync model

xtreg  sync overinv lev cash size d_fy* ,fe //First validate if subroe contributed to sync-- check the significance of c'

xtreg  subroe overinv  lev cash size d_fy* ,fe     //Second validate if subroe contributed to mediator overinv -- check the significance of a

xtreg  sync c.overinv##c.subroe lev cash size d_fy* ,fe //Last validate if subroe and mediator overinv contributed to sync -- check the significance of a and b



sgmediation sync,mv(subroe) iv(overinv)



