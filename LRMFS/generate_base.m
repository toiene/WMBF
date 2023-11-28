function poly_base = generate_base(x, power)
if power > 2
    error('power should be 0, 1, or 2');
end
n = size(x,1);
m = size(x,2); 
poly_base = ones(n,1);   
for i = 1:power
    poly_base = [poly_base x.^i]; 
    if i > 1
        for j = 1:m-1
            for k = j+1:m
                poly_base = [poly_base x(:,j).*x(:,k)];  
            end
        end
    end
end
end