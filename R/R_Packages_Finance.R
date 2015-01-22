# 
# title: "R_Packages_Finance"
# 
# R进行金融、会计类研究时，大致的流程是数据导入，数据清理，运行统计计量模型，输出结果。
# 每一个步骤都有专门的R包进行辅助，简要介绍如下：
# 
# 数据导入除了自带应付文本和CSV文件的read.table,read.txt家族外，还有针对读入Excel文件的一些包，比较好用的是XLConnect，这个包基于java的，支持读取xls和xlsx格式的读写。
# 用法可以参考：http://cran.r-project.org/web/packages/XLConnect/vignettes/XLConnect.pdf
# 
# 
# 
# install.packages(c("rJava","XLConnect"))
# 
# 
# 
# 
# 数据清理主要使用plyr，dplyr，tidyr,lubridate几个包，Wickham大牛和他的伙伴写的，效率很高，语法精炼。
# 
# 
# install.packages(c("plyr","dplyr","tidyr",“lubridate”))
# 
# 
# 
# 进行实证计量牵扯几方面，可以参考CRAN的taskview有每个包的简要介绍，按照提示直接安装整个taskview比较方便,另外quantmod包和rmetrics里面很多包也很实用：
# 
# 计量经济学taskview：
# http://cran.r-project.org/web/views/Econometrics.html
# 金融taskview：
# http://cran.r-project.org/web/views/Finance.html
# 
# install.packages("ctv")
# library("ctv")
# update.views("Finance")
# update.views("Econometrics")
# 
# source("http://www.rmetrics.org/Rmetrics.R")
# install.Rmetrics()
# install.packages("quantmod")
# 
# 
# 输出分两种，输出表格比较好的几个包是xtable,stargazer，输出图形当之无愧是ggplot2了，还有特别推荐knitr，文学化编程~
# 
# install.packages(c("xtable","stargazer","ggplot2","knitr"))

# 统一的安装代码如下：

install.packages(c("rJava","XLConnect"))
install.packages(c("plyr","dplyr","tidyr",“lubridate”))
install.packages("ctv")
library("ctv")
update.views("Finance")
update.views("Econometrics")
source("http://www.rmetrics.org/Rmetrics.R")
install.Rmetrics()
install.packages("quantmod")
install.packages(c("xtable","stargazer","ggplot2","knitr"))

