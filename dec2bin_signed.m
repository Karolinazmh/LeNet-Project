%signed dec2bin,x is input data;n is binary data_width
function y=dec2bin_signed(x,n)
if x>=0
    y=dec2bin(x,n);
else
    if x==-2^(n-1)
        tmp=abs(x);
    else
        tmp=2^(n-1)-x;
    end
    y=dec2bin(tmp,n);
end