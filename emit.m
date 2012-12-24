%%  Generate Tones
%   emit.m
%
%   This is the synthesis / emitting prototype matlab script
%
%

%input_string must be capital letters or numbers
input_string = 'H3LL0W0R1D';
input_binary = encodeEmit(input_string);

FS = 44100;
WS = 1024;
HWS = WS / 2;
period = FS / WS;
%pulse_time = 0.1;                   % 10 ms
%pulse_samples = pulse_time * FS;
averaging_windows = 8;
pulse_samples = averaging_windows * HWS;  % This is the number of STFT frames per pulse

freq_vec = (1:period:FS);
freq_range = (420:10:460);          % This based on the freq range we need

emit_freqs = freq_vec(freq_range);
t  = (1:1:pulse_samples);                           % Time Samples
noise = wgn(1, length(t) * length(input_binary), 0);      % This is the amount of noise in the 'environment'
tones = zeros(5, length(t));

for i=1:5
    tones(i, 1:end) = sin(2 * pi * (emit_freqs(i)/FS) * t);
end

output = zeros(1, length(t) * length(input_binary));

for e=1:length(input_binary)
    for i=1:length(t)
        for j=1:5
            if input_binary(e) == '1'
                output(i + ((e-1) * length(t))) = output(i + ((e-1) * length(t))) + tones(j, i);
            else
                output(i + ((e-1) * length(t))) = 0.0;
            end
        end
    end
end

% This scales the tones and adds the noise 
output = (output ./ 5) + noise;

Y = abs(fft(output, WS));
Y = Y(1:WS/2);
x = linspace(0, FS/2, WS/2);

% figure(1)
% hold on
% plot(x, Y)
% plot(freq_vec(1:10:end/2), 70, 'rx')

%%  Pick Tones
%
%   
%
%

% Take stft
YY = stft(output, WS, HWS);
YY = abs(YY);
num_frames = size(YY,2);
num_hops = floor(num_frames / averaging_windows);

% Threshold
amp_threshold = 30;
band_threshold = 4; %number of bands to confirm pulse


output_binary = '';

K = zeros(5, num_frames);

%loop from 1 to total number of bits transmitted
for i = 1:ceil(num_frames / averaging_windows)
    
    %loop through the hops that make up a bit
    for j = 1:averaging_windows    
        
        %error checking which we wont need later
        index = (i*averaging_windows-averaging_windows) + j;
        if index >= size(YY,2)
            index = size(YY,2);
        end
        
        %Check each frequency of interest against the threshold
        for k = 1:5
            pulse_detected(k,j) = YY(freq_range(k), index) > amp_threshold; 
        end  
    end
    
    %sum across the freqs to verify the discrete pulse
    short_pulse_verified = sum(pulse_detected) >= band_threshold;
   
    %average across the hops to verify a long pulse
    decode = sum(short_pulse_verified) >= averaging_windows / 2;
    
    %update the string accordingly
    if decode == 1;
        output_binary = strcat(output_binary, '1');
    else
        output_binary = strcat(output_binary, '0');
    end
    
end

[output_string, error] = decodeEmit(output_binary);

if strcmp(error,'')
    display(output_string);
else 
    display(error);
end


