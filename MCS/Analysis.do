cap cd C:\programs\data\mcs
cap cd /Users/luisluan/data/mcs
use MCS,clear
tabstat STGConcern BusiMode CHNConcern CoreComp Fin Bankhold Subs Guarrantee ///
		UnityBrand UnityLogo CashDist ESOP HoldFin TopinSub ORCV Budget ///
		ERP Diver Lev Risk Culture TopEdu TopAge StaffEdu UnityComp CompPub ///
		WebStrategy WebHonor WebHR DebtCost TopOverseas MIS SNS Web ///
		SubRoeContrib Indu ProdHHI TerriHHI MKTShares SubHHI ProbContract ///
		LawSuit AuditorCH Fine ProductPC AccountingRule Brand50 TopChange ///
		ProfitQua SalesPC QuickRatio,s(min max p50 mean sd N) c(s)
dropvars ProdHHI TerriHHI MKTShares SubHHI Diver 

gen Unity=UnityBrand+UnityLogo+UnityComp
gen LawProb=ProbContract+LawSuit + AuditorCH +Fine+AccountingRule
gen MktPwr=Indu+Brand50
gen FinPwr=Fin+Bankhold
tab FY,gen(d_FY)
drop d_FY1

factor STGConcern BusiMode CHNConcern CoreComp  FinPwr Subs Guarrantee ///
		Unity CashDist d_FY*

predict FBorder

 factor   ESOP HoldFin TopinSub ORCV Budget ///
		ERP  Lev Risk d_FY*

predict FInter

factor Culture TopEdu TopAge StaffEdu UnityComp CompPub ///
		WebStrategy WebHonor WebHR DebtCost TopOverseas MIS SNS Web d_FY*

predict FBelief


factor SubRoeContrib  LawProb  MktPwr ///
		 ProductPC   TopChange ///
		ProfitQua SalesPC QuickRatio d_FY*
		
predict FDiag

reg SYNC FDiag FBelief FBorder FInter Lev ATO Size i.FY
reg ROE FDiag FBelief FBorder FInter  ATO Size Lev i.FY




