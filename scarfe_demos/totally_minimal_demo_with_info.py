from psychopy import visual, core, event, monitors

# Define the colors
white = [1, 1, 1]  # Maximum luminance value for white
black = [0, 0, 0]  # Minimum luminance value for black
grey = [0.5, 0.5, 0.5]  # Halfway between black and white

# Create a monitor object for the selected screen
monitor_name = 'testMonitor'  # Ensure this matches a monitor defined in Monitor Center
monitor = monitors.Monitor(monitor_name)

# Open a window on the selected screen with grey background
win = visual.Window(monitor=monitor, screen=1, color=grey, fullscr=True, units='pix')

# Get window size in pixels
screenXpixels, screenYpixels = win.size

# Get the center of the window in pixels
xCenter, yCenter = screenXpixels / 2, screenYpixels / 2

# Query the inter-frame interval
ifi = win.monitorFramePeriod

# Get the refresh rate of the screen
hertz = win.getActualFrameRate()

# Get the nominal refresh rate of the screen (rounded to the nearest integer)
nominalHertz = round(hertz) if hertz is not None else 'N/A'

# Get the display size in mm (assuming monitor profile is accurate)
displaySize = monitor.getSizePix()

# Create a list of strings for each piece of information
info_text = [
    f"Screen Resolution: {screenXpixels}x{screenYpixels} pixels",
    f"Screen Center: ({xCenter}, {yCenter})",
    f"Inter-frame Interval (IFI): {ifi} seconds",
    f"Refresh Rate: {hertz} Hz",
    f"Nominal Refresh Rate: {nominalHertz} Hz",
    f"Display Size: {displaySize} pix",
    "Press any key to terminate the demo"
]

# Calculate the starting y position for the first text stimulus
total_text_height = 100 * len(info_text)  # Assume each line of text is 50 pixels high
start_y = yCenter - total_text_height / 2

# Create text stimuli for each piece of information
text_stimuli = []
for i, text in enumerate(info_text):
    y_pos = start_y - 50 * i  # Adjust the y position for each line
    text_stimuli.append(visual.TextStim(win, text=text, color=white, pos=(0, y_pos)))

# Draw all text stimuli on the screen
for text_stim in text_stimuli:
    text_stim.draw()

# Flip the window to update the display
win.flip()

# Wait for a key press to terminate the demo
event.waitKeys()

# Close the window
win.close()