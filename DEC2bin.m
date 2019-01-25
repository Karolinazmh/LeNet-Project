function y = DEC2bin( a,N )
%DEC2BIN 此处显示有关此函数的摘要
%   此处显示详细说明
if a>=0
    y(1) = 0;
    for i= 2: N
        temp=a*2;
        y(i)=floor(temp);
        a=temp-floor(temp);
    end 
else
    y(1) = 1;
    a = abs(a);
    for i= 2: N
        temp=a*2;
        y(i)=floor(temp);
        a=temp-floor(temp);
    end
end
%     y = mod(y+2^4,2^4);
      y_tmp = bin2dec_signed(num2str(y),N);
      y = dec2bin_signed(y_tmp,N);
end


