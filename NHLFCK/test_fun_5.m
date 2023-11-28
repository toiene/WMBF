function y = test_fun_5(x,type)
y_t = (6*x-2).^2.*sin(12*x-4);
if type == 1
    y = y_t;    % y = y_t+0.2*rand(size(x,1),1)
elseif type == 2
    y = 0.5*y_t+10*(x-0.5)+5;
elseif type == 3
    y = 0.4*y_t-x-1;
else
    error('type should be 1, 2 or 3')
end    
end