function y = test_fun_3(x,type)
x = 10*x;
y_t = sin(x)+0.2.*x+(x-5).^2./16+0.5;
if type == 1
    y = y_t;    % y = y_t+0.2*rand(size(x,1),1)
elseif type == 2
    y = (x-0.5).*(x-4).*(x-9)/20+2;
elseif type == 3
    y = sin(x)+0.2.*x+0.5;
else
    error('type should be 1, 2 or 3')
end    
end