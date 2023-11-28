function  [ori_weight_mse,weight_mse,ori_weight_sKL3,weight_sKL3,y_mse,y_sKL3] = weightedhk_ind(S, Y, xpre,theta,lob,upb,epsilon)%
%% our method: improved hierarchical kriging and weighted
%% weightedihk(S, Y, xpre)
[mS,nS] = size(S);
[mY,~] = size(Y);
if mY ~= mS
    error('S and Y should have the same number of rows');
end
if nS == 1
    error('the length of S should be 2 or more');
end
type = max(S(:,end));%一共有多少组保真度数据
para.rho = ones(type-1,1)*0.5;
para.theta = ones(type,nS-1)*theta;
para.sigma2 = ones(type,1);
para.beta = ones(type,1);
SX = S(:,1:end-1);
SY = Y(:,1);
ypre_bf = [];%存放每次的BF预测值
mse_bf = [];%存放每次的BF预测mse
mu_lf = [];%存放每次的SF预测值
mse_lf = [];%存放每次的SF预测mse
ind_1 = find(S(:,end) == 1);%高保真数据索引
SH = SX(ind_1,:);
YH = SY(ind_1,:);
for i = 2:type
    ind = find(S(:,end) == i);%每组低保真度数据索引
    [dmodel,~] = dacefit_hk2_se(SX(ind,:),SY(ind,:),SH, YH,@regpoly0,@corrgauss,para.theta(i,:),...
        lob*ones(1,nS-1),upb*ones(1,nS-1));
    [dmodel1, ~] = dacefit(SX(ind,:),SY(ind,:),@regpoly0,@corrgauss,para.theta(i,:),...
        lob*ones(1,nS-1),upb*ones(1,nS-1));
    [mu_s,mse_s] = predictor(xpre, dmodel1);
    [ypre,msepre] = predictor_hk2(xpre,dmodel);
    ypre_bf = [ypre_bf ypre]; mse_bf = [mse_bf msepre];
    mu_lf = [mu_lf mu_s]; mse_lf = [mse_lf mse_s];
end

[D_KL,~] = diversion_calculation(mu_lf,ypre_bf,mse_lf,mse_bf);
c = ceil(mean((log10(max(D_KL,[],1)) - log10(min(D_KL,[],1)))/2));
alpha1 = 0.5/c;
scale_KL3 = 1./(1+(D_KL).^alpha1);

weight_sKL3 = scale_KL3./sum(scale_KL3,2);weight_mse = (1./mse_bf)./(sum(1./mse_bf,2));
ori_weight_sKL3 = weight_sKL3;ori_weight_mse = weight_mse;

weight_sKL3 = weight_sKL3.*(sign(weight_sKL3>epsilon));
[row1,~] = find(weight_sKL3==0);
[~,ind1] = max(weight_sKL3(row1,:),[],2);
for m=1:length(row1)
    i = row1(m);
    j = ind1(m);
weight_sKL3(i,j)=1-sum(weight_sKL3(i,setdiff(1:type-1,j)));
end

weight_mse = weight_mse.*(sign(weight_mse>epsilon));
[row2,~] = find(weight_mse==0);
[~,ind2] = max(weight_mse(row2,:),[],2);
for m=1:length(row2)
    i = row2(m);
    j = ind2(m);
weight_mse(i,j)=1-sum(weight_mse(i,setdiff(1:type-1,j)));
end

y_sKL3 = sum(weight_sKL3.* ypre_bf,2);
y_mse = sum(weight_mse.* ypre_bf,2);

end

