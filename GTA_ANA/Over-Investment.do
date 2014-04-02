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
gen SubROE=i_PL4nonControl/b_LTEquityinvest
ren sync SYNC


gen INV=(cd_Tnetinvest-ci_amort-ci_intangileamort)/b_TA

winsor2 Size Cash Lev GrowthOpp INV ROA SubROE ATO, cut(1 99) replace

xtreg INV L.INV L.Size L.Lage L.Cash L.Lev L.GrowthOpp  L.yrt L.ROA d_ind* d_fy* ,fe
predict INVhat
gen OINV=INV-INVhat


logout, save(SYNC_descriptives) excel replace: ///
	tabstat SubROE OINV SYNC  Size Cash Lev GrowthOpp INV ROA Lage ATO,s(min max mean median sd count) c(s) f(%6.2f)
logout, save(SYNC_corr) excel replace: ///
	pwcorr_a SubROE OINV SYNC  Size Cash Lev GrowthOpp INV ROA Lage ATO, star1(0.01) star5(0.05) star10(0.1)
 







//blocks to test the mediation effect of OINV using other SubROE-OINV-sync model

reg  SubROE OINV  Lev Cash Size ROA ATO d_fy* d_ind*
est store SubROE_OLS
xtreg  SubROE OINV  Lev Cash Size ROA  d_fy* ,fe     //Second validate if SubROE contributed to mediator OINV -- check the significance of a
est store SubROE_FE

reg  SYNC OINV Lev Cash Size ROA d_fy* d_ind*
est store SYNC_OINV_OLS
xtreg  SYNC OINV Lev Cash Size ROA d_fy* ,fe //First validate if SubROE contributed to sync-- check the significance of c'
est store SYNC_OINV_FE

reg  SYNC OINV SubROE Lev Cash Size ROA d_fy* d_ind*
est store SYNC_FULL_OLS
xtreg  SYNC OINV SubROE Lev Cash Size ROA d_fy* ,fe //Last validate if SubROE and mediator OINV contributed to sync -- check the significance of a and b
est store SYNC_Full_FE

outreg2 [SubROE_OLS SubROE_FE] using SubROE, excel replace ///
	title("SubROE") /// 
	drop(d_*)  addstat(Wald , e(chi2)) /// 
	tdec(2) rdec(3) r2 e(F)  dec(3)

//sgmediation sync,mv(SubROE) iv(OINV)



