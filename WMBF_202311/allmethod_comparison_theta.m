function [pred_y] = allmethod_comparison_theta(x_sample,y_response,x_pre,theta,lob,upb)
%按照保真度划分数据
type_x = x_sample(:,end);  
dim = size(x_sample,2)-1;  
ty = max(type_x);
%高保真数据
x_h = x_sample((1==type_x),1:dim);
y_h = y_response((1==type_x),1);

%存放预测值
pred_y = [];

%定义theta
% theta = 0.1;
% lob = 1e-06;
% upb = 1e+02;

%% LRMFS
%低保真数据
for i = 2:ty
    ind = find(type_x == i);
    % build model
    dmodel_M1(i,:) = dacefit(x_sample(ind,1:dim),y_response(ind,1),@regpoly0,@corrgauss,ones(dim,1)*theta,ones(dim,1)*lob,ones(dim,1)*upb);  
    y_hp(:,i-1) = predictor(x_h,dmodel_M1(i,:));     
    % make prediction
    y_test_pre(:,i-1) = predictor(x_pre,dmodel_M1(i,:));
end
poly_base = generate_base(x_h,2);
% calculate the coefficient
reg_x = [y_hp poly_base];
reg_y = y_h;
coef = pinv(reg_x'*reg_x)*reg_x'*reg_y;  
% make prediction
poly_base_test = generate_base(x_pre,2);   
reg_x_test = [y_test_pre poly_base_test];
y_pre1 = reg_x_test*coef;  
pred_y = [pred_y y_pre1];

%% ihk2_extended fl_1、fl_2、fl_3、fh (aka.VWS-IHK)
x_l = x_sample(find(type_x == 2),1:dim);
y_L1 = y_response(find(type_x == 2),1);
y_L2 = y_response(find(type_x == 3),1);
if ty == 4    
    y_L3 = y_response(find(type_x == 4),1);
    [dmodelM2,~] = dacefit_ihk2_extended(x_l, y_L1, x_l, y_L2, x_l, y_L3, x_h, y_h, @regpoly0, @corrgauss, ones(dim,1)*theta,ones(dim,1)*lob,ones(dim,1)*upb);
    [YY1_IHK, ~] = predictor_ihk2_extended(x_pre, dmodelM2);
elseif ty == 3
    [dmodelM2,~] = dacefit_ihk2_extended_f2(x_l, y_L1, x_l, y_L2, x_h, y_h, @regpoly0, @corrgauss, ones(dim,1)*theta,ones(dim,1)*lob,ones(dim,1)*upb);
    [YY1_IHK, ~] = predictor_ihk2_extended_f2(x_pre, dmodelM2);
end
pred_y = [pred_y YY1_IHK];
%% hk2_extended fl_1、fl_2、fl_3、fh(aka. VWS-HK)
if ty == 4    
    y_L3 = y_response(find(type_x == 4),1);
    [dmodelM3,~] = dacefit_hk2_extended(x_l, y_L1, x_l, y_L2, x_l, y_L3, x_h, y_h, @regpoly0, @corrgauss, ones(dim,1)*theta,ones(dim,1)*lob,ones(dim,1)*upb);
    [YY2_HK, ~] = predictor_hk2_extended(x_pre,dmodelM3);
elseif ty == 3
    [dmodelM3,~] = dacefit_hk2_extended_f2(x_l, y_L1, x_l, y_L2, x_h, y_h, @regpoly0, @corrgauss, ones(dim,1)*theta,ones(dim,1)*lob,ones(dim,1)*upb);
    [YY2_HK, ~] = predictor_hk2_extended_f2(x_pre, dmodelM3);
end
pred_y = [pred_y YY2_HK];
%% Kriging fh
[dmodelM4,~] = dacefit(x_h, y_h, @regpoly0,  @corrgauss, ones(dim,1)*theta,ones(dim,1)*lob,ones(dim,1)*upb);
[YY4_Krig, ~] = predictor(x_pre,dmodelM4);
pred_y = [pred_y YY4_Krig];
%% ihk2 fl_1、fh
[dmodelM5,~] = dacefit_ihk2(x_l, y_L1, x_h, y_h, @regpoly0, @corrgauss, ones(dim,1)*theta,ones(dim,1)*lob,ones(dim,1)*upb);
[YY5_IHK0, ~] = predictor_ihk2(x_pre, dmodelM5);
pred_y = [pred_y YY5_IHK0];
%% hk2 fl_1、fh
[dmodelM6,~] = dacefit_hk2(x_l, y_L1, x_h, y_h, @regpoly0, @corrgauss2, ones(dim,1)*theta,ones(dim,1)*lob,ones(dim,1)*upb);
[YY6_IHK0, ~] = predictor_hk2(x_pre, dmodelM6);
pred_y = [pred_y YY6_IHK0];

%% NHLFCK
% MG2MF model
[dmodelM7] = MG2MF(x_sample,y_response,theta,lob,upb);
[Ypre7,~] = MG2MF_pre(dmodelM7,x_pre);
pred_y = [pred_y Ypre7];

%% adding indicative function
%% our hk
[~,~,~,~,y1_hk_mse,y1_hk_sKL3] = weightedhk_ind(x_sample,y_response(:,1),x_pre,theta,lob,upb,0.1);
pred_y = [pred_y y1_hk_mse y1_hk_sKL3];

%% our ihk
[~,~,~,~,y1_ihk_mse,y1_ihk_sKL3] = weightedihk_ind(x_sample,y_response(:,1),x_pre,theta,lob,upb,0.1);
pred_y = [pred_y y1_ihk_mse y1_ihk_sKL3];

