function  [y,W,or1, or2, dmse] = predictor_ihk2_extended_f2(x, dmodel)
%PREDICTOR  Predictor for y(x) using the given DACE model.
%
% Call:   y = predictor(x, dmodel)
%         [y, or] = predictor(x, dmodel)
%         [y, dy, mse] = predictor(x, dmodel) 
%         [y, dy, mse, dmse] = predictor(x, dmodel) 
%
% Input
% x      : trial design sites with n dimensions.  
%          For mx trial sites x:
%          If mx = 1, then both a row and a column vector is accepted,
%          otherwise, x must be an mx*n matrix with the sites stored
%          rowwise.
% dmodel : Struct with DACE model; see DACEFIT
%
% Output
% y    : predicted response at x.
% or   : If mx = 1, then or = gradient vector/Jacobian matrix of predictor
%        otherwise, or is an vector with mx rows containing the estimated
%                   mean squared error of the predictor
% Three or four results are allowed only when mx = 1,
% dy   : Gradient of predictor; column vector with  n elements
% mse  : Estimated mean squared error of the predictor;
% dmse : Gradient vector/Jacobian matrix of mse

% hbn@imm.dtu.dk
% Last update August 26, 2002
 
  or1 = NaN;   or2 = NaN;  dmse = NaN;  % Default return values
  if  isnan(dmodel.beta)
    y = NaN;   
    error('DMODEL has not been found')
  end

  [m n] = size(dmodel.S);  % number of design sites and number of dimensions
  sx = size(x);            % number of trial sites and their dimension
  if  min(sx) == 1 & n > 1 % Single trial point 
    nx = max(sx);
    if  nx == n 
      mx = 1;  x = x(:).';
    end
  else
    mx = sx(1);  nx = sx(2);
  end
  if  nx ~= n
    error(sprintf('Dimension of trial sites should be %d',n))
  end
  
  % Normalize trial sites
  x = (x - repmat(dmodel.Ssc(1,:),mx,1)) ./ repmat(dmodel.Ssc(2,:),mx,1);
  q = size(dmodel.Ysc,2);  % number of response functions
  y = zeros(mx,q);         % initialize result
  
  if  mx == 1  % one site only
    dx = repmat(x,m,1) - dmodel.S;  % distances to design sites
    if  nargout > 1                 % gradient/Jacobian wanted
      [ff1 , df1, dff1] = predictor(x, dmodel.dmc_1);
      [ff2 , df2, dff2] = predictor(x, dmodel.dmc_2);
      df = 1./(1./df1 + 1./df2);
      dff = 1./(1./dff1 + 1./dff2);
      ff = dff.*(ff1./dff1 + ff2./dff2);

      nn = (n+1)*(n+2)/2;  % Number of columns in f  
      f_p = [ff x zeros(sx(1),nn-n-1)];
      for j = 1:sx(1)
          f_p(j,1+(1:n)) = x(j,1:n).*ff(j,1);
      end
      j = n+1;   qq = n;
      for  k = 1 : n
          f_p(:,j+(1:qq)) = repmat(x(:,k),1,qq) .* x(:,k:n).*repmat(ff(:,1),1,qq);
          j = j+qq;   qq = qq-1;
      end
      f = f_p;
      
      [r, dr] = feval(dmodel.corr, dmodel.theta, dx);
      % Scaled Jacobian
