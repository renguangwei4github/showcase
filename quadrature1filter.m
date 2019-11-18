function output=quadrature1filter(I_carry,Q_carry,input,num_sample_input,num_sample_code,sample1,sample2)
load tap_filter1.mat;



I_input_filter1=input.*I_carry;
Q_input_filter1=input.*Q_carry;
I_filter1_output=filter(tap_filter1,1,I_input_filter1);
Q_filter1_output=filter(tap_filter1,1,Q_input_filter1);




output=[I_filter1_output(1:sample1:end)+sqrt(-1)*Q_filter1_output(1:sample1:end),zeros(1,32768-num_sample_code*2)];


