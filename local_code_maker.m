function local_code=local_code_maker(num_code,frebin,num_sample_code_60M,rate_code,k_sample,num_sample_code)
load ca_code.mat

num_code=round(num_code);

ca_code=ca_code(1:num_code);
code_temp=[ca_code ca_code];

index=ceil((1:num_sample_code_60M)*(rate_code+frebin*0.000001)/60);
sample_code_temp=code_temp(index);
sample_code=sample_code_temp(1:k_sample:num_sample_code_60M);
local_code=[sample_code zeros(1,32768-num_sample_code)];
