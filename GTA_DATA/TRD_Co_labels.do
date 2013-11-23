//keep following variables
keep stkcd indcd nindcd nindnme statco crcd commnt markettype listdt stknme
//generate sttag from company short name given by SEC
gen sttag=strpos(stknme,"ST" )>0

replace listdt= substr(listdt,1,4)
gen listdate=real(listdt)
drop listdt

label variable stkcd "֤ȯ����"
label variable indcd "��ҵ����A"
label variable nindcd "֤�����ҵ����" 
label variable nindnme "֤�����ҵ����B"
label variable crcd "AB�ɽ�����" 
label variable commnt "H�ɽ�����"
label variable markettype "�����г�"
label variable listdate "��������"
label variable stknme "֤ȯ���"
label variable sttag "ST��ʶ"
cap label drop indLBL mktLBL statLBL stLBL

label define stLBL 0 "��ST" 1 "ST"
label define indLBL 0001 "����" 0002 "������ҵ" 0003 "���ز�" 0004 "�ۺ�" 0005 "��ҵ" 0006 "��ҵ"
label define mktLBL 1 "��A" 2 "��B" 4 "��A" 8 "��B"  16 "��ҵ��"
label define statLBL 1 "��������"  2 "��ֹ����" 3 "ͣ��" 4 "��ͣ����"  

label values indcd indLBL
label values markettype mktLBL
label values sttag stLBL

encode statco,gen(costat)
label drop costat
drop statco
label values costat statLBL
label variable costat "��˾״̬"

