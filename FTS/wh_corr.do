cd C:\programs\STATA12X64\ado\personal\Returns
insheet using lw.csv,name clear
ren v1 date
ren v2 steel
save steel.dta,replace
insheet using lme.csv,name clear
ren v1 date
ren v2 copper
save copper.dta,replace
insheet using gz.csv,name clear
ren v1 date
ren v2 index
save index.dta,replace
insheet using jt.csv,name clear
ren v1 date
ren v2 coke
save coke.dta,replace
insheet using xj.csv,name clear
ren v1 date
ren v2 rubber
save rubber.dta,replace

use steel.dta,clear
merge 1:1 date using copper
drop if _merge~=3
drop _merge
merge 1:1 date using index
drop if _merge~=3
drop _merge
merge 1:1 date using coke
drop if _merge~=3
drop _merge
merge 1:1 date using rubber
drop if _merge~=3
drop _merge

logout, save(ftcorr) word: pwcorr_a index steel copper coke rubber
