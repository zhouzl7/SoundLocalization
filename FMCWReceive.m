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

chirp_u_length = 1024;
chirp_u_time = chirp_u_length / sampling_frequency;
chirp_u_begin_frequency = 200;
chirp_u_end_frequency = 600;
signal_u_chirp = chirp(0: 1 / sampling_frequency: chirp_u_time, chirp_u_begin_frequency, chirp_u_time, chirp_u_end_frequency);

%% analyze sound
soundFile = 'fmcw_receive.wav';
[data_signal, fs] = audioread(soundFile);
data_signal = data_signal(:,1);

band_pass = design(fdesign.bandpass('N,F3dB1,F3dB2', 6, begin_frequency-1000, end_frequency+2000, fs), 'butter');
data_signal = filter(band_pass, data_signal);
data_signal = data_signal';

pseudo_signal = [];
for i = 1: clip_count
    pseudo_signal = [pseudo_signal, clip];
end


% start = 38750;
[C, lag] = xcorr(data_signal, single_chirp);
[M, I] = max(C);
begin = lag(I);
start = begin;
while abs(M) >= 1
    start = begin;
    [C, lag] = xcorr(data_signal(1:begin), single_chirp);
    [M, I] = max(C);
    begin = lag(I);
end

if start <= 0
    start = 1;
end

n = length(data_signal);
pseudo_signal = [zeros(1, start), pseudo_signal];
m = length(pseudo_signal);
if n > m
    pseudo_signal = [pseudo_signal, zeros(1, n-m)];
else
    pseudo_signal = pseudo_signal(1:n);
end

figure(1);
subplot(2, 1, 1);
plot(data_signal);
xlabel('#');
ylabel('received signal');
subplot(2, 1, 2);
plot(pseudo_signal);
xlabel('#');
ylabel('pseudo_signal');


fftlen = 1024*64;
s = pseudo_signal .* data_signal;
indexes = zeros(clip_count, 1);
a = 0;
for i = start: 2 * clip_length: start + 2 * clip_length * (clip_count - 1)
   spectrum = abs(fft(s(i: i + clip_length), fftlen));
   [~, index] = max(abs(spectrum(1: round(fftlen / 10))));
   indexes(round((i-start) / (clip_length*2)) + 1) = index;
end

start_index = 0;
measured_distance = (indexes-start_index) * fs / fftlen * wave_speed * clip_time / (end_frequency - begin_frequency);

figure(2);
plot((0:(clip_count-1))*2*clip_time, measured_distance);
xlabel('#');
ylabel('measured distance');