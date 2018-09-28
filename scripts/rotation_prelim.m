d62e38 = matfile('../Experiments/Data_nobak/Rotation_d715cc-1_merge.mat');
%%
fs = d62e38.Fs;
time_res = 0.05;
%%
dt = 1/fs;
binsize = round(fs*time_res);
chancount = size(d62e38, 'wavedata', 2);
inputlength = max(size(d62e38, 'wavedata'));
truncateby = mod(inputlength, binsize);
t = (binsize*dt/2):(binsize*dt):((inputlength-truncateby)*dt);
hg = nan(length(t), chancount);
%%
for i = 1:chancount
    disp(num2str(i))
    tsoi = d62e38.wavedata(:, i);
    tsoi = notch(tsoi, [60 120 180], fs, 4);
    p = hilbAmp(tsoi, [70 200], fs);
    p = glove_smooth(p, fs, 0.2, 20);
    hg(:, i) = binevery(p, binsize);
end
% [p, f, t] = morletprocess(d62e38, d62e38.Fs, 0.050, false, 'wavedata');
%%
fileID = fopen('C:\Users\James\Desktop\coordinatepilot_behavioral\data_processed\d715cc_d5.csv', 'r');
dataArray = textscan(fileID, '%f%f%f%f%f%f%f%f%f%s%s%[^\n\r]', 'Delimiter', ',', 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);
dataArray([1, 2, 3, 4, 5, 6, 7, 8,  9]) = cellfun(@(x) num2cell(x), dataArray([1, 2, 3, 4, 5, 6, 7, 8, 9]), 'UniformOutput', false);
behaviordat = [dataArray{1:end-1}];
clear dataArray
load('C:\Users\James\Desktop\coordinatepilot_behavioral\scripts\pickuplocs.mat');
load('../Experiments/Data_nobak/Rotation_d715cc-1_merge.mat', 'tactdata');
%%
time_oi = 30:(length(hg)-30);
hg_norm = unity(hg, false, true);
[ position, controlVel, controlPol, error, rotation, runnum ] = behavior( behaviordat, pickuplocs, tactdata(:, 1), fs );
position = binevery(position, binsize);
controlVel = binevery(controlVel, binsize);
controlPol = binevery(controlPol, binsize);
error.angle = binevery(error.angle, binsize);
rotation = binevery(rotation, binsize, 'mode');
% runnum = binevery(runnum, binsize, 'mode');
%%
% hg_norm = [hg_norm(:, 113:128) hg_norm(:, 1:112)];
hg_norm = hg_norm(time_oi, :);
position = position(time_oi, :);
controlVel = controlVel(time_oi, :);
controlPol = controlPol(time_oi, :);
error.angle = error.angle(time_oi, :);
rotation = rotation(time_oi, :);
%%
chtable = table;
for ch =1:128
    tbl = table(controlPol(:, 1), abs(error.angle), rotation, hg_norm(:, ch), 'VariableNames', {'ControlMag', 'Error', 'Rotation', 'HG'});
    lm = fitlm(tbl, 'HG ~ 1+ControlMag+Error+Rotation+Rotation*Error');
    tablerow = lm.Coefficients(4, :);
    tablerow.Properties.RowNames = { num2str(ch) };
    chtable = [chtable; tablerow];
end