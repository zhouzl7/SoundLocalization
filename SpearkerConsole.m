sampling_frequency = 44100;

% begin_frequency1 = 2000;
% end_frequency1 = 4000;
% speaker1 = Speaker(begin_frequency1, end_frequency1);

begin_frequency2 = 6000;
end_frequency2 = 8000;
speaker2 = Speaker(begin_frequency2, end_frequency2);

% generate sound
player = audioplayer(speaker2, sampling_frequency);
playblocking(player);
% soundFile1 = '.\sound\speaker1.wav';
% audiowrite(soundFile1, speaker1, sampling_frequency, 'BitsPerSample', 16);
% 
% soundFile2 = '.\sound\speaker2.wav';
% audiowrite(soundFile2, speaker2, sampling_frequency, 'BitsPerSample', 16);