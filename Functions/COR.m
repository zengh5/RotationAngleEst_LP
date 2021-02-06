function p=COR(X,Y)
% 遇到常数值图片报错
  Xzm= X-mean(mean(X));
  Yzm= Y-mean(mean(Y));
  p=sum(dot(Xzm,Yzm))/((sum(dot(Xzm,Xzm))^0.5)*(sum(dot(Yzm,Yzm))^0.5));        
