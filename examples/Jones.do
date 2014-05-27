*if there is any error prompt,please try findit winsor2 version 12.0*Open sample data-----------------------------------------cd D:/use zxb.dta,clear*Panel Definition-----------------------------------------xtset stkcd FYxtbalance,range(1,7)*Data generation------------------------------------------*TAit=Δ流动资产-Δ现金及现金等价物-Δ(流动负债-一年内到期的长期负债)-折旧和摊销成本gen TAccrual = D.b_TCA - D.b_cash - (D.b_TCLiab - D.b_nonCLiabin1Y) - ci_amortgen TAccToTA = TAccrual/L.b_TAgen OneToTA = 1/L.b_TAgen DRevToTA = D.i_OPincome/L.b_TAgen PpeToTA = L.b_TFixA/L.b_TA*generate Recievables used in Modified Jones Modelgen REC = b_noteRCV + b_accountRCV + b_otherRCVsort stkcd FYgen RecToTA = D.REC/L.b_TA*generate Recievables used in Lu Jian Qiao Jones Modelgen IAL = b_LTexp2Amort + b_intangible //Intangible Assets and Other Long-Term Assets,definition unclear from Lu(1999)gen IaToTA = IAL/L.b_TA  gen DifToTA = DRevToTA - RecToTA*Data cleaningwinsor2 TAccToTA OneToTA DRevToTA PpeToTA DifToTA IaToTA RecToTA, cut(1 99) replace*Jones Model Estimation---------------------------------*Note that Jones Model should be estimated using firm specific time series data,which is hard for data in Chinagen DA=.   //Placeholder for Dicretional Accruals*gradiant regression and collecting residuals as proxy of DA forval i=4/7 {		bys stkcd:reg TAccToTA OneToTA DRevToTA PpeToTA if FY < `i' ,noconstant		predict DA`i' if FY == `i',residual	replace DA = DA`i' if DA`i' ~=. }*Modified Jones Model Calculation(Dechow,1995)------------gen _eq2_FY=FY //for merging purpose later*collecting betas from original Jones model regressionforval i=4/7 {		statsby _b FY=`i',by(stkcd) saving(Jones`i',replace):reg TAccToTA OneToTA DRevToTA PpeToTA if FY<`i' ,noconstant		}preserve //keep data in memoryuse Jones7,clearforval i=4/6 {		append using Jones`i'	rm Jones`i'.dta}save Jones,replacerestoremerge 1:1 stkcd _eq2_FY using Jones*Calculation NDA &DA using Dechow(1995) Formulagen ModiNDA = _b_OneToTA*OneToTA + _b_DRevToTA*(DRevToTA-RecToTA) + _b_PpeToTA*PpeToTAgen ModiDA = TAccToTA - ModiNDAwinsor2 ModiDA,cut(1 99) replace*Lu Jian Qiao Version of extended Jones model------------------*Methodology: Cross Sectional Regression*Added Data: Intangible Assets and Other Long-Term Assetsbys FY: reg TAccToTA OneToTA DifToTA PpeToTA IaToTA ,noconstant	predict LuDA, residual*Overall Summary of all DA proxies------------------------------tabstat DA ModiDA LuDA,s(min max mean p25 p50 p75 skew kurt) c(s) f(%6.2f)*DD model--------------------------------------------------------*Data generation------------------------------------------*ΔAR指应收账款的增加，ΔAP指应付账款，ΔTP是应纳税额sort stkcd FYgen DifWC = D.b_accountRCV + D.b_inventory - D.b_AccPaya - D.b_taxPaya + D.b_otherCAwinsor2 cd_TnetOPCF DifWC, cut(1 99) replace*DD model estimatin using firm specific time series data*rolling regression and collecting residualsrolling _b, window(3) start(2) end(6) keep(stkcd) saving(DD,replace):reg DifWC L.cd_TnetOPCF cd_TnetOPCF F.cd_TnetOPCF*Data precleaningpreserve //keep data in memoryuse DD,cleargen FY = end - 1dropvars start end daterenvars _stat_1 _b_cd_TnetOPCF _stat_3 _b_cons / _b1 _b2 _b3 _b4save, replacerestore*merge back betas of DD estimationcap drop _mergemerge 1:1 stkcd FY using DD*Calculate residuals using betasgen DDres = DifWC - _b4 - _b1*L.cd_TnetOPCF - _b2*cd_TnetOPCF - _b3*F.cd_TnetOPCF*Get standard deviation of DD model residuals as proxy of eanrings qualitybys stkcd: egen SD_DD_Res = sd(DDres)winsor2 SD_DD_Res,cut(1 99) replacetabstat SD_DD_Res,s(min max mean p25 p50 p75 skew kurt) c(s) f(%6.2f)