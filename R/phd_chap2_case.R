require(tm)
require(jiebaR)
require(wordcloud)
require(dplyr)

#初始化jeibaR的分词器，并设定工作目录
cutter<-worker(user ="finance.dict")
setwd("~/case/")
stopwordCN<-readLines("stopwordcn.txt",encoding = "UTF-8",skipNul = T,warn = F)

#自定义的wrapper for jiebaR <= cutter
jcut <- function(str="") {
  ftmp <- cutter<=str %>%
    paste(collapse = " ")
  return(ftmp)
}

#找出要读入的文件列表，用正则表达式查找年报管理层讨论文本
f_mgmt<-list.files(path="~/case/",,recursive = T,pattern = "*A\\d{4}\\.txt$")

#初始化一个与文本数量等长的空list
n_fl<-length(f_mgmt)
lst<-list()
length(lst)<-n_fl

#用一个df容纳所有的公司和年度信息
corp<-sapply(f_mgmt,substr,1,6,USE.NAMES = F)
year<-sapply(f_mgmt,substr,8,11,USE.NAMES = F)
df_fs<-data.frame(corp,year)



#批量读入文本
for(i in 1:n_fl){
  tmp<-scan(file=f_mgmt[i],what=character(),encoding = "UTF-8",skipNul=T) %>%
    paste(collapse = " ") 
    lst[i]<-tmp
}

df_fs$mgmt<-lst

df_fs$mgmt <-sapply(df_fs$mgmt,jcut,USE.NAMES = F)


fs_tdm<-function(list_chr){
  #直接定义为VectorSource语料库，并且去掉数字空白等内容
  f1<-VectorSource(unlist(list_chr)) %>%
    Corpus %>%
    tm_map(removeNumbers) %>%
    tm_map(removePunctuation) %>%
    tm_map(stripWhitespace) %>%
    tm_map(removeWords,stopwordCN)
  
  #生成词文矩阵
  tdm <-TermDocumentMatrix(f1)
  tdm<-removeSparseTerms(tdm,0.9999)
  return(tdm)
}  

fs_cluster<-function(tdm,ngroup=5){
  tdm_matrix <- t(as.matrix(tdm))
  #聚类分析
  km <- kmeans(tdm_matrix , ngroup)
  return(km)
}

  
fs_wc<-function(tdm){
  #调整字体为黑体，防止无法在Mac下输出图形中的汉字
  par(family = "STHeiti")
  
  #作为矩阵并且按照词频排序
  m1<-as.matrix(tdm)
  m1 <- sort(rowSums(m1),decreasing=TRUE)
  m1<-data.frame(word = names(m1),freq=m1)
  
  #输出词云
  wordcloud(m1$word,m1$freq, max.words=50, scale=c(1.5,0.5),
            random.order=FALSE,rot.per=0.5, use.r.layout=T,colors=brewer.pal(8,"Dark2")) 
}


      
#按照顺序生成词云组合
png(file = "myplot.png", bg = "white",width = 900,height = 1100,units="px")
par(mfrow=c(4,3),cex=2,mar=c(0.01,0.01,0.01,0.01),oma=c(0.01,0.01,0.01,0.01))
for(i in 1:12) {
  fs_wc(fs_tdm(df_fs$mgmt[i]))
}
dev.off()
#Kmeans聚类示例
# fs_km <- fs_tdm(df_fs$mgmt[3]) %>%
#   fs_cluster(20)
# fsc<-as.data.frame(cbind(unlist(df_fs$mgmt[3]),fs_km$cluster))

