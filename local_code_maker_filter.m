function local_code=local_code_maker_filter(num_code,frebin,num_sample_code_60M,rate_code,k_sample,num_sample_code)
load ca_code.mat
load tap_filter1.mat;
load tap_filter2.mat;

num_code=round(num_code);
ca_code_temp=ca_code;
for ii=2:(num_code/1023)
     ca_code_temp=[ca_code_temp ca_code];
end
ca_code=ca_code_temp;
code_temp=[ca_code ca_code];

index=ceil([1:num_sample_code_60M]*(rate_code+frebin*0.000001)/60);
sample_code_temp=code_temp(index);
I_filter1_output=filter(tap_filter1,1,sample_code_temp);

I_input_filter2=I_filter1_output(1:5:60000);
I_filter2_output=filter(tap_filter2,1,I_input_filter2);
sample_code=I_filter2_output(1:8:end);
local_code=[sample_code zeros(1,32768-num_sample_code)];
