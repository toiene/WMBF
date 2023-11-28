clear
clc
close all;
for i = 1:20
dim = 1;
load test_1;
%% Data
size_h = 5*dim;
size_l = 10*dim;
x_h = lhsamp(size_h,dim);
x_l = lhsamp(size_l,dim);
y_h = test_fun_3(x_h,1);
y_l_1 = test_fun_3(x_l,2);
y_l_2 = test_fun_3(x_l,3);
% y_l_3 = test_fun_2(x_l,4);
y_true = test_fun_3(x_test,1);
%% MG2MF model 
%构造样本集，其中第二列为保真度标签：1为高保真，2-n为低保真
x_sample = [x_h, ones(size_h,1);x_l ones(size_l,1)*2;x_l ones(size_l,1)*3];  
y_response = [y_h, ones(size_h,1);y_l_1 ones(size_l,1)*2;y_l_2 ones(size_l,1)*3]; 

% x_sample = [x_h, ones(size_h,1);x_l ones(size_l,1)*2;x_l ones(size_l,1)*3;x_l ones(size_l,1)*4]; 
% y_response = [y_h, ones(size_h,1);y_l_1 ones(size_l,1)*2;y_l_2 ones(size_l,1)*3;y_l_3 ones(size_l,1)*4]; 

x_pre = x_test; 
[dmodel_MF] = MG2MF(x_sample,y_response);
[Ypre,YMSE] = MG2MF_pre(dmodel_MF,x_pre);
%% true
mae = max(abs(y_true - Ypre));
rmse = sqrt(mean((y_true - Ypre).^2));
result(i,:) = [mae,rmse];
end
result
