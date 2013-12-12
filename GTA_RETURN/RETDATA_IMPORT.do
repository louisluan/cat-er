*-----------------Program version definition-------------------
version 12.1
*-----------------local definition--------------------------
local progdir "C:/Users/Louis/Documents/GitHub/cat-er/GTA_RETURN/"
local ddir "C:/programs/data/GTARET/"
local flname "TRD_Co TRD_Nrrate TRD_Weekcm TRD_Weekm TRD_Week TRD_Week_1 TRD_Week_2"
local fl1 "TRD_Co"

*------------------set working dir-------------------------------
cd "`ddir'"

*------------------Data input-------------------------------


foreach fl of local flname {

  insheet using `fl'.csv,name clear
  local tmpfl=`"`fl'"'
  if substr(`"`tmpfl'"',1,9)== "TRD_Week_" {
   
   local tmpfl= "TRD_Week"
   do `progdir'`tmpfl'_labels.do //no space between to locals
  }   

  cap drop if stkcd> 900000
  cap drop if stkcd> 200000 & stkcd < 290000
  //cap gen mid=string(stkcd) + "_" + accper + "_" +  typrep
  save `fl',replace
  
}
