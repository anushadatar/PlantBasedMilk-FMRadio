%% ADC FM Lab Exercise 2 : Demodulating the signal using I-Q data.

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
% The data are returned as complex numbers.
% Separate real and imaginary part, and remove any DC offset.
y_I = real(x)-mean(real(x));
y_Q = imag(x)-mean(imag(x));

%% Decode the IQ data based on the equation in part a.
cutoff = 100000;
message = (diff(y_Q).*y_I(1:size(y_I)-1)) - (diff(y_I).*y_Q(1:size(y_I)-1));
mean_sub_message = message - 2.5.*mean(message); % Center the data from the message.
% Follow the same normalization procedure from the first exercise. 
norm_sub_message = 0.1.*(mean_sub_message - min(mean_sub_message)) ./ (max(mean_sub_message) - min(mean_sub_message));
decimate_message = decimate(norm_sub_message, 4); 
plot_FT(decimate_message, fs./4);
%% Play the sound of the decoded message.
sound(decimate_message, fs./4)