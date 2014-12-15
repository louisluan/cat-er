
local ddir "C:\programs\data\RESSET"
cd `ddir'
//define each report type's blocks of files, e.g. if there are BS1-BS4.csv 4 csv tables,bs_i=4,so do is_i and cs_i 
local bs_i=5
local is_i=7
local cs_i=6
local fr_i=2
mat mnum= (`bs_i',`is_i',`cs_i',`fr_i')
local lm= colsof(mnum)
local flname "BS_ IS_ SCF_ FINRATIO_"

//blocks to import csv data and save as dta
local j=1
foreach fl of local flname {
  
	 forvalue k=1/`=mnum[1,`j++']' {
	 insheet using `fl'`k'.csv,name clear
	 cap drop v*
	 cap drop _spefieldrmk 
	 save `fl'`k'.dta,replace
	}
 }

 //blocks to append dta files and generate merge id
local j=1
foreach fl of local flname {
  
	 use `fl'1.dta,clear
	 
	 forvalue k=2/`=mnum[1,`j++']' {
	 append using `fl'`k'.dta
	 
	}
	duplicates drop
	cap drop if _lstflg=="B"
    cap drop if _reporttype=="O" 
	cap drop if _reporttype=="Q3*" 
	cap drop if _adjflg==0
	cap drop if a_a_stkcd>=400000 & a_a_stkcd< 600000
	cap drop if a_a_stkcd>=900000
	drop if missing( a_a_stkcd )
	cap gen _conflg=1
	
    gen mid=trim(_comcd)+"_"+ string(_conflg)+ "_" + substr(_reporttype,1,2) + "_"+ trim(_enddt) 
	save `fl'A.dta,replace
 }






//main merging process keep matched data
use BS_A,clear
cap drop if _lstflg=="B"
merge 1:1 mid using IS_A
drop if _merge~=3
drop _merge
merge 1:1 mid using SCF_A
drop if _merge~=3
drop _merge
merge 1:1 mid using FINRATIO_A
drop if _merge==2
drop _merge
//blocks to delete all temp dta files
local fdta:dir . files "*.dta"
foreach fl of local fdta {
   erase `fl'
}
//save data in memory into a final dta
save FS_resset,replace







