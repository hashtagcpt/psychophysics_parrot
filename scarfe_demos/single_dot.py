from psychopy import visual, core, event
import numpy as np

# Set up the window and some default settings
# Clear the workspace
# This part is implicit in Python as each run starts fresh, unlike MATLAB's workspace

# Seed the random number generator for reproducibility
np.random.seed()  # Equivalent to rng('shuffle')

# Get screen information
# PsychoPy automatically handles multiple screens, defaulting to the maximum screen if specified
screen_width_pix = 1920  # Example value, replace with your screen's width
screen_height_pix = 1080  # Example value, replace with your screen's height

# Define black and white
white = [1, 1, 1]
black = [-1, -1, -1]

# Open a window and color it black
win = visual.Window(size=(screen_width_pix, screen_height_pix), color=black, fullscr=True, units='pix')

# Get the size of the on-screen window in pixels
screenXpixels, screenYpixels = win.size

# Get the center coordinate of the window in pixels
xCenter, yCenter = screenXpixels / 2, screenYpixels / 2

# Enable alpha blending for anti-aliasing
win.setBlendMode('avg')

# Set the color of our dot to full red
dotColor = [1, -1, -1]

# Determine a random X and Y position for our dot
dotXpos = np.random.rand() * screenXpixels
dotYpos = np.random.rand() * screenYpixels

# Dot size in pixels
dotSizePix = 50

# Draw the dot to the screen
dot = visual.Circle(win, radius=dotSizePix / 2, fillColor=dotColor, lineColor=dotColor, pos=(dotXpos - xCenter, dotYpos - yCenter))
dot.draw()

# Flip to the screen
win.flip()


# Create the text stimulus
message = visual.TextStim(win, text='Press any key to continue', color=white, pos=(0, -screenYpixels / 2 + 50))

# Draw the dot and the text message to the screen
dot.draw()
message.draw()

# Flip to the screen
win.flip()

# Wait for a keyboard button press to continue
event.waitKeys()

# Flash the dot at 10 Hz for 1 second
flash_duration = 1.0  # duration in seconds
flash_rate = 10  # frequency in Hz
num_flashes = int(flash_duration * flash_rate)
flash_interval = 1.0 / flash_rate

# Perform the flashing
for _ in range(num_flashes):
    dot.draw()
    win.flip()
    core.wait(flash_interval / 2)
    win.flip()
    core.wait(flash_interval / 2)

# Close the window and exit
win.close()
core.quit()