%%
% Exercise 1 : Demodulating the signal using the in-phase data.

fs = 300e3; % This is the sample rate (in Hz)
fc = 90.8e6; % This is the center frequency (offset by 100 kHz). 
x = zeros(3e6,1); % Empty vector to store the collected data in.

% Receiver code adapted from RTL-SDR receiver starter code. 
% Captures signals from the device.
% create object for RTL-SDR receiver
rx = comm.SDRRTLReceiver('CenterFrequency',fc, 'EnableTunerAGC', false, 'TunerGain', 35,  'SampleRate', fs);

counter = 1; % initialize a counter
while(counter < length(x)) % while the buffer for data is not full
    rxdata = rx();   % read from the RTL-SDR
    x(counter:counter + length(rxdata)-1) = rxdata; % save the samples returned
    counter = counter + length(rxdata); % increment counter
end
% the data are returned as complex numbers
% separate real and imaginary part, and remove any DC offset
y_I = real(x)-mean(real(x));
y_Q = imag(x)-mean(imag(x));

%%
% Part c : Plot the Fourier Transform of the received signal. 
plot_FT(y_I, fs);

%%
% Part d : Plot the time response.

plot((1:10000), y_I(1:10000))
xlabel('Sample');
ylabel('Amplitude');
title('Zoom-In Showing Frequency Modulations of Sampled Data')
%%
% Part e : Plot the derivative.
derivative_signal = diff(y_I(1:10001));
positive_signal = derivative_signal(derivative_signal > 0);
normalized_signal = (positive_signal - min(positive_signal))./(max(positive_signal) - min(positive_signal));
plot((1:size(normalized_signal)), normalized_signal);

%% 
% Part f : Low-pass filter the signal
cutoff_frequency = 40000;
h = sinc(((cutoff_frequency)./pi) .* (-50:49));
filtered_signal = conv(normalized_signal, h);
normalized_filtered_signal = (filtered_signal - min(filtered_signal))./(max(filtered_signal) - min(filtered_signal));
plot((1:size(filtered_signal)), filtered_signal);