local rsdir "C:/programs/data/RESSET/"
local gtadir "C:/programs/data/GTA/"
cd `rsdir'
use FS_resset,clear
drop if _conflg==1
drop if _reporttype~="Q4"
encode _enddt,gen(date)
xtset a_a_stkcd date
xtbalance,range(1,7)
keep date _comcd a_a_stkcd _enddt _monefd _trafinass _noterecv _accrecv _advpay _intrecv _divrecv _othrecv _invtr _defchr _ncurass1y _othcurass _caadjitems _totcurass _soldfinass _holdinvterm _ltrecv _ltequinv _invrealest _fixass _constrpro _constrmat _dispofixass _prodbioass _oilgasass _intanass _devlpexp _goodwill _ltdefchr _deftaxass _othncurass _ncaexcitems _ncaadjitems _totncurass _totass _stloan _trafindb _notepay _accpay _advrecp _empsalpay _taxexppay _intpay _divpay _stbdpay _othaccpay _accrexp _defprcd _ncurlia1y _othcurlia _specurlia _totcurlia _ltloan _bdpay _ltpay _spepay _othncurlia _totncurlia _totlia _shrcap _capsur _treastk _speres _surres _retear _ordriskresfd _uncfinvlos _othres _shewiomin _minshe _seexcitems _seadjitems _seotheff _totshe _totliashe _totincmope _incmope _othincmope _totcostope _costope _othcostope _saletaxsur _opeexp _admexp _finexp _losdevalass _spcitemtoc _othitemtoc _othnetrev _netincmfvc _invincm _invincmassoc _exchincm _othitemseffop _adjitemseffop _opeprf _noperev _nopeexp _losdealncurass _othitemefftp _adjitemefftp _prfbftax _incmtax _othitemeffnp _adjitemeffnp _netprf _parcomownnetprf _othcpsincome _ajditemeffcl _totcpsincome _clparentcomown _clminown _adjitemeffcl _baseps _diluteps _ncfope _ncfinv
gen mid=string(a_a_stkcd) + "_" + substr(_enddt,1,4)
save RESSET_PARENT.dta,replace
cd `gtadir'
use GTA_FS.dta,clear
drop if substr(GIC,1,1)=="I" //drop financial industry firms
drop if substr(accper,6,2)~="12" //keep only annual data

cap drop mid
gen mid=string(stkcd) + "_" + substr(accper,1,4)
merge 1:1 mid using `rsdir'RESSET_PARENT.dta
drop if _merge~=3
drop _merge mid date
encode accper,gen(date)
xtset stkcd date
xtbalance,range(9,14)
save consolid_parent.dta,replace