%       dy = (df * dmodel.beta).' + dmodel.gamma * dr;
      dy = (df).' + dmodel.gamma * dr;
      % Unscaled Jacobian
      or1 = dy .* repmat(dmodel.Ysc(2, :)', 1, nx) ./ repmat(dmodel.Ssc(2,:), q, 1);
      if q == 1
        % Gradient as a column vector
        or1 = or1';
      end
      if  nargout > 2  % MSE wanted
        
        rt = dmodel.C \ r;
        u = dmodel.Ft.' * rt - f.';
        v = dmodel.G \ u;
        or2 = repmat(dmodel.sigma2,mx,1) .* repmat((1 + sum(v.^2) - sum(rt.^2))',1,q);
        
        if  nargout > 3  % gradient/Jacobian of MSE wanted
          % Scaled gradient as a row vector
          Gv = dmodel.G' \ v;
          g = (dmodel.Ft * Gv - rt)' * (dmodel.C \ dr) - (df * Gv)';
          % Unscaled Jacobian
          dmse = repmat(2 * dmodel.sigma2',1,nx) .* repmat(g ./ dmodel.Ssc(2,:),q,1);
          if q == 1
            % Gradient as a column vector
            dmse = dmse';
          end
        end
      end
      
    else  % predictor only
      [ff1 , dff1] = predictor(x, dmodel.dmc_1);
      [ff2 , dff2] = predictor(x, dmodel.dmc_2);
      dff = 1./(1./dff1 + 1./dff2);
      ff = dff.*(ff1./dff1 + ff2./dff2);
  
      nn = (n+1)*(n+2)/2;  % Number of columns in f  
      f_p = [ff x zeros(sx(1),nn-n-1)];
      for j = 1:sx(1)
          f_p(j,1+(1:n)) = x(j,1:n).*ff(j,1);
      end
      j = n+1;   qq = n;
      for  k = 1 : n
          f_p(:,j+(1:qq)) = repmat(x(:,k),1,qq) .* x(:,k:n).*repmat(ff(:,1),1,qq);
          j = j+qq;   qq = qq-1;
      end
      f = f_p;
      
      r = feval(dmodel.corr, dmodel.theta, dx);
    end
    
    % Scaled predictor
    sy = f * dmodel.beta + (dmodel.gamma*r).';
    % Predictor
    y = sy;
    
  else  % several trial sites
    % Get distances to design sites  
    dx = zeros(mx*m,n);  kk = 1:m;
    for  k = 1 : mx
      dx(kk,:) = repmat(x(k,:),m,1) - dmodel.S;
      kk = kk + m;
    end
    
    % Get regression function and correlation
    [ff1 , dfff1] = predictor(x, dmodel.dmc_1);
    [ff2 , dfff2] = predictor(x, dmodel.dmc_2);
    dfff = 1./(1./dfff1 + 1./dfff2); 
    w = [1./dfff1 1./dfff2];W = dfff.*w;
    ff = dfff.*(ff1./dfff1 + ff2./dfff2);
    
    nn = (n+1)*(n+2)/2;  % Number of columns in f  
    f_p = [ff x zeros(sx(1),nn-n-1)];
    for j = 1:sx(1)
        f_p(j,1+(1:n)) = x(j,1:n).*ff(j,1);
    end
    j = n+1;   qq = n;
    for  k = 1 : n
      f_p(:,j+(1:qq)) = repmat(x(:,k),1,qq) .* x(:,k:n).*repmat(ff(:,1),1,qq);
      j = j+qq;   qq = qq-1;
    end
    f = f_p;
    
    r = feval(dmodel.corr, dmodel.theta, dx);
    r = reshape(r, m, mx);
    
    % Scaled predictor 
    sy = f * dmodel.beta + (dmodel.gamma * r).';
    % Predictor
    y = sy;
    
    if  nargout > 1   % MSE wanted
      rt = dmodel.C \ r;
      u = dmodel.G \ (dmodel.Ft.' * rt - f');
      or1 = repmat(dmodel.sigma2,mx,1) .* repmat((1 + colsum(u.^2) - colsum(rt.^2))',1,q);
      if  nargout > 2
        disp('WARNING from PREDICTOR.  Only  y  and  or1=mse  are computed')
      end
    end
    
  end % of several sites
  
% >>>>>>>>>>>>>>>>   Auxiliary function  ====================

function  s = colsum(x)
% Columnwise sum of elements in  x
if  size(x,1) == 1,  s = x; 
else,                s = sum(x);  end