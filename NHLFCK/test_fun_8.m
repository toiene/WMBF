function y = test_fun_8(x,type)
[m,n] = size(x);
x1 = x(:,1)*0.5+0.5;
x2 = x(:,2)*0.5+0.5;
x3 = x(:,3)*0.5+0.5;
x4 = x(:,4)*0.5+0.5;
y_f = @(x1,x2,x3,x4) x1./2.*(sqrt(1+(x1+x3.^2).*x4./x1.^20)-1)+(x1+3*x4).*exp(1+sin(x3));
if type == 1
    y = y_f(x1,x2,x3,x4);
elseif type == 2
    y = 0.79*(1+sin(x1)/10).*y_f(x1,x2,x3,x4)-2*x1+x2.^2+x3.^2+0.5;
elseif type == 3
    y = y_f(x1,x2,x3,0.8*x4)+exp(x3/2)-x1/10;
else
    error('type should be 1, 2 or 3');
end
end