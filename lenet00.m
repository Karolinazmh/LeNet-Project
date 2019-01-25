%% LENET5 VPS 模型
% weight:4bit
% bias:4bit
% activation:8bit
% 已有推断精度 precision＿96.130% 
% VPS 推断精度 precision＿

%% VPS模型
% clc;
% clear all;
AD=12;% AD位数
% AD=16;
%%%%%%%%%%%%%%%%初始化设罿 设置权重 偏置等参数%%%%%%%%%%%%%%%%
%% 卷积层1
input_channel1_num=1; 	%第一层输入的通道数
kernel_num1=6;        	%第一层的卷积核数目
kernel_size1=5;		  	%卷积核大小
stride1=1;			  	%第一层卷积的步长
kernel_matrix1=zeros(kernel_num1,kernel_size1^2,input_channel1_num);
weight_size1=kernel_size1^2 * kernel_num1;
layer1_weight=load('.\10.30data\weight\module.conv1.wrapped_module.weight.csv');
for i=1:input_channel1_num
	for j=1:kernel_num1
		kernel_matrix1(j,:,i)=layer1_weight(1+(j-1)*(kernel_size1^2)*input_channel1_num+(i-1)*(kernel_size1^2):kernel_size1^2+(j-1)*(kernel_size1^2)*input_channel1_num+(i-1)*(kernel_size1^2));
	end
end
b1=zeros(kernel_num1,1);%第一层的偏置
b1=load('.\10.30data\weight\module.conv1.base_b_q.csv');

%% 卷积层2
input_channel2_num=6;   %第二层卷积输入的通道数
kernel_num2=16;       	%第二层卷积核的数目
kernel_size2=5;		  	%卷积核的尺寸
stride2=1;			  	%第二层卷积的步长
kernel_matrix2=zeros(kernel_num2,kernel_size2^2,input_channel2_num);
weight_size2=kernel_size2^2 * kernel_num2;
layer2_weight=load('.\10.30data\weight\module.conv2.wrapped_module.weight.csv');
for i=1:input_channel2_num
	for j=1:kernel_num2
		kernel_matrix2(j,:,i)=layer2_weight(1+(j-1)*(kernel_size2^2)*input_channel2_num+(i-1)*(kernel_size2^2):kernel_size2^2+(j-1)*(kernel_size2^2)*input_channel2_num+(i-1)*(kernel_size2^2));
	end
end
b2=zeros(kernel_num2,1);%第二层的偏置
b2=load('.\10.30data\weight\module.conv2.base_b_q.csv');

%% 全连接层1
FC1_channel_num=120;
FC1_vector_size=400;
kernel_matrix_fc1=zeros(FC1_channel_num,FC1_vector_size,1);
fc1_weight=load('.\10.30data\weight\module.fc1.wrapped_module.weight.csv');
for i=1:FC1_channel_num
        kernel_matrix_fc1(i,:,1)=fc1_weight((i-1)*FC1_vector_size+1:i*FC1_vector_size);
end
b_fc1=load('.\10.30data\weight\module.fc1.base_b_q.csv');

%% 全连接层2
FC2_channel_num=84;
FC2_vector_size=120;
kernel_matrix_fc2=zeros(FC2_channel_num,FC2_vector_size,1);
fc2_weight=load('.\10.30data\weight\module.fc2.wrapped_module.weight.csv');
for i=1:FC2_channel_num
        kernel_matrix_fc2(i,:,1)=fc2_weight((i-1)*FC2_vector_size+1:i*FC2_vector_size);
end
b_fc2=load('.\10.30data\weight\module.fc2.base_b_q.csv');

%% 全连接层3
FC3_channel_num=10;
FC3_vector_size=84;
kernel_matrix_fc3=zeros(FC3_channel_num,FC3_vector_size,1);
fc3_weight=load('.\10.30data\weight\module.fc3.wrapped_module.weight.csv');
for i=1:FC3_channel_num
        kernel_matrix_fc3(i,:,1)=fc3_weight((i-1)*FC3_vector_size+1:i*FC3_vector_size);
end
b_fc3=load('.\10.30data\weight\module.fc3.base_b_q.csv');


