/*directories for holding all GTA FS sheet data `ddir' and the do file `progdir' are defined at top
  All gta data file should be csv format,comma delimited,and if there were encoding problems, open the dataset and resave using excel 2007 or later
*/


//define GTA sheet names, from B/S I/S to C/S d i
//loops to import sheet data to stata and make initial treatments
// use "/" in path to avoid \ worked as escape sequencer 

local progdir "C:/Users/Louis/Documents/GitHub/cat-er/GTA_DATA/"
local ddir "C:/programs/data/GTA/"
local flname "FS_Combas FS_Comins FS_Comscfd FS_Comscfi TRD_Co HLD_Contrshr"

cd `ddir'

foreach fl of local flname {

  insheet using `fl'.csv,name clear
  cap drop if strpos(accper,"/1/1")>0

  do `progdir'`fl'_labels.do
   qui ds
  foreach v of varlist `r(varlist)' {
  local tmp:variable label `v'

  local tmp1= substr("`tmp'",1,2)
  //对字符型local的引用需额外增加""，如"`tmp1'"
  if "`tmp1'"== "Z_" {    
    drop `v'
     }
  
  }
   
  do `progdir'`fl'_ren.do
  drop if stkcd> 900000
  drop if stkcd> 200000 & stkcd < 290000
  cap gen mid=string(stkcd) + "_" + accper + "_" +  typrep
  save `fl',replace
  
}


//merging all fs into one,basing balance sheet



use `ddir'FS_Combas,clear
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
// qui xtset stkcd date

save GTA_FS,replace
