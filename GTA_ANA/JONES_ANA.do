//Lu(1999) modified Jones model
sort stkcd date
gen tacc=i_netprofit-cd_TnetOPCF-D.b_otherRCV

gen tacc2ta=tacc/L.b_TA

gen one2ta=1/L.b_TA
gen sales2ta= D.i_TOPincome/L.b_TA
gen ppe2ta=(b_TFixA+b_buildinsite+b_projectmaterial)/L.b_TA
gen ia2ta= (b_intangible+b_goodwill)/L.b_TA
encode indc,gen(dindc)


reg tacc2ta (date#dindc)##(c.one2ta c.sales2ta c.ppe2ta c.ia2ta),noconstant
cap drop DA
predict DA,res

sort stkcd date
gen tacc1=i_netprofit-cd_TnetOPCF
gen tacc2ta1=tacc1/L.b_TA
reg tacc2ta1 (date#dindc)##(c.one2ta c.sales2ta c.ppe2ta c.ia2ta),noconstant
predict DA1,res

gen difDA=DA1-DA

tabstat difDA,s(min p25 median p75 max mean sd)
