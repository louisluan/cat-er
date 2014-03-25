gen TY=real(substr(trdwnt,1,4))
gen TW=real(substr(trdwnt,6,2))
sort stkcd TY TW
gen rtw=1+wretwd
egen cumrt=prod(rtw),by(stkcd TY)
gen yrt=cumrt-1

gen FY=TY-2005
bys stkcd FY: egen maxwid=max(TW) 

bys stkcd FY: keep if TW==maxwid
keep stkcd FY yrt



save year_ret.dta,replace
