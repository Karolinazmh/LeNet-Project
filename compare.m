% clc;
% clear all;
%%��ȡӲ����·������
fid = fopen('C:\Users\xt\Desktop\ziliao\Matlab\150-16\O_data.txt','r');
line = 1; %�б��
NUM=100;
vector_length=16;%��������
data_length=17;%ÿһ�����λ��
while ~feof(fid)
   lineData = fgetl(fid);
   fpga_result_bin(line,:)=lineData;%��fpga_result.txt�е���ֵ����fpga_result_bin��
   line=line+1;
end
fclose(fid);
fpga_result_dec=zeros(NUM,vector_length);
for i=1:NUM
   tmp_vector=fpga_result_bin(i,:);%���ж�ȡ�������
   for j=1:vector_length
      tmp_data=tmp_vector((j-1)*data_length+1  :  j*data_length);%ÿ��ÿdata_lengthλ��ȡһ��
      fpga_result_dec(i,j)=bin2dec_signed(tmp_data,data_length);
   end
end
