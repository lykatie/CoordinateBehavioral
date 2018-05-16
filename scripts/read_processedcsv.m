%Main: Visuomotor Behavior Quantification Analysis 
%Extracts and stores data from all partcipants
%Analyzes user's quality performance w/ following quantification methods:
%   -Target execution by target angle error 
%   -Playing duration (total and each run)
%   -Straight vs corner path performance ( angle error and time?)
%   --------------add other methods----------

% List all available data, one .csv per session*subject
filelist = dir('data_processed/*.csv');
% Load the canonical list of where the targets are
load('pickuplocs.mat');
% Start an empty struct: this is where the results of the data processing
% go, into errorresult
% errorresult.
errorresult = struct();
for i = 1:numel(filelist)
    errorresult(i).name = filelist(i).name;
    filename = ['data_processed/' filelist(i).name];
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, '%f%f%f%f%f%f%f%f%f%s%s%[^\n\r]', 'Delimiter', ',', 'EmptyValue' ,NaN, 'ReturnOnError', false);
    fclose(fileID);
    
    %Convert the 2-layer cell type from textscan into a one-layer cell and
    %trim the last column. Still cells but note that columns 10 and 11 are
    %NOT continuous - most are empty
    dataArray([1, 2, 3, 4, 5, 6, 7, 8, 9]) = cellfun(@(x) num2cell(x), dataArray([1, 2, 3, 4, 5, 6, 7, 8, 9]), 'UniformOutput', false);
    behaviordat = [dataArray{1:end-1}];
    
    %Extracts user's total playing behavior(sync to tdt axes)
    [position, controlVel, controlPol, error, rotation, runnum, tdtclock] = behavior(behaviordat, pickuplocs);
    
    %Quantification Methods
    [~, ~, errorresult(i).runerror, errorresult(i).meanerror, errorresult(i).sderror] = summaryerror(error, rotation, runnum);
    %add playing duration
%     [total, rest, play] = summaryPlaytime(tdtclock, controlPol);
    %add straight/corner

    
end
% clearvars filename fileID dataArray ans;
% save('T113318behav', 'T113318behav');