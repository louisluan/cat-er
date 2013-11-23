gen tdate=real(substr(reptdt,1,4))
drop if length(s0701b)<2 | length(s0703b)<2
gsort stkcd -tdate
duplicates drop stkcd,force


gen soetag= strpos(s0701b,"����") >0 | strpos(s0703b,"����") > 0

cap drop tdate reptdt s0701a s0702a s0703a s0705a s0702b s0706b  s0704a 

cap label drop soeLBL

label define soeLBL 0 "�ǹ���" 1 "����"
label value soetag soeLBL 
label variable soetag "���йɱ�ʶ"
label variable s0704b "����Ȩ����"
label variable s0704c "����Ȩ����"
label variable seperation "����Ȩ������Ȩ֮��"
