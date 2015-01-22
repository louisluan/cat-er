cd "D:\download\DB"
local myfilelist: dir . files "*.xls"
foreach filename of local myfilelist {
  import excel using `"`filename'"',firstrow cellra(D2:D28) clear
  xpose,clear
  gen stkcd=substr("`filename'",1,6)
  gen dt=real(substr("`filename'",8,4))
  save `filename'.dta, replace
}

cd "D:\download\DB1"
local myfilelist: dir . files "*.xls"
foreach filename of local myfilelist {
  import excel using `"`filename'"',firstrow cellra(B2:B28) clear
  xpose,clear
  dis "`filename'"
  gen stkcd=substr("`filename'",1,6)
  gen dt=real(substr("`filename'",8,4))
  save `filename'.dta, replace
}

clear
cd "D:\download\DB"
local myfilelist: dir . files "*.dta"
foreach filename of local myfilelist {
   append using "`filename'"
  
}
save exdb.dta,replace
