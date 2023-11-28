function y = test_fun_6(x,type)
x = x*4-2;
x1 = x(:,1);
x2 = x(:,2);
y_t = @(x1,x2) 4.*x1.^2-2.1.*x1.^4+x1.^6./3+x1.*x2-4.*x2.^2+4.*x2.^4;
if type == 1
    y = y_t(x1,x2);    % y = y_t+0.2*rand(size(x,1),1)
elseif type == 2
    y = y_t(0.7.*x1,0.7.*x2)+x1.*x2-65;
elseif type == 3
    y = y_t(0.8.*x1,0.6.*x2)-x1.^4+32;
else
    error('type should be 1, 2 or 3')
end    
end