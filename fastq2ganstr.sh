#!/bin/bash

# source config.txt || echo "config.txt missing !!"

wkdir=/public/huanglu/STR/gangstr

ref_genome=$wkdir/genome/hg19.fa
fq_dir=$wkdir/fq
bam_outdir=$wkdir/result/sortbam
threads=15

# warning! no "_1.fastq" or "_2.fastq" suffixes needed for $fqlist_file, they should be in abs dir

bwa_align_sort(){
ref_genome=$1
fq_dir=$2
SRR=$3
threads=$4
sort_bam_file=$5

fq1=${SRR}_1.fastq.gz
fq2=${SRR}_2.fastq.gz

TAG='@RG\tID:'$SRR'\tLB:'$SRR'\tSM:'$SRR'\tPL:Illumina\tPU:'$SRR  #ID LB SM are necessary

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
        $fq_dir/$fq1 \
        $fq_dir/$fq2 | \
    samtools sort -@ $threads -o $sort_bam_file
fi
	
if [ -f ${sort_bam_file}.bai ]
then
    echo ${sort_bam_file}".bai detected, skip"
else
    samtools index $sort_bam_file
fi
}

run_gangstr(){

sort_bam_file=$1
wkdir=$2

gangstr_sort_bam_file=/mnt/result/sortbam/`basename $sort_bam_file`
gangstr_region=/mnt/input/hg19_ver13.bed
gangstr_ref_genome=/mnt/genome/hg19.fa
vcfname=`basename $sort_bam_file|sed 's/.sort.bam//g'`
gangstr_outprefix="/mnt/result/vcf/"$vcfname
gangstr_logfile="/mnt/result/vcf/"$vcfname".gangstr.log.txt"

if [ -f $wkdir"/result/vcf/"$vcfname".vcf" ]
then
	echo $wkdir"/result/vcf/"$vcfname".vcf detected, skipping"
else
	nohup singularity exec -B /public/huanglu/STR/gangstr:/mnt \
			/public/home/ylb/huanglu/container/gangstr.simg \
			GangSTR \
			--bam $gangstr_sort_bam_file \
			--ref $gangstr_ref_genome \
			--regions $gangstr_region \
			--out $gangstr_outprefix  > $gangstr_logfile 2>&1 &
fi
}


srrlist=(`ls $fq_dir|grep "fastq.gz$"|cut -d "_" -f 1|uniq -c|awk '{if($1==2) print$2}'`) #仅适用相同SRR号

echo ${#srrlist[@]}" SRRs added: "
echo ${srrlist[@]}

for i in ${srrlist[@]}
do
    sort_bam_file=$bam_outdir/${i}.sort.bam
    bwa_align_sort $ref_genome $fq_dir $i $threads $sort_bam_file || echo $i" error in bwa_align_sort"
	run_gangstr $sort_bam_file $wkdir && mv $fq_dir/$i"_*" $wkdir"/result/done_fq/" || echo "error in run_gangstr"
done




    
    
    
    
