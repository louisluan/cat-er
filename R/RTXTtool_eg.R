require(tm)
require(jiebaR)
f1<-scan("~/Downloads/test.txt",what=character(),encoding = "UTF-8")
ct<-worker()
f1<-ct<=paste(f1,collapse = " ")

code<-rep(sample(5),100)
txt<-LETTERS[1:500]
df<-data.frame(code,txt,stringsAsFactors = FALSE)
for(i in 1:500){
  df$txt[i]<-paste(sample(f1,20),collapse = " ")
}
df$txt<-as.factor(df$txt)

f2<-scan("~/Downloads/sip.txt",what=character(),encoding = "UTF-8")
ct<-worker()
f2<-ct<=paste(f2,collapse = " ")
code<-rep(sample(5),100)
txt<-LETTERS[1:500]
dfa<-data.frame(code,txt,stringsAsFactors = FALSE)
for(i in 1:500){
  dfa$txt[i]<-paste(sample(f2,20),collapse = " ")
}
dfa$txt<-as.factor(dfa$txt)

matrix<-create_matrix(df$txt,removeNumbers=T)
m1<-create_matrix(dfa$txt,removeNumbers = T)

container <- create_container(matrix,df$code,trainSize=1:200, testSize=201:500,virgin=F)
c1 <- create_container(matrix,dfa$code,trainSize=0:2, testSize=1:500,virgin=T)
models <- train_models(container, algorithms=c("RF","SVM"))
results <- classify_models(c1, models)
precision_recall_f1 <- create_precisionRecallSummary(c1, results)
