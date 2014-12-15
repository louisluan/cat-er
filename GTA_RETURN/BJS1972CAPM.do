*-----------------Program version definition-------------------
version 12.1
*-----------------local definition--------------------------
local progdir "C:/Users/Louis/Documents/GitHub/cat-er/GTA_RETURN/"
local ddir "C:/programs/data/GTARET/"
local flname "TRD_Co TRD_Nrrate TRD_Weekcm TRD_Weekm TRD_Week TRD_Week_1 TRD_Week_2"



*------------------set working dir-------------------------------
cd "`ddir'"

*------------------Data input-------------------------------
use RETDATA.dta,clear
encode trdwnt,gen(trdwks)
drop if markettype==2 | markettype==8
drop if statco=="D" | statco=="S"
drop if trdwks<300 // drop return data for the year 2006 
drop trdwks
encode trdwnt,gen(weeknum)
egen compid=group(stkcd)

order compid weeknum trdwnt
sort compid weeknum
xtset compid weeknum
replace wretwd=(wclsprc-wopnprc)/wopnprc if wretwd==.
replace wretnd=(wclsprc-wopnprc)/wopnprc if wretnd==.
xtbalance,range(1,104)
*------------Black Jensen Scholes(1972) portfolio method for CAPM test---------------
//time series regression to get beta-i for each company for window [1,T1],set window size=50
gen cwr_a=wretwd-nrrwkdt //gen risk-free adjusted weekly return for each company
gen mwr_a=wretwdos-nrrwkdt //gen risk-free adjusted weekly return for market
statsby  _b _se, by(compid) saving(csbetabjs.dta,replace): regress cwr_a mwr_a if weeknum<=50 //stage 1time serie regression of CAPM T-T1
merge m:1 compid using csbetabjs,nogen //merge beta-i back to the data
gsort -_b_mwr_a compid weeknum
egen compidpf=group(_b_mwr_a compid)
drop if compidpf>1600
cap drop cid
gen cid=autocode(compidpf,10,1,10)
egen portfmean=mean(cwr_a),by(cid weeknum)
preserve
keep portfmean mwr_a weeknum cid
tabstat portfmean,s(min max mean p50 skew kurt) c(s) f(%6.3f)
statsby _b _se r2=e(r2) n=e(df_r),clear by(cid): regress portfmean mwr_a if weeknum>50 & weeknum<=80//stage 2 time serie regression of CAPM T1-T2
foreach v of var _b*{
loc s=substr("`v'",4,.)
g _t_`s'=`v'/_se_`s'
g _p_`s'=ttail(_eq2_n, abs(_t_`s'))*2
}
save BJS_S2_TEST,replace
restore

/*useless
mat pfmeanr=J(10,104,0)
forval i=1/10 {
	local j=`i'*160
	local k=`j'-159
	local holder=0
	forval t=1/104{
	  forval m=`k'/`j'{
	  local holder= `holder'+wretwd[`m']
	
	  }
	mat pfmeanr[`i',`t']=1+`holder'/160
  }

}

mat pfr=J(10,1,0)
forval i=1/10 {
	local r=1
	forval t=100/104{
      local k=pfmeanr[`i',`t']
	  local r=`r'*`k'
	}
	local s=1/5
	mat pfr[`i',1]=`r'^`s'-1
}

*/
gen tag=autocode(compidpf,10,1,1600)
egen wkmean=mean(wretwd),by(weeknum tag)
replace wkmean=1+wkmean
duplicates drop weeknum tag wkmean,force
keep wkmean weeknum tag
cap drop y
g y=wkmean

bys tag weeknum  :replace y=y[_n-1]*wkmean if _n>1
list if weeknum==104

