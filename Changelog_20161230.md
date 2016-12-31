# gem5
1. modify the file gem5/src/cpu/simple/timing.cc,
now for timing CPU, the exec debug trace can also output physical address

2. modify gem5/src/mem/comm_monitor.cc,
now for timing CPU, the CommMonitor debug trace can also output physical address

3. modify gem5/configs/custom/fs_tiled_comm_stall.py, gem5/configs/common/Options.py. Now the simulate_inst_stalls and simulate_data_stalls of atomic cpu can be turned off/on.

4. To turn on/off the two options simulate_inst_stalls and simulate_data_stalls, add or delete the following two options in the running scripts:
gem5/run_gem5_alpha_Comm_final.sh
gem5/run_gem5_alpha_Comm_restore.sh

5. More information about simulate_inst_stalls and simulate_data_stalls FOR atomic CPU:
In Exec debug trace file:
a. time difference between memory access inst and the subsequent inst = dcache_latency + icache_latency
dcache_latency = memory access time
icache_latency >= 2 cycles

b. if simulate_inst_stalls is turned off, then the icache_latency = 0 cycles
timediff between memory access inst and the subsequent inst = dcache_latency

