cap cd /Users/luisluan/data/GTARET
cap cd C:\programs\data\GTARET


use RETDATA,clear
gen TY=real(substr(trdwnt,1,4))
gen TW=real(substr(trdwnt,6,2))
sort stkcd TY TW
//---------------------calculate yearly return using weekly data-----------
gen rtw=1+wretwd 
egen cumrt=prod(rtw),by(stkcd TY)
gen yrt=cumrt-1
//---------------------calculate annual overall trading volume--------------
egen yvol=sum(wnshrtrd),by(stkcd TY)

//----------------------keep unique data--------------------------------
gen FY=TY-2005
bys stkcd FY: egen maxwid=max(TW) 

bys stkcd FY: keep if TW==maxwid
label var yrt "Yearly Return" 
label var yvol "Yearly Trading Volume"
keep stkcd FY yrt yvol


//----------save data and overwrite the copy in GTA dir----------------
save year_ret.dta,replace

local rtdir "C:\programs\data\GTA\"
local rtdirmac "/Users/luisluan/data/GTA/"

cap{
  copy year_ret.dta "`rtdir'",replace
  copy year_ret.dta "`rtdir'" ,replace
}
