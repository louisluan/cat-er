cd C:\programs\STATA12X64\ado\personal\FS_reports
//define each report type's blocks of files, e.g. if there are BS1-BS4.csv 4 csv tables,bs_i=4,so do is_i and cs_i 
local bs_i=4
local is_i=5
local cs_i=4

//import SIC code and save as a dta file for further merge using
insheet using SIC.csv,name clear
cap drop v* //drop possibly imported null variables
duplicates drop _comcd,force 
save SIC.dta,replace

//loops for importing statement of cashflows and save as seperated dta
forvalue i=1/`cs_i'{
 insheet using CS`i'.csv,names clear
 cap drop v*
 save CS`i',replace
}

//loops for importing balance sheets and save as seperated dta
forvalue i=1/`bs_i'{
 insheet using BS`i'.csv,names clear
 cap drop v*
 save BS`i',replace
}

//loops for importing income statements and save as seperated dta
forvalue i=1/`is_i'{
 insheet using IS`i'.csv,names clear
 cap drop v*
 save IS`i',replace
}

//merge balance sheets into one dta and erase single ones
use BS1.dta,clear

forvalue i=2/`bs_i'{
 append using BS`i'
 rm BS`i'.dta
}

duplicates drop
drop if _lstflg=="B"
drop if _reporttype=="O" 
gen mid=trim(_comcd)+"_"+ string(_conflg)+"_"+ string(_adjflg)+"_"+ substr(_reporttype,1,2)+"_"+ trim(_enddt) 
save BS_resset,replace

//merge statements of cashflows into one dta and erase single ones
use CS1.dta,clear

forvalue i=2/`cs_i'{
 append using CS`i'
 rm CS`i'.dta
}

duplicates drop
drop if _lstflg=="B"
drop if _reporttype=="O"

gen mid=trim(_comcd)+"_"+ string(_conflg)+"_"+ string(_adjflg)+"_"+ substr(_reporttype,1,2)+"_"+ trim(_enddt)
save CS_resset,replace

//merge income statements into one dta and erase single ones
use IS1.dta,clear

forvalue i=2/`is_i'{
 append using IS`i'
 rm IS`i'.dta
}
duplicates drop
drop if _lstflg=="B"
drop if _reporttype=="O"
drop if _reporttype=="Q3*"
gen mid=trim(_comcd)+"_"+ string(_conflg)+"_"+ string(_adjflg)+"_"+ substr(_reporttype,1,2)+"_"+ trim(_enddt)
save IS_resset,replace

//erase lingered single b/s c/s i/s dta
rm BS1.dta
rm CS1.dta
rm IS1.dta

//main merging process keep matched data
use BS_resset,clear
cap drop if _lstflg=="B"
cap merge 1:1 mid using IS_resset,assert(match)
drop if _merge~=3
drop _merge
cap merge 1:1 mid using CS_resset,assert(match)
drop if _merge~=3
drop _merge
cap merge m:1 _comcd using SIC.dta,assert(match master)
drop if _merge==2
drop _merge
drop if _indcd1=="I" //drop company data if it was a financial firm
save FSA_resset,replace


drop if _adjflg==1 
drop if _conflg==2
encode _enddt,gen(date)
xtset a_a_stkcd date
xtdes
