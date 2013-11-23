//Lu(1999) modified Jones model
sort stkcd FY
gen T_ACCR=i_netprofit-cd_TnetOPCF-D.b_otherRCV

gen T_ACCR_TA=T_ACCR/L.b_TA

gen R_TA=1/L.b_TA
gen D_SALES_TA= D.i_TOPincome/L.b_TA
gen PPE_TA=(b_TFixA+b_buildinsite+b_projectmaterial)/L.b_TA
gen INTANG_TA= (b_intangible+b_goodwill)/L.b_TA
cap gen LTI_RO1 = 2*b_LTEquityinvest/(L.b_TA+b_TA)
cap encode indc,gen(dindc)


reg T_ACCR_TA (FY#dindc)##(c.R_TA c.D_SALES_TA c.PPE_TA c.INTANG_TA C.LTI_RO1),noconstant

cap drop DA
predict DA,res

reg T_ACCR_TA (FY#dindc)##(c.R_TA c.D_SALES_TA c.PPE_TA c.INTANG_TA),noconstant
predict DA0,res


