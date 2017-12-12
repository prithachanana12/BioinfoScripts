# usage: bash TophatFusion.sh
# Run this script within the MAPRSeq alignment folder and it will create the needed structure for tophat's fusion algorithm but for each individual sample. Then it submits all the qsub jobs automatically.

ls -1 | egrep '^tophat_' | while read i;
do folder=$(echo $i | sed s/'tophat'/'FUSION'/g);
name=$(echo $i | sed s/'tophat_'//g)
lanid=$(whoami)
email=$(finger $lanid | cut -d';' -f2 | head -1)
mkdir $folder;
cp -r blast ensGene.txt mcl refGene.txt $folder;
cd $folder;
ln -s ../${i} ./;
qsub -V -cwd -b y -q lg-mem -m ae -M $email -l h_vmem=32G -l h_stack=20M -pe threaded 2 -N TophatFusion_${name} /data5/bsi/bictools/alignment/tophat/tophat-2.1.0.Linux_x86_64/tophat-fusion-post /data2/bsi/reference/sequence/human/ncbi/hg19/indexed/allchr -o out;
cd ../;
done;
