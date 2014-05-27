insheet using TRD_Dalyr1.csv,name clear
save dr1,replace
insheet using TRD_Dalyr2.csv,name clear
save dr2,replace

insheet using TRD_Dalyr3.csv,name clear
save dr3,replace



append using dr1
append using dr2
cap drop dt
gen dt=date(trddt,"YMD")
format %td dt
order stkcd dt trddt
sort stkcd dt
save dr,replace

rm dr1.dta
rm dr2.dta
rm dr3.dta

insheet using RS_Aibasic.csv,name clear
cap drop dt
gen dt=date(ailtadt,"YMD")
format %td dt
dulpicates tag stkcd dt,gen(dtag)
drop if dtag==1
drop dtag
save seo, replace

merge 1:1 stkcd dt using seo
save dr,replace
