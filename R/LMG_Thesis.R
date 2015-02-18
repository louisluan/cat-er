#-------工具函数，平衡面板用的---------
require(dplyr)
require(lazyeval)
require(stargazer)
p_balance<-function(df,id="Fundcd",t="year",from=1,to=9) {
  #计算时间变量长度
  ncount<-to-from+1
  #如果时间变量是字符的，改成整数
  df[[t]]<-as.integer(df[[t]])
  #传递给dplyr::filter_的参数，方便执行期动态转换为df实际的变量名
  xt<-list(pt=as.symbol(t),pfrom=from,pto=to)
  #真正用dplyr执行筛选平衡面板的部分
  #先排序，然后根据id分组，选出程序参数里定好的时间范围
  #选出来平衡的数据，然后去掉分组，返回处理好的df，时间变为integer了
  df<-arrange_(df,.dots=list(id,t)) %>%
    group_by_(.dots=list(id)) %>%
    filter_(interp("pt>=pfrom & pt<=pto",.values = xt)) %>%
    filter(n()==ncount) %>%
    ungroup()
  return(df)
}
#---------------------工具函数，计算标准误----------------------------------------
vcovDC <- function(x, ...){
  vcovHC(x, cluster="group", ...) + vcovHC(x, cluster="time", ...) -
    vcovHC(x, method="white1", ...)
}

#-----------------------工具函数，相关系数矩阵------------------

corr<-function(x){
  p_cor<-cor(x);
  s_cor<-cor(x,method="spearman");
  p_cor[upper.tri(p_cor)==TRUE]<-s_cor[upper.tri(s_cor)==TRUE];
  return(p_cor);
}

#-------------------------------

load("~/Downloads/pp.RData")
load("~/Downloads/oo.RData")

#定义市场好坏
pp$mktcond<-pp$ret>0
#合并数据
xx<-left_join(oo,pp)
#选出来收益率不是缺失值的数据
fund<-xx[!is.na(xx$Bgr6m),]

#把年度定义为factor方便当成整数处理
fund$year<-as.integer(as.factor(fund$Trdmnt))

#平衡面板，去除收益数据不完整的基金
fund<-p_balance(fund)

#计算上年的业绩排名分为10组,1最差，10最好,然后计算总平均分代表基金能力
#用平均分可以不丢失1期数据
g_fund<-mutate(fund,rank=ntile(lag(Bgr6m),10)) %>%
  group_by(Fundcd) %>%
  mutate(capa=mean(rank,na.rm=T)) %>%
  ungroup()

#定义与无风险利率的差分,只选择回归用得上的变量
reg_fund<-mutate(g_fund,r_f=(nrr/100),r_fund=Bgr6m-r_f,r_m=ret-r_f) %>%
  mutate(id=Fundcd,ln_ta=log(Tassets),p_bond=Pttbmv) %>%
  select(id,year,r_fund,r_m,r_f,p_bond,ln_ta,mktcond,capa)

#定义回归公式
ols<-r_fund ~ mktcond*p_bond + ln_ta + capa + r_m

result<-lm(ols,data=reg_fund)
summary(result)

#基金固定效应
presult <- plm(ols,reg_fund,model="within",index=c("id","year"))
summary(presult)

logit<-mktcond ~ p_bond + r_f +lag(p_bond) +lag(r_f)
g_result<-glm(logit,family=binomial(link = "logit"),data=reg_fund)
#稳健性检验

#时间聚类标准误
r_newey<-coeftest(result, vcov=function(x) vcovHC(x, cluster="time", type="HC1"))

#时间、个体双向聚类标准误
r_dual<-coeftest(result, vcov=function(x) vcovDC(x, type="HC1"))

#--------------格式化输出------------

#描述性统计
stargazer(as.data.frame(select(reg_fund,mktcond,p_bond,ln_ta,capa,r_m)),
          type="html",title="Descriptive Statistics",
          out.header=TRUE,summary.logical=FALSE,
          digits=2,median=TRUE,
          out="~/Downloads//descriptives.htm"
)

#相关系数矩阵输出
stargazer(corr(select(reg_fund,p_bond,ln_ta,capa,r_m)[!is.na(reg_fund$p_bond),]),
          type="html",title="Correlations",
          out.header=TRUE,summary.logical=FALSE,
          digits=2,median=TRUE,
          out="~/Downloads//cor.htm",
          notes="Left:Pearson,Right:Spearman"
)

#假设一回归输出
stargazer(result,presult,type="html",title="Regression Results",
          report="vc*p",digits=3,
          model.names=FALSE,model.numbers=TRUE,
          column.labels=c("OLS","Within"),column.separate=c(1,1),
          header=FALSE,
          omit="kids",omit.labels="",
          flip=TRUE,out.header=TRUE,out="~/Downloads//reg.htm")

#假设一稳健性检验
stargazer(r_newey,r_dual,type="html",title="Robustness Tests",
          report="vc*p",digits=3,
          model.names=FALSE,model.numbers=TRUE,
          column.labels=c("NEWEY-WEST","DUAL"),column.separate=c(1,1),
          header=FALSE,
          omit="kids",omit.labels="",
          flip=TRUE,out.header=TRUE,out="~/Downloads//robust.htm")

#假设二：择时

stargazer(g_result,type="html",title="Discrete Selection",
          report="vc*p",digits=3,
          model.names=FALSE,model.numbers=TRUE,
          column.labels=c("Logit"),column.separate=c(1),
          header=FALSE,
          omit="kids",omit.labels="",
          flip=TRUE,out.header=TRUE,out="~/Downloads//logit.htm")



