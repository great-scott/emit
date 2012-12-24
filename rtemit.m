%%
%
%	rtemit.m 
%	"real-time" implementation of emit reception
%	
%
%

% callback blocksize
% this should be 1/2 the analysis window size which also equals the hop size	
window_size = 1024;
cb_size = window_size / 2;
hop_size = cb_size;
averaging_window = 8;

% Threshold
amp_threshold = 30;
band_threshold = 4; %number of bands to confirm pulse

freq_vec = (1:period:FS);
freq_range = (420:10:460);          % This based on the freq range we need
emit_freqs = freq_vec(freq_range);

% header detected (gather information)




% assume information received and no errors
prev_frame = zeros(window_size, 1); 	% previous fft frame (for detection, ignore)
curr_frame = zeros(window_size, 1); 	% current fft analysis frame
sig_frame = zeros(window_size, 1);		% signal frame
window = hann(window_size);				% hann window

counter = 0;  				% counter (necessary for matlab implementation)
ending = length(output);	% the end of the emission (will be # frames / bits known from header)
num_frames_counted = 1;		% this keeps track of the number of frames we've counted so far (+1 for matlab indices)
pulse_buffer = zeros(averaging_window, 1);
pulse_detect = zeros(length(emit_freqs), 1);

output_binary = '';			% our binary string

% main processing loop each loop through represents an audio callback
% this loops simulates being called every hop_size samples
while counter <= ending
	% shift previous hop_size # samples from back to front
	sig_frame(1:hop_size) = sig_frame((hop_size + 1):end);
	% add in new samples
	end_bound = counter + hop_size;
	if end_bound <= ending
		sig_frame((hop_size + 1):end) = output((counter + 1):end_bound);
	end

	% window
    for i = 1:window_size
		curr_frame(i) = sig_frame(i) * window(i);
    end
	% fft and magnitude
	curr_frame = abs(fft(curr_frame, window_size));

	% loop through and check if freqs over threshold
	for i = 1:length(emit_freqs)
		pulse_detect(i) = curr_frame(freq_range(i)) > amp_threshold;
	end

	if sum(pulse_detect) >= band_threshold
		pulse_buffer(num_frames_counted) = 1;
	else
		pulse_buffer(num_frames_counted) = 0;
	end

	% increment counter values 
	num_frames_counted = num_frames_counted + 1;
	counter = counter + hop_size;
	% reset pulse_buffer one it's over the averaging_window amount
	if num_frames_counted > averaging_window
		decode = sum(pulse_buffer) >= averaging_windows / 2;

		%update the string accordingly
    	if decode == 1;
        	output_binary = strcat(output_binary, '1');
    	else
        	output_binary = strcat(output_binary, '0');
    	end

		pulse_buffer(1:end) = 0;
		num_frames_counted = 1;
	end

end

[output_string, error] = decodeEmit(output_binary);

if strcmp(error,'')
    display(output_string);
else 
    display(error);
end


