clear all;
ARRAY_ROW_NUM_FC1 = 400;%阵列行数
ARRAY_COLUMN_NUM_FC1 = 120;%阵列列数
ARRAY_ROW_NUM_FC2 = 120;%阵列行数
ARRAY_COLUMN_NUM_FC2 = 84;%阵列列数
ARRAY_ROW_NUM_FC3 = 84;%阵列行数
ARRAY_COLUMN_NUM_FC3 = 10;%阵列列数

DATA_NUM = 10;%数据组数

I_data = randi(2^8,DATA_NUM,ARRAY_ROW_NUM_FC1);
I_pos_weight_fc1 = randi(2^8,ARRAY_ROW_NUM_FC1,ARRAY_COLUMN_NUM_FC1);
I_neg_weight_fc1 = randi(2^8,ARRAY_ROW_NUM_FC1,ARRAY_COLUMN_NUM_FC1);
I_pos_weight_fc2 = randi(2^8,ARRAY_ROW_NUM_FC2,ARRAY_COLUMN_NUM_FC2);
I_neg_weight_fc2 = randi(2^8,ARRAY_ROW_NUM_FC2,ARRAY_COLUMN_NUM_FC2);
I_pos_weight_fc3 = randi(2^8,ARRAY_ROW_NUM_FC3,ARRAY_COLUMN_NUM_FC3);
I_neg_weight_fc3 = randi(2^8,ARRAY_ROW_NUM_FC3,ARRAY_COLUMN_NUM_FC3);
I_bias_fc1 = randi(2^4,1,ARRAY_COLUMN_NUM_FC1);
I_bias_fc2 = randi(2^4,1,ARRAY_COLUMN_NUM_FC2);
I_bias_fc3 = randi(2^4,1,ARRAY_COLUMN_NUM_FC3);

I_data_bin = dec2bin(I_data'-1,8);
I_pos_weight_fc1_bin = dec2bin(I_pos_weight_fc1'-1,8);
I_neg_weight_fc1_bin = dec2bin(I_neg_weight_fc1'-1,8);
I_pos_weight_fc2_bin = dec2bin(I_pos_weight_fc2'-1,8);
I_neg_weight_fc2_bin = dec2bin(I_neg_weight_fc2'-1,8);
I_pos_weight_fc3_bin = dec2bin(I_pos_weight_fc3'-1,8);
I_neg_weight_fc3_bin = dec2bin(I_neg_weight_fc3'-1,8);
I_bias_fc1 = dec2bin(I_bias_fc1'-1,4);
I_bias_fc2 = dec2bin(I_bias_fc2'-1,4);
I_bias_fc3 = dec2bin(I_bias_fc3'-1,4);

%O_data = I_data * (I_pos_weight_fc1 - I_neg_weight_fc1);

fid_data_in = fopen('D:\project\OPU\OPU_matlab\FC1_sim_data\I_data.txt', 'w');%需要先打开一个文件
fid_I_pos_weight_fc1 = fopen('D:\project\OPU\OPU_matlab\FC1_sim_data\I_pos_weight_fc1.txt', 'w');
fid_I_neg_weight_fc1 = fopen('D:\project\OPU\OPU_matlab\FC1_sim_data\I_neg_weight_fc1.txt', 'w');
fid_I_bias_fc1 = fopen('D:\project\OPU\OPU_matlab\FC1_sim_data\I_bias_fc1.txt', 'w');
fid_I_pos_weight_fc2 = fopen('D:\project\OPU\OPU_matlab\FC1_sim_data\I_pos_weight_fc2.txt', 'w');
fid_I_neg_weight_fc2 = fopen('D:\project\OPU\OPU_matlab\FC1_sim_data\I_neg_weight_fc2.txt', 'w');
fid_I_bias_fc2 = fopen('D:\project\OPU\OPU_matlab\FC1_sim_data\I_bias_fc2.txt', 'w');
fid_I_pos_weight_fc3 = fopen('D:\project\OPU\OPU_matlab\FC1_sim_data\I_pos_weight_fc3.txt', 'w');
fid_I_neg_weight_fc3 = fopen('D:\project\OPU\OPU_matlab\FC1_sim_data\I_neg_weight_fc3.txt', 'w');
fid_I_bias_fc3 = fopen('D:\project\OPU\OPU_matlab\FC1_sim_data\I_bias_fc3.txt', 'w');

I_data_bin_trans = I_data_bin';
for i=1:DATA_NUM
fprintf(fid_data_in,'%s\r\n',I_data_bin_trans(:,ARRAY_ROW_NUM_FC1*(i-1)+1:ARRAY_ROW_NUM_FC1*i));
end

fprintf(fid_I_pos_weight_fc1,'%s',I_pos_weight_fc1_bin');
fprintf(fid_I_neg_weight_fc1,'%s',I_neg_weight_fc1_bin');
fprintf(fid_I_bias_fc1,'%s',I_bias_fc1');
fprintf(fid_I_pos_weight_fc2,'%s',I_pos_weight_fc2_bin');
fprintf(fid_I_neg_weight_fc2,'%s',I_neg_weight_fc2_bin');
fprintf(fid_I_bias_fc2,'%s',I_bias_fc2');
fprintf(fid_I_pos_weight_fc3,'%s',I_pos_weight_fc3_bin');
fprintf(fid_I_neg_weight_fc3,'%s',I_neg_weight_fc3_bin');
fprintf(fid_I_bias_fc3,'%s',I_bias_fc3');

fclose(fid_data_in)
fclose(fid_I_pos_weight_fc1)
fclose(fid_I_neg_weight_fc1)
fclose(fid_I_bias_fc1)
fclose(fid_I_pos_weight_fc2)
fclose(fid_I_neg_weight_fc2)
fclose(fid_I_bias_fc2)
fclose(fid_I_pos_weight_fc3)
fclose(fid_I_neg_weight_fc3)
fclose(fid_I_bias_fc3)
