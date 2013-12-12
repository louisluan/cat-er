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
drop if trdwks<50 // drop return data for the year 2006 
drop trdwks
encode trdwnt,gen(weeknum)
egen compid=group(stkcd)

order compid weeknum trdwnt
sort compid weeknum
xtset compid weeknum
