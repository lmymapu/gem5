#!/bin/bash -e

# Shell Script to run PARSEC Benchmarks

# BENCHMARK: Choose one from this list {'blackscholes', 'bodytrack', 'canneal', 'dedup', 'facesim', 'ferret', 'fluidanimate', 'freqmine', 'rtview', 'streamcluster','swaptions', 'vips', 'x264'}
# NUM_OF_PROCS: Enter the degree of parallelism
# SIM_TYPE: Choose one from this list {'simdev', 'simsmall', 'simmedium', 'simlarge', 'test'}
# CPU_TYPE: 'atomic' at boot and for recording Atomic Exec Traces; Then the CPU is switched (restored using the ckpt) to Timing and a CommMonitor is added and now we get Timing Exec and Timing Mon Traces

# M5_PATH: Set in "~/.bash_aliases" to find the Gem5 Full System Images, "/home/ga38qol/full_system_images/Parsec-Alpha"


if [ $# -lt 4 ]; then
  echo "Usage: $0 <benchmark> <num_of_procs> <num_of_tiles> <sim_type>"
  exit 1
fi

BENCHMARK="$1"
NUM_OF_PROCS="$2"
NUM_OF_TILES="$3"
SIM_TYPE="$4"
CPU_TYPE="$5"

CPU_CLOCK="1GHz"
SYS_CLOCK="1GHz"
MEM_SIZE="256MB"
L1D_SIZE="256B"
L2_SIZE="1kB"
DEBUG_FLAG="CommMonitor"

echo " "
echo "#####################-------------------You are running "$BENCHMARK"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$SIM_TYPE"-------------------#####################"
echo " "


# Re-run Benchmark starting from Region of Interest (ROI) - Atomic Exec

./build/ALPHA/gem5.opt --stats-file=$SIM_TYPE"_"$CPU_TYPE"_Stats_"$NUM_OF_PROCS"C"$NUM_OF_TILES"T_L1DComm.txt" \
--debug-flags=$DEBUG_FLAG --debug-file=$BENCHMARK"_"$SIM_TYPE"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$CPU_TYPE"_"$MEM_SIZE"_"$DEBUG_FLAG"_L1DComm.txt" \
configs/custom/fs_tiled_comm_stall.py \
--kernel=$M5_PATH/binaries/vmlinux_2.6.27-gcc_4.3.4 \
--disk-image=$M5_PATH/disks/linux-parsec-2-1-m5-with-test-inputs.img \
--script=$M5_PATH/scripts/$BENCHMARK/$BENCHMARK"_"$NUM_OF_PROCS"C"/$BENCHMARK"_"$NUM_OF_PROCS"c_"$SIM_TYPE"_ckpts.rcS" \
--caches --l1d_size=$L1D_SIZE --l1d_assoc=2 \
--l2cache --l2_size=$L2_SIZE --l2_assoc=4 \
--cacheline_size=32 \
--L1DCommMonitor \
--AtomicCPUDcacheLatency \
--AtomicCPUIcacheLatency \
--cpu-type=$CPU_TYPE \
--restore-with-cpu=$CPU_TYPE \
--cpu-clock=$CPU_CLOCK \
--sys-clock=$SYS_CLOCK \
--mem-size=$MEM_SIZE \
--num-tiles=$NUM_OF_TILES \
-n $NUM_OF_PROCS \
-r 1

# Mengyu: extract ROI part from debug trace Exec

#./m5out/instCount m5out/$SIM_TYPE"_"$CPU_TYPE"_Stats_"$NUM_OF_PROCS"C"$NUM_OF_TILES"T.txt" \
#m5out/$BENCHMARK"_"$SIM_TYPE"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$CPU_TYPE"_"$DEBUG_FLAG"_ckpts.txt" \
#m5out/$BENCHMARK"_"$SIM_TYPE"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$CPU_TYPE"_"$DEBUG_FLAG"_ROI.txt" \
#m5out/$BENCHMARK"_"$SIM_TYPE"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$CPU_TYPE"_"$DEBUG_FLAG"_stats.txt" \


# Convert raw PARSEC Benchmark Traces to Trace-based Processor readable format - Timing Exec

#./m5out/convert/gem5_to_trace_switch m5out/$BENCHMARK"_"$SIM_TYPE"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$CPU_TYPE"_"$DEBUG_FLAG"_ROI.txt" m5out/convert/$BENCHMARK"_"$SIM_TYPE"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_timing_"$CPU_CLOCK$SYS_CLOCK"_mem"$MEM_SIZE"_"$DEBUG_FLAG".txt" m5out/convert/benchmark/$SIM_TYPE/$BENCHMARK/$NUM_OF_PROCS"P"/$BENCHMARK"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$SIM_TYPE"_timing_"$DEBUG_FLAG".txt"

# Cleanup - Ckpt and Temp Files
# rm -rf  m5out/cpt.*

# Re-run Benchmark starting from Region of Interest (ROI) - Timing Exec and Mon

#~ ./build/alpha/gem5.opt \
#~ --debug-flags=$debug_flag --debug-file=$benchmark"_"$sim_type"_"$num_of_procs"p"$num_of_tiles"t_timing_"$debug_flag"_ckpts.txt" \
#~ configs/custom/fs_tiled.py \
#~ --kernel=$m5_path/binaries/vmlinux_2.6.27-gcc_4.3.4 \
#~ --disk-image=$m5_path/disks/linux-parsec-2-1-m5-with-test-inputs.img \
#~ --script=$m5_path/scripts/$benchmark/$benchmark"_"$num_of_procs"c"/$benchmark"_"$num_of_procs"c_"$sim_type"_ckpts.rcs" \
#~ --caches --l1d_size=256b --l1d_assoc=2 \
#~ --l2cache --l2_size=1kb --l2_assoc=4 \
#~ --cacheline_size=32 \
#~ --cpu-clock=$cpu_clock \
#~ --sys-clock=$sys_clock \
#~ --mem-size=$mem_size \
#~ --restore-with-cpu=timing \
#~ --num-tiles=$num_of_tiles \
#~ -n $num_of_procs \
#~ -r 1


# Convert the monitor traces and combine them into a single file
# usage of the program for combination:
# ./reshape <num_of_cpus> <inputfile1> <inputfile2> <inputfile3> ... <inputfileN> <outputfile>
# num_of_cpus has to be equal to number of inputfiles.

#~ CMonFiles="*.ptrc.gz"
#~ cd m5out/
#~ for f in $CMonFiles
#~ do
#~ fmod="convert"/$f"trace.txt"
#~ ./../util/decode_packet_trace.py $f $fmod
#~ done
#~ rm -rf $CMonFiles
#~ cd convert/
#~ MonTF="*.ptrc.gztrace.txt"
#~ ./reshape $NUM_OF_PROCS $MonTF ./benchmark/$SIM_TYPE/$BENCHMARK/$NUM_OF_PROCS"P"/$BENCHMARK"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$SIM_TYPE"_timing_Mon.txt"
#~ rm -rf $MonTF
#~ cd ../..


# Convert raw PARSEC Benchmark Traces to Trace-based Processor readable format - Atomic Exec

#./m5out/convert/gem5_to_trace ./m5out/$BENCHMARK"_"$SIM_TYPE"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$CPU_TYPE"_"$DEBUG_FLAG"_ckpts.txt" ./m5out/convert/$BENCHMARK"_"$SIM_TYPE"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$CPU_TYPE$CPU_CLOCK$SYS_CLOCK"_mem"$MEM_SIZE"_"$DEBUG_FLAG".txt" ./m5out/convert/benchmark/$SIM_TYPE/$BENCHMARK/$NUM_OF_PROCS"P"/$BENCHMARK"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$SIM_TYPE"_"$CPU_TYPE"_"$DEBUG_FLAG".txt"


#rm -rf  m5out/$BENCHMARK"_"$SIM_TYPE"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$CPU_TYPE"_"$DEBUG_FLAG"_ckpts.txt"
#rm -rf  m5out/convert/$BENCHMARK"_"$SIM_TYPE"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$CPU_TYPE$CPU_CLOCK$SYS_CLOCK"_mem"$MEM_SIZE"_"$DEBUG_FLAG".txt"



# Cleanup - Temp Files

#rm -rf  m5out/$BENCHMARK"_"$SIM_TYPE"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_timing_"$DEBUG_FLAG"_ckpts.txt"
#rm -rf  m5out/convert/$BENCHMARK"_"$SIM_TYPE"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_timing_"$CPU_CLOCK$SYS_CLOCK"_mem"$MEM_SIZE"_"$DEBUG_FLAG".txt"


# Statistics regarding the number of lines in debug trace

#cd m5out/convert/benchmark/$SIM_TYPE/$BENCHMARK/$NUM_OF_PROCS"P"/
#wc -l $BENCHMARK"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$SIM_TYPE"_"$CPU_TYPE"_"$DEBUG_FLAG".txt" > compare.txt	# Atomic Exec
#wc -l $BENCHMARK"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$SIM_TYPE"_timing_"$DEBUG_FLAG".txt" >> compare.txt		# Timing Exec
#wc -l $BENCHMARK"_"$NUM_OF_PROCS"P"$NUM_OF_TILES"T_"$SIM_TYPE"_timing_Mon.txt" >> compare.txt			# Timing Mon
#cd ../../../../../..

echo " "
echo "#####################-------------------Done with "$BENCHMARK"_"$NUM_OF_PROCS"P_"$NUM_OF_TILES"T_"$SIM_TYPE"-------------------#####################"
echo " "


# For Quick Code Modifications
#--L1DCommMonitor \
#--cpu-type=timing --mem-type=SimpleMemory --defaultStruct \
#--restore-with-cpu=timing \
#--debug-flags=Exec --debug-file=$BENCHMARK"_"$SIM_TYPE"_"$NUM_OF_PROCS"P_ckpts.txt" 
