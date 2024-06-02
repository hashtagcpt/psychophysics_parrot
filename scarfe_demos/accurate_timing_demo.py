from psychopy import visual, core, event, logging
import numpy as np

# Setup default logging
logging.console.setLevel(logging.WARNING)

# Define colors
white = [1, 1, 1]
black = [-1, -1, -1]
grey = [0.5, 0.5, 0.5]
red = [1, -1, -1]
purple = [1, -1, 1]
blue = [-1, -1, 1]

# Create a monitor object
screen_width_pix = 1920  # Screen width in pixels
screen_height_pix = 1080  # Screen height in pixels
screen_width_cm = 53.0  # Screen width in cm
screen_distance_cm = 60.0  # Viewing distance in cm
screen_name = 'testMonitor'  # Name of the monitor

# Create a monitor object manually
from psychopy import monitors
monitor = monitors.Monitor(screen_name, width=screen_width_cm, distance=screen_distance_cm)
monitor.setSizePix((screen_width_pix, screen_height_pix))

# Open a window
win = visual.Window(size=(screen_width_pix, screen_height_pix), monitor=monitor, color=grey, fullscr=True, units='pix')

# hide the mouse
win.setMouseVisible(False)

# Measure the vertical refresh rate of the monitor
ifi = win.monitorFramePeriod

# Set the priority level
core.rush(True)

# Length of time and number of frames for each drawing test
num_secs = 1
num_frames = int(np.round(num_secs / ifi))

# Number of frames to wait when specifying good timing
waitframes = 1

# Function to report deviations from expected frame timing
def report_timing_deviations(vbl_times, ifi):
    frame_intervals = np.diff(vbl_times)
    expected_intervals = np.ones_like(frame_intervals) * ifi
    deviations = frame_intervals - expected_intervals
    return deviations

# Example #1: Poor timing
vbl_times = []
for frame in range(num_frames):
    win.color = grey
    vbl = win.flip()
    vbl_times.append(vbl)

deviations_1 = report_timing_deviations(vbl_times, ifi)
print(f"Example #1 - Mean Deviation: {np.mean(deviations_1):.6f} sec, SD: {np.std(deviations_1):.6f} sec")

# Example #2: Specified timing
vbl = win.flip()
vbl_times = []
for frame in range(num_frames):
    win.color = red
    vbl = win.flip(vbl + (waitframes - 0.5) * ifi)
    vbl_times.append(vbl)

deviations_2 = report_timing_deviations(vbl_times, ifi)
print(f"Example #2 - Mean Deviation: {np.mean(deviations_2):.6f} sec, SD: {np.std(deviations_2):.6f} sec")

# Example #3: Specified timing with maximum priority
vbl = win.flip()
vbl_times = []
for frame in range(num_frames):
    win.color = purple
    vbl = win.flip(vbl + (waitframes - 0.5) * ifi)
    vbl_times.append(vbl)

deviations_3 = report_timing_deviations(vbl_times, ifi)
print(f"Example #3 - Mean Deviation: {np.mean(deviations_3):.6f} sec, SD: {np.std(deviations_3):.6f} sec")

# Example #4: Specified timing with maximum priority and drawing finished
vbl = win.flip()
vbl_times = []
for frame in range(num_frames):
    win.color = blue
    core.wait(0.001)  # Simulate additional processing
    vbl = win.flip(vbl + (waitframes - 0.5) * ifi)
    vbl_times.append(vbl)

deviations_4 = report_timing_deviations(vbl_times, ifi)
print(f"Example #4 - Mean Deviation: {np.mean(deviations_4):.6f} sec, SD: {np.std(deviations_4):.6f} sec")

# Reset priority
core.rush(False)

# show the mouse
win.setMouseVisible(True)

# Close the window
win.close()
