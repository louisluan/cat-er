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
statsby  _b _se, by(compid) saving(csbetabjs.dta,replace): regress cwr_a mwr_a if weeknum<50 //time serie regression of CAPM
merge m:1 compid using csbetabjs,nogen //merge beta-i back to the data
gsort -_b_mwr_a compid weeknum
egen compidpf=group(_b_mwr_a compid)
drop if compidpf>1600
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
	forval t=1/104{
      local k=pfmeanr[`i',`t']
	  local r=`r'*`k'
	}
	local s=1/104
	mat pfr[`i',1]=`r'^`s'-1
}
*/

