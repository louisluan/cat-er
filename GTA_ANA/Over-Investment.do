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
drop if substr(GIC,1,1)=="I"

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

gen GrowthOpp=D.i_TOPincome/L.i_TOPincome
gen Lev=b_TLiab/b_TA
gen Cash=b_cash/b_TA
gen ATO=i_TOPincome/b_TA
gen Lage=FY+2005-listdate
gen Size=ln(b_TA)
gen ROA=i_netprofit/b_TA
gen ROE=i_netprofit/b_TOE
gen SubROE=i_PL4nonControl/b_LTEquityinvest
gen LnVol=ln(yvol)
gen TopShare2=topshare^2
ren sync SYNC
gen MtB=wclsprc/b_TA


gen INV=(cd_Tnetinvest-ci_amort-ci_intangileamort)/b_TA


winsor2 Size Cash Lev GrowthOpp INV ROA SubROE ATO LnVol, cut(1 99) replace

reg INV L.INV L.Size L.Lage L.MtB L.Cash L.Lev  L.ROA L.ATO soetag  L.yrt d_ind* d_fy*
predict OINV,res

winsor2 OINV ,cut(1 99) replace

keep stkcd FY INV OINV SYNC TopShare2 topshare LnVol SubROE ROE ROA Size MtB Lage ATO Cash Lev GrowthOpp

save OINV_SYNC.dta,replace

