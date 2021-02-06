function [E,Enorm,LP] = LPenergy(F,omitportion,asis)
% function E = LPenergy(F,omitportion) calculates total energy of linear pattern
% F ... camera fingerprint or image noise residual, mean(F(:)) = 0
% omitportion  between 0 and 1, excluding omitportion of central rows and columns
% E ... E.col and E.row structure fields
% Enorm  ... Enorm.col and Enorm.row structure fields - normalized energy
%  so that expected values for random Gaussian F are Enorm.col=1, Enorm.row=1
% asis ... not subtracting the mean

if nargin<2, omitportion=0; end
if nargin<3, asis=0; end

if length(size(F))==3,
    for j=1:3
        E(j) = LPenergy(F(:,:,j),omitportion);
    end
    return
end

if ~asis
    F = F-mean2(F);
end

LP.row = mean(F');
LP.col = mean(F);

if omitportion~=0,
    ler = size(F,2);
    from = ceil(ler/2*(1-omitportion));
    to = floor(ler/2*(1+omitportion));
    LP.row(from:to) = 0;
    
    lec = size(F,1);
    from = ceil(lec/2*(1-omitportion));
    to = floor(lec/2*(1+omitportion));
    LP.col(from:to) = 0;
end

E.row = sum(LP.row.^2); 
E.col = sum(LP.col.^2); 

% Expected energy EE of linear pattern of i.i.d. Gaussian F
[M,N] = size(F);
EE.row = M/N;
EE.col = N/M;
Enorm.row = E.row/EE.row;
Enorm.col = E.col/EE.col;