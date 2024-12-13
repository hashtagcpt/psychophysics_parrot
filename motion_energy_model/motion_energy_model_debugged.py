import numpy as np
import scipy.io as sio
import matplotlib.pyplot as plt
from scipy.signal import convolve2d
from scipy.special import factorial

# Load stimulus data
stimulus_file = 'AB15.mat'
stim_data = sio.loadmat(stimulus_file)
stim = stim_data['stim']

# Step 1a: Define the space axis of the filters
nx = 80
max_x = 2.0
dx = (max_x * 2) / nx
x_filt = np.linspace(-max_x, max_x, nx)

# Spatial filter parameters
sx = 0.5
sf = 1.1

# Spatial filter response
gauss = np.exp(-x_filt**2 / sx**2)
even_x = np.cos(2 * np.pi * sf * x_filt) * gauss
odd_x = np.sin(2 * np.pi * sf * x_filt) * gauss

# Step 1b: Define the time axis of the filters
nt = 100
max_t = 0.5
dt = max_t / nt
t_filt = np.linspace(0, max_t, nt)

# Temporal filter parameters
k = 100
slow_n = 9
fast_n = 6
beta = 0.9

# Temporal filter response
slow_t = (k * t_filt)**slow_n * np.exp(-k * t_filt) * (1/factorial(slow_n) - beta * (k * t_filt)**2 / factorial(slow_n + 2))
fast_t = (k * t_filt)**fast_n * np.exp(-k * t_filt) * (1/factorial(fast_n) - beta * (k * t_filt)**2 / factorial(fast_n + 2))

# Step 1c: Combine space and time to create spatiotemporal filters
e_slow = np.outer(slow_t, even_x)
e_fast = np.outer(fast_t, even_x)
o_slow = np.outer(slow_t, odd_x)
o_fast = np.outer(fast_t, odd_x)

# Step 2: Create spatiotemporally oriented filters
left_1 = o_fast + e_slow
left_2 = -o_slow + e_fast
right_1 = -o_fast + e_slow
right_2 = o_slow + e_fast

# Convolve the filters with the stimulus
def convolve_filters(stim, filt):
    return convolve2d(stim, filt, mode='valid', boundary='fill', fillvalue=0)

# Perform the convolution
resp_right_1 = convolve_filters(stim, right_1)
resp_right_2 = convolve_filters(stim, right_2)
resp_left_1 = convolve_filters(stim, left_1)
resp_left_2 = convolve_filters(stim, left_2)

# Step 4: Square the filter output
resp_right_1 = resp_right_1**2
resp_right_2 = resp_right_2**2
resp_left_1 = resp_left_1**2
resp_left_2 = resp_left_2**2

# Step 5: Normalize the filter output
energy_right = resp_right_1 + resp_right_2
energy_left = resp_left_1 + resp_left_2
total_energy = np.sum(energy_right) + np.sum(energy_left)

RR1 = np.sum(resp_right_1) / total_energy
RR2 = np.sum(resp_right_2) / total_energy
LR1 = np.sum(resp_left_1) / total_energy
LR2 = np.sum(resp_left_2) / total_energy

# Step 6: Sum the paired filters in each direction
right_Total = RR1 + RR2
left_Total = LR1 + LR2

# Step 7: Calculate net energy as the R-L difference
motion_energy = right_Total - left_Total

# Display summary output and graphics
print('\n\nNet motion energy =', motion_energy, '\n\n')

# Plot the stimulus
plt.figure(1)
plt.imshow(stim, cmap='gray')
plt.axis('off')
plt.title('Stimulus')

# Plot the output
energy_opponent = energy_right - energy_left
xv, yv = energy_left.shape
xv, yv = energy_left.shape
energy_flicker = total_energy / (xv * yv)
motion_contrast = energy_opponent / energy_flicker

# Plot, scaling by max L or R value
mc_max = np.max(motion_contrast)
mc_min = np.min(motion_contrast)
peak = max(abs(mc_max), abs(mc_min))

plt.figure(2)
plt.imshow(motion_contrast, cmap='gray', vmin=-peak, vmax=peak)
plt.axis('off')
plt.title('Normalized Motion Energy')

plt.show()