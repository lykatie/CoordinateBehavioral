function [improvement, improvementnorm, runerror] = summaryerror(error, rotation, runnum)
%SUMMARYERROR Summary of this function goes here
%   Detailed explanation goes here
    runlist = unique(runnum);
    runerror = nan(numel(runlist), 2);
    for i = 1:numel(runlist)
        runerror(i, 1) = sum(abs(error.angle(runnum == runlist(i))));
        runerror(i, 2) = mode(rotation(runnum == runlist(i)));
    end
    
    rotlist = [0 45 90 180];
    improvement = nan(numel(rotlist), 1);
    improvementnorm = improvement;
    for i = 1:numel(rotlist)
        rot_oi = rotlist(i);
        run_oi = find(runerror(:, 2) == rot_oi);
        coeffs = polyfit((1:length(run_oi))', runerror(run_oi, 1), 1);
        improvement(i) = coeffs(1);
        improvementnorm(i) = coeffs(1) / coeffs(2);
    end
end

