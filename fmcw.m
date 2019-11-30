%% 发送信号生成
fs = 44100;
T = 0.04;
f0 = 2000; % start freq
f1 = 4000; % end freq
t = 0:1/fs:T;
data = chirp(t, f0, T, f1, 'linear');
output = [];
clip_count = 160;
for i = 1:clip_count
    output = [output, data, zeros(1,1921)];
end

%% 接收信号读取，并滤波
[mydata,fs] = audioread('.\sound\received.wav');
mydata = mydata(:,1);

hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6,1000,5000,fs),'butter');
mydata = filter(hd,mydata);
figure;
subplot(2, 1, 1);
plot(mydata);

%% 生成pseudo-transmitted信号
pseudo_T = [];
for i = 1:clip_count
    pseudo_T = [pseudo_T,data,zeros(1,T*fs+1)];
end

% fmcw信号的起始位置在start处
% 若start有偏差会造成什么影响？
[C, lag] = xcorr(mydata, data);
[M, I] = max(C);
begin = lag(I);
start = begin;
while abs(M) >= 2
    start = begin;
    [C, lag] = xcorr(mydata(1:begin), data);
    [M, I] = max(C);
    begin = lag(I);
end


start = start-100;

if start <= 0
    start = 1;
end
pseudo_T = [zeros(1,start),pseudo_T];
[n,~] = size(mydata);
[~,m] = size(pseudo_T);
pseudo_T = [pseudo_T,zeros(1,n-m)];
subplot(2, 1, 2);
plot(pseudo_T);

s = pseudo_T.*mydata';

len = (T*fs+1)*2; % chirp信号及其后空白的长度之和
% 做快速傅里叶变换时补零的长度。
% 在数据后补零可以使的采样点增多，频率分辨率提高。
% 可以自行尝试不同的补零长度对于计算结果的影响。
fftlen = 1024*64;

%% 计算每个chirp信号所对应的频率偏移
idxs = zeros(clip_count, 1);
for i = start:len:start+len*(clip_count-1)
    FFT_out = abs(fft(s(i:i+len/2),fftlen));
    [~, idx] = max(abs(FFT_out(1:round(fftlen/2))));
    idxs(round((i-start)/len)+1) = idx;
end

%% 依据频率差公式计算出距离
start_idx = idxs(6);
delta_distance = (idxs-start_idx)*fs/fftlen*340*T/(f1-f0);
delta_distance = delta_distance(6:end-5);
%     measured_distance = smooth(measured_distance);
% delta_distance = movmedian(delta_distance, 20);

%% 画出距离的变化
figure;
plot((0:clip_count-11)*2*T, delta_distance);
xlabel('time (s)', 'FontSize', 18);
ylabel('distance (m)', 'FontSize', 18);