%读入多个数据文件
%  for i_file=11:11
%     name=num2str(i_file-1);
%     test_lib=load(['.\10.30data\test_act\test_act',name,'.csv']);
%     result_real_lib=load(['.\10.30data\test_res\test_res',name,'.csv']);

    test_lib = load('.\10.30data\one_iter\test_input.csv');
    [size_lib,unuse]=size(test_lib);
    fmap_num=size_lib/784; %28*28*1=784 一幅图大小
    %fid_input = fopen(['.\refer_result\fc1_input',name,'.txt'],'w');
    fid_fc1_input = fopen('.\fc1_input.txt','w');
	for i_top=1:fmap_num
		
		input_fmap=zeros(28,28,1);
		input = test_lib( (i_top-1)*784+1 : i_top*784 , 1);
		
		for i=1:784
			input_fmap(i)=round(input(i)*64); %%第一层系数qx=64
		end
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%计算部分%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% 先是两层卷积计算
		%% 第一层卷积 卷积完成后 ReLU + maxpooling 
		conv1_input=zeros(32,32,input_channel1_num); % padding 2
		for i1=1:input_channel1_num
			conv1_input(3:30,3:30,i1) = input_fmap(:,:,i1);
		end	
		
		con_result1 = conv_vps_quan_4(conv1_input,kernel_matrix1,kernel_num1,kernel_size1,stride1,AD,50); %VPS 卷积计算
		[a,b,c] = size(con_result1);
		parfor i1=1:c	% 不相关 并行循环执行
			con_result1_bias(:,:,i1) = con_result1(:,:,i1)/(64*4) +b1(i1)/15.618;% 
		end	
		
		relu_thr1=zeros(a,b,c);
		con_result_relu1=max(relu_thr1,con_result1_bias); %28*28*6
		conv1_pooling_input=con_result_relu1;
		parfor i1=1:c
			layer1_result(:,:,i1) = pooling( conv1_pooling_input(:,:,i1),2,2);%最大池化 14*14*6
		end
		
		%% 第二层卷积 卷积完成后 ReLU + maxpooling 输入 14*14*6
		conv2_input = round(layer1_result*16); %第二层卷积不需要? padding
		con_result2 = conv_vps_quan_4(conv2_input,kernel_matrix2,kernel_num2,kernel_size2,stride2,8,128);
		[a,b,c] = size(con_result2);
		parfor i2=1:c 
			conv2_result_bias(:,:,i2) = con_result2(:,:,i2)/(16*8) + b2(i2)/4.474; %
		end
		
		relu_thr2=zeros(a,b,c);
		con_result_relu2=max(relu_thr2,conv2_result_bias); % 10*10*16
		conv2_pooling_input=con_result_relu2;
		parfor i2=1:c
			layer2_result(:,:,i2) = pooling( conv2_pooling_input(:,:,i2),2,2); % 5*5*16
		end
		
		%% 三层全连接层
		%% 第一层全连接层计算
		[a,b,c]=size(layer2_result);%5*5*16
		for j1=1:a*b*c
			fc1_input(j1,:)=round(layer2_result(j1)*4);
        end
%         input = fc1_input';
        
%         for i_input=1:length(input)
%             fprintf(fid_input,'%d',input(i_input));
%             if i_input==length(input)
%                 fprintf(fid_input,'\n');
%             end
%         end
        
		fc1_result=zeros(120,1);
		parfor i=1:4 % 4*100=400
			fc1_result_tmp=vcore_ad_3bit_lite(kernel_matrix_fc1(:,(i-1)*100+1:i*100),fc1_input((i-1)*100+1:i*100,:),AD);
			fc1_result=fc1_result+fc1_result_tmp;
		end

		fc1_result=fc1_result/(4*4)+b_fc1/25.853; % 120*1
		
		fc1_zero=zeros(120,1);
		fc1_result_relu=max(fc1_result,fc1_zero);
		
		%% 第二层全连接层计算
		fc2_input = round(fc1_result_relu*4); % 120*1
		fc2_result=zeros(84,1);
		parfor i=1:4 % 4*30=120
			fc2_result_tmp=vcore_ad_3bit_lite(kernel_matrix_fc2(:,(i-1)*30+1:i*30),fc2_input((i-1)*30+1:i*30,:),AD);
			fc2_result=fc2_result+fc2_result_tmp;
        end
		fc2_result=fc2_result/(4*16)+b_fc2/19.257; % 84*1
		
		fc2_zero=zeros(84,1);
		fc2_result_relu=max(fc2_result,fc2_zero);
		
		%% 第三层全连接层计算
		fc3_input = round(fc2_result_relu*4); % 84*1
		fc3_result=zeros(10,1);
		parfor i=1:4 % 4*21=84
			fc3_result_tmp=vcore_ad_3bit_lite(kernel_matrix_fc3(:,(i-1)*21+1:i*21),fc3_input((i-1)*21+1:i*21,:),AD);
			fc3_result=fc3_result+fc3_result_tmp;
		end
% fc3_result=kernel_matrix_fc3*fc3_input;
		fc3_result=fc3_result/(4*8)+b_fc3/15.395; % 10*1
		
		%% 计算最终的识别结果
		final_result=fc3_result;
		max_final_result=max(final_result);
		for i=1:10
			if(final_result(i)==max_final_result)
				tmp_max=i-1;
			end
        end		
		result_lib(i_top)=tmp_max;
        
        for i=1:400
            fc1_input_bin = dec2bin_signed(fc1_input(401-i),8);
            fprintf(fid_fc1_input,'%s',fc1_input_bin');
        end
        fprintf(fid_fc1_input,'\r\n');
    
    end

    
    
 	% 结果写入文件


    %fclose(fid_input);
%  	fid=fopen(['.\refer_result\result',name,'_2.txt'],'w');
% % % 	fid=fopen('.\result\result_one_iter.txt','w');
%  	for i=1:fmap_num
%  		fprintf(fid,'%d \n',result_lib(i));
%  	end
% % 	
%  	fclose(fid);
%  end

	