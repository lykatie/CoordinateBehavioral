function [ position, controlVel, errorStruct, rotation ] = behavior( behaviorcells )
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
    rotationraw(rotationraw >= 2000 | rotationraw < 1000) = 0;
    rotationraw = rotationraw - 1000;
    rotationraw(1) = 0;
    for i = 2:length(rotationraw)
        if(rotationraw(i) == -1000)
            rotationraw(i) = rotationraw(i-1);
        end
    end
    rotation = rotationraw;

    errorStruct = struct();
end

