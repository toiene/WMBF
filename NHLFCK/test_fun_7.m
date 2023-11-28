function y = test_fun_7(x,type)

x1 = x(:,1);
x2 = x(:,2); 
y_t = -sin(x1)-exp(x1./100)+10+x2.^2./10;  %HF

if type == 1
    y = y_t;    %HF
elseif type == 2
    y = -sin(x1)-exp(x1./100)+10.3+0.03.*(x1-0.3).^2+(x2-1).^2./10;    %LF1
elseif type == 3
    y = -sin(0.9.*x1)-exp(0.9*x1./100)+10+(0.8.*x2).^2./10;    %LF2  
else
    error('type should be 1, 2 or 3')
end    
end