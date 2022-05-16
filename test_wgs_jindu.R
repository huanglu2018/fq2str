
# 查看是否下载完

setwd("/public/huanglu/WGS_summary")
wgslist=data.table::fread("/public/huanglu/WGS_summary/undownload.txt",data.table=F)[,1]
for(i in wgslist){
  if (file.exists(paste0("/public/huanglu/WGS_summary/link_fq/",i,"_1.fastq.gz")) & file.exists(paste0("/public/huanglu/WGS_summary/link_fq/",i,"_2.fastq.gz"))){
    write(i,"/public/huanglu/WGS_summary/done_fq2.txt",append=T)
  }else if(file.exists(paste0("/public/huanglu/WGS_summary/link_sra/",i,".sra"))){
    write(i,"/public/huanglu/WGS_summary/done_sra2.txt",append=T)
  }else{
    write(i,"/public/huanglu/WGS_summary/undownload2.txt",append=T)
    }
}



########挑选出非wgs的fastq

# fqdir="/public/huanglu/WGS_summary/fq"
# filelist=dir(fqdir)
# fqlist=data.table::fread("/public/huanglu/WGS_summary/done_fq.txt",data.table=F)[,1]
# for (i in filelist){
  # id=sub(".fastq.gz","",sub("_2.fastq.gz","",sub("_1.fastq.gz","",i)))
  # if(!(id %in% fqlist)){
  # system(paste0("mv ",fqdir,"/",i," /public/huanglu/WGS_summary/non_wgs/"))
  # }
# }