function y = test_fun_4(x,type)
x = 10*x;
y_t = 2*sin(pi*x/5);
if type == 1
    y = y_t;    % y = y_t+0.2*rand(size(x,1),1)
elseif type == 2
    y = x.*(x-5).*(x-12)./30;
elseif type == 3
    y = (x+2).*(x-5).*(x-10)./30;
else
    error('type should be 1, 2 or 3')
end    
end