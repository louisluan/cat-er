/*directory for holding all GTA FS sheet data,the do file should be located at parent dir of data at ..\
  All gta data file should be csv format,comma delimited,and the char encoding must be utf-8(not GB2312 or GBK)
  If there is encoding problems, you can open the csv with office excel 2007 later versions and save another copy of new csv for later operations
*/


//define GTA sheet names, from B/S I/S to C/S d i
//loops to import sheet data to stata and make initial treatments



local ddir "C:\programs\STATA12X64\ado\personal\gta\"
local flname "FS_Combas FS_Comins FS_Comscfd FS_Comscfi TRD_Co HLD_Contrshr"

cd `ddir'\data

foreach fl of local flname {

  insheet using `fl'.csv,name clear
  cap drop if strpos(accper,"/1/1")>0
  do `ddir'\`fl'_labels.do
   qui ds
  foreach v of varlist `r(varlist)' {
  local tmp:variable label `v'

  local tmp1= substr("`tmp'",1,2)
  //对字符型local的引用需额外增加""，如"`tmp1'"
  if "`tmp1'"== "Z_" {    
    drop `v'
     }
 }
 
  
  
  do `ddir'\`fl'_ren.do
  drop if stkcd> 900000
  drop if stkcd> 200000 & stkcd < 290000
  cap gen mid=string(stkcd) + "_" + accper + "_" +  typrep
  save `fl',replace
  
}


//merging all fs into one,basing balance sheet
local ddir "C:\programs\STATA12X64\ado\personal\gta\"


use `ddir'\data\FS_Combas,clear
merge 1:1 mid using FS_Comins
drop if _merge~=3
drop _merge
merge 1:1 mid using FS_Comscfd
drop if _merge~=3
drop _merge
merge m:1 stkcd using TRD_Co
drop if _merge==2
drop _merge
merge m:1 stkcd using HLD_Contrshr
drop if _merge==2
drop _merge

gen date=date(accper,"YMD")
format date %tdCCYY-NN-DD
qui xtset stkcd date

save GTA_FS,replace
