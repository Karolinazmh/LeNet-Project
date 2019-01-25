%signed dec2bin,x is input data;n is binary data_width
function y=bin2dec_signed(x,n);
if x(1)=='0'
    y=bin2dec(x);
else 
    tmp=bin2dec(x);
    y=tmp-2^n;
end