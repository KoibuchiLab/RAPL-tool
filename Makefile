

help:
	@echo "make {test, test-stress-calc4}"

#test:	test-stress-sor7
test:	test-stress-calc4
#test:	test-cpupower-freq-sor7
#test:	20170803-test

set-cpufreq:
	sudo cpupower frequency-set -u $(CPU_FREQ)GHz

#	@echo "APP: {bt, cg, dc, ep, ft, is, lu, mg, sp, ua}"
run-npb-core: 20170803-NPB-run
	make -C 20170803-NPB-run APP=$(APP) OMP_NUM=$(CORE_NUM) run-B-arg

20170803-NPB-run:
	git clone -b $@ NPB-branch $@

log-env:
	hostname > env.txt
	uname -a >> env.txt
	cat /proc/meminfo >> env.txt
#	gcc --version >> env.txt
#	gfortran --version >> env.txt
	cat /proc/cpuinfo >> env.txt


###############################################
# log NUC (air, water)

#CPU_FREQS_NUC := 3.5 3.0 2.5 2.0 1.5 1.0 0.8 # 2
CPU_FREQS_NUC := 3.5 0.8 # 2
CORE_NUMS_NUC := 1 2 4 8 # 4
#CORE_NUMS_NUC := 1 8 # test

log-nuc:
	@for core_num in $(CORE_NUMS_NUC); do\
		for cpu_freq in $(CPU_FREQS_NUC); do\
			make CORE_NUM=$$core_num CPU_FREQ=$$cpu_freq log-stress-freq-core ;\
		done ;\
	done

log-stress-freq-core: # CPU_FREQ, CORE_NUM
	make set-cpufreq
	mkdir -p log_freq$(CPU_FREQ)
	sudo turbostat --Summary --debug --interval 1 > ./log_freq$(CPU_FREQ)/log-turbostat_appstress_freq$(CPU_FREQ)_core$(CORE_NUM).log & echo "$$!" > turbostat.pid
	sleep 5
	stress -c $(CORE_NUM) --timeout 30s # stress command
	sleep 5
	sudo kill `cat ./turbostat.pid`
	rm ./turbostat.pid
	make reset-cpupower-nuc

reset-cpupower-nuc:
	sudo cpupower frequency-set -u 3.5GHz

###############################################
# log calc4


CPU_FREQS_CALC4 := 3.6 3.2 2.8 2.4 2.0 1.6 1.2 3.4 3.0 2.6 2.2 1.8 1.4 # 13
#CPU_FREQS_CALC4 := 3.6 1.6 # test
#CPU_FREQS_CALC4 := 3.6 # test
CORE_NUMS := 1 2 4 8 16 32 # 6
#CORE_NUMS := 16 32 # test
APPS := bt cg dc ep ft is lu mg sp ua # +stress 11
#APPS := cg dc # test

log-calc4:
	@for cpu_freq in $(CPU_FREQS_CALC4); do\
		make CPU_FREQ=$$cpu_freq log-apps-freq-calc4 ;\
	done

log-apps-freq-calc4:
	@for core_num in $(CORE_NUMS); do\
		make CPU_FREQ=$(CPU_FREQ) CORE_NUM=$$core_num log-apps-freq-core-calc4 ;\
	done

log-apps-freq-core-calc4: # CPU_FREQ, CORE_NUM
	@for app_name in $(APPS); do\
		make APP=$$app_name CPU_FREQ=$(CPU_FREQ) CORE_NUM=$(CORE_NUM) log-npb-freq-core-calc4 ;\
	done ; \
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=$(CORE_NUM) log-stress-freq-core-calc4

