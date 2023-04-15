function y = lcir(x, a, b)
assert(a>0 && b>0);
r = sqrt(a^2+b^2);
if abs(x) < a^2/r
    y = (b/a)*x;
elseif abs(x) < r
    y = sign(x) .* sqrt(-x.^2 + 2*r*abs(x) - a^2);
else
    y = sign(x)*b;
end


