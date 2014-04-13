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

winsor2 STGConcern BusiMode CHNConcern CoreComp  FinPwr Subs Guarrantee ///
		Unity CashDist ESOP HoldFin TopinSub ORCV Budget ///
		ERP  Lev Risk Culture TopEdu TopAge StaffEdu UnityComp CompPub ///
		WebStrategy WebHonor WebHR DebtCost TopOverseas MIS SNS Web ///
		SubRoeContrib  LawProb  MktPwr ///
		 ProductPC   TopChange ROE SYNC ///
		ProfitQua SalesPC QuickRatio,cut(1 99) replace

factor STGConcern BusiMode CHNConcern CoreComp  FinPwr Subs Guarrantee ///
		Unity CashDist ESOP HoldFin TopinSub ORCV Budget ///
		ERP  Lev Risk Culture TopEdu TopAge StaffEdu UnityComp CompPub ///
		WebStrategy WebHonor WebHR DebtCost TopOverseas MIS SNS Web ///
		SubRoeContrib  LawProb  MktPwr ///
		 ProductPC   TopChange ///
		ProfitQua SalesPC QuickRatio d_FY*, factors(4) pcf

reg ROE STGConcern BusiMode CHNConcern CoreComp  FinPwr Subs Guarrantee ///
		Unity CashDist
reg SYNC STGConcern BusiMode CHNConcern CoreComp  FinPwr Subs Guarrantee ///
		Unity CashDist

predict FBorder

reg ROE ESOP HoldFin TopinSub ORCV Budget ///
		ERP  Lev Risk 
		
reg SYNC ESOP HoldFin TopinSub ORCV Budget ///
		ERP  Lev Risk 

predict FInter

reg ROE Culture TopEdu TopAge StaffEdu UnityComp CompPub ///
		WebStrategy WebHonor WebHR DebtCost TopOverseas MIS SNS Web
		
reg SYNC Culture TopEdu TopAge StaffEdu UnityComp CompPub ///
		WebStrategy WebHonor WebHR DebtCost TopOverseas MIS SNS Web

predict FBelief

reg  SYNC SubRoeContrib  LawProb  MktPwr ///
		 ProductPC   TopChange ///
		ProfitQua SalesPC QuickRatio

reg  ROE SubRoeContrib  LawProb  MktPwr ///
		 ProductPC   TopChange ///
		ProfitQua SalesPC QuickRatio
		
predict FDiag

reg SYNC FA1-FA4 Lev ATO Size i.FY
reg ROE FA1-FA4  ATO Size Lev i.FY




