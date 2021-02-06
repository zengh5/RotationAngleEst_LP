% Splicing localization using rotation angle inconsistency
% Here, both the original and tampered region have been rotated. 
% So we have to estimate the rotation angle block by block.
% This is a different scenario with [1], where the background is assumed
% without rotation.
% [1] M. Goljan, J. Fridrich, M. Kirchner. Image Manipulation Detection Using Sensor Linear Pattern. Electronic Imaging, 2018.
% 
clear, clc
close all
dwtmode('symw')
addpath('Functions')
addpath('Functions\DTCWT')
addpath('Filter')
Step = 128;
Block = 512;
sigma = 0.5;
% Parameters for searching
SearchingRange = [-15 0];
SearchingStep = 0.3;   % recommended values are <0.5

% In creating the sample image, the background is rotated by 5 degrees, and
% the forged region is rotated by 10 degrees.
I = imread('Images\wood_carvings_forged-10-05.png');
figure, imshow(imresize(I, 1/8),'border','tight')

SPN_CWT = NoiseExtractColor_CWT(double(I),sigma*0.8);      
[M, N] = size(SPN_CWT);
nowR = floor((M-Block)/Step)+1;
nowC = floor((N-Block)/Step)+1;
sumofsignature = 0;
AccumulateS = zeros(nowR*Step-Step+Block, nowC*Step-Step+Block);
Count = zeros(nowR*Step-Step+Block, nowC*Step-Step+Block);
for row= 1 : nowR
    tic,
    for col =1 : nowC
       F = SPN_CWT(row*Step-Step+1:row*Step-Step+Block, col*Step-Step+1:col*Step-Step+Block );
       [angleE,Enormmax,alphas,Enorm] = RotSearchLPs(F, SearchingRange, SearchingStep);
       % If finer estimation is needed, uncomment the follow script
%        [angleE,Enormmax,alphas,Enorm] = RotSearchLPs(F, [angleE-1, angleE+1], 0.1);
       AccumulateS(row*Step-Step+1:row*Step-Step+Block, col*Step-Step+1:col*Step-Step+Block )=...
           AccumulateS(row*Step-Step+1:row*Step-Step+Block, col*Step-Step+1:col*Step-Step+Block)+angleE;
       Count(row*Step-Step+1:row*Step-Step+Block, col*Step-Step+1:col*Step-Step+Block )=...
           Count(row*Step-Step+1:row*Step-Step+Block, col*Step-Step+1:col*Step-Step+Block)+1;      
    end
    toc,
end

Overlap_Angle = AccumulateS./Count;
figure,imshow(-Overlap_Angle,[ ])
colorbar,
title('Rotation angle inconsistency')
