*-----------------Program version definition-------------------
version 12.1
*-----------------local definition--------------------------
local progdir "C:/Users/Louis/Documents/GitHub/cat-er/GTA_RETURN/"
local ddir "C:/programs/data/GTARET/"
local flname "TRD_Co TRD_Nrrate TRD_Weekcm TRD_Weekm TRD_Week TRD_Week_1 TRD_Week_2 TRD_Week_3"
local numfl = 3

*------------------set working dir-------------------------------
cd "`ddir'"

*------------------Data input-------------------------------


foreach fl of local flname {

  insheet using `fl'.csv,name clear
  local tmpfl=`"`fl'"'
  if substr(`"`tmpfl'"',1,9)== "TRD_Week_" {
   
   local tmpfl= "TRD_Week"
  }   
  do `progdir'`tmpfl'_labels.do //no space between to locals
  cap drop if stkcd> 900000
  cap drop if stkcd> 200000 & stkcd < 290000
  cap {
     split clsdt,p(/) gen(Z_tc)
	 replace Z_tc2= "0"+Z_tc2 if length(Z_tc2)==1
	 replace Z_tc3= "0"+Z_tc3 if length(Z_tc3)==1
	 replace clsdt=Z_tc1+"-"+Z_tc2+"-"+Z_tc3
     drop Z_tc*
	 
  }
  //cap gen mid=string(stkcd) + "_" + accper + "_" +  typrep
  save `fl',replace
  
}

*------------------Data Merge & cleaning-------------------------------

use TRD_Week.dta,clear

forvalue i=1/`numfl' {
  append using TRD_Week_`i'.dta
  erase TRD_Week_`i'.dta
}
save TRD_Week,replace

use TRD_Week,clear

merge m:1 stkcd using TRD_co
drop if _merge~=3
drop _merge
merge m:1 clsdt using TRD_Nrrate
drop if _merge~=3
drop _merge
merge m:1 markettype trdwnt using TRD_Weekm
drop if _merge~=3
drop _merge
cap drop Z_tc*
save RETDATA,replace
