% a weight calcualting function
function [D_KL,D_JS,H_cross] = diversion_calculation(mu1,mu2,sigma1_2,sigma2_2)
sigma1 = sqrt(sigma1_2);
sigma2 = sqrt(sigma2_2);
log_rate = log(sigma2./sigma1);
sigma_multi = sigma2.*sigma1;
mu_sum = (mu1-mu2).^2;

%KL diversion
D_KL = (log_rate - 1/2 + (sigma1_2 + mu_sum)./ (2 * sigma2_2));
%JS diversion
sigma_sum = sigma1_2 + sigma2_2;
D_JS = (log(sigma_sum./(4*sigma_multi)) + mu_sum./sigma_sum + 1)./2;

H_cross = log(sqrt(2*pi)*sigma2)+(sigma1_2 + mu_sum)./ (2 * sigma2_2);





