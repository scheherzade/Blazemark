#!/bin/bash
saved_path=$LD_LIBRARY_PATH
#blaze_dir="/home/sshirzad/src/blaze_shahrzad"
blaze_dir="/home/sshirzad/src/blaze"
repo_dir="/home/sshirzad/repos/Blazemark"
results_dir="$repo_dir/results"
benchmarks_dir="${blaze_dir}/blazemark/benchmarks"
config_dir="${repo_dir}/configurations"
#thr=(6 7 8)
#thr=(16)
#th=$1
rm -rf ${results_dir}/*
#benchmarks=('dmatdvecmult')
#benchmarks=('dmatdmatmult')
benchmarks=('dvecdvecadd' 'dmatdmatadd')
#benchmarks=('dmatdmatadd')
r='openmp'
mkdir -p ${results_dir}/info
date>> ${results_dir}/info/date.txt
git --git-dir ~/src/hpxMP/.git log>>${results_dir}/info/hpxmp_git_log.txt
git --git-dir ~/src/blaze/.git log>>${results_dir}/info/blaze_git_log.txt
git --git-dir ~/src/hpx/.git log>>${results_dir}/info/hpx_git_log.txt
git --git-dir ~/src/hpxMP/.git log>>${results_dir}/info/hpxmp_git_log.txt
cp $repo_dir/scripts/hpxmp_log.sh ${results_dir}/info/
cp $blaze_dir/blaze/math/smp/openmp/* ${results_dir}/info/
cp $repo_dir/configurations/Configfile_openmp ${results_dir}/info/

for b in ${benchmarks[@]}
do
if [ $b == 'dvecdvecadd' ] || [ $b == 'daxpy' ]
then 
end_line=219
elif [ $b == 'dmatdvecmult' ]
then
end_line=147
else
end_line=119
fi
param_filename=${blaze_dir}/blazemark/params/$b.prm
cd ${blaze_dir}
#git checkout $param_filename
#
#for p in $(seq 6)
#do
#	line_number=$((49+p))
#	s='\/\/('
#	sed -i "${line_number}s/(/${s}/" $param_filename
#done
#sed -i "58s/*/\//" $param_filename 
#sed -i "${end_line}s/*/\//" $param_filename
#
$repo_dir/scripts/generate_benchmarks.sh ${b} ${r} "${blaze_dir}/blazemark/"

for th in $(seq 16)
do
for i in $(seq 11)
do
export OMP_NUM_THREADS=${th} 
export OMP_PLACES=cores
#export HPX_COMMANDLINE_OPTIONS="--hpx:print-counter=/threads/idle-rate  --hpx:print-counter=/threads/time/average --hpx:print-counter=/threads/time/cumulative-overhead --hpx:print-counter=/threads/count/cumulative --hpx:print-counter=/threads/time/average-overhead"
LD_PRELOAD=/home/sshirzad/src/hpxMP/build_release/libhpxmp.so ${benchmarks_dir}/${b}_${r} -only-blaze>>${results_dir}/${i}-${b}-${th}-hpxmp.dat
#${benchmarks_dir}/${b}_${r} -only-blaze>>${results_dir}/${i}-${b}-${th}-${r}.dat

echo "${i}th time finished for ${th} threads"
done
done
done
