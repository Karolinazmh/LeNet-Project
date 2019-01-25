function [ o ] = conv_vps_quan_4(fmap,kernel_matrix,kernel_num,kernel_size,stride,ad,row)

%   �˴���ʾ��ϸ˵��
%ʹ��Vcore m*v��ɾ��
%fmapΪ����feature map
%kernel_matrixΪ����kernel ��ɵľ���
%kernel_numΪ����kernel ����������kernel_matrix�Ŀ��
%kernel_sizeΪ����kernel �Ĵ�С������kernel_matrix�ĸ߶ȣ�
%strideΪ�������	
%fmap_sizeΪ����ͼ��ߴ�
%adΪad��Ϊλ��
%row��ʾ�����ۼӵ�������ÿrow�еĵ����ۼ�ͨ��һ��adת��
[fmap_size,b,channel_num]=size(fmap);
o_size = (fmap_size-kernel_size)/stride+1;
vector_length = kernel_size^2;%�����ĳ��ȣ�Ϊ�����չ���ĳ���
o=zeros(o_size,o_size,kernel_num );
mid_o=zeros(o_size,o_size,kernel_num,channel_num);
vector=zeros(vector_length,1);
iter_num = o_size^2;%�������
vps_row=channel_num*vector_length;
group_kernel_ch_num=fix(row/vector_length);%�������������������ĸ���
ad_num=fix(vps_row/(group_kernel_ch_num*vector_length));
rmd=vps_row-ad_num*group_kernel_ch_num*vector_length;
rmd_kernel_ch_num=rmd/vector_length;
total_ad_iter=ceil(vps_row/(group_kernel_ch_num*vector_length));%�ܵĵ�������
for i_top=1:total_ad_iter
%%%%%%%%%%%���һ�ε�����ʣ�������� %%%%%%%%%%%   
	if(i_top==total_ad_iter)		 
		for m=1:rmd_kernel_ch_num
			fmap_tmp=fmap(:,:,m+(i_top-1)*group_kernel_ch_num);
			kernel_matrix_tmp1(:,(m-1)*vector_length+1:m*vector_length)=kernel_matrix(:,:,m+(i_top-1)*group_kernel_ch_num);
			for i=1:iter_num
				if(mod(i,o_size)==0)%position����i�ε�����ͼ���е�λ��
					col=floor(i/o_size);
					row=o_size;
				else 
					col=floor(i/o_size)+1;
					row=mod(i,o_size);
				end
				row_s=1+(row-1)*stride;%������ʼλ��
				col_s=1+(col-1)*stride;
				%����ʼλ�ÿ�ʼȡkernel_size*kernel_size�ֿ�
				for i1=1:vector_length% ѡ������
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
        kernel_matrix_tmp1_p=max(kernel_matrix_tmp1,kernel_matrix_tmp1_zeros);%������
        kernel_matrix_tmp1_n=abs(min(kernel_matrix_tmp1,kernel_matrix_tmp1_zeros));%������
        
		parfor i1=1:iter_num
% 			result_p(:,1,i1) =vcore_ad_3bit_lite(kernel_matrix_tmp1_p,vector1(:,1,i1),ad);%������������
% 			result_n(:,1,i1) =vcore_ad_3bit_lite(kernel_matrix_tmp1_n,vector1(:,1,i1),ad);
			result_p(:,1,i1) =kernel_matrix_tmp1_p*vector1(:,1,i1);
			result_n(:,1,i1) =kernel_matrix_tmp1_n*vector1(:,1,i1);
% 		    result(:,1,i1) =kernel_matrix_tmp1*vector1(:,1,i1);
        end
        result=result_p-result_n;
    %%%%%%%�������������������feature map��ʽת��%%%%%%%            
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
     %%%%%%%�������������������feature map��ʽת��%%%%%%%     
     
%%%%%%%%%%%���һ�ε�����ʣ�������� %%%%%%%%%%%   


%%%%%%%�����ʣ��ļ��� %%%%%%%	
    else
		kernel_matrix_tmp=zeros(kernel_num,vector_length*group_kernel_ch_num );
		for m=1:group_kernel_ch_num
			fmap_tmp=fmap(:,:,m+(i_top-1)*group_kernel_ch_num);
			kernel_matrix_tmp(:,(m-1)*vector_length+1:m*vector_length)=kernel_matrix(:,:,m+(i_top-1)*group_kernel_ch_num);
			for i=1:iter_num
				if(mod(i,o_size)==0)%position����i�ε�����ͼ���е�λ��
					col=floor(i/o_size);
					row=o_size;
				else 
					col=floor(i/o_size)+1;
					row=mod(i,o_size);
				end
				row_s=1+(row-1)*stride;%������ʼλ��
				col_s=1+(col-1)*stride;
				%����ʼλ�ÿ�ʼȡkernel_size*kernel_size�ֿ�
				for i1=1:vector_length% ѡ������
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
        
        
    %%%%%%%�������������������feature map��ʽת��%%%%%%%        
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
    %%%%%%%�������������������feature map��ʽת��%%%%%%%            
    end
%%%%%%%�����ʣ��ļ��� %%%%%%%	    
    
    
	o=o+mid_o(:,:,:,i_top);%��ͨ������ۼӷ�

end
