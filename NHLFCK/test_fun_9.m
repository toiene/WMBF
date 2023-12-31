function y = test_fun_9(x,type)
[m,n] = size(x);
x1 = x(:,1)*15-5;
x2 = x(:,2)*15-5;
x3 = x(:,3)*15-5;
x4 = x(:,4)*15-5;
x5 = x(:,5)*15-5;
x6 = x(:,6)*15-5;
y_f = @(x1,x2,x3,x4,x5,x6) 100*(x2-x1.^2).^2+(x1-1).^2+100*(x3-x2.^2).^2+(x2-1).^2+100*(x4-x3.^2).^2+(x3-1).^2+100*(x5-x4.^2).^2+(x4-1).^2+100*(x6-x5.^2).^2+(x5-1).^2;
if type == 1
    y = y_f(x1,x2,x3,x4,x5,x6);
elseif type == 2
    y = 100*(x2-x1.^2).^2+4*(x1-1).^4+100*(x3-x2.^2).^2+4*(x2-1).^4+100*(x4-x3.^2).^2+4*(x3-1).^4+100*(x5-x4.^2).^2+4*(x4-1).^4+100*(x6-x5.^2).^2+4*(x5-1).^4;
elseif type == 3
    y = 80*(x2-x1.^2).^2+(x1-1).^2+80*(x3-x2.^2).^2+(x2-1).^2+80*(x4-x3.^2).^2+(x3-1).^2+80*(x5-x4.^2).^2+(x4-1).^2+80*(x6-x5.^2).^2+(x5-1).^2;
elseif type == 4
    y = 100*(x2-x1.^2).^2+100*(x3-x2.^2).^2+100*(x4-x3.^2).^2++100*(x5-x4.^2).^2+100*(x6-x5.^2).^2;
else
    error('type should be 1, 2 or 3, 4');
end
y = y./100000;
end