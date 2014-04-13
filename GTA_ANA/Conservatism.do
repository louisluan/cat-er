cap cd /Users/luisluan/data/GTA
cap cd C:\programs\data\GTA


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

xtset stkcd FY

//block to generate variable data 

//-------------Accrual model of conservatism----------------------


foreach v of varlist b_cash-ci_netcasheqincr {
  cap  replace `v'=0 if `v'==.
}

gen TACC=i_netprofit+ci_amort-cd_TnetOPCF //Total Accrual

gen OpACC=D.b_accountRCV+D.b_inventory+D.b_prepaid-D.b_AccPaya-D.b_taxPaya //Operatioanl Accrual

gen NonOpAcc=TACC-OpACC //Non-Operational Accrual

gen cons_NonOpAcc=-NonOpAcc/L.TA //Accrual model of conservatism

//---------------Matching model of conservatism-------------


gen Expn=i_TOPincome-(i_netprofit-i_Aimpair-i_otherCOS-i_fairvaluePL-i_investPL)


statsby _b, by(stkcd) saving(MatchingConsv.dta,replace): reg i_TOPincome L.Expn Expn F.Expn

merge m:1 stkcd using MatchingConsv
 
drop _merge

ren _stat_1 cons_Match

//-----------------C-Score Model of conservatism-------------------

gen Lev=b_TLiab/b_TA
gen Size=ln(b_TA)
gen MtB=wclsprc/b_TA

gen EtP=i_beps/L.wclsprc
gen D=yrt<0





