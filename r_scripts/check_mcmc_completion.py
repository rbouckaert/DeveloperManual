from cmath import log
import os, sys, re

def natural_sort(l): 
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [convert(c) for c in re.split('([0-9]+)', key)]
    return sorted(l, key=alphanum_key)

def list_logfiles(logfiles_path):
    logfile_names = natural_sort([logfiles_path + f for f in os.listdir(logfiles_path) if f.endswith(".log")])
    n_files = len(logfile_names)

    return logfile_names

def check_a_logfile(logfile_name, chain_length):
    with open(logfile_name, "r") as logfile:
        all_lines = logfile.readlines()
        last_line = all_lines[-1]
    
        if last_line[0] == "#" or last_line[0] == "S": return 0.0
        else:
            tokens = last_line.split("\t")
            sample_n = tokens[0]
            
            return float(sample_n) / chain_length * 100.0 

def iterate_over_logfiles(logfile_names, chain_length, n_sim):

    n_jobs_started = len(logfile_names)
    finished = 0
    for logfile_name in logfile_names:
        pctg = check_a_logfile(logfile_name, chain_length)
        
        if pctg == 100.0:
            finished += 1

    print("Running: " + str(n_jobs_started - finished) + "/" + str(n_sim))
    print("Finished: " + str(finished) + "/" + str(n_sim))
    print("Pending: " + str(n_sim - n_jobs_started) + "/" + str(n_sim))

if __name__ == "__main__":
    logfiles_path = sys.argv[1]
    chain_length = int(sys.argv[2])
    n_sim = 100

    logfile_names = list_logfiles(logfiles_path)
    
    iterate_over_logfiles(logfile_names, chain_length, n_sim)

