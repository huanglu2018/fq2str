#!/bin/sh

source config.txt || echo "config.txt missing !!"

bwa_align_sort(){
ref_genome=$1
SRR=$2
threads=$3
sort_bam_file=$4

fq1=${SRR}_1.fastq.gz
fq2=${SRR}_2.fastq.gz

TAG='@RG\tID:'$SRR'\tLB:'$SRR'\tSM:'$SRR'\tPL:Illumina\tPU:'$SRR  #ID LB SM 为必需

if [ -f $ref_genome.bwt ]
then
    :
else
    echo "ref_genome missing bwa index file, indexing..."
    bwa index -a bwtsw $ref_genome
fi

if [ -f ${ref_genome}.fai ]
then
	:
else
	echo "ref_genome missing samtools index file, indexing..."
	samtools faidx $ref_genome
fi
	
if [ -f $sort_bam_file ]
then
    echo $sort_bam_file" detected, skip"
else
    bwa mem -t $threads \
        -R $TAG \
        $ref_genome \
        $fq1 \
        $fq2 | \
    samtools sort -@ $threads -o $sort_bam_file
fi
	
if [ -f ${sort_bam_file}.bai ]
then
    echo ${sort_bam_file}".bai detected, skip"
else
    samtools index $sort_bam_file
fi
}

# srrlist=`ls $fqdir|grep "fastq.gz$"|cut -d "_" -f 1|uniq -c|awk '{if($1==2) print$2}'` #仅适用相同SRR号
# 出现两次的fq，说明存在fq1和fq2

for i in `less -S $fqlist_file`
do
    sort_bam_file=${i}.sort.bam
    bwa_align_sort $ref_genome $i $threads $sort_bam_file || echo $i" error in bwa_align_sort"
done

run_hipstr(){
str_annotation=$1
ref_genome=$2
sort_bam_file_list=$3  #文件形式？避免冲突
str_out=$4

if [ ${#sort_bam_file_list[@]} -lt 20 ]
then
    echo "bam number less than 20, Use STR calling with de novo allele generation + default stutter models [not recommended]"
    HipSTR \
        --bams $sort_bam_file_list \
        --fasta $ref_genome \
        --regions $str_annotation \
        --def-stutter-model \
        --str-vcf $str_out
else
    echo "bam number more than 20, Use STR calling with de novo allele generation + De novo stutter estimation"
    HipSTR \
        --bams $sort_bam_file_list \
        --fasta $ref_genome \
        --regions $str_annotation \
        --str-vcf $str_out
fi
}

fqdir=`echo $i|xargs -I {} dirname {}`
sort_bam_file_list=`find $fqdir -name "*sort.bam"`

run_hipstr $str_annotation $ref_genome $sort_bam_file_list $str_out || echo "error in run_hipstr"




    
    
    
    