clc;
clear all;
%%读取硬件电路计算结果
fid = fopen('D:\project\OPU\OPU_matlab\FC1_sim_data\fc1_result.txt','r');
line = 1; %行标记
NUM=1;
vector_length=120;%阵列列数
data_length=17;%每一列输出位宽
while ~feof(fid)
   lineData = fgetl(fid);
   fpga_result_bin(line,:)=lineData;%将fpga_result.txt中的数值读到fpga_result_bin中
   line=line+1;
end
fclose(fid);
fpga_result_dec=zeros(NUM,vector_length);
for i=1:NUM
   tmp_vector=fpga_result_bin(i,:);%按行读取结果向量
   for j=1:vector_length
      tmp_data=tmp_vector((j-1)*data_length+1  :  j*data_length);%每行每data_length位读取一次
      fpga_result_dec(i,j)=bin2dec_signed(tmp_data,data_length);
   end
end
