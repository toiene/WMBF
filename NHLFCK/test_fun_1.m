function y = test_fun_1(x,type)
x = 2*pi*x;
y_t = sin(x);
if type == 1
    y = y_t;    % y = y_t+0.1*rand(size(x,1),1)
elseif type == 2
    y = sin(x)+0.1*(x-pi).^2;
elseif type == 3
    y = 1.2*sin(x)+0.1.*(x-pi).^2-0.2;
else
    error('type should be 1, 2 or 3')
end    
end