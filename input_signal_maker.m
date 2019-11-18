function output=input_signal_maker(C_N,pinpian,frebin,k_doppler,length_frebin,num_sample_input,num_code,code_delay,rate_code,t_delay)

load ca_code.mat;

num_code=round(num_code);
p_noise_db=10*log10(15)+60-C_N;
var_noise=sqrt(10^(p_noise_db/10));

n=0:num_sample_input-1;
carry=cos(2*pi*(46.52+pinpian*0.000001)*n/60+2*pi*rand(1));


ca_code=ca_code(1:num_code);
code_temp=[ca_code ca_code ca_code ca_code];
a=round(rand(1)*3);

code_temp((num_code*a+1):num_code*4)=-code_temp((num_code*a+1):num_code*4);
code_temp=[code_temp(num_code*4-code_delay+1:num_code*4) code_temp(1:num_code*4-code_delay)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diff_temp=(pinpian-frebin*length_frebin)*k_doppler*0.001*t_delay;
fan=diff_temp/(rate_code+pinpian*0.000001*k_doppler);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
index=ceil(((1:num_sample_input)/60+fan)*(rate_code+pinpian*0.000001*k_doppler));
sample_code=code_temp(index+num_code);

input_signal=carry.*sample_code+wgn(1,num_sample_input,p_noise_db);

input_signal=input_signal/(3*var_noise);

input_signal((input_signal>1))=1;
input_signal((input_signal<-1))=-1;
output=input_signal;


