/*
�����еĹ�˾�ж���¼���������һ����Ҫȷ����Щ��˾�����˾���N���¼���������ر������ݸ���N�Σ�
��Ϊ��ͬ�ġ���˾���¼������о���
��һ���������¼������ݽ��зֹ�˾ʱ����ͳ�ƣ�����Ψһ�ļ���
*/

use eventdates, clear
by company_id: gen eventcount=_N
by company_id: keep if _n==1
sort company_id
keep company_id eventcount 
save eventcount,replace

*���¼������ļ��ϲ���ԭʼ�Ļر��������У��Ը����¼�������������Ʒ�������¼���˾�Ļر���ΪN��

use stockdata, clear
sort company_id
merge m:1 company_id using eventcount //�Ǳ���Ψһ�ģ��ı߾���1����Ψһ��һ����m
tab _merge
keep if _merge==3
drop _merge

*�ؼ������expand�����Ӧ�Ĺ�˾��N��ͬ���������ʹ۲⣬�Ա������ϲ�
expand eventcount,gen(duptag)
*����set����������¼����¼���˾����ĵڼ���set���ݣ������ϲ��ͱ�ʶ�����ĸ��¼���	 
drop eventcount
sort company_id date
by company_id date: gen set=_n
sort company_id set
save stockdata2,replace

*׼��ԭʼ���¼������ݣ�ҲΪ����¼��Ĺ�˾����set����������ϲ�
use eventdates, clear
by company_id: gen set=_n
sort company_id set
save eventdates2,replace
use stockdata2, clear
merge m:1 company_id set using eventdates2
tab _merge		 
*�ر�������ȱʧֵ		  
list company_id if _merge==2 
keep if _merge==3
drop _merge
*�������һ���µ�ID������group_id��Ψһ��ʶÿһ�����ݣ������������������id		  
egen group_id = group(company_id set)	  
save stockdata2,replace
