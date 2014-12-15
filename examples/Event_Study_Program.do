/*
��һ������������ȥ��������ظ��۲⣬�Լ��۲�����̫���޷��о��Ĺ�˾
�ڶ���������dif�������������¼��պ�ÿ��������֮���ʱ�����������ý�����Ҳ������������
����ʹ�ý����յ����ݼ��㷽�����Բο�����˵��������ʹ�õ���������

calculating the number of trading days is a little trickier than calendar days. For trading
days, we first need to create a variable that counts the number of days within each company_id. Then we
determine which observation occurs on the event date. We create a variable with the event date's day number
on all of the observations within that company_id. Finally, we simply take the difference between the two,
creating a variable, dif, that counts the number of days between each individual observation and the event
day. 

*-------------------------For number of trading days:------------------------
sort company_id date
by company_id: gen datenum=_n
by company_id: gen target=datenum if date==event_date
egen td=min(target), by(company_id)
drop target
gen dif=datenum-td

*/


*----------------------------------For calendar days:-----------------------
use stockdata2,clear
gen dif=date-event_date

/*
��ʼȷ���¼�����ǰ���Ƿ����㹻����������
������[-2,+2]�Լ�������5��Ϊ�¼����ڣ�30����Ϊ���ƴ��ڡ�
�ȸ��ݶ��������¼��͹��ƴ��ڣ�Ȼ��ͳ�ƶ�Ӧ�������������ݵ����������Ա����ɾ����������Ĺ۲�


*/

bys company_id: gen event_window=1 if dif>=-2 & dif<=2
egen count_event_obs=count(event_window), by(company_id)
bys company_id: gen estimation_window=1 if dif<-30 & dif>=-60
egen count_est_obs=count(estimation_window), by(company_id)
replace event_window=0 if event_window==.
replace estimation_window=0 if estimation_window==.

/*�ж��Ƿ����㹻�Ĺ۲���к������ƣ���ɾ������������Ĺ�˾
*/

tab company_id if count_event_obs<5
tab company_id if count_est_obs<30


drop if count_event_obs < 5
drop if count_est_obs < 30

*----------------------------------���������ر�-------------------------------------
/*
���г�ģ��CAPM��ÿ�ҹ�˾����ʱ�����й��ƣ��ó�alpha��beta����������������¼������������ر��Ĺ��ƣ�Ԥ�⣩

�˴�������һ���µ�id����ʶ��˾����ţ���������лع��ѭ����д��

*/

gen predicted_return=.
egen id=group(group_id) /* for multiple event dates, use: egen id = group(group_id) */

qui tab id
local N = r(r)  

forvalues i=1(1)`N' { 
	l id company_id if id==`i' & dif==0
	reg ret market_return if id==`i' & estimation_window==1
	predict p if id==`i'
	replace predicted_return = p if id==`i' & event_window==1
	drop p
}

/*�����쳣������
AR=�¼����ڵ�������-Ԥ��������
CAR=����������AR
*/

sort id date
gen abnormal_return=ret-predicted_return if event_window==1
bys id: egen cumulative_abnormal_return = sum(abnormal_return)

/*Testing for Significance
��ÿ֧��Ʊ����CAR!=0�ļ��飬�����ͳ�������£�����һ��tͳ����
TEST= ((��AR)/N) / (AR_SD/sqrt(N))
AR_SD ��AR��������׼��. ��ֵͨ����1.96@5%������ˮƽ

*/

sort id date
bys id: egen ar_sd = sd(abnormal_return)
gen test =(1/sqrt(5)) * ( cumulative_abnormal_return/ar_sd)
list company_id cumulative_abnormal_return test if dif==0


*��������csv:
//outsheet company_id event_date cumulative_abnormal_return test using stats.csv if dif==0, comma names

/*���������Լ���

Ϊ�˿����췽�����أ�ʹ��reg��ֱ��ʹ��test�����Ƚ�
*/

reg cumulative_abnormal_return if dif==0, robust //Parametric t test with heteroscedacity standard errors

signtest cumulative_abnormal_return=0 //Non-parametric median test
/*��ͼ*/
tsline  cumulative_abnormal_return market_return if  event_window==1
