
default:
	@echo "log files analyzer"



#CPU_FREQS := 1.6 1.5 1.4 1.3 1.2 1.1 1.0 # 7 sor7
#CPU_FREQS := 3.6 3.2 2.8 2.4 2.0 1.6 1.2 # calc4
CPU_FREQS := 3.6 3.4 3.2 3.0 2.8 2.6 2.4 2.2 2.0 1.8 1.6 1.4 1.2 # calc4
#CPU_FREQS := 1.6
#CORE_NUMS := 1 2 4 8 16 17 32 34 64 68 128 136 256 272 # 14 sor7
CORE_NUMS := 1 2 4 8 16 32 # 6 calc4
APPS := bt cg dc ep ft is lu mg sp ua stress # 11
#APPS := cg stress # 11

# NUC
CPU_FREQS := 3.5 0.8 # 2
CORE_NUMS := 1 2 4 8 # 4
APPS := stress # 11

#LOG_DIR := ./20170804-sor7
#LOG_DIR := ./20170819-calc4
#LOG_DIR := 20171011-nuc1
LOG_DIR := 20171012-1-nuc2

load-logs: load-pkgwatt load-ramwatt load-pkgtemp

load-pkgwatt:
	@for cpu_freq in $(CPU_FREQS); do\
		log_file=$(LOG_DIR)/pkgwatt-freq$$cpu_freq.csv ;\
		echo -n "\t"  > $$log_file ;\
		for core_num in $(CORE_NUMS); do\
			echo -n $$core_num "\t" ;\
		done >> $$log_file ;\
		echo "" >> $$log_file ;\
		for app_name in $(APPS); do\
			echo -n $$app_name "\t" ;\
			for core_num in $(CORE_NUMS); do\
			awk 'NR>1 {if(max<$$26) max=$$26} END{printf "%f\t", max}' $(LOG_DIR)/log_freq$$cpu_freq/log-turbostat_app$$app_name\_freq$$cpu_freq\_core$$core_num.log; \
			done ;\
			echo "" ;\
		done >> $$log_file ;\
	done | tee load-test.log

# calc4?			awk 'NR>1 {if(max<$$16) max=$$16} END{printf "%f\t", max}' $(LOG_DIR)/log_freq$$cpu_freq/log-turbostat_app$$app_name\_freq$$cpu_freq\_core$$core_num.log; \

load-ramwatt:
	@for cpu_freq in $(CPU_FREQS); do\
		log_file=$(LOG_DIR)/ramwatt-freq$$cpu_freq.csv ;\
		echo -n "\t"  > $$log_file ;\
		for core_num in $(CORE_NUMS); do\
			echo -n $$core_num "\t" ;\
		done >> $$log_file ;\
		echo "" >> $$log_file ;\
		for app_name in $(APPS); do\
			echo -n $$app_name "\t" ;\
			for core_num in $(CORE_NUMS); do\
			awk 'NR>1 {if(max<$$17) max=$$17} END{printf "%f\t", max}' $(LOG_DIR)/log_freq$$cpu_freq/log-turbostat_app$$app_name\_freq$$cpu_freq\_core$$core_num.log; \
			done ;\
			echo "" ;\
		done >> $$log_file ;\
	done | tee load-test.log

# sor7			awk 'NR>1 {if(max<$$12) max=$$12} END{printf "%f\t", max}' $(LOG_DIR)/log_freq$$cpu_freq/log-turbostat_app$$app_name\_freq$$cpu_freq\_core$$core_num.log; \

load-pkgtemp:
	@for cpu_freq in $(CPU_FREQS); do\
		log_file=$(LOG_DIR)/pkgtemp-freq$$cpu_freq.csv ;\
		echo -n "\t"  > $$log_file ;\
		for core_num in $(CORE_NUMS); do\
			echo -n $$core_num "\t" ;\
		done >> $$log_file ;\
		echo "" >> $$log_file ;\
		for app_name in $(APPS); do\
			echo -n $$app_name "\t" ;\
			for core_num in $(CORE_NUMS); do\
			awk 'NR>1 {if(max<$$12) max=$$12} END{printf "%f\t", max}' $(LOG_DIR)/log_freq$$cpu_freq/log-turbostat_app$$app_name\_freq$$cpu_freq\_core$$core_num.log; \
			done ;\
			echo "" ;\
		done >> $$log_file ;\
	done | tee load-test.log

load-temperature:
	@for cpu_freq in $(CPU_FREQS); do\
		echo -n "\t"  > $(LOG_DIR)/temp-freq$$cpu_freq.csv ;\
		for core_num in $(CORE_NUMS); do\
			echo -n $$core_num "\t" ;\
		done >> $(LOG_DIR)/temp-freq$$cpu_freq.csv ;\
		echo "" >> $(LOG_DIR)/temp-freq$$cpu_freq.csv ;\
		for app_name in $(APPS); do\
			echo -n $$app_name "\t" ;\
			for core_num in $(CORE_NUMS); do\
			awk 'NR>1 {if(max<$$12) max=$$12} END{printf "%f\t", max}' $(LOG_DIR)/log_freq$$cpu_freq/log-turbostat_app$$app_name\_freq$$cpu_freq\_core$$core_num.log; \
			done ;\
			echo "" ;\
		done >> $(LOG_DIR)/temp-freq$$cpu_freq.csv ;\
	done | tee load-test.log

# sor7			awk 'NR>1 {if(max<$$9) max=$$9} END{printf "%f\t", max}' $(LOG_DIR)/log_freq$$cpu_freq/log-turbo#			  echo $$app $$cpu_freq $$core_num; \


##########################
# test
load-watt-max: # APP, CPU_FREQ, CORE_NUM
	awk 'NR>1 {if(max<$$12) max=$$12} END{print max}' $(LOG_DIR)/log_freq$(CPU_FREQ)/log-turbostat_app$(APP)_freq$(CPU_FREQ)_core$(CORE_NUM).log

load-temp-max: # APP, CPU_FREQ, CORE_NUM
	awk 'NR>1 {if(max<$$9) max=$$9} END{print max}' $(LOG_DIR)/log_freq$(CPU_FREQ)/log-turbostat_app$(APP)_freq$(CPU_FREQ)_core$(CORE_NUM).log

test-load:
	awk 'NR>1 {if(max<$$12) max=$$12} END{print max}' $(LOG_DIR)/log_freq1.6/log-turbostat_appbt_freq1.6_core32.log

