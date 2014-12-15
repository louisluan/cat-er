/*
由于有的公司有多次事件发生，第一步需要确认那些公司发生了具体N次事件，并将其回报率数据复制N次，
视为不同的“公司”事件进行研究。
第一步，利用事件日数据进行分公司时间数统计，留下唯一的计数
*/

use eventdates, clear
by company_id: gen eventcount=_N
by company_id: keep if _n==1
sort company_id
keep company_id eventcount 
save eventcount,replace

*将事件计数文件合并到原始的回报率数据中，以根据事件计数的情况复制发生多次事件公司的回报率为N次

use stockdata, clear
sort company_id
merge m:1 company_id using eventcount //那边是唯一的，哪边就是1，不唯一的一边是m
tab _merge
keep if _merge==3
drop _merge

*关键命令，用expand扩充对应的公司到N次同样的收益率观测，以备后续合并
expand eventcount,gen(duptag)
*生成set变量，来记录多次事件公司具体的第几个set数据，后续合并和标识具体哪个事件用	 
drop eventcount
sort company_id date
by company_id date: gen set=_n
sort company_id set
save stockdata2,replace

*准备原始的事件日数据，也为多次事件的公司生成set变量，方便合并
use eventdates, clear
by company_id: gen set=_n
sort company_id set
save eventdates2,replace
use stockdata2, clear
merge m:1 company_id set using eventdates2
tab _merge		 
*回报数据有缺失值		  
list company_id if _merge==2 
keep if _merge==3
drop _merge
*最后生成一个新的ID变量，group_id来唯一标识每一组数据，后续都用这个变量作id		  
egen group_id = group(company_id set)	  
save stockdata2,replace
