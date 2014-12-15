cap cd C:\programs\data\GTA
cap cd /Users/luisluan/data/GTA

use OINV_SYNC.dta,clear




xtset stkcd FY

gen OPRisk=(b_noteRCV+b_accountRCV+b_otherRCV)/b_TA

ren topshare TopShare





//Blocks to winsorize data and gen descriptive statistics 
winsor2   SYNC OINV Lev OPRisk  TopShare LnVol  Cash Size ROA  ,cut(1 99) replace


//Main regression block

reg  SYNC  OINV  OPRisk Lev ROA TopShare   LnVol  Cash Size   soetag d_fy* d_ind*,vce(cluster stkcd)
est store FULL

reg  SYNC  OINV  OPRisk Lev ROA TopShare   LnVol  Cash Size   soetag d_fy* d_ind*
est store OLS

set seed 1
reg  SYNC  OINV  OPRisk Lev ROA TopShare   LnVol  Cash Size   soetag d_fy* d_ind*,vce(bootstrap,reps(500))
est store BS

reg  SYNC  OINV ROA TopShare   LnVol  Cash Size  soetag d_fy* d_ind*,vce(cluster stkcd)
est store H1

reg  SYNC  OPRisk ROA TopShare   LnVol  Cash Size  soetag d_fy* d_ind*,vce(cluster stkcd)
est store H2

reg  SYNC Lev ROA TopShare   LnVol  Cash Size  soetag d_fy* d_ind*,vce(cluster stkcd)
est store H3


qreg SYNC  OINV  OPRisk Lev ROA TopShare   LnVol  Cash Size   soetag d_fy* d_ind*,q(0.5)
est store MID
xtreg  SYNC  OINV  OPRisk Lev ROA TopShare   LnVol  Cash Size , fe
est store FE

xtreg  SYNC  OINV  OPRisk Lev ROA TopShare  Cash c.LnVol##c.Size  d_fy*, fe
margins,at(Size=(19.1(0.05)25)) vsquish
marginsplot
marginsplot, recast(line) recastci(rline) ///
             ytitle("同步性") xtitle("对数资产规模") title("对数资产规模边际效应") ///
             ciopts(lpattern(dash))
graph export Size_MARGINAL_EFFECT_TO_SYNC.png

//blocks to output the regression results
*----main reg results------------
outreg2 [H1 H2 H3 FULL OLS BS] using SYNCANA, excel replace ///
	title("SYNC") /// 
	drop(d_*) adds(F,e(F),Wald,e(chi2))  /// 
	tdec(2) rdec(3) dec(3)  adjr2 
	
	
outreg2 [MID FE] using SYNCROBUST, excel replace ///
	title("ROBUSTNESS") /// 
	drop(d_*) adds(F,e(F),Wald,e(chi2))  /// 
	tdec(2) rdec(3) dec(3)  
	
*Grammer of addstats,short for adds in parentheses is -(name1,scalar1,name2,scalar2)	
	
//blocks to output the descriptive statistics
logout, save(SYNC_descriptives) excel replace: ///
	tabstat SYNC  OINV Lev OPRisk ROA TopShare  LnVol  Cash Size ,s(min max mean median sd count) c(s) f(%6.2f)
logout, save(SYNC_corr) excel replace: ///
	pwcorr   SYNC OINV Lev  OPRisk ROA TopShare  LnVol  Cash Size  


	
/**     out-dated codes
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


//blocks to test the mediation effect of OINV using other SubROE-OINV-sync model

reg  SubROE OINV  Lev Cash Size ROA ATO soetag d_fy* d_ind*
est store SubROE_OLS
xtreg  SubROE OINV  Lev Cash Size ROA ATO d_fy* ,fe     //Second validate if SubROE contributed to mediator OINV -- check the significance of a
est store SubROE_FE

reg  SYNC OINV TopShare  LnVol Lev Cash Size ROA soetag d_fy* d_ind*,vce(cluster stkcd)
est store SYNC_OINV_OLS
xtreg  SYNC OINV Lev Cash Size ROA d_fy* ,fe //First validate if SubROE contributed to sync-- check the significance of c'
est store SYNC_OINV_FE

reg  SYNC OINV SubROE TopShare  LnVol Lev Cash Size ROA soetag d_fy* d_ind*,vce(cluster stkcd)

reg  SYNC OINV SubROE Lev Cash Size ROA soetag d_fy* d_ind*
est store SYNC_FULL_OLS
xtreg  SYNC OINV SubROE Lev Cash Size ROA d_fy* ,fe //Last validate if SubROE and mediator OINV contributed to sync -- check the significance of a and b
est store SYNC_Full_FE
**/
	

