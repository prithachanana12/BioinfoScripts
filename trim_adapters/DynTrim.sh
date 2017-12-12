name=$(echo $1 | sed s/'_R1_'/'_R3_'/g)
cd /data2/delivery/Taner_Nilufer_net04/160108_ST-K00112_0073_AH5HFYBBXX/secondary/FASTQs
/projects/bsi/bictools/apps/alignment/trim_galore/0.2.2/trim_galore_multiadapt -s 3 -q 20 -a AGATCGGAAGAGC -b GCTCTTCCGATCT -l 15 --paired --phred33 /data2/delivery/Taner_Nilufer_net04/160108_ST-K00112_0073_AH5HFYBBXX/secondary/FASTQs/Originals/${1} /data2/delivery/Taner_Nilufer_net04/160108_ST-K00112_0073_AH5HFYBBXX/secondary/FASTQs/Originals/${name}
