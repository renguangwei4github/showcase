clear;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%variables that need to adjust
C_N=37;%C/N0
th_times=6;%seconde threshold
type_jilei=2;%type of accumulation£º
             %1:square and average£¬2:square and accumulation£¬3:abs and accumulation
start5=1;%when to find the peak
         %0:find from the first accumulation,1:find from the fifth accumulation
filter_delay=18;%delay of the filter
pinpian=250;%difference of frequency£¬Hz
NUM_tongji=100;%times of simulation
NUM_frebin=5;%times of frequencey slot
rate_code=1.023*1;%code rate,MHz
period_code=1;%code period, ms
rate_sample=3;%smaple rate, MHz
sample1=5;%sample period of the 1st filter
sample2=4;%sample period of the 2nd filter
length_frebin=500;%span of frequency slot£¬Hz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%constants
code_delay=100;%code delay
k_doppler=rate_code/1268.52;%ratio of the dopper shift
num_code=rate_code*period_code*1000;%number of the code in one period
num_sample_input=2*period_code*60000;%input sample rate
num_sample_code_60M=period_code*60*1000;%number of the sample in one period
num_sample_code=period_code*rate_sample*1000;%number of the re-sample in one period
k_sample=60/rate_sample;
code_th1=code_delay*60/rate_code-1.5*60/rate_code;%code_th1 and code_th2 the threshold of code delay
code_th2=code_delay*60/rate_code+1.5*60/rate_code;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
true=0;%number of acquisite successfully
buhuo_true=0;
for num_tongji=1:NUM_tongji
    flag=0;%flag of of acquisite successfully
    %%%%%%%%%%
    frebin=0; 
    for num_frebin=1:NUM_frebin %process the frequencey slots
        
        %do FFT on local code   
        local_code=local_code_maker(num_code,frebin*length_frebin*k_doppler,num_sample_code_60M,rate_code,k_sample,num_sample_code);%create local code, Hz
        code_local_fft=conj(fft(local_code));
        %produce carriers for I and Q
        n=0:num_sample_input-1;
        I_carry=cos(2*pi*(46.52+frebin*length_frebin*0.000001)*n/60);
        Q_carry=sin(2*pi*(46.52+frebin*length_frebin*0.000001)*n/60);
        t_delay=0;
        %begin dwell
        num_dwell_ok=0;%times of dwell
        dwell=0;%used to store the code delay
        for num_dwell=1:5 %dwell 5 times
            
            accum=0;%number of accumulation
            for num_accum=1:10 
                
                
                input_signal=input_signal_maker(C_N,pinpian,frebin,k_doppler,length_frebin,num_sample_input,num_code,code_delay,rate_code,t_delay);%create input signal
             
                output=quadrature2filter(I_carry,Q_carry,input_signal,num_sample_input,num_sample_code,sample1,sample2);%I,Q demodulation
                input_fft=fft(output);
                result=(ifft(code_local_fft.*input_fft));
                
                if type_jilei==1%square and average
                   result=abs(result);
                   accum_temp1=result(1:num_sample_code).^2;
                   accum_temp2=[accum_temp1(2:end) 0];
                   accum_temp=accum_temp1+accum_temp2;
                elseif type_jilei==2%accumulation of square
                   result=abs(result);
                   accum_temp=result(1:num_sample_code).^2;
                elseif type_jilei==3%accumulation of abs
                   
                   for i=1:num_sample_code
                       bignum=abs(real(result(i))); 
                       litnum=abs(imag(result(i)));
                       if bignum<litnum
                           temp=bignum;
                           bignum=litnum;
                           litnum=temp;
                       end
                       if bignum>=3*litnum
                           accum_temp(i)=bignum+litnum/8;
                       else
                           accum_temp(i)=7*bignum/8+litnum/2;
                       end
                   end%for               
                end%
                accum=accum+accum_temp(1:num_sample_code);
                
             
                if start5==1
                    if num_accum<5
                        t_delay=t_delay+6;
                    end
                    if num_accum<5 
                       continue;
                    end 
                else
                    t_delay=t_delay+6;
                end
                
                
                [C Y]=max(accum);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %computing the average, var
                accum_mean=mean(accum);
                accum_var=sqrt(var(accum));
                th_high=accum_mean+20*accum_var;
                th_low=accum_mean+th_times*accum_var;
                %%%%%%%%%%%%%%%%%%%%%%%%%%
                C
                th_low
                Y-1
                (C-accum_mean)/accum_var
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
             %campare the peak with threshold
                if (C>th_high)
                   flag=1;
                   ca_delay=Y-1;
                   break;
                end
                if (th_low<C && C<=th_high)
                   num_dwell_ok=num_dwell_ok+1;
                   dwell(num_dwell_ok)=Y-1;
                   break;
                end
            end%
            
            if flag==1
                break;
            end
            
            if(num_dwell_ok>=3)%dwell well more 3 times
               dwell_temp=dwell;
               %ascending sort
               for i=1:num_dwell_ok-1
                   for j=i+1:num_dwell_ok
                        if(dwell_temp(i)>dwell_temp(j))
                           dwell_exchange=dwell_temp(i);
                           dwell_temp(i)=dwell_temp(j);
                           dwell_temp(j)=dwell_exchange;
                        end
                   end
               end
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                dwell_temp=[dwell_temp dwell_temp(1:2)+num_sample_code];
                for i=3:num_dwell_ok+2
                   if(dwell_temp(i)-dwell_temp(i-2)<=2)
                      flag=1;
                      ca_delay=mean(dwell_temp(i-2:i));
                      break;
                   end
                end%for
                
            end%if
            
            
            if flag==1
                break;
            end
            %move to next frequencey slot
            if(((5-num_dwell+num_dwell_ok)<3)||((num_dwell==1)&&(num_dwell_ok==0)))
                break;
            end
            
        end%
            
        
        if flag==1
            break;
        end      
        
        %change frequencey slot
        if(frebin>=0)
            frebin=-(frebin+1)
        else
            frebin=-frebin
        end
        
    end%
    
    %%%%%%%%%%
    if flag==1
        buhuo_true=buhuo_true+1
        ca_adjust=fix(ca_delay)*k_sample-filter_delay;
        if ca_adjust<0
            ca_adjust=ca_adjust+num_sample_code_60M;
        end
        if ca_adjust>num_sample_code_60M
            ca_adjust=ca_adjust-num_sample_code_60M;
        end
        if ((code_th1<=ca_adjust)&&(ca_adjust<=code_th2))
           true=true+1
        end
    end
    %%%%%%%%%%%%
end%
buhuo=true/num_tongji*100

 