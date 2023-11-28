function C = smc(S1,S2,theta)
[m n] = size(S2);
mx = size(S1,1);
dx = zeros(mx*m,n);  kk = 1:m;
for  k = 1 : mx
    dx(kk,:) = repmat(S1(k,:),m,1) - S2;
    kk = kk + m;
end
r = feval(@corrgauss, theta, dx);
C = reshape(r, m, mx);
end