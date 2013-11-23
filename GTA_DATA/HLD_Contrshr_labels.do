gen tdate=real(substr(reptdt,1,4))
drop if length(s0701b)<2 | length(s0703b)<2
gsort stkcd -tdate
duplicates drop stkcd,force


gen soetag= strpos(s0701b,"国有") >0 | strpos(s0703b,"国有") > 0

cap drop tdate reptdt s0701a s0702a s0703a s0705a s0702b s0706b  s0704a 

cap label drop soeLBL

label define soeLBL 0 "非国有" 1 "国有"
label value soetag soeLBL 
label variable soetag "国有股标识"
label variable s0704b "所有权比例"
label variable s0704c "控制权比例"
label variable seperation "控制权与所有权之差"
