clear
//deal with day data
import excel using XJD.xls,first clear
gen o=1
replace o=-1 if trim(F)=="Âô"
gen date=date(B,"YMD")
format date %td
destring H ,gen(price)
drop A-H
drop I-P
sort date
gen t="c"
save xjd.dta,replace


//deal with half-day data

import excel using XJB.xls,first clear
gen o=1
replace o=-1 if C=="¿ÕÍ·"
drop C-K
gen date=date(A,"YMDhm")
format date %td
destring B ,gen(price)
drop A-B
gen t="o"
append using xjd.dta
sort date
save xjb.dta,replace




gen tag=1 if t[_n]==t[_n-1]
drop if tag==1
drop tag
import excel using XJ.xls, clear
renvars A-D / price o date t
gen pl=price[_n]-price[_n+1] if o==-1& t=="o"
replace pl=price[_n+1]-price[_n] if o==1 & t=="o"
gen cpl=int(sum(pl)*9.9)+100000
gen opl=(1+int((cpl-100000)/100000))*int(sum(pl)*9.9)+100000
twoway line opl date
gen rt=(opl[_n+2]-opl[_n])/opl[_n]
format rt %4.2f
tabstat rt,stats(min mean p50 max sd) col(s) format(%4.2f)
//logout, save(tradetest) word replace: tabstat rt,stats(min mean p50 max sd) col(s) format(%4.2f)


