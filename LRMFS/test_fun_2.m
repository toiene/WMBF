function y = test_fun_2(x,type)
y_t = (6*x-2).^2.*sin(12*x-4);
if type == 1
    y = y_t;    % y = y_t+0.2*rand(size(x,1),1)
elseif type == 2
    y = y_t*0.5+10*(x-0.5)+5;
elseif type == 3
    y = y_t*0.4-x-1;
elseif type == 4
    y = y_t*0.3-10*x+6;
else
    error('type should be 1, 2 ,3 or 4')
end
end