# test make APP=cg CPU_FREQ=3.6 CORE_NUM=32 log-npb-freq-core-calc4
log-npb-freq-core-calc4: # APP, CPU_FREQ, CORE_NUM
	make set-cpufreq # CPU_FREQ
	mkdir -p log_freq$(CPU_FREQ)
	sudo turbostat --Summary --debug --interval 1 > ./log_freq$(CPU_FREQ)/log-turbostat_app$(APP)_freq$(CPU_FREQ)_core$(CORE_NUM).log & echo "$$!" > turbostat.pid
	sleep 5
	make APP=$(APP) CORE_NUM=$(CORE_NUM) run-npb-core
	sleep 5
	sudo kill `cat ./turbostat.pid`
	rm ./turbostat.pid
	mv 20170803-NPB-run/log_app* ./log_freq$(CPU_FREQ)/
	make reset-cpupower-calc4

log-stress-freq-core-calc4: # CPU_FREQ, CORE_NUM
	make set-cpufreq
	mkdir -p log_freq$(CPU_FREQ)
	sudo turbostat --Summary --debug --interval 1 > ./log_freq$(CPU_FREQ)/log-turbostat_appstress_freq$(CPU_FREQ)_core$(CORE_NUM).log & echo "$$!" > turbostat.pid
	sleep 5
	stress -c $(CORE_NUM) --timeout 30s # stress command
	sleep 5
	sudo kill `cat ./turbostat.pid`
	rm ./turbostat.pid
	make reset-cpupower-calc4

reset-cpupower-calc4:
	sudo cpupower frequency-set -u 3.6GHz

###########
# ref
load-watt:
	@for cpu_freq in $(CPU_FREQS); do\
		echo -n "\t"  > freq$$cpu_freq.csv ;\
		for core_num in $(CORE_NUMS); do\
			echo -n $$core_num "\t" ;\
		done >> freq$$cpu_freq.csv ;\
		echo "" >> freq$$cpu_freq.csv ;\
		for app_name in $(APPS); do\
			echo -n $$app_name "\t" ;\
			for core_num in $(CORE_NUMS); do\
			awk 'NR>1 {if(max<$$12) max=$$12} END{printf "%f\t", max}' ./20170804-sor7/log_freq$$cpu_freq/log-turbostat_app$$app_name\_freq$$cpu_freq\_core$$core_num.log; \
			done ;\
			echo "" ;\
		done >> freq$$cpu_freq.csv ;\
	done | tee load-test.log


###############################################
# log sor7

log-sor7:
	make CPU_FREQ=1.6 log-apps-freq-sor7
	make CPU_FREQ=1.5 log-apps-freq-sor7
	make CPU_FREQ=1.4 log-apps-freq-sor7
	make CPU_FREQ=1.3 log-apps-freq-sor7
	make CPU_FREQ=1.2 log-apps-freq-sor7
	make CPU_FREQ=1.1 log-apps-freq-sor7
	make CPU_FREQ=1.0 log-apps-freq-sor7

log-apps-freq-sor7: # CPU_FREQ
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=272 log-apps-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=256 log-apps-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=136 log-apps-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=128 log-apps-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=68 log-apps-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=64 log-apps-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=34 log-apps-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=32 log-apps-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=17 log-apps-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=16 log-apps-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=8 log-apps-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=4 log-apps-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=2 log-apps-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=1 log-apps-freq-core-sor7

log-apps-freq-core-sor7: # CPU_FREQ, CORE_NUM
	make APP=bt CPU_FREQ=$(CPU_FREQ) CORE_NUM=$(CORE_NUM) log-npb-freq-core-sor7
	make APP=cg CPU_FREQ=$(CPU_FREQ) CORE_NUM=$(CORE_NUM) log-npb-freq-core-sor7
	make APP=dc CPU_FREQ=$(CPU_FREQ) CORE_NUM=$(CORE_NUM) log-npb-freq-core-sor7
	make APP=ep CPU_FREQ=$(CPU_FREQ) CORE_NUM=$(CORE_NUM) log-npb-freq-core-sor7
	make APP=ft CPU_FREQ=$(CPU_FREQ) CORE_NUM=$(CORE_NUM) log-npb-freq-core-sor7
	make APP=is CPU_FREQ=$(CPU_FREQ) CORE_NUM=$(CORE_NUM) log-npb-freq-core-sor7
	make APP=lu CPU_FREQ=$(CPU_FREQ) CORE_NUM=$(CORE_NUM) log-npb-freq-core-sor7
	make APP=mg CPU_FREQ=$(CPU_FREQ) CORE_NUM=$(CORE_NUM) log-npb-freq-core-sor7
	make APP=sp CPU_FREQ=$(CPU_FREQ) CORE_NUM=$(CORE_NUM) log-npb-freq-core-sor7
	make APP=ua CPU_FREQ=$(CPU_FREQ) CORE_NUM=$(CORE_NUM) log-npb-freq-core-sor7
	make CPU_FREQ=$(CPU_FREQ) CORE_NUM=$(CORE_NUM) log-stress-freq-core-sor7


