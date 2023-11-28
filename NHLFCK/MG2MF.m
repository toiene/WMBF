function dmodel_MF = MG2MF(x_sample,y_response,theta,lob,upb)
%%
type_x = x_sample(:,end);  
type_y = y_response(:,end); 
dim = size(x_sample,2)-1;  
ty = max(type_x);  
for i = 1:ty
    if sum(find(i == type_x)) ~= sum(find(i == type_y))
        error('the size of x_sample and response should be the same');
    end
end
%%
mmm = size(x_sample,1);  
S_mean = mean(x_sample(:,1:dim));  
S_std = std(x_sample(:,1:dim));
x_sample(:,1:dim) = (x_sample(:,1:dim) - repmat(S_mean,mmm,1))./repmat(S_std,mmm,1);
Y_mean = mean(y_response(:,1));
Y_std = std(y_response(:,1));
y_response(:,1) = (y_response(:,1) - repmat(Y_mean,mmm,1))./repmat(Y_std,mmm,1);
x_h = x_sample((1==type_x),1:dim);
y_h = y_response((1==type_x),1);
% theta = ones(1,dim)*0.01;
% lob = 0.0001*ones(1,dim);
% upb = 1*ones(1,dim);
for i = 2:ty  
    ind = find(type_x == i);
    dmodel(i,:) = dacefit_N(x_sample(ind,1:dim),y_response(ind,1),@regpoly0,@corrgauss,ones(1,dim)*theta,ones(1,dim)*lob,ones(1,dim)*upb);   %构建不同的LF模型
%     if dmodel(i,:).sigma2 > 1e4
%         error('the LF sample points shoule be considered again');
%     end
    y_pre(:,i-1) = predictor(x_h,dmodel(i,:));
end
option = optimset('Display','off','MaxFunEvals',1000000,'MaxIter',100); 
[rho G2]= fmincon(@(Y_rho)cal_G2(Y_rho,x_h,y_h,y_pre,dim),zeros(1,ty-1),[],[],[],[],[],[],[],option); 
for i = 1:ty
    nn(i,:) = size(x_sample(type_x == i,:),1);
end
d = y_h-sum(repmat(rho,nn(1,:),1).*y_pre,2);
dmodel(1,:) = dacefit_N(x_h,d,@regpoly0,@corrgauss,ones(1,dim)*theta,ones(1,dim)*lob,ones(1,dim)*upb);
% dmodel(1,:) = dacefit_N(x_h,d,@regpoly0,@corrgauss2,0.01,0.01,100);
%%
y = [];
for i = 1:ty
    ind = find(type_x == i);
    y = [y;(y_response(ind,1)-dmodel(i).Ysc(1,:))./dmodel(i).Ysc(2,:)];
end
%%
ttt = size(x_sample,1);
C = zeros(ttt,ttt);
for i = 1:ty
    ind1 = find(type_x == i);
    for j = 1:ty
        ind2 = find(type_x == j);
        if i == j
            CCC = smc(dmodel(i).S,dmodel(j).S,dmodel(i).theta);
            C(ind1,ind2) = CCC.*dmodel(i).sigma2;
            if i == 1
                for k = 2:ty
                    CCC = smc(dmodel(i).S,dmodel(j).S,dmodel(k).theta);
                    C(ind1,ind2) = C(ind1,ind2) + CCC.*dmodel(k).sigma2.*rho(k-1).^2;
                end
            end
        else
            if i == 1
                CCC = smc(dmodel(i).S,dmodel(j).S,dmodel(j).theta);
                C(ind2,ind1) = CCC.*dmodel(j).sigma2.*rho(j-1);
            elseif j == 1
                CCC = smc(dmodel(i).S,dmodel(j).S,dmodel(i).theta);
                C(ind2,ind1) = CCC.*dmodel(i).sigma2.*rho(i-1);
            end
        end
    end
end
%%
C = sparse(C);
[R, rd] = chol(C);
if rd
    [V,D] = eig(full(C));
    C1 = C + eye(size(C,1))*(- min(diag(D)) + 10^(-2));
%     C = C + eye(size(C,1))*10^-11*(10+size(C,1));%eps  10^-12
    [R, rd] = chol(sparse(C1));
    if rd
        error('The correlation matrix is not positive definite')
    end
end
R = R'; Ft = R\ones(size(x_sample,1),1);
[Q, G] = qr(Ft, 0);
Yt = R\y;
beta = G\(Q'*Yt);
rho11 = Yt - Ft*beta;
% sigma2 = sum(rho11.^2)/size(x_sample,1);
%%
dmodel_MF = struct('dmodel',dmodel, 'R',R, 'Ft',Ft, 'G',G, 'beta',beta,...
    'gamma',rho11'/R, 'ty',ty, 'type_x',type_x, 'rho',rho, 'S',[S_mean; S_std], 'Y',[Y_mean; Y_std] ); %'sigma2',dmodel(1).Ysc(2,:).^2*sigma2
end