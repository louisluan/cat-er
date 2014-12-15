//keep following variables
keep stkcd indcd nindcd nindnme statco crcd commnt markettype listdt stknme
//generate sttag from company short name given by SEC
gen sttag=strpos(stknme,"ST" )>0

replace listdt= substr(listdt,1,4)
gen listdate=real(listdt)
drop listdt

label variable stkcd "证券代码"
label variable indcd "行业代码A"
label variable nindcd "证监会行业代码" 
label variable nindnme "证监会行业名称B"
label variable crcd "AB股交叉码" 
label variable commnt "H股交叉码"
label variable markettype "上市市场"
label variable listdate "上市日期"
label variable stknme "证券简称"
label variable sttag "ST标识"
cap label drop indLBL mktLBL statLBL stLBL

label define stLBL 0 "非ST" 1 "ST"
label define indLBL 0001 "金融" 0002 "公用事业" 0003 "房地产" 0004 "综合" 0005 "工业" 0006 "商业"
label define mktLBL 1 "沪A" 2 "沪B" 4 "深A" 8 "深B"  16 "创业板"
label define statLBL 1 "正常交易"  2 "终止上市" 3 "停牌" 4 "暂停上市"  

label values indcd indLBL
label values markettype mktLBL
label values sttag stLBL

encode statco,gen(costat)
label drop costat
drop statco
label values costat statLBL
label variable costat "公司状态"

