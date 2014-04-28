cap cd C:\programs\data\GTA
cap cd /Users/luisluan/data/GTA

use OINV_SYNC.dta,clear




xtset stkcd FY



//Blocks to winsorize data and gen descriptive statistics 
winsor2   SYNC OINV cons_SDE CScore topshare  LnVol Lev Cash Size ROA  ,cut(1 99) replace

pwcorr   SYNC OINV   cons_SDE  CScore topshare  LnVol Lev Cash Size ROA  


reg  SYNC c.cons_SDE##c.OINV  topshare  LnVol Lev Cash Size ROA soetag d_fy* d_ind*,vce(cluster stkcd)
set seed 1
reg  SYNC c.cons_SDE##c.OINV topshare  LnVol Lev Cash Size ROA soetag d_fy* d_ind*,vce(bootstrap,reps(100))



margins,at(OINV=(-0.2(0.05)0.18)) vsquish
marginsplot
marginsplot, recast(line) recastci(rline) ///
             ytitle("同步性") xtitle("不确定性") title("不确定性边际效应") ///
             ciopts(lpattern(dash))
graph export OINV_MARGINAL_EFFECT_TO_SYNC.png

margins,at(cons_SDE=(0.01(0.05)0.9)) vsquish
marginsplot
marginsplot, recast(line) recastci(rline) ///
             ytitle("同步性") xtitle("运营风险") title("运营风险边际效应") ///
             ciopts(lpattern(dash))
graph export CONS_MARGINAL_EFFECT_TO_SYNC.png

/**     out-dated codes
//blocks to test the mediation effect of OINV using other SubROE-OINV-sync model

reg  SubROE OINV  Lev Cash Size ROA ATO soetag d_fy* d_ind*
est store SubROE_OLS
xtreg  SubROE OINV  Lev Cash Size ROA ATO d_fy* ,fe     //Second validate if SubROE contributed to mediator OINV -- check the significance of a
est store SubROE_FE

reg  SYNC OINV topshare TopShare2 LnVol Lev Cash Size ROA soetag d_fy* d_ind*,vce(cluster stkcd)
est store SYNC_OINV_OLS
xtreg  SYNC OINV Lev Cash Size ROA d_fy* ,fe //First validate if SubROE contributed to sync-- check the significance of c'
est store SYNC_OINV_FE

reg  SYNC OINV SubROE topshare TopShare2 LnVol Lev Cash Size ROA soetag d_fy* d_ind*,vce(cluster stkcd)

reg  SYNC OINV SubROE Lev Cash Size ROA soetag d_fy* d_ind*
est store SYNC_FULL_OLS
xtreg  SYNC OINV SubROE Lev Cash Size ROA d_fy* ,fe //Last validate if SubROE and mediator OINV contributed to sync -- check the significance of a and b
est store SYNC_Full_FE
**/


//blocks to output the descriptive statistics
logout, save(SYNC_descriptives) excel replace: ///
	tabstat SubROE OINV SYNC  Size Cash Lev GrowthOpp INV ROA Lage ATO,s(min max mean median sd count) c(s) f(%6.2f)
logout, save(SYNC_corr) excel replace: ///
	pwcorr_a SubROE OINV SYNC  Size Cash Lev GrowthOpp INV ROA Lage ATO, star1(0.01) star5(0.05) star10(0.1)

//blocks to output the regression results

outreg2 [SubROE_OLS SubROE_FE] using SubROE, excel replace ///
	title("SubROE") /// 
	drop(d_*)   /// 
	tdec(2) rdec(3) r2 e(F) dec(3)
	
outreg2 [SYNC_OINV_OLS SYNC_OINV_FE] using SYNC_OINV, excel replace ///
	title("SYNC_OINV") /// 
	drop(d_*)   /// 
	tdec(2) rdec(3) r2 e(F) dec(3)
	
outreg2 [SYNC_FULL_OLS SYNC_Full_FE] using FULL, excel replace ///
	title("FULL") /// 
	drop(d_*)   /// 
	tdec(2) rdec(3) r2 e(F) dec(3)

sgmediation SYNC,mv(CScore) iv(OINV) cv(Lev Cash Size ROA d_fy*)
