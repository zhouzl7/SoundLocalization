%% generate transmit signal
sampling_frequency = 48000;
clip_time = 0.04;
clip_length = sampling_frequency * clip_time + 1;
begin_frequency = 18000;
end_frequency = 20500;
sampling_point = 0: 1 / sampling_frequency: clip_time;
wave_speed = 340;
single_chirp = chirp(sampling_point, begin_frequency, clip_time, end_frequency, 'linear');
clip = [single_chirp, zeros(1, clip_length)];
clip_count = 88;
output = [];
for i = 1 : clip_count
    output = [output clip];
end
% generate sound
soundFile = 'output.wav';
audiowrite(soundFile, output, sampling_frequency, 'BitsPerSample', 16);