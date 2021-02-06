function y = upsconv2_fast2(x,f,s,dwtARG1,dwtARG2)
%UPSCONV2 Upsample and convolution.
%
%   Y = UPSCONV2(X,{F1_R,F2_R},S,DWTATTR) returns the size-S
%   central portion of the one step dyadic interpolation
%   (upsample and convolution) of matrix X using filter F1_R
%   for rows and filter F2_R for columns. The upsample and
%   convolution attributes are described by DWTATTR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-May-2003.
%   Last Revision: 23-Feb-2007.
%   Copyright 1995-2007 The MathWorks, Inc.

% Special case.
% if isempty(x) , y = 0; return; end

% Check arguments for Extension and Shift.
switch nargin
%     case 3 ,
%         perFLAG  = 0;
%         dwtSHIFT = [0 0];
    case 4 , % Arg4 is a STRUCT
        perFLAG  = isequal(dwtARG1.extMode,'per');
        dwtSHIFT = mod(dwtARG1.shift2D,2);
    case 5 ,
        perFLAG  = isequal(dwtARG1,'per');
        dwtSHIFT = mod(dwtARG2,2);
end

% Define Size.
lf = length(f{1});
sx = 2*size(x);
% 
% ndimX = ndims(x);
% if ndimX>2 , sx = sx(1:2); end
if isempty(s)
    if ~perFLAG , 
        s = sx-lf+2; 
    else
        s = sx; 
    end
end

% if ndimX<3
    y = upsconv2ONE(x);
% else
%     y = cell(0,3);
%     for j = 1:3
%         y{j} = upsconv2ONE(x(:,:,j));
%     end
%      y = cat(3,y{:});
% end

    function y = upsconv2ONE(z)
        [r,c]   = size(z);  %%
        % Compute Upsampling and Convolution.
        if ~perFLAG
%             tic
            y = dyadup_f(z,'row');

%             y  = zeros(2*r-1,c);
%             y(1:2:2*r-1,:) = z;
            
%             T1 = toc,
%             tic
            y = conv2(y,f{1}(:),'full'); 
%             y = conv2(y',f{1}(:)','full'); 
%             T2 = toc,
%             y = y';
%             T2 = toc,
%             tic
            y = dyadup_f(y,'col');
%             y2  = zeros(size(y,1),2*c-1);
%             y2(:,1:2:2*c-1) = y;
%             T3 = toc,
%             tic
            y = conv2(y ,f{2}(:)','full');
%             T4 = toc,
%             tic
%             y = wkeep2(y,s,'c',dwtSHIFT);
            
            d = (size(y)-s)/2;
            first = 1+floor(d);
            last = size(y)-ceil(d);
            y = y(first(1):last(1),first(2):last(2));
%             T5 = toc,

        else
            y = dyadup(z,'row',0,1);
            y = wextend('addrow','per',y,lf/2);
            y = conv2(y',f{1}(:)','full'); y = y';
            y = y(lf:lf+s(1)-1,:);
            %-------------------------------------------
            y = dyadup(y,'col',0,1);
            y = wextend('addcol','per',y,lf/2);
            y = conv2(y,f{2}(:)','full');
            y = y(:,lf:lf+s(2)-1);
            %-------------------------------------------
            if dwtSHIFT(1)==1 , y = y([2:end,1],:); end
            if dwtSHIFT(2)==1 , y = y(:,[2:end,1]); end
            %-------------------------------------------
        end
    end

end
