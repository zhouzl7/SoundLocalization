sampling_frequency = 44100;

begin_frequency1 = 16000;
end_frequency1 = 18500;
speaker1 = Speaker(begin_frequency1,end_frequency1);

begin_frequency2 = 6000;
end_frequency2 = 8500;
speaker2 = Speaker(begin_frequency2,end_frequency2);

% generate sound
soundFile1 = 'speaker1.wav';
audiowrite(soundFile1, speaker1, sampling_frequency, 'BitsPerSample', 16);

soundFile2 = 'speaker2.wav';
audiowrite(soundFile2, speaker2, sampling_frequency, 'BitsPerSample', 16);