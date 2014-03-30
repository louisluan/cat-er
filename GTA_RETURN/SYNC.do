cd C:\programs\data\GTARET
use RETDATA,clear
gen TY=real(substr(trdwnt,1,4))
gen TW=real(substr(trdwnt,6,2))
sort stkcd TY TW
encode(nnindcd),gen(inddum)
bys inddum TY TW:egen trind=sum(wmvosd*wretwd)
bys inddum TY TW:egen tvind=sum(wmvosd)
gen wrind= trind/tvind
drop trind tvind
gen riw=1+wretwd
gen rmw=1+wretwdos
gen rind=1+wrind

sort stkcd TY TW
gen TSID=TY*100+TW
xtset stkcd TSID
statsby  _b _se r2=e(r2), by(stkcd TY) saving(SYNC.dta,replace): regress riw rmw L.rmw rind L.rind
use SYNC,clear

gen FY=TY-2005
gen sync=ln(_eq2_r2/(1-_eq2_r2))
save SYNC,replace 
