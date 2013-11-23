insheet date1 price using IF.csv,clear
encode date1,gen(date)
sort date
cap drop date1
tsset,clear
tsset date
tsappend,add(2)

tsline price
arch price, earch(1) egarch(1) ar(1) ma(1) distribution(t)
cap drop price2
predict price2
