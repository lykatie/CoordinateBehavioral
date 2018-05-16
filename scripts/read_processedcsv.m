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

%%
%Store total runerror sum 
orientation = [0 45 90 180];
for i = 1:numel(filelist)
    total = zeros(length(orientation), 3); %4x3 matrix
    for j =1:numel(orientation)
        mask = logical(zeros(length(errorresult(i).runerror),1));
        mask = errorresult(i).runerror(:,3) == orientation(j);
        total(j, 1) = sum(errorresult(i).runerror(mask,1));
        total(j, 2) = sum(errorresult(i).runerror(mask,2));
        total(:,3) = orientation;
    end
    errorresult(i).runerror_total = total;
end



%stores all errorangle sums for each orientation and each file
% [25(files), 2(error angles), 4(orientations)]
file_sum = zeros(numel(filelist),2,length(orientation)); 
for i=1:size(file_sum,1)
    for j=1:size(file_sum, 2)
        for k=1:size(file_sum,3)
            file_sum(i,j,k) = errorresult(i).runerror_total(k,j);
        end
    end
end

%mean/stdev of all files by orientation
errmean = zeros(length(orientation), 3);
errstdev = zeros(size(errmean));
for i=1:size(errmean,1)
    for j=1:size(errmean,2)-1
        errmean(i,j) = mean(file_sum(:,j,i));
        errstdev(i,j) = std(file_sum(:,j,i));
    end
end

%plot
figure;
errorbar(orientation, errmean(:,1), errstdev(:,1), 'o-')
hold on
errorbar(orientation, errmean(:,2), errstdev(:,2), 'ro-')

    






