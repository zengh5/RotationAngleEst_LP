% Rotation angle estimation with Linear pattern
% This code is for reproducing the results of 
% [1] M. Goljan. Blind Detection of Image Rotation and Angle Estimation. Electronic Imaging, 2018.
% [2] H. Zeng, M. D. M. Hosseini, and M. Goljan. Replacing DWT with DTCWT 
% in blind image rotation angle estimation, Electronic Imaging, 2021.

% Parameter setting:
% coase step = 0.05, finer step = 0.025, delta = 1

clear, clc
close all
dwtmode('symw')
addpath('Functions')
addpath('Functions\DTCWT')
addpath('Filter')

sigma = 0.5;
angles = [-1.22,0,0.55,1.11,2.77,3.88,4.44,11.66,21.66,31.66,41.66];

% read the image
image = 'Images/christmas_hedge.png';
Im = imread(image);

for j = 1 : length(angles)
    SeeProgress(j)
    %2 Rotate image
    angletrue = angles(j);
    Irot = imrotate(Im, -angletrue,'bicubic', 'crop');
    
    %3 Crop the image
    Irot = imcropmiddle(Irot,[512,512]);
    %       Irot = imcropmiddle(Irot,[720,720]);
    figure,imshow(Irot)
    [M,N,~]=size(Irot);
    
    %4 Settting the searching range and step    
    step1 = 0.05;  % Coarse step
    step2 = 0.025; % Finer step
    if angletrue<5
        range = [-15, 30];
    else
        range = [0, 45];
    end
    
    tic
    %5 Core algorithm 
    SPN_DWT = NoiseExtractColor(Irot,sigma);
    % Initial search
    [angleE_D,Enormmax_D,alphas,Enorm] = RotSearchLPs(SPN_DWT, range, step1);
    % Finer search
    range2 = [angleE_D-1, angleE_D+1];
    [angleE_D,Enormmax_D,alphas,Enorm] = RotSearchLPs(SPN_DWT, range2, step2);
    T_DWT = toc,
    figure, plot(alphas, Enorm.sum)
    xlabel('\theta')
    ylabel('Energy of Linear Pattern')
    title('DWT')
    
    tic,
    SPN_CWT = NoiseExtractColor_CWT(double(Irot),sigma*0.8);
    [angleE_C,Enormmax_C,alphas,Enorm] = RotSearchLPs(SPN_CWT, range, step1);
    range2 = [angleE_C-1, angleE_C+1];
    [angleE_C,Enormmax_C,alphas,Enorm] = RotSearchLPs(SPN_CWT, range2, step2);

    T_CWT = toc,
    figure, plot(alphas, Enorm.sum)
    xlabel('\theta')
    ylabel('Energy of Linear Pattern')
    title('CWT')
    
    %6 Evaluate the estimation result. 
    % A successful estimation is declared when the difference between the estimated 
    % angle and the groundtruth is smaller than 0.1 degree.
    angle_D(j) = angleE_D;
    result_D(j)= (abs(angleE_D-angletrue)<=0.1);
    Energy_D(j)= Enormmax_D;
    %
    angle_C(j) = angleE_C;
    result_C(j)= (abs(angleE_C-angletrue)<=0.1);
    Energy_C(j)= Enormmax_C;
    
end
