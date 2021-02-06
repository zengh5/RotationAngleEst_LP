function F = NoiseExtractColor(im,sigma,color)
% F = NoiseExtractColor(im,sigma) computes noise residual F for color image im

if ~exist('sigma','var'), sigma=1; end      % default value
if ~exist('color','var'), color=0; end
L = 4;                            	
qmf = MakeONFilter('Daubechies',8);

% Obtain the noise residual F
PRNU_R = single( NoiseExtract( im(:,:,1), qmf, sigma, L ) );
PRNU_G = single( NoiseExtract( im(:,:,2), qmf, sigma, L ) );
PRNU_B = single( NoiseExtract( im(:,:,3), qmf, sigma, L ) );

F = cat(3, PRNU_R, PRNU_G, PRNU_B );
if ~color,
    F = rgb2gray1(F,'single'); 
    F = F - mean(F(:)); 
end