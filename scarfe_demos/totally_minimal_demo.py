from psychopy import visual, core, event, monitors

# Define the colors
white = 1.0  # Maximum luminance value for white
black = -1.0  # Minimum luminance value for black
grey = 0.0  # Halfway between black and white

# Get the list of all monitors
all_monitors = monitors.getAllMonitors()

# Select the screen to draw to (use the last screen in the list, which is typically the external monitor)
screen_number = len(all_monitors) - 1

# Create a monitor object for the selected screen
monitor_name = all_monitors[screen_number]
monitor = monitors.Monitor(monitor_name)

# Open a window on the selected screen with grey background
win = visual.Window(monitor=monitor, color=grey, fullscr=True)

# Create a text stimulus
message = visual.TextStim(win, text='Press any key to terminate the demo', color=white, pos=(0, 0))

# Draw the text message on the screen
message.draw()
win.flip()

# Wait for a key press to terminate the demo
event.waitKeys()

# Close the window
win.close()
