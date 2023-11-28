function G2 = cal_G2(Y_rho,x_h,y_h,y_pre,dim)
if dim == 2
    load test_2;
elseif dim == 8
    load test_8;
elseif dim == 1
    load test_1;  
elseif dim == 4
    load test_4;
elseif dim == 6
    load test_6;
elseif dim == 10
    load test_10;
end
aaa = size(x_test,1);
d2y = zeros(aaa*dim,1);
nn = size(y_h,1);
NIND = size(Y_rho,1);  
for i = 1:NIND
    d = y_h-sum(repmat(Y_rho(i,:),nn,1).*y_pre,2);   
    dmodel_d = dacefit(x_h,d,@regpoly0,@corrgauss2,1,0.01,100);
    for j = 1:aaa
        [~,d2y(dim*(j-1)+1:dim*j,i)] = predictor(x_test(j,:),dmodel_d);
    end
end
G2 = sum((d2y).^2,1).'/aaa;
end