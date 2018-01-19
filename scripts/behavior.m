function [ position, controlVel, controlPol, rotation, runnum ] = behavior( behaviorcells )
%BEHAVIOR Summary of this function goes here
%   Detailed explanation goes here
%COMPUTE_BUTNALIGN Summary of this function goes here
%   Detailed explanation goes here
    col.time = 1;
    col.pos = [2 4];
    col.vel = [5 6];
    col.button = 10;
    col.pickup = 11;

    unity_struct = unitycsvextract(behaviorcells, col);
    position = cell2mat(behaviorcells(:, col.pos));
    controlVel = cell2mat(behaviorcells(:, col.vel));

    rotationraw = unity_struct.events(:, 1);
    
    rotation = rotationraw;
    rotation(rotation >= 2000 | rotation < 1000) = 0;
    rotation = rotation - 1000;
    rotation(1) = 0;
    
    runnum = zeros(size(rotationraw));
    runnum(1) = 1;

    for i = 2:length(rotationraw)
        if(rotation(i) == -1000)
            rotation(i) = rotation(i-1);
        end
        if(rotationraw(i) == 2000)
            runnum(i) = runnum(i-1)+1;
        else
            runnum(i) = runnum(i-1);
        end
    end

    controlPol = nan(size(controlVel));
    [controlPol(:, 1), controlPol(:, 2)] = ...
        cart2pol(controlVel(:, 1), controlVel(:, 2));
    
    
end

