function [ o ] = conv_vps_quan_4(fmap,kernel_matrix,kernel_num,kernel_size,stride,ad,row)

%   此处显示详细说明
%使用Vcore m*v完成卷积
%fmap为输入feature map
%kernel_matrix为输入kernel 组成的矩阵
%kernel_num为输入kernel 数量，决定kernel_matrix的宽度
%kernel_size为输入kernel 的大小，决定kernel_matrix的高度，
%stride为卷积步长	
%fmap_size为输入图像尺寸
%ad为ad的为位宽
%row表示电流累加的行数。每row行的电流累加通过一个ad转换
[fmap_size,b,channel_num]=size(fmap);
o_size = (fmap_size-kernel_size)/stride+1;
vector_length = kernel_size^2;%向量的长度，为卷积核展开的长度
o=zeros(o_size,o_size,kernel_num );
mid_o=zeros(o_size,o_size,kernel_num,channel_num);
vector=zeros(vector_length,1);
iter_num = o_size^2;%运算次数
vps_row=channel_num*vector_length;
group_kernel_ch_num=fix(row/vector_length);%最大行数里包含的向量的个数
ad_num=fix(vps_row/(group_kernel_ch_num*vector_length));
rmd=vps_row-ad_num*group_kernel_ch_num*vector_length;
rmd_kernel_ch_num=rmd/vector_length;
total_ad_iter=ceil(vps_row/(group_kernel_ch_num*vector_length));%总的迭代次数
for i_top=1:total_ad_iter
%%%%%%%%%%%最后一次迭代，剩余的最后几行 %%%%%%%%%%%   
	if(i_top==total_ad_iter)		 
		for m=1:rmd_kernel_ch_num
			fmap_tmp=fmap(:,:,m+(i_top-1)*group_kernel_ch_num);
			kernel_matrix_tmp1(:,(m-1)*vector_length+1:m*vector_length)=kernel_matrix(:,:,m+(i_top-1)*group_kernel_ch_num);
			for i=1:iter_num
				if(mod(i,o_size)==0)%position，第i次迭代在图像中的位置
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
					vector1(i1+(m-1)*vector_length,:,i)= fmap_tmp(row_p,col_p);
				end
			end
        end
        [size_a1,size_b1,size_c1]=size(kernel_matrix_tmp1);
        kernel_matrix_tmp1_zeros=zeros(size_a1,size_b1,size_c1);
        kernel_matrix_tmp1_p=max(kernel_matrix_tmp1,kernel_matrix_tmp1_zeros);%正矩阵
        kernel_matrix_tmp1_n=abs(min(kernel_matrix_tmp1,kernel_matrix_tmp1_zeros));%负矩阵
        
		parfor i1=1:iter_num
% 			result_p(:,1,i1) =vcore_ad_3bit_lite(kernel_matrix_tmp1_p,vector1(:,1,i1),ad);%矩阵向量运算
% 			result_n(:,1,i1) =vcore_ad_3bit_lite(kernel_matrix_tmp1_n,vector1(:,1,i1),ad);
			result_p(:,1,i1) =kernel_matrix_tmp1_p*vector1(:,1,i1);
			result_n(:,1,i1) =kernel_matrix_tmp1_n*vector1(:,1,i1);
% 		    result(:,1,i1) =kernel_matrix_tmp1*vector1(:,1,i1);
        end
        result=result_p-result_n;
    %%%%%%%将最后计算向量结果按照feature map形式转化%%%%%%%            
		for i2=1:iter_num
			
			if(mod(i2,o_size)==0)%position
				col=floor(i2/o_size);
				row=o_size;
			else 
				col=floor(i2/o_size)+1;
				row=mod(i2,o_size);
			end
				
			for i3=1:kernel_num
				mid_o(row,col,i3,i_top)=result(i3,1,i2);
			end
        end
     %%%%%%%将最后计算向量结果按照feature map形式转化%%%%%%%     
     
%%%%%%%%%%%最后一次迭代，剩余的最后几行 %%%%%%%%%%%   


%%%%%%%非最后剩余的几行 %%%%%%%	
    else
		kernel_matrix_tmp=zeros(kernel_num,vector_length*group_kernel_ch_num );
		for m=1:group_kernel_ch_num
			fmap_tmp=fmap(:,:,m+(i_top-1)*group_kernel_ch_num);
			kernel_matrix_tmp(:,(m-1)*vector_length+1:m*vector_length)=kernel_matrix(:,:,m+(i_top-1)*group_kernel_ch_num);
			for i=1:iter_num
				if(mod(i,o_size)==0)%position，第i次迭代在图像中的位置
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
					vector(i1+(m-1)*vector_length,:,i)= fmap_tmp(row_p,col_p);
				end
			end
        end
        [size_a,size_b,size_c]=size(kernel_matrix_tmp);
        kernel_matrix_tmp_zeros=zeros(size_a,size_b,size_c);
        kernel_matrix_tmp_p=max(kernel_matrix_tmp,kernel_matrix_tmp_zeros);
        kernel_matrix_tmp_n=abs(min(kernel_matrix_tmp,kernel_matrix_tmp_zeros));
        
		parfor i1=1:iter_num
% 			result_p(:,1,i1) =vcore_ad_3bit_lite(kernel_matrix_tmp_p,vector(:,1,i1),ad);
% 			result_n(:,1,i1) =vcore_ad_3bit_lite(kernel_matrix_tmp_n,vector(:,1,i1),ad);
			result_p(:,1,i1) =kernel_matrix_tmp_p*vector(:,1,i1);
			result_n(:,1,i1) =kernel_matrix_tmp_n*vector(:,1,i1);
% 		    result(:,1,i1) =kernel_matrix_tmp*vector(:,1,i1);
		end
        result=result_p-result_n;
        
        
    %%%%%%%将最后计算向量结果按照feature map形式转化%%%%%%%        
		for i2=1:iter_num
			
			if(mod(i2,o_size)==0)%position
				col=floor(i2/o_size);
				row=o_size;
            else
                col=floor(i2/o_size)+1;
				row=mod(i2,o_size);
			end
				
			for i3=1:kernel_num
				mid_o(row,col,i3,i_top)=result(i3,1,i2);
			end
        end
    %%%%%%%将最后计算向量结果按照feature map形式转化%%%%%%%            
    end
%%%%%%%非最后剩余的几行 %%%%%%%	    
    
    
	o=o+mid_o(:,:,:,i_top);%各通道结果累加法

end
