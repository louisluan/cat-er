/*
第一步，数据清理，去除多余的重复观测，以及观测数量太少无法研究的公司
第二步，生成dif变量，来计算事件日和每个交易日之间的时间间隔，可以用交易日也可以用日期日
关于使用交易日的数据计算方法可以参考下面说明，本例使用的是日期日

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
开始确认事件窗口前后是否有足够的收益数据
本例以[-2,+2]以及当天这5天为事件窗口，30天作为估计窗口。
先根据定义生成事件和估计窗口，然后统计对应窗口内收益数据的总天数，以便后续删除天数不足的观测


*/

bys company_id: gen event_window=1 if dif>=-2 & dif<=2
egen count_event_obs=count(event_window), by(company_id)
bys company_id: gen estimation_window=1 if dif<-30 & dif>=-60
egen count_est_obs=count(estimation_window), by(company_id)
replace event_window=0 if event_window==.
replace estimation_window=0 if estimation_window==.

/*判断是否有足够的观测进行后续估计，并删除数据量不足的公司
*/

tab company_id if count_event_obs<5
tab company_id if count_est_obs<30


drop if count_event_obs < 5
drop if count_est_obs < 30

*----------------------------------估计正常回报-------------------------------------
/*
用市场模型CAPM对每家公司进行时间序列估计，得出alpha和beta，并后续用其进行事件窗口内正常回报的估计（预测）

此处新生成一个新的id来标识公司的序号，并方便进行回归的循环编写。

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

/*计算异常收益率
AR=事件窗口的收益率-预测收益率
CAR=加总起来的AR
*/

sort id date
gen abnormal_return=ret-predicted_return if event_window==1
bys id: egen cumulative_abnormal_return = sum(abnormal_return)

/*Testing for Significance
对每支股票进行CAR!=0的检验，计算的统计量如下，这是一个t统计量
TEST= ((ΣAR)/N) / (AR_SD/sqrt(N))
AR_SD 是AR的样本标准差. 阈值通常用1.96@5%显著性水平

*/

sort id date
bys id: egen ar_sd = sd(abnormal_return)
gen test =(1/sqrt(5)) * ( cumulative_abnormal_return/ar_sd)
list company_id cumulative_abnormal_return test if dif==0


*输出结果倒csv:
//outsheet company_id event_date cumulative_abnormal_return test using stats.csv if dif==0, comma names

/*总体显著性检验

为了考虑异方差因素，使用reg比直接使用test更加稳健
*/

reg cumulative_abnormal_return if dif==0, robust //Parametric t test with heteroscedacity standard errors

signtest cumulative_abnormal_return=0 //Non-parametric median test
/*画图*/
tsline  cumulative_abnormal_return market_return if  event_window==1
