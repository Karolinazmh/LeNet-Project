clear all;
clc;
%% 导入训练好的weights/bias/activations
FC1_channel_num=120;
FC1_vector_size=400;
kernel_matrix_fc1=zeros(FC1_channel_num,FC1_vector_size,1);
fc1_weight_ori=load('D:\project\WYX\10.30data\weight\module.fc1.wrapped_module.weight.csv');
for i=1:FC1_channel_num
        kernel_matrix_fc1(i,:,1)=fc1_weight_ori((i-1)*FC1_vector_size+1:i*FC1_vector_size);
end
kernel_matrix_fc1 = kernel_matrix_fc1';
fc1_weight = zeros(FC1_channel_num * FC1_vector_size,1);
for i=1:FC1_channel_num
    for j=1:FC1_vector_size
        temp = kernel_matrix_fc1(FC1_vector_size-j+1,FC1_channel_num-i+1);
        fc1_weight((i-1)*FC1_vector_size+j) = temp;
    end
end

FC2_channel_num=84;
FC2_vector_size=120;
kernel_matrix_fc2=zeros(FC2_channel_num,FC2_vector_size,1);
fc2_weight_ori=load('D:\project\WYX\10.30data\weight\module.fc2.wrapped_module.weight.csv');
for i=1:FC2_channel_num
        kernel_matrix_fc2(i,:,1)=fc2_weight_ori((i-1)*FC2_vector_size+1:i*FC2_vector_size);
end
kernel_matrix_fc2 = kernel_matrix_fc2';
fc2_weight = zeros(FC2_channel_num * FC2_vector_size,1);
for i=1:FC2_channel_num
    for j=1:FC2_vector_size
        temp = kernel_matrix_fc2(FC2_vector_size-j+1,FC2_channel_num-i+1);
        fc2_weight((i-1)*FC2_vector_size+j) = temp;
    end
end

FC3_channel_num=10;
FC3_vector_size=84;
kernel_matrix_fc3=zeros(FC3_channel_num,FC3_vector_size,1);
fc3_weight_ori=load('D:\project\WYX\10.30data\weight\module.fc3.wrapped_module.weight.csv');
for i=1:FC3_channel_num
        kernel_matrix_fc3(i,:,1)=fc3_weight_ori((i-1)*FC3_vector_size+1:i*FC3_vector_size);
end
kernel_matrix_fc3 = kernel_matrix_fc3';
fc3_weight = zeros(FC3_channel_num * FC3_vector_size,1);
for i=1:FC3_channel_num
    for j=1:FC3_vector_size
        temp = kernel_matrix_fc3(FC3_vector_size-j+1,FC3_channel_num-i+1);
        fc3_weight((i-1)*FC3_vector_size+j) = temp;
    end
end

fc1_bias = load('D:\project\WYX\10.30data\weight\module.fc1.base_b_q.csv');
fc2_bias = load('D:\project\WYX\10.30data\weight\module.fc2.base_b_q.csv');
fc3_bias = load('D:\project\WYX\10.30data\weight\module.fc3.base_b_q.csv');

%fc1_input = fc1_input(1:NUM,:);
%% 将weights分为正负权值
fc1_weight_pos = fc1_weight;
fc1_weight_neg = fc1_weight;
fc2_weight_pos = fc2_weight;
fc2_weight_neg = fc2_weight;
fc3_weight_pos = fc3_weight;
fc3_weight_neg = fc3_weight;
fc1_weight_pos(fc1_weight_pos<0)=0;
fc1_weight_neg(fc1_weight_neg>0)=0;
fc2_weight_pos(fc2_weight_pos<0)=0;
fc2_weight_neg(fc2_weight_neg>0)=0;
fc3_weight_pos(fc3_weight_pos<0)=0;
fc3_weight_neg(fc3_weight_neg>0)=0;
fc1_weight_neg = abs(fc1_weight_neg);
fc2_weight_neg = abs(fc2_weight_neg);
fc3_weight_neg = abs(fc3_weight_neg);

%% 将weights和bias转换为8bit和4bit二进制
%fc1_input_bin = dec2bin_signed(fc1_input',8);
fc1_weight_pos_bin = dec2bin(fc1_weight_pos',8);
fc1_weight_neg_bin = dec2bin(fc1_weight_neg',8);
fc2_weight_pos_bin = dec2bin(fc2_weight_pos',8);
fc2_weight_neg_bin = dec2bin(fc2_weight_neg',8);
fc3_weight_pos_bin = dec2bin(fc3_weight_pos',8);
fc3_weight_neg_bin = dec2bin(fc3_weight_neg',8);

fid_fc1_bias = fopen('.\fc1_bias.txt','w');
fc1_bias_deq = fc1_bias/25.853;

for i=1:120
    fc1_bias_bin = DEC2bin(fc1_bias_deq(i),5);
    fprintf(fid_fc1_bias,'%s',fc1_bias_bin');
end
fclose(fid_fc1_bias);

fid_fc2_bias = fopen('.\fc2_bias.txt','w');
fc2_bias_deq = fc2_bias/19.257;
for i=1:84
    fc2_bias_bin = DEC2bin(fc2_bias_deq(i),7);
    fprintf(fid_fc2_bias,'%s',fc2_bias_bin');
end
fclose(fid_fc2_bias);

fc3_bias_deq = fc3_bias/15.395;
fid_fc3_bias = fopen('.\fc3_bias.txt','w');
for i=1:10
    fc3_bias_bin = DEC2bin(fc3_bias_deq(i),4);
    fprintf(fid_fc3_bias,'%s',fc3_bias_bin');
end
fclose(fid_fc3_bias);



%% 将处理好的数据存入文件中
%fid_fc1_input = fopen('.\fc1_input.txt','w');
fid_fc1_weight_pos = fopen('.\fc1_weight_pos.txt','w');
fid_fc1_weight_neg = fopen('.\fc1_weight_neg.txt','w');
fid_fc2_weight_pos = fopen('.\fc2_weight_pos.txt','w');
fid_fc2_weight_neg = fopen('.\fc2_weight_neg.txt','w');
fid_fc3_weight_pos = fopen('.\fc3_weight_pos.txt','w');
fid_fc3_weight_neg = fopen('.\fc3_weight_neg.txt','w');


%fprintf(fid_fc1_input,"%s",fc1_input_bin');
fprintf(fid_fc1_weight_pos,'%s',fc1_weight_pos_bin');
fprintf(fid_fc1_weight_neg,'%s',fc1_weight_neg_bin');
fprintf(fid_fc2_weight_pos,'%s',fc2_weight_pos_bin');
fprintf(fid_fc2_weight_neg,'%s',fc2_weight_neg_bin');
fprintf(fid_fc3_weight_pos,'%s',fc3_weight_pos_bin');
fprintf(fid_fc3_weight_neg,'%s',fc3_weight_neg_bin');



%fclose(fid_fc1_input);
fclose(fid_fc1_weight_pos);
fclose(fid_fc1_weight_neg);
fclose(fid_fc2_weight_pos);
fclose(fid_fc2_weight_neg);
fclose(fid_fc3_weight_pos);
fclose(fid_fc3_weight_neg);


