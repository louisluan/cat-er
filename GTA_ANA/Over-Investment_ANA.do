cap cd C:\programs\data\GTA
cap cd /Users/luisluan/data/GTA

use OINV_SYNC.dta,clear


qreg OINV Lev Cash Size ROA  ATO soetag d_fy* d_ind* , quantile(.75) nolog
qreg OINV Lev Cash Size ROE  ATO soetag d_fy* d_ind* ,quantile(.75) nolog

reg OINV Lev Cash Size ROA F(1/3).ROA ATO soetag d_fy* d_ind* ,vce(cluster stkcd)
reg OINV Lev Cash Size ROE F(1/3).ROE ATO soetag d_fy* d_ind* ,vce(cluster stkcd)

xtreg  OINV Lev Cash Size ROA F(1/3).ROA ATO soetag d_fy* d_ind* ,fe vce(cluster stkcd)
xtreg  OINV Lev Cash Size ROE F(1/3).ROE ATO soetag d_fy* d_ind* ,fe vce(cluster stkcd)






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

sgmediation SYNC,mv(SubROE) iv(OINV) cv(Lev Cash Size ROA d_fy*)
