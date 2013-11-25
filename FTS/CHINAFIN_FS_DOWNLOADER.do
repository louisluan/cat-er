cd C:\programs\STATA12X64\ado\personal\FS_reports
import excel using stock_id.xls,first clear
duplicates drop
encode B,gen(dum)

local p "C:\programs\STATA12X64\ado\personal\FS_reports\"
qui sum dum
local count = r(max)
forvalue i=1(1)`count' {
  cap mkdir `i'
  preserve
  drop if dum~=`i'
  nois list B in 1/1
  qui sum dum
  local j= r(N)
  
  nois dis "`j'"
  forvalue t=1(1)`j'{
   local id  `=A[`t']' `id'
   
  }

  local pd="`p'"+"`i'"

  cap chinafin `id',path(`pd')
  restore
}



