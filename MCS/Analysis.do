cap cd C:\programs\data\mcs
cap cd /Users/luisluan/data/mcs
use MCS,clear
tabstat STGConcern BusiMode CHNConcern CoreComp Fin Bankhold Subs Guarrantee ///
		UnityBrand UnityLogo CashDist ESOP HoldFin TopinSub ORCV Budget ///
		ERP Diver Lev Risk Culture TopEdu TopAge StaffEdu UnityComp CompPub ///
		WebStrategy WebHonor WebHR DebtCost TopOverseas MIS SNS Web ///
		SubRoeContrib Indu ProdHHI TerriHHI MKTShares SubHHI ProbContract ///
		LawSuit AuditorCH Fine ProductPC AccountingRule Brand50 TopChange OINV ///
		ProfitQua SalesPC QuickRatio,s(min max p50 mean sd N) c(s) f(%6.2f)
dropvars ProdHHI TerriHHI MKTShares SubHHI Diver 

gen Unity=UnityBrand+UnityLogo+UnityComp
gen LawProb=ProbContract+LawSuit + AuditorCH +Fine+AccountingRule
gen ITCon=ERP+Web+SNS+MIS

tabstat Unity LawProb ITCon,s(min max p50 mean sd N) c(s) f(%6.2f)

tab FY,gen(d_FY)
drop d_FY1

winsor2 STGConcern BusiMode CHNConcern CoreComp  LawProb  Guarrantee ///
		Unity CashDist ESOP TopinSub ORCV Budget ITCon ///
	    Lev Risk Culture TopEdu TopAge StaffEdu UnityComp CompPub ///
		WebStrategy WebHonor WebHR DebtCost ///
		SubRoeContrib ProductPC   TopChange ROE OINV ///
		ProfitQua SalesPC QuickRatio,cut(1 99) replace
		
tabstat STGConcern BusiMode CHNConcern CoreComp  LawProb ITCon Guarrantee ///
		Unity CashDist ESOP TopinSub ORCV Budget ///
	    Lev Risk Culture TopEdu TopAge StaffEdu  CompPub ///
		WebStrategy WebHonor WebHR DebtCost ///
		SubRoeContrib  ///
		 ProductPC   TopChange ROE OINV ///
		ProfitQua SalesPC QuickRatio,s(min max p50 mean sd N) c(s) f(%6.2f)





factor STGConcern BusiMode CHNConcern CoreComp  Guarrantee Unity CashDist,fa(1) 

predict FBorder

		
factor ESOP TopinSub ORCV  TopEdu Lev Risk ITCon,fa(1)

predict FInt
		
factor Culture   CompPub WebStrategy WebHonor WebHR,fa(1)

predict FBelief
		
factor  SubRoeContrib ProductPC TopChange ROE OINV ProfitQua SalesPC QuickRatio,fa(1)

predict FDiag

reg ROE FInt FBelief FBorder FDiag i.stkcd i.FY
reg SYNC FInt FBelief FBorder FDiag Size ATO i.stkcd i.FY






