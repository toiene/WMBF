clc,clear;

%% LR-MFS model
dim = 2;
load test_2
%%
for i = 1:20
size_h = 10;
size_l = 20;
x_h = lhsamp(size_h,dim);
x_l = lhsamp(size_l,dim);
y_h = test_fun_7(x_h,1);
y_l_1 = test_fun_7(x_l,2);
y_l_2 = test_fun_7(x_l,3);
% y_l_3 = test_fun_9(x_l,4);
y_true = test_fun_7(x_test,1);
%%
dmodel_l1 = dacefit(x_l,y_l_1,@regpoly0,@corrgauss,ones(dim,1),ones(dim,1)*0.01,ones(dim,1)*100);  
dmodel_l2 = dacefit(x_l,y_l_2,@regpoly0,@corrgauss,ones(dim,1),ones(dim,1)*0.01,ones(dim,1)*100); 
% dmodel_l3 = dacefit(x_l,y_l_3,@regpoly0,@corrgauss,ones(dim,1),ones(dim,1)*0.01,ones(dim,1)*100);
y_h_1 = predictor(x_h,dmodel_l1); 
y_h_2 = predictor(x_h,dmodel_l2);  
% y_h_3 = predictor(x_h,dmodel_l3);
poly_base = generate_base(x_h,2);   
%%
% reg_x = [y_h_1 y_h_2 y_h_3 poly_base];
reg_x = [y_h_1 y_h_2 poly_base];   
reg_y = y_h;
coef = (reg_x'*reg_x)^-1*reg_x'*reg_y;  
%%
y_test_1 = predictor(x_test,dmodel_l1);  
y_test_2 = predictor(x_test,dmodel_l2);   
% y_test_3 = predictor(x_test,dmodel_l3); 
poly_base_test = generate_base(x_test,2);   
% reg_x_test = [y_test_1 y_test_2 y_test_3 poly_base_test];
reg_x_test = [y_test_1 y_test_2 poly_base_test];  
y_pre = reg_x_test*coef;  
%%

error = abs(y_pre - y_true);
mae = max(error);
rmse = sqrt(mean(error.^2));
result(i,:) = [mae,rmse];
end
result




