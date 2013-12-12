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
*------------Lintner(1965) Two Stage Regression method for CAPM test---------------
//time series regression to get beta-i for each company
gen cwr_a=wretwd-nrrwkdt //gen risk-free adjusted weekly return for each company
gen mwr_a=wretwdos-nrrwkdt //gen risk-free adjusted weekly return for market
statsby  _b _se, by(compid) saving(csbeta.dta,replace): regress cwr_a mwr_a //time serie regression of CAPM

//cross sectional regression to test hypothesis
egen crbar=mean(wretwd)
egen mrbar=mean(wretwdos)
egen rfbar=mean(nrrwkdt)
gen difr=crbar-rfbar  //Ri(bar)-Rf(bar)
gen difm=mrbar-rfbar //Rm(bar)-Rf(bar)
preserve
duplicates drop compid,force
merge 1:1 compid using csbeta,nogen //merge beta-i back to the data
reg difr _b_mwr_a //cross-sectional regression
restore
test _cons //test alpha==0
test _b_mwr_a=difm[1] //test r==0
