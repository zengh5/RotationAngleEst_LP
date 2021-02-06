function F = NoiseExtractColor_CWT(im,sigma,color)
% computes noise residual F for color image im

if ~exist('sigma','var'), sigma=1; end      % default value
if ~exist('color','var'), color=0; end

% Obtain the noise residual F
PRNU_R = im(:,:,1) - denC2D_fast(im(:,:,1),sigma);
PRNU_G = im(:,:,2) - denC2D_fast(im(:,:,2),sigma);
PRNU_B = im(:,:,3) - denC2D_fast(im(:,:,3),sigma);

F = cat(3, PRNU_R, PRNU_G, PRNU_B );
if ~color,
    F = rgb2gray1(F,'single'); 
    F = F - mean(F(:)); 
end