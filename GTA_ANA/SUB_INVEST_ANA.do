cd C:\programs\STATA12X64\ado\personal\gta\data
use GTA_FS,clear
drop accper typrep b_gold b_derivatives b_repurchase b_projectmaterial b_bioA mid
drop if sttag==1
drop if statco~=1
tab listdate if date==date("2012-9-30","YMD")
drop if listdate > 2009
drop if month(date)~=12
cap xtset,clear
gen dt=year(date)
xtset stkcd dt
xtbalance,range(2008 2011)

xtdes


gen ROEss=2 * i_TComPLMinor/(L.b_OEMinor+b_OEMinor)
gen ROEcc=2 * i_PL4nonControl/(L.b_LTEquityinvest+b_LTEquityinvest)
gen ROEmm= 2 * i_netprofit4M/(L.b_TOEbelong2M+b_TOEbelong2M)
gen ROE1=2* i_TComPL/(L.b_TOE+b_TOE)
winsor ROEcc,gen(ROEc) p (0.1)
winsor ROEss,gen(ROEs) p (0.1)
winsor ROEmm,gen(ROEm) p (0.1)
winsor ROE1,gen(ROE) p (0.1)

label var ROEm "母公司ROE"
label var ROEs "子公司ROE"
label var ROEc "联营公司ROE"
label var ROE "上市公司ROE"
label var dt "年度"


drop if ROEc==. | ROEc==0 | ROEs==. | ROEs==0 | ROEm==. | ROEm==0 | ROE==. | ROE==0
xtdes
xtbalance,range(2009 2011)
graph box ROEs ROEc ROEm ROE,over(dt)
logout, save(mytable) excel replace:bys dt:sum ROEs ROEc ROEm ROE



logout, save(mytable) excel replace: bys dt:tabstat ROEs ROEc ROE, stat(mean median sd) c(s)

logout, save(mytable) word replace: bys dt: ttest ROEs=ROEc

logout, save(mytable) excel replace: pwcorr_a ROEs ROEc ROEm ROE

kdensity ROE,normal saving(roe)
kdensity ROEm,normal saving(roem)

kdensity ROEs,normal saving(roes)
kdensity ROEc,normal saving(roec)



bys dt:oneway ROEc ROEs
bys dt:sdtest ROEs=ROEc
bys date:ttest ROEs=ROE if ROEc~=. & ROEc~=0
