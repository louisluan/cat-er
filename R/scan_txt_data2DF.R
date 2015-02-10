#读取财报数据
f_mgmt<-list.files(path="~/case/bg",,recursive = T,pattern = "*B2011\\.txt$")

#读取网站战略数据
f_webstr<-list.files(path="~/case/bg",,recursive = T,pattern = "*D\\d{0,}.txt$")


#读取所有年度的财报数据
f_eg<-list.files(path="~/case/bg",,recursive = T,pattern = "*A\\d{4}\\.txt$")

setwd("~/case//bg")
n_fl<-length(f_eg)
lst<-list()

length(lst)<-n_fl
for(i in 1:n_fl){
  tmp<-scan(file=f_eg[i],what=character(),encoding = "UTF-8",skipNul=T) %>%
    paste(collapse = " ")
  lst[i]<-tmp
}
corp<-sapply(f_eg,substr,1,6,USE.NAMES = F)
year<-sapply(f_eg,substr,8,11,USE.NAMES = F)
df_fs<-data.frame(corp,year)
df_fs$mgmt<-lst

