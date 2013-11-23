cd C:\programs\STATA12X64\ado\personal\gta\data
use GTA_FS,clear
drop accper typrep b_gold b_derivatives b_repurchase b_projectmaterial b_bioA mid
drop if sttag==1
drop if statco~=1
tab listdate if date==date("2012-9-30","YMD")
drop if listdate > 2009
drop if month(date)~=12
cap xtset,clear
gen dt=year(date)
xtset stkcd dt
xtbalance,range(2008 2011)

xtdes
