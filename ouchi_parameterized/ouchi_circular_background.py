from psychopy import visual, event, core
import numpy as np

def generate_checker_pattern_with_patch(
    num_strips=20, size=512, color1=[-1, -1, -1], color2=[1, 1, 1],
    orientation=0, patch_radius=100, patch_orientation=90,
    patch_color1=[-1, -1, -1], patch_color2=[1, 1, 1]
):
    """
    Generate a checkerboard-like pattern with a central circular patch and a circular mask for the background.

    Parameters:
    -----------
    num_strips : int
        Number of strips to divide the image into (default=20).
    size : int
        Size of the resulting square image in pixels (default=512).
    color1 : list of float
        The "black" color for the main pattern (in PsychoPy color space).
    color2 : list of float
        The "white" color for the main pattern.
    orientation : float
        Orientation of the main pattern in degrees (default=0).
    patch_radius : int
        Radius of the central circular patch in pixels (default=100).
    patch_orientation : float
        Orientation of the circular patch in degrees (default=90).
    patch_color1 : list of float
        The "black" color for the patch (default matches main pattern).
    patch_color2 : list of float
        The "white" color for the patch (default matches main pattern).

    Returns:
    --------
    image_arr : np.ndarray
        A 3D NumPy array (size x size x 3) with the pattern.
    """
    # Create the main checkerboard pattern
    image_arr = np.zeros((size, size, 3), dtype=float)
    strip_width = size // num_strips
    cycles_per_strip = 16  # Adjust as needed for square-wave frequency
    segment_height = size // (cycles_per_strip * 2)

    for strip_i in range(num_strips):
        strip_start_x = strip_i * strip_width
        strip_end_x = min((strip_i + 1) * strip_width, size)

        start_with_color1 = (strip_i % 2 == 0)

        for x in range(strip_start_x, strip_end_x):
            for cycle_i in range(cycles_per_strip * 2):
                segment_start_y = cycle_i * segment_height
                segment_end_y = min((cycle_i + 1) * segment_height, size)

                if start_with_color1:
                    current_color = color1 if (cycle_i % 2 == 0) else color2
                else:
                    current_color = color2 if (cycle_i % 2 == 0) else color1

                image_arr[segment_start_y:segment_end_y, x, :] = current_color

    # If orientation is not zero, rotate the entire pattern
    if orientation != 0:
        from scipy.ndimage import rotate
        image_arr = rotate(image_arr, angle=orientation, axes=(1, 0), reshape=False, mode='constant', cval=0)


    # Apply a circular mask to the background
    yy, xx = np.meshgrid(range(size), range(size))
    center = size // 2
    background_circular_mask = (xx - center)**2 + (yy - center)**2 <= (size // 2)**2
    for i in range(3):
        image_arr[..., i] = np.where(background_circular_mask, image_arr[..., i], 0)

    # Generate the circular patch
    circular_patch_mask = (xx - center)**2 + (yy - center)**2 <= patch_radius**2

    # Create the patch pattern
    patch_arr = np.zeros((size, size, 3), dtype=float)
    for strip_i in range(num_strips):
        strip_start_x = strip_i * strip_width
        strip_end_x = min((strip_i + 1) * strip_width, size)

        start_with_color1 = (strip_i % 2 == 0)

        for x in range(strip_start_x, strip_end_x):
            for cycle_i in range(cycles_per_strip * 2):
                segment_start_y = cycle_i * segment_height
                segment_end_y = min((cycle_i + 1) * segment_height, size)

                if start_with_color1:
                    current_color = patch_color1 if (cycle_i % 2 == 0) else patch_color2
                else:
                    current_color = patch_color2 if (cycle_i % 2 == 0) else patch_color1

                patch_arr[segment_start_y:segment_end_y, x, :] = current_color

    # Rotate the patch pattern
    if patch_orientation != 0:
        from scipy.ndimage import rotate
        patch_arr = rotate(patch_arr, angle=patch_orientation, axes=(1, 0), reshape=False, mode='constant', cval=0)

    # Blend the patch into the main pattern using the circular patch mask
    for i in range(3):  # Iterate over RGB channels
        image_arr[..., i] = np.where(circular_patch_mask, patch_arr[..., i], image_arr[..., i])

    return image_arr

if __name__ == "__main__":
    # Create a PsychoPy window
    win = visual.Window([800, 800], color=[0, 0, 0], units='pix')

    # background contrast paramaters
    bg_contrast_r_1 = 1
    bg_contrast_g_1 = 1
    bg_contrst_b_1 = 1
    bg_contrast_r_2 = 1
    bg_contrast_g_2 = 1
    bg_contrst_b_2 = 1

    # foreground contrast parameters
    fg_contrast_r_1 = 1
    fg_contrast_g_1 = 1
    fg_contrast_b_1 = 1
    fg_contrast_r_2 = 1
    fg_contrast_g_2 = 1
    fg_contrast_b_2 = 1
  
    # Generate the checkerboard pattern with a circular patch
    pattern = generate_checker_pattern_with_patch(
        num_strips= 128,
        size=512,
        color1=[-1*bg_contrast_r_1, -1*bg_contrast_g_1, -1*bg_contrst_b_1],  # Black
        color2=[1*bg_contrast_r_2, 1*bg_contrast_g_2, 1*bg_contrst_b_2],  # Black
        orientation=45,        # Vertical
        patch_radius=100,     # Circular patch radius
        patch_orientation=-60, # Orthogonal orientation
        patch_color1=[-1*fg_contrast_r_1, -1*fg_contrast_g_1, -1*fg_contrast_b_1],
        patch_color2=[1*fg_contrast_r_2, 1*fg_contrast_g_2, 1*fg_contrast_b_2]
    )


    # Create an ImageStim from the pattern
    stim = visual.ImageStim(win, image=pattern, size=(512, 512))

    # Draw and show
    stim.draw()
    win.flip()

    # Wait for a key press to close
    event.waitKeys()
    win.close()
    core.quit()
