/*Combining event and stock data
First, set memory to a large enough size so that you can do the rest of the operations below. 
We will be creating some variables and possibly duplicating cases, so the dataset can get VERY BIG. 
To check how much memory you have allocated, the command is query, and to check how big your file is, the command is describe.
Now, we need to find out how many event dates there are for each company.
Use the dataset of event dates and generate a variable that counts the number of event dates per company.*/

use eventdates, clear
by company_id: gen eventcount=_N
*Cut the dataset down to just one observation for each company. Each company observation is associated with the count of event dates for that company. Save this as a new dataset - don't overwrite your dataset of event dates!
by company_id: keep if _n==1
sort company_id
keep company_id eventcount 
save eventcount,replace

*The next step is to merge the new 'eventcount' dataset with your dataset of stock data.

use stockdata, clear
sort company_id
merge company_id using eventcount
tab _merge
keep if _merge==3
drop _merge

*Now use Stata's 'expand' command to create the duplicate observations. The 'eventcount' variable has been merged on to each stock observation, and tells Stata how many copies of that observation are needed. This is where your dataset can get VERY BIG, as we are duplicating the observations to however many counts of event we have per company.
expand eventcount		 
*You need to create a variable that indicates which 'set' of observations within the company each observation belongs to. Then sort the dataset to prepare for another merge.
drop eventcount
sort company_id date
by company_id date: gen set=_n
sort company_id set
save stockdata2,replace


*Back in your original event dates dataset - not the 'eventcount' one! You need to create a matching set variable to identify the different event dates within each company. The final step is to use the set variable to match each event date with a set of stock observations.
use eventdates, clear
by company_id: gen set=_n
sort company_id set
save eventdates2,replace
use stockdata2, clear
merge company_id set using eventdates2
tab _merge		 
*Here, you may have observations where you have the events information but not stock information. You may examine which companies stock information is missing.
		  
list company_id if _merge==2 
keep if _merge==3
drop _merge
*Finally, create a new variable that groups company_id and set so that you have a unique identifier to use in the rest of your analysis.
		  
egen group_id = group(company_id set)	  
*During the rest of your analysis, use group_id wherever the event study instructions say company_id. You're now ready to return to the Event Study with Stata page.
