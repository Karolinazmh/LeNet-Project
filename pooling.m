function [ o ] = pooling( fmap,kernel_size,stride)
%%%%%%%%%%%%%%%%%%%%%%%%%%                for       test               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear all
% 
% fmap=single(floor(512*rand(55,55)));
% kernel_size=3;
% stride=2;

%%%%%%%%%%%%%%%%%%%%%%%%%%                for       test               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   此处显示详细说明
%使用Vcore m*v完成卷积
%fmap为输入feature map
%kernel_matrix为输入kernel 组成的矩阵
%kernel_num为输入kernel 数量，决定kernel_matrix的宽度
%kernel_size为输入kernel 的大小，决定kernel_matrix的高度，
%stride为卷积步长	
%fmap_size为输入图像尺寸
[m,n]=size(fmap);
fmap_size=m;
kernel_num=1;
o_size = (fmap_size-kernel_size)/stride+1;
vector_length = kernel_size^2;
o=zeros(o_size,o_size,kernel_num);
vector=zeros(vector_length,1);
iter_num = o_size^2;%向量数
parfor i=1:iter_num
	if(mod(i,o_size)==0)%position
		col=floor(i/o_size);
		row=o_size;
	else 
		col=floor(i/o_size)+1;
		row=mod(i,o_size);
	end
	row_s=1+(row-1)*stride;%向量起始位置
	col_s=1+(col-1)*stride;
	%从起始位置开始取kernel_size*kernel_size分块
	for i1=1:vector_length% 选择向量
		if(mod(i1,kernel_size)==0)%position
			col_p=col_s+floor(i1/kernel_size)-1;
			row_p=row_s+kernel_size-1;
		else 
			col_p=col_s+floor(i1/kernel_size)+1-1;
			row_p=row_s+mod(i1,kernel_size)-1;
		end
		vector(i1,:,i)= fmap(row_p,col_p);
    end
end
parfor i1=1:iter_num
    result(i1) =max(vector(:,1,i1));
end
for i2=1:iter_num
    
	if(mod(i2,o_size)==0)%position
		col=floor(i2/o_size);
		row=o_size;
	else 
		col=floor(i2/o_size)+1;
		row=mod(i2,o_size);
    end
	o(row,col)=result(i2);
end
end
