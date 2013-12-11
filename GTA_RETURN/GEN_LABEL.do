*-----------------Program version definition-------------------
version 12.1
*-----------------local definition--------------------------
local ddir "C:\Users\Louis\Desktop\2013½ðÈÚ¼ÆÁ¿-PPT"
local fname "TRD_Nrrate"

*------------------set working dir-------------------------------
cd "`ddir'"

*------------------Data input-------------------------------
//infile str15 vname str20 vlabel str5 vvoid  str150 vdes  
insheet using `fname'.txt,clear delimiter(" ")

drop v3
gen v3=v2+v4
