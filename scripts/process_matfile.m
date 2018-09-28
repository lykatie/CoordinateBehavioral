filelist = dir('data_neural/*.csv.mat');
for i = 1:numel(filelist)
    neuraldataname = ['data_neural/' filelist(i).name];
    matfilein = matfile(neuraldataname);
    %%
    fs = matfilein.Fs;
    time_res = 0.05;
    %%
    dt = 1/fs;
    binsize = round(fs*time_res);
    chancount = size(matfilein, 'wavedata', 2);
    inputlength = max(size(matfilein, 'wavedata'));
    truncateby = mod(inputlength, binsize);
    t = (binsize*dt/2):(binsize*dt):((inputlength-truncateby)*dt);
    hg = nan(length(t), chancount);
    %%
    for i = 1:chancount
        disp(num2str(i))
        tsoi = matfilein.wavedata(:, i);
        tsoi = notch(tsoi, [60 120 180], fs, 4);
        p = hilbAmp(tsoi, [70 200], fs);
        p = glove_smooth(p, fs, 0.2, 20);
        hg(:, i) = binevery(p, binsize);
    end

    save(['data_neural/' filelist(i).name '.hg.mat'], 'hg')

end