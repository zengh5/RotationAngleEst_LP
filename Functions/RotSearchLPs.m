function [angle,Enormmax,alphas,Enorm] = RotSearchLPs(F,range,step,figname,method,order)
% Search for rotation that maximizes energy of linear pattern of matrix F
% F      ... camera sensor fingerprint that may be rotated
% range  ... searching goes from range(1) to range(2) (in degrees) 
% step   ... angle increment (degrees), default is 0.1
% figname... figure name (must be a string); if fig then the plot of the objective function is shown
% method ... interpolation method 'bicubic', 'bilinear', or 'nearest'
% order  ... polynomial fit of this order is subtracted from the objective function before determining
%            the angle with maximum energy
% angle  ... angle at which Enorm is maximized
% Enormmax ... normalized energy of LP evaluated at angle
% alphas ... list of angles for which Enorm is evaluated
% Enorm  ... normalized energy of LP evaluated at alphas
% The code is provided by M. Goljan

if ~exist('method','var'), 
    method='nearest'; 
end  
% (for all experiments after 4/9/2017) because other methods strongly supress any LP
if ~exist('order','var'), 
    order=2; 
end  % default polynomial order is 2
% Make sure F is zero mean, or abs(mean(F(:)))<0.000001
F = F-mean(F(:));  
F = F/std2(F);

alphas = range(1):step:range(2);
if alphas(end)~=range(2)
    alphas(end+1) = range(2);
end

for i=length(alphas):-1:1
    alpha = alphas(i);
    % R = imrotate(F,alpha,method,'loose');
    R = imrotate(F,alpha,method,'crop');

    [E(i),En(i)] = LPenergy(R/std2(R));
    Enorm.row(i) = En(i).row;
    Enorm.col(i) = En(i).col;
    Enorm.sum(i) = Enorm.row(i)+Enorm.col(i);

end
[angle,Enormmax] = findPeak(alphas,Enorm.sum,order); 

% [angle.row,Enormmax.row] = findPeak(alphas,Enorm.row,order); 
% % [Enormmax.row,ind] = max(Enorm.row); 
% % angle.row = alphas(ind);
% [angle.col,Enormmax.col] = findPeak(alphas,Enorm.col,order); 
% [Enormmax.col,ind] = max(Enorm.col); 
% angle.col = alphas(ind);

% Expected normalized energy for random F (without any stronger linear pattern) is 1

if exist('figname','var')
    if figname
        if ~ischar(figname), figname = num2str(figname); end
        figure('Name',figname,'Visible','On');
        plot(alphas,Enorm.row,'k','LineWidth',2),
%         xylabel('Angle (degree)','Normalized LP energy'),
        xylabel('{\it\beta}','{\ite}({\bfL})')
        hold on
        plot(alphas,Enorm.col,'k:','LineWidth',2),
        a = axis; a(3)=0; axis(a);
        legend('Rows','Columns','Location','NorthWest')
        plot(range,[1 1],'g--'),
        hold off
    end
end

function [xmax,ymax] = findPeak(x,y,order)
if order==0,
    [ymax,indmax] = max(y); 
    xmax = x(indmax);
else
% fit a polynomial of the required order
    p = polyfit(x,y,order);          
    y_dif = y-polyval(p,x);
    [y_difmax,indmax] = max(y_dif);
    ymax = y(indmax);
    xmax = x(indmax);
end