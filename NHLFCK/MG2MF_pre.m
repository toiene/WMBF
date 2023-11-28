function [YY,mse] = MG2MF_pre(dmodel_MF,x_pre)
tttt = size(x_pre,1);
x_pre = (x_pre - repmat(dmodel_MF.S(1,:),tttt,1))./ repmat(dmodel_MF.S(2,:),tttt,1);
mse = zeros(tttt,1);
YY = zeros(tttt,1);
ttt = size(dmodel_MF.R,1);
ty = dmodel_MF.ty;
for iii = 1:tttt
    c = zeros(ttt,1);
    for i = 1:ty
        ind = find(dmodel_MF.type_x == i);
        if i == 1
            cc = smc(x_pre(iii,:),dmodel_MF.dmodel(i).S,dmodel_MF.dmodel(i).theta).*dmodel_MF.dmodel(i).sigma2;
            for j = 2:ty
                cc = cc+smc(x_pre(iii,:),dmodel_MF.dmodel(i).S,dmodel_MF.dmodel(j).theta).*dmodel_MF.dmodel(j).sigma2.*dmodel_MF.rho(j-1).^2;
            end
        else
            cc = smc(x_pre(iii,:),dmodel_MF.dmodel(i).S,dmodel_MF.dmodel(i).theta).*dmodel_MF.dmodel(i).sigma2.*dmodel_MF.rho(i-1);
        end
        c(ind,:) = cc;
    end
    %%
    c = sparse(c);
    YY(iii,:) = dmodel_MF.beta + (dmodel_MF.gamma*c).';
    YY(iii,:) = YY(iii,:).*dmodel_MF.Y(2,:)+dmodel_MF.Y(1,:);
    mse(iii,:) = dmodel_MF.dmodel(1).sigma2;
    for i = 2:ty
        mse(iii,:) = mse(iii,:)+dmodel_MF.dmodel(i).sigma2.*dmodel_MF.rho(i-1).^2;
    end
    rt = dmodel_MF.R\c;
    u = dmodel_MF.G\(dmodel_MF.Ft.'*rt - 1);
%   mse(iii,:) = mse(iii,:)-c.'*C^-1*c+(1-ones(1,ttt)*C^-1*c)/(ones(1,ttt)*C^-1*ones(ttt,1));
    mse(iii,:) = mse(iii,:)+sum(u.^2)-sum(rt.^2);
end
end