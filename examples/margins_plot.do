/*
ref: http://www.ats.ucla.edu/stat/stata/faq/margins_graph12.htm
     http://www.ats.ucla.edu/stat/stata/faq/conconb12.htm
*/

use http://www.ats.ucla.edu/stat/data/hsbdemo, clear

regress read c.math##c.socst                          //OLS regression
sum math                                              //Check the lower and uper bound of math
margins, at(math=(28(2)76)) vsquish                   //Calculate margins from lower to upper bound of math with a step 2
set scheme s1mono                                     //Set the color scheme to journal style(B-W)
marginsplot                                           //Plot the above mentioned margins
                                                      //Change ci-plot to dash line and retitle Y and X axis
marginsplot, recast(line) recastci(rline) ///
    ytitle("Read Score") xtitle("Math Score") ///
	ciopts(lpattern(dash)) 
