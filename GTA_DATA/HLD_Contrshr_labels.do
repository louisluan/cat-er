gen tdate=real(substr(reptdt,1,4))
drop if s0701a=="0" | s0701b=="0"
gen soetag= strpos(s0701b,"国有") >0 | strpos(s0703b,"国有") > 0

bys stkcd tdate:egen topshare=mean(s0704b) if s0704b~=.
bys stkcd tdate:egen topcontrol=mean(s0704c) if s0704c~=.
bys stkcd tdate:egen topshared=mean(s0704a) if s0704a~=.
drop if missing(topshare) & missing(topshared)
egen topshare1=rowmax(topshare topshared) if topshared~=. & topshare~=.
drop if topshare1==.
drop topshare topshared
ren topshare1 topshare
gsort stkcd -tdate
duplicates drop stkcd tdate,force




cap drop  s0701a s0702a s0703a s0704a s0705a s0701b s0702b s0703b s0704b s0706b  s0704c  
cap drop  notes tdate

cap label drop soeLBL 

cap gen mid=string(stkcd) + "_" + reptdt + "_" +  "A"

label define soeLBL 0 "非国有" 1 "国有"
label value soetag soeLBL 
label variable soetag "国有股标识"
label variable topshare "1大股东所有权比例"
label variable topcontrol "1大股东控制权比例"
label variable seperation "控制权与所有权之差"
