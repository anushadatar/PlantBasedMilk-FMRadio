%% ADC FM Lab Exercise 1 : Demodulating the signal using the in-phase data.

%% Set the center and sampling frequencies. 
fs = 300e3; % This is the sample rate (in Hz).
fc = 90.8e6; % This is the center frequency (offset by 100 kHz). 

%% Collect data using the radio receiver!

% Leveraged RTL-SDR MATLAB starter code provided with lab.
x = zeros(3e6,1); % Empty vector to store the collected data in.
% Receiver code adapted from RTL-SDR receiver starter code. 
% Captures signals from the device.
% create object for RTL-SDR receiver
rx = comm.SDRRTLReceiver('CenterFrequency',fc, 'EnableTunerAGC', false, 'TunerGain', 35,  'SampleRate', fs);
counter = 1; % initialize a counter
while(counter < length(x)) % while the buffer for data is not full.
    rxdata = rx();   % read from the RTL-SDR
    x(counter:counter + length(rxdata)-1) = rxdata; % save the samples returned
    counter = counter + length(rxdata); % increment counter
end
% the data are returned as complex numbers
% separate real and imaginary part, and remove any DC offset
y_I = real(x)-mean(real(x));
y_Q = imag(x)-mean(imag(x));

%% Plot the Fourier Transform of the received signal. 
plot_FT(y_I, fs);

%% Plot the time response.
plot((1:10000), y_I(1:10000))
xlabel('Sample');
ylabel('Amplitude');
title('Zoom-In Showing Frequency Modulations of Sampled Data')
%% Plot the signal after normalizing the positive portions of the derivative.
diff_signal = diff(y_I);
pos_signal = diff_signal(diff_signal > 0);
norm_signal = (pos_signal - min(pos_signal)) ./ (max(pos_signal) - min(pos_signal));
plot((1:size(norm_signal)), norm_signal)
ylim([0 1])

%% Low-pass filter the signal.
cutoff = 100000;
[h, d] = lowpass(norm_signal, 1./cutoff, fs);
filt_signal = conv(norm_signal, sinc((cutoff./pi) .* (-50:49)));
%filt_signal = filter(d, norm_signal);
norm_filt_signal = (filt_signal - min(filt_signal)) ./ (max(filt_signal) - min(filt_signal));
mean_sub_signal = norm_filt_signal - 2.5.*mean(norm_filt_signal);
norm_sub_signal = 0.1.*(mean_sub_signal - min(mean_sub_signal)) ./ (max(mean_sub_signal) - min(mean_sub_signal));
decimate_signal = decimate(norm_sub_signal, 4);

%% Plot the Fourier transform of the final signal.
plot_FT(decimate_signal, fs./9);

%% Play the decoded received sound! 
sound(decimate_signal, fs./9);