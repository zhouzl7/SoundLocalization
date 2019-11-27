sampling_frequency = 48000;
clip_time = 0.04;
clip_length = sampling_frequency * clip_time + 1;
begin_frequency = 18000;
end_frequency = 20500;
offset_frequency = 100;
sampling_point = 0: 1 / sampling_frequency: clip_time;
wave_speed = 340;
single_chirp = chirp(sampling_point, begin_frequency, clip_time, end_frequency, 'linear');
clip = [single_chirp, zeros(1, clip_length)];
%% analyze sound
soundFile = 'received.wav';
[data_signal, fs] = audioread(soundFile);
data_signal = data_signal(:, 1)';
data_signal = BPassFilter(data_signal, begin_frequency - offset_frequency, end_frequency + offset_frequency, fs);

start = length(data_signal);
while true
    [correlation, lag] = xcorr(data_signal(1: start), single_chirp);
    [max_corr, index] = max(correlation);
    if max_corr < 1
        break
    end
    start = lag(index);
end

if start <= 0
    start = 1;
end
data_signal = data_signal(start: end);
clip_count = ceil(length(data_signal) / clip_length / 2);
data_signal(end + 1: clip_count * clip_length * 2) = 0;
pseudo_signal = repmat(clip, 1, clip_count);


figure(1);
subplot(2, 1, 1);
plot(data_signal);
xlabel('#');
ylabel('received signal');
subplot(2, 1, 2);
plot(pseudo_signal);
xlabel('#');
ylabel('pseudo_signal');

resolution = 0.01;
fft_length = round(sampling_frequency * (end_frequency - begin_frequency) * resolution / wave_speed / clip_time);
s = pseudo_signal .* data_signal;
indexes = zeros(clip_count, 1);
for i = 1: 2 * clip_length: 1 + 2 * clip_length * (clip_count - 1)
   spectrum = abs(fft(s(i: i + clip_length), fft_length));
   [~, index] = max(abs(spectrum(1: round(fft_length / 10))));
   indexes(round((i - 1) / clip_length / 2) + 1) = index;
end
measured_distance = indexes * fs / fft_length * wave_speed * clip_time / (end_frequency - begin_frequency);

figure(2);
plot((0: (clip_count - 1)) * 2 * clip_time, measured_distance);
xlabel('#');
ylabel('measured distance');