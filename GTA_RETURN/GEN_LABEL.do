*-----------------Program version definition-------------------
version 12.1
*-----------------local definition--------------------------
local ddir "C:\programs\data\GTARET"
local fname "TRD_Weekm"

*------------------set working dir-------------------------------
cd "`ddir'"

*------------------Data input-------------------------------
//infile str15 vname str20 vlabel str5 vvoid  str150 vdes  
insheet using `fname'.txt,clear delimiter(" ")

drop v3
gen v3=v2+v4
drop v2 v4
gen v0="label variable "
replace v1=lower(v1)

gen cmd=v0+v1+" "
replace v3=`"""' + v3 + `"""'
drop v0 v1
order cmd v3

