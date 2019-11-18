function output=quadrature2filter(I_carry,Q_carry,input,num_sample_input,num_sample_code,sample1,sample2)
load tap_filter1.mat;
load tap_filter2.mat;


I_input_filter1=input.*I_carry;
Q_input_filter1=input.*Q_carry;
I_filter1_output=filter(tap_filter1,1,I_input_filter1);
Q_filter1_output=filter(tap_filter1,1,Q_input_filter1);


I_input_filter2=I_filter1_output(1:sample1:num_sample_input);
Q_input_filter2=Q_filter1_output(1:sample1:num_sample_input);
I_filter2_output=filter(tap_filter2,1,I_input_filter2);
Q_filter2_output=filter(tap_filter2,1,Q_input_filter2);


output=[I_filter2_output(1:sample2:end)+sqrt(-1)*Q_filter2_output(1:sample2:end),zeros(1,32768-num_sample_code*2)];


