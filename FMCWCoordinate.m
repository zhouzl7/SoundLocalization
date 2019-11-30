%% analyze sound
soundFile = '.\sound\received.wav';
[data_signal, fs] = audioread(soundFile);
data_signal = data_signal(:,1);

%% distance to speaker1
begin_frequency1 = 2000;
end_frequency1 = 4000;
startDistance1 = 0.25; % the distance between start point and speaker1
offset1 = 20;
distance1 = FMCWDistance(data_signal, begin_frequency1, end_frequency1, fs, startDistance1, offset1);

%% distance to speaker2
begin_frequency2 = 6000;
end_frequency2 = 8000;
rstartDistance2 = 0.25; % the distance between start point and speaker2
offset2 = 100;
distance2 = FMCWDistance(data_signal, begin_frequency2, end_frequency2, fs, rstartDistance2, offset2);

%% calculate the coordinate
len = length(distance1);
if len > length(distance2)
    len = length(distance2);
end
corX = [];
corY = [];
for i = 1 : len
    r1 = distance1(i);
    r2 = distance2(i);
    a1 = 0; b1 = 0; a2 = 0.5; b2 = 0;
    syms x y;
    [x,y] = solve((x-a1)^2+(y-b1)^2-r1^2,(x-a2)^2+(y-b2)^2-r2^2);
    if length(x) >= 1
        corX = [corX, x(1)];
        corY = [corY, abs(y(1))];
    end
end

figure;
plot(0, 0, 'or', 0.5, 0, 'or', corX, corY, '*-.');
xlabel('x(m)');
ylabel('y(m)');

