filelist = dir('data_processed/*.csv');
load('pickuplocs.mat');
errorresult = struct();
for i = 1:numel(filelist)
    errorresult(i).name = filelist(i).name;
    filename = ['data_processed/' filelist(i).name];
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, '%f%f%f%f%f%f%f%f%f%s%s%[^\n\r]', 'Delimiter', ',', 'EmptyValue' ,NaN, 'ReturnOnError', false);
    fclose(fileID);
    dataArray([1, 2, 3, 4, 5, 6, 7, 8, 9]) = cellfun(@(x) num2cell(x), dataArray([1, 2, 3, 4, 5, 6, 7, 8, 9]), 'UniformOutput', false);
    behaviordat = [dataArray{1:end-1}];
    [position, controlVel, controlPol, error, rotation, runnum] = behavior(behaviordat, pickuplocs);
    [errorresult(i).error, errorresult(i).errornorm] = summaryerror(error, rotation, runnum);
end
% clearvars filename fileID dataArray ans;
% save('T113318behav', 'T113318behav');