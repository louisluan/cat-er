
local progdir "C:/Users/Louis/Documents/GitHub/cat-er/MCS/"
local ddir "C:/programs/data/mcs"

local flname="000409 000420 000519 000581 000725 000760 000786 000876 000878 000910 000928 000953 002013 002032 002045 002050 002071 002074 002080 002083 002085 002102 002103 002110 002118 002132 002143 002162 002191 002202 002240 002250 002256 002276 002293 002326 002345 002356 002399 002403 002540 002604 600095 600099 600114 600199 600230 600234 600809 600983 "

cd `ddir'

foreach fl of local flname {

  import excel using `fl'.xls, first clear allstring cellrange(A1:D53)
 
  foreach v of varlist B C D {
	local lbvar:variable label `v'
	ren `v' y`lbvar'
  }

  
  replace y2010="." if y2010=="NA" | y2010==""
  replace y2011="." if y2011=="NA" | y2011==""
  replace y2012="." if y2012=="NA" | y2012==""
  gen yy2010=real(y2010)
  gen yy2011=real(y2011)
  gen yy2012=real(y2012)
  dropvars y2010 y2011 y2012
  

  xpose,clear
  drop if _n==1
  gen FY=2009+_n
  gen stkcd=real("`fl'")
  save `fl',replace
  
}

foreach fl of local flname {

  
  append using `fl'.dta
  
}

foreach fl of local flname {

  
  rm  `fl'.dta
}


do `progdir'RenVars.do 

order stkcd FY STGConcern
duplicates drop
drop OINV

merge 1:1 stkcd FY using OINV.dta
drop if _merge==2
drop _merge

save MCS.dta,replace


