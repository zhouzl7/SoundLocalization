function measured_distance = FMCWDistance(data_signal, begin_frequency, end_frequency, fs, r0, offset)
    sampling_frequency = 44100;
    clip_time = 0.04;
    clip_length = sampling_frequency * clip_time + 1;
    sampling_point = 0: 1 / sampling_frequency: clip_time;
    wave_speed = 340;
    single_chirp = chirp(sampling_point, begin_frequency, clip_time, end_frequency, 'linear');
    clip = [single_chirp, zeros(1, clip_length)];
    clip_count = 160;
    
    band_pass = design(fdesign.bandpass('N,F3dB1,F3dB2', 6, begin_frequency-1000, end_frequency+1000, fs), 'butter');
    data_signal = filter(band_pass, data_signal);
    data_signal = data_signal';
    
    pseudo_signal = [];
    for i = 1: clip_count
        pseudo_signal = [pseudo_signal, clip];
    end
    
    
    [C, lag] = xcorr(data_signal, single_chirp);
    [M, I] = max(C);
    begin = lag(I);
    start = begin;
    while abs(M) >= 2
        start = begin;
        [C, lag] = xcorr(data_signal(1:begin), single_chirp);
        [M, I] = max(C);
        begin = lag(I);
    end
    
    [C, lag] = xcorr(data_signal(start+clip_length*10-offset:start+clip_length*16), single_chirp);
    [~, I] = max(C);
    begin = lag(I);
    
    start = start + begin;

   start = start - 100;
    
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

    figure;
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
    for i = start: 2 * clip_length: start + 2 * clip_length * (clip_count - 6)
       spectrum = abs(fft(s(i: i + clip_length), fftlen));
       [~, index] = max(abs(spectrum(1: round(fftlen / 10))));
       indexes(round((i-start) / (clip_length*2)) + 1) = index;
    end

    start_index = indexes(6);
%     start_index = 0;
    measured_distance = ((indexes-start_index) * fs / fftlen * wave_speed * clip_time / (end_frequency - begin_frequency)) / 5 + r0;
    measured_distance = measured_distance(6:end-5);
    
    measured_distance = smooth(measured_distance, 5, 'rlowess');
    measured_distance = movmedian(measured_distance, 15);
    
%     measured_distance = smooth(measured_distance);
%     measured_distance = smooth(measured_distance, 10, 'rlowess');
%     measured_distance = smoothdata(measured_distance, 'gaussian', 9);
%     measured_distance = smoothdata(measured_distance, 'includenan');
    figure;
    plot((0:clip_count-11)*2*clip_time, measured_distance);
    xlabel('#');
    ylabel('measured distance(m)');
end

