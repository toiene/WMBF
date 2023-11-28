function [mae,rmse,mre,rrmse] = cal_error(ypred,ytrue)

error = abs(ypred - ytrue);
mae = max(error);
rmse = sqrt(mean(error.^2));
re = error./abs(ytrue);
mre = mean(re);
rrmse = rmse./mean(abs(ytrue));
