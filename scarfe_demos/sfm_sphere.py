from psychopy import visual, core, event, monitors
import numpy as np

# Clear the workspace
# PsychoPy clears variables at the start, unlike MATLAB

# Set up default settings for PsychoPy
np.random.seed()

# Screen initialization
monitor = monitors.Monitor('testMonitor')  # Create a monitor profile (change 'testMonitor' as needed)
screenid = 0  # Assuming single screen setup, otherwise use max(screenids) equivalent

# Determine the values of black and white
black = [0, 0, 0]
white = [1, 1, 1]

# Set up our screen
win = visual.Window(color=black, fullscr=True, units='pix', monitor=monitor)

# Get the vertical refresh rate of the monitor
ifi = win.getMsPerFrame(nFrames=60, showVisual=False)[0] / 1000.0

# Get the width and height of the window in pixels
screenXpix, screenYpix = win.size

# Determine the center of the screen
center = [screenXpix / 2, screenYpix / 2]

# Get the physical dimensions of the monitor
widthMM, heightMM = monitor.getSizePix()
if widthMM is None or heightMM is None:
    widthMM, heightMM = 520, 320  # Use default values if monitor size is not specified

# Convert to centimeters
screenYcm = heightMM / 10
screenXcm = widthMM / 10
pixPerCm = np.mean([screenXpix / screenXcm, screenYpix / screenYcm])

# Set the blend function so that we get nice antialiased edges to the dots defining our cylinder
win.setBlendMode('avg')

# Stimulus information
sphereRadius = 14  # Radius of the sphere in cm
maxDepthPix = sphereRadius * pixPerCm  # Maximum depth in pixels
sphereSurfArea = 4 * np.pi * sphereRadius**2  # Surface area of the sphere
dotDensity = 2
numDots = round(dotDensity * sphereSurfArea)  # Specify the number of dots we want on the sphere

# Uniformly distribute the points in spherical space
th = 2 * np.pi * np.random.rand(numDots)
ph = np.arcsin(-1 + 2 * np.random.rand(numDots))

# Convert the point coordinates into Cartesian space
sphereCoordsX = sphereRadius * np.cos(th) * np.cos(ph)
sphereCoordsY = sphereRadius * np.sin(th) * np.cos(ph)
sphereCoordsZ = sphereRadius * np.sin(ph)

# Convert to pixels
sphereCoordsX = sphereCoordsX * pixPerCm
sphereCoordsY = sphereCoordsY * pixPerCm
sphereCoordsZ = sphereCoordsZ * pixPerCm

# Maximum and minimum depth possible
minMaxDepth = np.array([0, 1]) * sphereRadius * pixPerCm

# The dot coordinates: these coordinates are 3D
dotCoordsAll = np.array([sphereCoordsX, sphereCoordsY, sphereCoordsZ])

# Set the dot size in pixels
dotMinSizePixels = 4
dotMaxSizePixels = 8

# Randomly color the dots
dotColors = np.random.rand(3, numDots) * 2 - 1  # Scale colors from [0, 1] to [-1, 1]

# Update the stimulus on each frame
waitframes = 1

# Start angle and the angle in degrees that we will rotate per frame
angle = 0
degPerFrame = 0.3
rotYmat = np.array([[np.cos(np.radians(degPerFrame)), 0, np.sin(np.radians(degPerFrame))],
                    [0, 1, 0],
                    [-np.sin(np.radians(degPerFrame)), 0, np.cos(np.radians(degPerFrame))]])

# Do the rendering
while not event.getKeys():

    # This is orthographic projection, so we get only the dots which are in front of the plane of the screen
    behindCue = dotCoordsAll[2, :] >= 0
    dotCoords = dotCoordsAll[:2, behindCue]

    # Dot sizes for this frame
    dotDepths = np.concatenate((dotCoordsAll[2, behindCue], minMaxDepth))
    dotSizes = np.interp(dotDepths, (minMaxDepth[0], minMaxDepth[1]), (dotMinSizePixels, dotMaxSizePixels))
    dotSizes = dotSizes[:-2]

    # Colors of the dots that we will display
    theDotColors = dotColors[:, behindCue]

    # Draw the dots
    visual.ElementArrayStim(win, units='pix', nElements=len(dotSizes),
                            xys=dotCoords.T, sizes=dotSizes,
                            colors=theDotColors.T, elementMask='circle', elementTex=None).draw()

    # Flip to the screen
    win.flip()

    # Increment the angle and rotate the 3D coordinates
    dotCoordsAll = np.dot(rotYmat, dotCoordsAll)

# Close the window
win.close()
core.quit()
