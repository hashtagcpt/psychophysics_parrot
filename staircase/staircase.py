import numpy as np

class Staircase:
    def __init__(self, levels, init_step_size, step_size, right_rule, wrong_rule, 
                 max_trials, max_revs, start_level, verbose, ceiling_behaviour, 
                 max_ceiling_increments):
        # Set by inputs
        self.levels = levels
        self.init_step_size = init_step_size
        self.step_size = step_size
        self.right_rule = right_rule
        self.wrong_rule = wrong_rule
        self.max_trials = max_trials
        self.max_revs = max_revs
        self.verbose = verbose
        self.requested_start_level = start_level
        self.ceiling_behaviour = ceiling_behaviour if ceiling_behaviour in ['limiting', 'resetting'] else 'limiting'
        self.max_ceiling_increments = max_ceiling_increments

        # Initialized to zero/empty
        self.n_trials = np.zeros(len(self.levels))
        self.n_correct = np.zeros(len(self.levels))
        self.trial_count = 0
        self.rev_count = 0
        self.cur_direction = 0
        self.cur_right = 0
        self.cur_wrong = 0
        self.did_just_reverse = 0
        self.num_ceiling_increments = 0
        self.reversals = []
        self.reversal_directions = []

        self.cur_level = self._set_to_nearest_level(self.requested_start_level)
        if self.verbose:
            print('\nStaircase class object initialized.\n')

    @property
    def min_level(self):
        return np.min(self.levels)

    @property
    def max_level(self):
        return np.max(self.levels)

    @property
    def n_levels(self):
        return len(self.levels)

    @property
    def cur_index(self):
        return np.where(self.levels == self.cur_level)[0][0]

    @property
    def cur_step_size(self):
        return self.init_step_size if self.rev_count == 0 else self.step_size

    @property
    def is_finished(self):
        return (self.rev_count >= self.max_revs or
                self.trial_count >= self.max_trials or
                self.num_ceiling_increments >= self.max_ceiling_increments)

    @property
    def cur_reversal_thresh(self):
        if len(self.reversals) < 3:
            return np.nan
        return np.mean(self.reversals[1:])

    @property
    def cur_reversal_error(self):
        if len(self.reversals) < 3:
            return np.nan
        return np.std(self.reversals[1:]) / np.sqrt(len(self.reversals[1:]))

    def do_resp(self, is_correct):
        self._trial_inc()
        self.did_just_reverse = 0
        if is_correct:
            self.cur_right += 1
            self.n_correct += 1
            if self.verbose:
                print(f'Correct response, nRight = {self.cur_right}')
        else:
            self.cur_wrong += 1
            if self.verbose:
                print(f'Incorrect response, nWrong = {self.cur_wrong}')
        self._check_rules()

    def _trial_inc(self):
        self.n_trials += 1
        if self.rev_count != 0:
            self.trial_count += 1
            if self.verbose:
                print(f'Reversal: {self.rev_count}, Trial: {self.trial_count}')

    def _set_to_nearest_level(self, req_level):
        abs_diff = np.abs(np.array(self.levels) - req_level)
        return self.levels[np.argmin(abs_diff)]

    def _check_rules(self):
        if self.cur_right >= self.right_rule:
            if self.verbose:
                print('Change level: decrease.')
            self._change_level(0)
        elif self.cur_wrong >= self.wrong_rule:
            if self.verbose:
                print('Change level: increase.')
            self._change_level(1)

    def _change_level(self, new_dir):
        if self.cur_direction != new_dir:
            self._do_reversal(new_dir)

        # Update current level based on direction
        if self.cur_direction == 0:
            self.cur_level -= self.cur_step_size
        else:
            self.cur_level += self.cur_step_size

        # Ceiling behavior: Limiting or Resetting
        if self.cur_level > self.max_level:
            self.num_ceiling_increments += 1
            if self.ceiling_behaviour == 'limiting':
                self.cur_level = self.max_level
                if self.verbose:
                    print(f'Max exceeded {self.num_ceiling_increments} time(s), bound at {self.cur_level}.')
            elif self.ceiling_behaviour == 'resetting':
                self.cur_level = self._set_to_nearest_level(self.requested_start_level)
                if self.verbose:
                    print(f'Max exceeded {self.num_ceiling_increments} time(s), resetting to {self.requested_start_level}.')
        elif self.cur_level < self.min_level:
            if self.ceiling_behaviour == 'limiting':
                self.cur_level = self.min_level
                if self.verbose:
                    print(f'Min exceeded, bound at {self.cur_level}.')
            elif self.ceiling_behaviour == 'resetting':
                self.cur_level = self._set_to_nearest_level(self.requested_start_level)
                if self.verbose:
                    print(f'Min exceeded, resetting to {self.requested_start_level}.')

        # Reset counters for correct and incorrect responses
        self.cur_right = 0
        self.cur_wrong = 0

    def _do_reversal(self, new_dir):
        self.rev_count += 1
        self.reversals.append(self.cur_level)
        self.reversal_directions.append(new_dir)
        if self.verbose:
            print(f'Reversal, {self.cur_direction} to {new_dir}, revCount = {self.rev_count}, revThresh = {self.cur_reversal_thresh:.1f} \u00B1 {self.cur_reversal_error:.1f}')
        self.cur_direction = new_dir
        self.did_just_reverse = 1

# Example usage
# staircase = Staircase(levels=[1, 2, 3, 4, 5], init_step_size=1, step_size=1, right_rule=2, wrong_rule=2,
#                       max_trials=100, max_revs=10, start_level=3, verbose=True, ceiling_behaviour='limiting', max_ceiling_increments=float('inf'))
