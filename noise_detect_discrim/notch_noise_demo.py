import numpy as np
import matplotlib.pyplot as plt

def make_notch_filtered_noise(noise, center_freq, octaves, notch):
    """
    Make a 1-D rectangular notch filtered noise.

    :param noise: Input noise signal.
    :param center_freq: Center frequency for the notch filter.
    :param octaves: Octave range for the filter.
    :param notch: Tuple indicating the start and end of the notch.
    :return: Notch filtered noise signal.
    """
    # Get noise size
    sz = noise.shape[0]

    # Compute low and high cutoffs
    low = int(np.floor(center_freq / (2 ** (octaves / 2))))
    high = int(np.ceil(center_freq * (2 ** (octaves / 2))))

    # Check bounds low & high
    if low < 1:
        raise ValueError(f"Low pass cut-off < 1. Low = {low}.")
    if high * 2 > sz:
        raise ValueError(f"High pass cut-off < {sz}.")

    # Take the FFT
    noise_fft = np.fft.fft(noise)

    # Calculate the amplitude spectrum
    amplitude_spectrum = np.abs(noise_fft)

     # Make notch filter
    rect_filt = np.ones(sz)
    rect_filt[low:notch[0]] = 0
    rect_filt[notch[1]:high] = 0
    # Mirror the filter for negative frequencies
    if notch[0] != 0:
        rect_filt[-notch[0]:-low] = 0
    if notch[1] != sz // 2:
        rect_filt[-high:-notch[1]] = 0

    # Apply the notch filter to the amplitude spectrum
    filtered_amplitude_spectrum = amplitude_spectrum * rect_filt
    filtered_noise_fft = filtered_amplitude_spectrum * np.exp(1j * np.angle(noise_fft))

    # Return the inverse FFT of the filtered signal
    return np.real(np.fft.ifft(filtered_noise_fft))

def make_box_filtered_noise(noise, center_freq, octaves, notch):
    """
    Make a 1-D rectangular box filtered noise.

    :param noise: Input noise signal.
    :param center_freq: Center frequency for the box filter.
    :param octaves: Octave range for the filter.
    :param notch: Tuple indicating the start and end of the box.
    :return: Notch filtered noise signal.
    """
    # Get noise size
    sz = noise.shape[0]

    # Compute low and high cutoffs
    low = int(np.floor(center_freq / (2 ** (octaves / 2))))
    high = int(np.ceil(center_freq * (2 ** (octaves / 2))))

    # Check bounds low & high
    if low < 1:
        raise ValueError(f"Low pass cut-off < 1. Low = {low}.")
    if high * 2 > sz:
        raise ValueError(f"High pass cut-off < {sz}.")

    # Take the FFT
    noise_fft = np.fft.fft(noise)

    # Calculate the amplitude spectrum
    amplitude_spectrum = np.abs(noise_fft)

     # Make notch filter
    rect_filt = np.zeros(sz)
    rect_filt[low:notch[0]] = 1
    rect_filt[notch[1]:high] = 1
    # Mirror the filter for negative frequencies
    if notch[0] != 0:
        rect_filt[-notch[0]:-low] = 1
    if notch[1] != sz // 2:
        rect_filt[-high:-notch[1]] = 1

    # Apply the notch filter to the amplitude spectrum
    filtered_amplitude_spectrum = amplitude_spectrum * rect_filt
    filtered_noise_fft = filtered_amplitude_spectrum * np.exp(1j * np.angle(noise_fft))

    # Return the inverse FFT of the filtered signal
    return np.real(np.fft.ifft(filtered_noise_fft))

def generate_gaussian_white_noise(length):
    """
    Generate Gaussian white noise.

    :param length: The length of the noise array.
    :return: 1D array of Gaussian white noise.
    """
    return np.random.normal(0, 1, length)

def normalize_contrast(data):
    """
    Normalize the contrast of the data to the range [0, 1].

    :param data: The data to be normalized.
    :return: Normalized data.
    """
    data_min = data.min()
    data_max = data.max()
    return (data - data_min) / (data_max - data_min)

def plot_spectrum(noise, title, c_bar = False):
    """
    Plot the amplitude spectrum of the noise.

    :param noise: The noise signal.
    :param title: Title for the plot.
    """
    # Compute the amplitude spectrum
    spectrum = np.abs(np.fft.fftshift(np.fft.fft(noise)))

    # Convert the 1D spectrum to a 2D representation
    spectrum_2d = np.tile(spectrum, (len(noise), 1))

    # Plot the spectrum
    plt.imshow(np.log(spectrum_2d + 1), cmap='gray')
    plt.title(title)
    if c_bar:
        plt.colorbar()

# Generate 1D Gaussian white noise
length = 512  # Length of the noise array
noise_1d = generate_gaussian_white_noise(length)

# Convert to 2D
noise_2d = np.tile(noise_1d, (length, 1))

# Apply notch filter
center_freq =  8 #length // 4
octaves = 6
notch = (center_freq // 2, 3 * center_freq // 2)
filtered_noise_1d = make_box_filtered_noise(noise_1d, center_freq, octaves, notch)
print(filtered_noise_1d)

filtered_noise_1d = normalize_contrast(filtered_noise_1d)
filtered_noise_2d = np.tile(filtered_noise_1d, (length, 1))

# Plotting
plt.figure(figsize=(12, 10))

# Original and filtered noise images
plt.subplot(2, 2, 1)
plt.imshow(noise_2d, cmap='gray')
plt.title("Original 2D Gaussian White Noise")

plt.subplot(2, 2, 2)
plt.imshow(filtered_noise_2d, cmap='gray')
plt.title("Filtered Noise")

# Amplitude spectra
plt.subplot(2, 2, 3)
plot_spectrum(noise_1d, "Amplitude Spectrum of Original Noise")

plt.subplot(2, 2, 4)
plot_spectrum(filtered_noise_1d, "Amplitude Spectrum of Filtered Noise")

plt.tight_layout()
plt.show()