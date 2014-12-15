/*ref: http://bbs.pinggu.org/forum.php?mod=viewthread&tid=817559
 1. findit sax12
 2. download x12-pc at http://www.census.gov/srd/www/x12a/
 3. Place x-12 at Stata's adopath
 Suggest using Win-X12 GUI directly
 http://www.census.gov/srd/www/winx12/winx12_down.html
 http://www.census.gov/ts/TSMS/WIX12/winx12doc.pdf

*/
import excel using UKEA_CSDB_DS.csdbABPF.xls,first clear
drop if _n>300
drop if length(A)<5
gen consum=real(ABPF)
encode A,gen(date)
drop  A ABPF
replace date=date-21
label drop  date
tsset date,quarterly

sax12 consum, satype(single) transfunc(auto) ///
	regpre(const td)  outauto(ao ls tc) ///
	outlsrun(0) ammaxlag(3 1) ///
	ammaxdiff(2 1) ammaxlead(12)///
	x11seas(x11default) ///
	sliding history
