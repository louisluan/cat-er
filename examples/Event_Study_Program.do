/*
Cleaning the data and Calculating the Event and Estimation Windows
It's likely that you have more observations for each company than you need. 
It's also possible that you do not have enough for some. 
Before you can continue, you must make sure that you will be conducting your
analyses on the correct observations. To do this, you will need to create a variable, dif, that will count
the number of days from the observation to the event date. This can be either calendar days or trading
days.

calculating the number of trading days is a little trickier than calendar days. For trading
days, we first need to create a variable that counts the number of days within each company_id. Then we
determine which observation occurs on the event date. We create a variable with the event date's day number
on all of the observations within that company_id. Finally, we simply take the difference between the two,
creating a variable, dif, that counts the number of days between each individual observation and the event
day. 
*/

*-------------------------For number of trading days:------------------------
sort company_id date
by company_id: gen datenum=_n
by company_id: gen target=datenum if date==event_date
egen td=min(target), by(company_id)
drop target
gen dif=datenum-td
*----------------------------------For calendar days:-----------------------
gen dif=date-event_date

/*Next, we need to make sure that we have the minimum number of observations before and after the event
date, as well as the minimum number of observations before the event window for the estimation window.
Let's say we want 2 days before and after the event date (a total of 5 days in the event window) and 30
days for the estimation window. (You can of course change these numbers to suit your analysis.)*/

by company_id: gen event_window=1 if dif>=-2 & dif<=2
egen count_event_obs=count(event_window), by(company_id)
by company_id: gen estimation_window=1 if dif<-30 & dif>=-60
egen count_est_obs=count(estimation_window), by(company_id)
replace event_window=0 if event_window==.
replace estimation_window=0 if estimation_window==.

/*The procedure for determining the event and estimation windows is the same. First we create a variable that
equals 1 if the observation is within the specified days. Second, we create another variable that counts
how many observations, within each company_id, has a 1 assigned to it. Finally, we replace all the missing
values with zeroes, creating a dummy variable. You can now determine which companies do not have a
sufficient number of observations.*/

tab company_id if count_event_obs<5
tab company_id if count_est_obs<30

/*The "tab" will produce a list of company_ids that do not have enough observations within the event and
estimation windows, as well as the total number of observations for those company_ids. To eliminate these
companies:*/

drop if count_event_obs < 5
drop if count_est_obs < 30

*-----------------------------------------------------------------------------------------
/*Estimating Normal Performance
Now we are at the point where we can actually start an analysis. First we need a way to estimate Normal
Performance. To do this, we will run a seperate regression for each company using the data within the
estimation window and save the alphas (the intercept) and betas (the coefficient of the independent
variable). We will later use these saved regression equations to predict normal performance during the
event window.
Note that return, the dependent variable in our regression, is simply the CRSP variable for a given stock's
return, while the independent variable vretd that we use to predict ret is the value-weighted return of an
index for whatever exchange the stock trades on. Use the equivalent variables for your dataset.
Here, we created a variable "id" that numbers the companies from 1 to however many there are. The N is the
number of company-event combinations that have complete data. This process iterates over the companies,
runs a regression in the estimation window for each, and then uses that regression to predict a 'normal'
return in the event window.
*/

gen predicted_return=.
egen id=group(company_id)

qui tab id
local N = r(r)  
/* for multiple event dates, use: egen id = group(group_id) */
forvalues i=1(1)`N' { /*note: replace N with the highest value of id */
	l id company_id if id==`i' & dif==0
	reg ret market_return if id==`i' & estimation_window==1
	predict p if id==`i'
	replace predicted_return = p if id==`i' & event_window==1
	drop p
}

/*Abnormal and Cumulative Abnormal Returns
We can now calculate the abnormal and cumulative abnormal returns for our data. The daily abnormal return
is computed by subtracting the predicted normal return from the actual return for each day in the event
window. The sum of the abnormal returns over the event window is the cumulative abnormal return.
Here we simply calculate the abnormal return for each observation in the event window. Then we set the
cumulative abnormal return equal to the sum of the abnormal returns for each company.
*/

sort id date
gen abnormal_return=ret-predicted_return if event_window==1
by id: egen cumulative_abnormal_return = sum(abnormal_return)

/*Testing for Significance
We are going to compute a test statistic, test, to check whether the average abnormal return for each stock
is statistically different from zero.*
TEST= ((¦²AR)/N) / (AR_SD/sqrt(N))
where AR is the abnormal return and AR_SD is the abnormal return standard deviation. If the absolute value
of test is greater than 1.96, then the average abnormal return for that stock is significantly different
from zero at the 5% level. The value of 1.96 comes from the standard normal distribution with a mean of 0
and a standard deviation of 1. 95% of the distribution is between ¡À1.96.

Note: this test uses the sample standard deviation. A less conservative alternative is to use the
population standard deviation. To derive this from the sample standard deviation produced by Stata,
multiply ar_sd by the square root of n-1/n; in our example, by the square root of 4/5.
*/

sort id date
by id: egen ar_sd = sd(abnormal_return)
gen test =(1/sqrt(5)) * ( cumulative_abnormal_return /ar_sd)
list company_id cumulative_abnormal_return test if dif==0


*This will output the results of your event study into an Excel-readable spreadsheet file:
outsheet company_id event_date cumulative_abnormal_return test using stats.csv if dif==0, comma names

/*Testing Across All Events
Instead of, or in addition to, looking at the average abnormal return for each company, you probably want
to calculate the cumulative abnormal for all companies treated as a group. Here's the code for that:

The P-value on the constant from this regression will give you the significance of the cumulative abnormal
return across all companies. This test preferable to a t-test because it allows you to use robust standard
errors.*/

reg cumulative_abnormal_return if dif==0, robust //Parametric t test with heteroscedacity standard errors

signtest cumulative_abnormal_return=0 //Non-parametric median test


reg cumulative_abnormal_return if dif==0, robust
