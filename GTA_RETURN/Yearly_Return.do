gen TY=real(substr(trdwnt,1,4))
gen TW=real(substr(trdwnt,6,2))
sort stkcd TY TW
gen rtw=1+wretwd
egen cumrt=prod(rtw),by(stkcd TY)
gen yrt=cumrt-1


keep if TW==1
keep stkcd TY yrt
gen FY=TY-2005
drop TY

save year_ret.dta,replace
