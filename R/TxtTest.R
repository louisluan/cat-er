library(Rwordseg)
dictdir="C:\\programs\\dict\\"

dicts=c("Agu.scel","caiwu.scel","college.scel","daxie.scel","dianli.scel","falv.scel","fangchan.scel","ganggu.scel","gongshang.scel","gov.scel","gupiao.scel","hanyu.scel","jianzhu.scel","jixie.scel","kuaiji.scel","nongye.scel","place.scel","renli.scel","shuili.scel","waimao.scel","wuliu.scel","xiyao.scel","yejin.scel","zhongyao.scel")

for(i in seq(1,24,1)) {
	dictfp=paste(dictdir,dicts[i],sep="")
	installDict(dictfp, dicts[i],dicttype = c("text", "scel"), load = TRUE)
	
}


segmentCN("核心能力因为存在二氧化碳的累计折旧，所以战略上四川乐山大佛呵呵笑了，真是很好渠道的案例",returnType=c("tm"))

segment.options(isNameRecognition = TRUE)
egfile=paste(dictdir,"News0414.txt",sep="")
segmentCN(egfile)