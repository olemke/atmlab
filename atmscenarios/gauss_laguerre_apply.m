function Y = gauss_laguerre_apply(Y,x_i,w_i,xnorm)

%= Set defaults
%
xnorm_DEFAULT = 1;
%
set_defaults;


%= Check input
%
if length(x_i) ~= length(w_i)
  error('Length of *x_i* and *w_i* must be identical.');
end
%
if size(Y,1) ~= length(x_i)
  error('Size of *Y* does not match length of *x_i*');
end


x_i = x_i / xnorm;

x_i = vec2col( x_i );
w_i = vec2col( w_i );

Y = Y .* repmat(xnorm*exp(x_i).*w_i,1,size(Y,2));
