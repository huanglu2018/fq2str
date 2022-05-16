#!/bin/bash

in_dir=/public/huanglu/WGS_summary/fq
winner_out_dir=/public/huanglu/WGS_summary/fq_valid
loser_out_dir=/public/huanglu/WGS_summary/fq_invalid

for i in `ls $in_dir`
do
	echo "gzip -t on "$i
	gzip -t $in_dir/$i && mv $in_dir/$i $winner_out_dir/ && echo $i" succeed !!!" || mv $in_dir/$i $loser_out_dir/ || echo $i" failed..."
done
