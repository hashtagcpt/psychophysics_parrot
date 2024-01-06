import numpy as np
import csv
import random
from staircase import Staircase

def do_sim(sim_noise_std_dev, lin_stim_level):
    """
    Simulate subject behavior for 2AFC task.
    """
    resp_t = random.gauss(0, sim_noise_std_dev) + lin_stim_level  # target interval
    resp_n = random.gauss(0, sim_noise_std_dev)                   # null interval

    if resp_t > resp_n:
        resp = 1
    else:
        resp = 0

    return resp   # correct if noisy target > null

def demo_1_minimal_example():
    durations = [8, 10, 12, 14, 16, 32, 64]
    log_stim_levels = durations
    init_step_size = 6
    step_size = 3
    n_right_to_descend = 3
    n_wrong_to_ascend = 1
    max_num_trials = 100
    max_num_reversals = 10
    start_level = 12
    verbose = True

    sc = Staircase(log_stim_levels, init_step_size, step_size, n_right_to_descend, 
                   n_wrong_to_ascend, max_num_trials, max_num_reversals, 
                   start_level, verbose, 'limiting', float('inf'))

    sim_noise_std_dev = np.sqrt(2)

    while not sc.is_finished:
        log_stim_level = sc.cur_level
        lin_stim_level = 10 ** (log_stim_level / 20)
        is_sim_correct = do_sim(sim_noise_std_dev, lin_stim_level)
        
        sc.do_resp(is_sim_correct)

        print(f'Current threshold from reversals: {sc.cur_reversal_thresh:.2f} +/- {sc.cur_reversal_error:.2f}\n')

    # Writing output to CSV
    csv_file_name = 'demo_1_staircase_sim_output_table.csv'
    with open(csv_file_name, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['logLev', 'nTrials', 'nCorrect'])
        for i, level in enumerate(sc.levels):
            writer.writerow([level, sc.n_trials[i], sc.n_correct[i]])

    print(f'Output saved in: {csv_file_name}')

# Run the demo
demo_1_minimal_example()