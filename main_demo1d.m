%1d-demonstration example
clear,clc
load test_1.mat

%参数设置
dim = size(x_test,2);
d = (dim+1)*(dim+2)/2;
m_list = 2;%低保真数据组数

x_test1 = x_test;
x_12 = linspace(0,1,12)';
size_l = 6;x_l = linspace(0,1,size_l)';
size_h = 5;x_h =[x_12([3,4])',0.5,x_12([9,10])']';

y_L1 = test_fun_4(x_l,2);
y_L2 = test_fun_4(x_l,3);
y_H  = test_fun_4(x_h,1);
ytest  = test_fun_4(x_test1,1);

x_sample = [x_h, ones(size_h,1);x_l ones(size_l,1)*2;x_l ones(size_l,1)*3];
y_response = [y_H, ones(size_h,1);y_L1 ones(size_l,1)*2;y_L2 ones(size_l,1)*3];

theta = 1;lob = 1e-02;upb = 1e+02;
predy_f = allmethod_comparison_theta(x_sample,y_response,x_test,theta,lob,upb);

%计算error
Res = [];
for i = 1:11
    [mae,rmse,mre] = cal_error(predy_f(:,i),ytest);
    Res = [Res;[mae,rmse,mre]];
end