log-npb-freq-core-sor7: # APP, CPU_FREQ, CORE_NUM
	make set-cpufreq
	mkdir -p log_freq$(CPU_FREQ)
	sudo turbostat --Summary --interval 1 > ./log_freq$(CPU_FREQ)/log-turbostat_app$(APP)_freq$(CPU_FREQ)_core$(CORE_NUM).log & echo "$$!" > turbostat.pid
	sleep 5
	make APP=$(APP) CORE_NUM=$(CORE_NUM) run-npb-core
	sleep 5
	sudo kill `cat ./turbostat.pid`
	rm ./turbostat.pid
	mv 20170803-NPB-run/log_app* ./log_freq$(CPU_FREQ)/


log-stress-freq-core-sor7: # CPU_FREQ, CORE_NUM
	make set-cpufreq
	mkdir -p log_freq$(CPU_FREQ)
	sudo turbostat --Summary --interval 1 > ./log_freq$(CPU_FREQ)/log-turbostat_appstress_freq$(CPU_FREQ)_core$(CORE_NUM).log & echo "$$!" > turbostat.pid
	sleep 5
	stress -c $(CORE_NUM) --timeout 30s # stress command
	sleep 5
	sudo kill `cat ./turbostat.pid`
	rm ./turbostat.pid

reset-cpupower-sor7:
	sudo cpupower frequency-set -u 1.6GHz

###############################################
# log 20170803
20170803-test:
	make CPU_FREQ=1.6 CORE_NUM=272 test-stress-freq-core-sor7
	make CPU_FREQ=1.5 CORE_NUM=272 test-stress-freq-core-sor7
	make CPU_FREQ=1.4 CORE_NUM=272 test-stress-freq-core-sor7
	make CPU_FREQ=1.3 CORE_NUM=272 test-stress-freq-core-sor7
	make CPU_FREQ=1.2 CORE_NUM=272 test-stress-freq-core-sor7
	make CPU_FREQ=1.1 CORE_NUM=272 test-stress-freq-core-sor7
	make CPU_FREQ=1.0 CORE_NUM=272 test-stress-freq-core-sor7

test-stress-sor7:
	make CORE_NUM=8 test-stress-sor7-core
	make CORE_NUM=68 test-stress-sor7-core
	make CORE_NUM=136 test-stress-sor7-core
	make CORE_NUM=272 test-stress-sor7-core

test-cpupower-freq-sor7:
	make CPU_FREQ=1.6 test-cpupower
	make CPU_FREQ=1.5 test-cpupower
	make CPU_FREQ=1.4 test-cpupower

test-cpupower:
	@echo CPU_FREQ=$(CPU_FREQ)
	make set-cpufreq
	sudo cpupower frequency-info


###############################################
# calc4

test-stress-calc4:
	sudo turbostat --debug --interval 1 --out turbostat.log & echo "$$!" > turbostat.pid
	stress -c 8 --timeout 10s # do something
	sudo kill `cat ./turbostat.pid`


###############################################
# tests

test-kill-pid:
	sudo turbostat --debug --interval 1 --out turbostat.log & echo "$$!" > turbostat.pid
	sleep 5 # do something
	sudo kill `cat ./turbostat.pid`

test-arg:
	@make ARG1=aaa echo-arg1
echo-arg1:
	@echo $(ARG1)

20170714-log:
	sudo turbostat --debug --interval 1


