clear;
clc;
clear all;

%%Import data

Participants = input("No. of desired participants (6, 10, 20, 50, 500, 5000, 16000): " ); %input number of participants

if Participants == 6
    x = '6participants.xlsx';
elseif Participants == 20
    x = '20-participants.xlsx';
elseif Participants == 50
    x = '50-participantsL.xlsx';
elseif Participants == 10
    x = '10participants80-20.xlsx';
elseif Participants == 5000
    x = '5k-participants.xlsx';
elseif Participants == 16000
    x = '16k-participants1C.xlsx';
else
    x = '500-participants.xlsx';
end

uy = 1;
auto = input('Do you want to run a pre defined setting? (1 or 0): ');
if auto == 1
    array = xlsread(x,'iterations');
    cs = 3;
    num = 0;
    scen = 6;
    po = length(array);
    percent = zeros(1,po);
else 
    po = 1;
end
for ju = 1:po
%Data
LoadCurve = (xlsread(x, 'Load'));      % Load Data of customers every 15 min
Generation = (xlsread(x,'Generation'));   % Generation Data every 15 min
Initial_ACDR = (xlsread(x, 'Initial ACDR'));  % initial ACDR

%Data of participants
Capacity = (xlsread(x, 'CAPACITY'));  % DR capacity of participants for a day
Start_t = xlsread(x, 'Start Time'); % Start time of preferred time slot of participants
End_t = xlsread(x, 'End Time'); % End time of preffered time slot of participants
resp = (xlsread(x, 'Response'));  % Discrete flexible load of participants
loc =  xlsread(x, 'Area');  % area of participant's location
[time data] = size(LoadCurve);

TotalLoad = Generation(:,3);    % Total load of the system
TotalGen = Generation(:,2);     % Total generation of the system
time = Generation(1:96,1);      % time (1:96)
N = Participants;               % number of customers


%% Initialize matrices and variables
P_ACDR   = zeros(1,length(time)-2);     % ACDR 
DRsignal = zeros(1,length(time)-2);     % DR signal
act_sig  = zeros(1,length(time)-2);     % Activation Signal
CDR      = zeros(1,N);
second_iter = 0;
temp_loc = [];  %temporary location
xx = 1;
pp = 1;
nog = length(unique(loc));

% dictionaries for coalition
group = dictionary();
group_CDR = dictionary();
time_res  = dictionary();
group_int = dictionary();
indiv_res = dictionary();
group_pick = dictionary();
group_pick2 = dictionary();
group_res = dictionary();
group_load = dictionary();


%% Initial CDR & Coalition setting

if auto ~= 1
    fprintf('\n1: Baseline Scenario no Coalitions.\n2: Coalitions based on location ONLY\n3: Coalitions based on location but limit to x number of participants\n\n');
    cs = input('Choose Coalition Protocol: ');
end
for i = 1:length(Capacity)
     CDR(i) = (Capacity(i)/sum(Capacity,2))*Initial_ACDR;   % initial CDR of participants based on capacity
end

% Coalition setting 
if cs ~= 1
    if cs == 2 || cs == 3
      for ii = 1:length(loc)
          group{loc(ii)} = [];  % Set locations as keys
      end
      for ii = 1:length(loc)
          group{loc(ii)} = [group{loc(ii)} ii]; % put index of participants in dictionary based on loc
      end
      avail_grp = sort(keys(group));    % sort locations

      if cs == 3
         if auto ~=1
            dt = input('pick number of participants per coalition:');   % limits the num of participants in a group
         elseif auto == 1
             dt = array(ju);
         end
         for ii = 1:length(avail_grp)   % check for every coalition
           yt = 1;
           top = 1;
           avail_grp = sort(keys(group));
           if length(group{avail_grp(ii)}) > dt % checks if # of participants in a group exceeds limit
                % regroups the coalition based on limit
                group{avail_grp(end)+yt} = group{avail_grp(ii)}([dt+1:end]);
                group{avail_grp(ii)} = group{avail_grp(ii)}([1:dt]);
                yt = yt+1;
                avail_grp = sort(keys(group));
                while length(group{avail_grp(end)}) > dt
                    group{avail_grp(end)+top} = group{avail_grp(end)}(dt+1:end);
                    avail_grp = sort(keys(group));
                    group{avail_grp(end-1)}   = group{avail_grp(end-1)}(1:dt);
                    avail_grp = sort(keys(group));
                end
           end
        end
      end
    end

    avail_grp = keys(group);    

for ix = 1:length(avail_grp)
     group_pick{avail_grp(ix)} = zeros(length(time)-2,length(group{avail_grp(ix)}));
     group_CDR{avail_grp(ix)}  = zeros(1,length(time)-2);
     group_res{avail_grp(ix)}  = zeros(1,length(time)-2);
     indiv_res{avail_grp(ix)}  = zeros(length(time)-2,length(group{avail_grp(ix)}));
end

for i = 1:length(avail_grp)
    y = 1;
    for u = 1:length(group{avail_grp(i)})
        % get discrete responses of participants per group
        group_int{avail_grp(i)}(y) = resp(group{avail_grp(i)}(u));  
        y = y+1;
    end
end
end 
coalitions = group;

%% Loops per time interval
% ACDR Computation
for t=1:(length(time)-2)  % time
        if t == 1   % initialization
            P_Load = TotalLoad(t+1);                 % total Load at time t 
            P_RES = TotalGen(t+1);                   % total Generation at time t
            P_ACDR(t) = (P_RES - TotalGen(t))-(P_Load - (TotalLoad(t)));    % ACDR at time t
        else
            P_Load = TotalLoad(t+1);                   % total Load at time t 
            P_RES = TotalGen(t+1);                     % total Generation at time t
            P_ACDR(t) = (P_RES - TotalGen(t))-(P_Load - (TotalLoad(t)));    % ACDR at time t
            fprintf('\nP_ACDR = %d at time %d', P_ACDR(t),t)
        end
     
       %check ACDR if DR is needed
       if P_ACDR(t)==0  % no imbalance
           act_sig(t) = 1;
           DRsignal(t) = 0;
           fprintf("\nNo need for demand response at t = %d \n", t)
       elseif P_ACDR(t) ~= 0
           fprintf("\nISO calls for demand response at t = %d \n", t)
           DRsignal(t) = 1;
       end 
       

       % Activation Signal Computation
       if t == 1 && DRsignal(t) ~= 0
           act_sig(t) = ((P_ACDR(t)-Initial_ACDR)/Initial_ACDR);
           
       elseif DRsignal(t) ~= 0
           if P_ACDR(t-1) == 0  % check if previous ACDR is 0
               dex = find(P_ACDR,2,"last"); % finds previous ACDR that is non-zero
               act_sig(t) = activation(P_ACDR(t),P_ACDR(dex(1)));
           else
               act_sig(t) = activation(P_ACDR(t),P_ACDR(t-1));  %computes for the activation signal at time t
           end
       end

       if t == 1   % checker on when to use initialize CDR and Arrays
            first_iter =  1; 
            P_b          = []; % array for power snapshots
            upperL       = zeros(length(time)-2,N); % array for upper limit
            lowerL       = zeros(length(time)-2,N); % array for lower limit
            CDR_         = zeros(length(time)-2,N); % array for CDR (Will transfer after cascading)
            idealCons    = zeros(length(time)-2,N); % array for ideal consumption after DR
            AfterDR_Final = zeros(length(time)-2);
            AfterDR_Final_indiv = zeros(length(time)-2, N);
            finalDR      = zeros(length(time)-2);
            if auto ~= 1
                scen      =  0; % scenario picker
            end
       else
            first_iter =  0;
       end

        for i = 1:N     % loops every participant
            P_b(t,i) = LoadCurve(t,i);                 % saving snapshots 

            % Computation of Limits on Preferred Time Slot
            if t < Start_t(i) || t > End_t(i)   % not within time slot
                Limit(t,i) = P_b(t,i);
                DR_sig(t,i) = 0;    % cannot participate at time t
            else
                Limit(t,i) = P_b(t,i) + resp(i);
                DR_sig(t,i) = 1;  % can participate at time t
            end
            
            % Computation of CDR
            if first_iter == 1    
                % initialization on the first call of a DR event
                CDR_(1,i)  = (1+act_sig(t))*CDR(1,i);
            else
                CDR_(t,i) = (1+act_sig(t))*CDR_(t-1,i);
            end
        end

    %% Actual DR
    
        if scen == 0 || scen == 1 || scen == 2 || scen == 3 && auto ~= 1
            fprintf('1: Baseline Scenario no DR event.\n2: Ideal Scenario DR event occurs but no coalitions.\n3: Non-ideal Scenario DR event occurs with coalitions.\n4: Hold Option 1.\n5: Hold Option 2.\n6: Hold Option 3.\n\n');
            scen = input('   Please select desired scenario no.: ');
        end

        %% Demand Responses per customer
        for i = 1:N
            % computes for ideal consumption per customer at time t
            if DR_sig(t,i)==0
                idealCons(t,i) = (LoadCurve(t,i));
            else
                idealCons(t,i) = (LoadCurve(t,i)) + CDR_(t,i); 
            end

            final(t,i) = (LoadCurve(t,i)) + CDR_(t,i);

            if scen == 1 || scen == 4 ; % no DR event
                AfterDR_Final_indiv(t,i) = (P_b(t,i));  % no responses

            elseif scen == 2 || scen == 3 || scen == 5 || scen == 6 % DR event but with no coalitions
              if t >= Start_t(i) && t<= End_t(i)
                   if resp(i) > 0 && CDR_(t,i) > 0  % checks if response and CDR are both positive
                      if abs(abs(CDR_(t,i))-abs(resp(i))) < abs(CDR_(t,i))  % assess whether the customer responds
                          AfterDR_Final_indiv(t,i) = (P_b(t,i)) + resp(i);
                       else
                           AfterDR_Final_indiv(t,i) = P_b(t,i);
                      end
                   elseif resp(i) < 0 && CDR_(t,i) < 0  % checks if response and CDR are both negative
                       if abs(abs(CDR_(t,i))-abs(resp(i))) < abs(CDR_(t,i)) % assess whether the customer responds
                          AfterDR_Final_indiv(t,i) = (P_b(t,i)) + resp(i);
                       else
                           AfterDR_Final_indiv(t,i) = (P_b(t,i));
                       end
                   else
                        AfterDR_Final_indiv(t,i) = (P_b(t,i));
                 
                   end                
               else
                    AfterDR_Final_indiv(t,i) = (P_b(t,i));
               end
               no_coa_DR(t,i) = AfterDR_Final_indiv(t,i);
            end
            
        end
        
        if scen == 3 || scen == 6;
           for ix = 1:length(avail_grp) 
               group_CDR{avail_grp(ix)}  = Total_cdr(t, group{avail_grp(ix)}, CDR_,group_CDR{avail_grp(ix)});
               group_pick{avail_grp(ix)} = coalition_response(t, group_int{avail_grp(ix)}, group_CDR{avail_grp(ix)},group_pick{avail_grp(ix)});
               group_pick{avail_grp(ix)} = coalition_timer(t, Start_t, End_t, group_pick{avail_grp(ix)}, group{avail_grp(ix)});
               group_res{avail_grp(ix)}  = coalition_responder(t, group_pick{avail_grp(ix)}, group{avail_grp(ix)}, group_res{avail_grp(ix)});
               finalDR(t) = finalDR(t) + group_res{avail_grp(ix)}(t);
               indiv_res{avail_grp(ix)}  = indiv_responder(t, group{avail_grp(ix)}, group_pick{avail_grp(ix)}, group_int{avail_grp(ix)}, indiv_res{avail_grp(ix)}, P_b);
               AfterDR_Final_indiv = dic2mat(t, group{avail_grp(ix)}, indiv_res{avail_grp(ix)}, AfterDR_Final_indiv);
            end
               AfterDR_Final(t) = finalDR(t) + sum(P_b(t,:));
               yes_coa_DR = AfterDR_Final_indiv;
        end    
end


        
%% Plot System-level Results
timed = [1:1:94]; 
if scen == 3 || scen == 6
    figure(1)
    hold on
    stairs(timed,sum(final,2)/1000);
    stairs(timed,sum(AfterDR_Final_indiv,2)/1000);
    stairs(timed,sum(P_b,2)/1000);
    hold off
    legend('Desired Load Profile', 'After DR','Before DR','Location', 'northwest');
    title('System Level Response');
    xlabel('Time');
    ylabel('Power (kW)');

    figure(4)
    hold on
    stairs(time.',TotalGen/1000);
    stairs(time.',TotalLoad/1000);
    hold off
    legend('Total Generation', 'Total Load','Location', 'northwest');
    title('System-level Generation-Demand Curve');
    xlabel('Time');
    ylabel('Power (kW)');
    
    a = sum(CDR_,2);
    g = sum(final,2);
    y = sum(AfterDR_Final_indiv,2);
    z = sum(AfterDR_Final_indiv,2);
    w = sum(P_b,2);
    
    no_DR = immse(g,w);
    y_DR  = immse(g,z);
    number(uy)  = cs;
    percent(uy) = ((no_DR-y_DR)/no_DR)*100;  
    uy = uy+1;
    before = area(g,w)*0.25/1000;
    after = area(g,z)*0.25/1000;
    fulfillment = 100*((before-after)/before);
else
    figure(1)
    hold on
    stairs(timed,sum(final,2));
    stairs(timed,sum(AfterDR_Final_indiv,2));
    stairs(timed,sum(P_b,2));
    hold off
    legend('Desired Load Profile', 'After DR','Before DR','Location', 'northwest');
    title('System Level Response')
    
    figure(4)
    hold on
    stairs(time.',TotalGen/1000);
    stairs(time.',TotalLoad/1000);
    hold off
    legend('Total Generation', 'Total Load','Location', 'northwest');
    title('System-level Generation-Demand Curve');
    xlabel('Time');
    ylabel('Power (kW)');
    
    a = sum(CDR_,2);
    g = sum(final,2);
    y = sum(AfterDR_Final);
    z = sum(AfterDR_Final_indiv,2);
    w = sum(P_b,2);
    
    no_DR = immse(g,w);
    y_DR  = immse(g,z);
    number(uy)  = cs;
    percent(uy) = ((no_DR-y_DR)/no_DR)*100;
    uy = uy+1;
    before = area(g,w)*0.25/1000;
    after = area(g,z)*0.25/1000;
    fulfillment = 100*((before-after)/before);
end

%% Conclusions

if scen == 1 || scen == 4 ;
  fprintf("\nNo DR event occured. The MSE between the desired load profile and the actual load profile is: %f \n", no_DR)
elseif scen == 2 || scen == 5;

  fprintf("\nDR event occured. The MSE between the desired load profile and the actual load profile is: %f", y_DR)
  fprintf("\nWhile the MSE when there is no DR event is:%f \n", no_DR)

  if y_DR < no_DR
      fprintf("\nTherefore, the DR event improved the system imbalance.\n")
      fprintf("That is a %f or %f improvement.\n", abs(no_DR-y_DR), abs(100*(no_DR-y_DR)/no_DR) )
  elseif y_DR > no_DR
      fprintf("\nTherefore, the DR event worsened the system imbalance\n")
  else
       fprintf("\nTherefore, the DR event neither improved nor worsened the system imbalance\n")
  end
elseif scen == 3 || scen == 6;
  fprintf("\nDR event occured. The MSE between the desired load profile and the actual load profile is: %f", y_DR)
  fprintf("\nWhile the MSE when there is no DR event is:%f \n", no_DR)

  if y_DR < no_DR
      fprintf("\nTherefore, the DR event improved the system imbalance.\n")
      fprintf("That is a %f or %f percent improvement.\n", abs(no_DR-y_DR),abs(((no_DR-y_DR)/no_DR)*100))
      fprintf("%f percent of the ACDR is fulfilled by the demand response.\n", fulfillment)
      fprintf("ACDR: %f kWh \n", before)
      fprintf("Unfulfilled ACDR: %f kWh \n", after)
      fprintf("Fulfilled ACDR: %f kWh\n", before-after)
  elseif y_DR > no_DR
      fprintf("\nTherefore, the DR event worsened the system imbalance\n")
  else
       fprintf("\nTherefore, the DR event neither improved nor worsened the system imbalance\n")
  end
end

%% Histogram of ACDR
figure(5)
histogram(P_ACDR/1000);
legend('ACDR')
title('Histogram of ACDR');
xlabel('Power (kW)');
ylabel('Frequency');

%% Discrete Responses of Participants in their Corresponding Groups
mem = [];
c = values(group_int);
mem_count=[];

for z=1:length(avail_grp)
    cap_nega = 0; cap_posi = 0;
    grp = c{z};
    mem_count(z) = numel(grp);
    nega = 0; posi = 0;
    for y=1:mem_count(z)
        if grp(y)<0
            nega = nega + 1;
            cap_nega = cap_nega + grp(y);
        else
            posi = posi + 1;
            cap_posi = cap_posi + grp(y);
        end
    end
    mem(z,1) = nega;
    mem(z,2) = posi;
    capacity(z,1) = abs(cap_nega)/1000;
    capacity(z,2) = cap_posi/1000;
end

figure(8);  
bar(avail_grp,mem);
legend('negative discrete responses','positive discrete responses');
xlabel('Group Number');
ylabel('Number of Participants');
title('Distribution of Participants in Coalitions');

figure(9);
bar(avail_grp,capacity);
title('Total Discrete Responses per Coalition');
xlabel('Group Number');
ylabel('Capacity (kW)');
legend('Load Decrease', 'Load Increase')

for t=1:94
    for h=1:length(avail_grp)
        group_mem = group(avail_grp(h));
        group_mem = cell2mat(group_mem);
        CAP_n(t,h) = cap_time(t,group_mem,Start_t,End_t,resp,-1);
        CAP_p(t,h) = cap_time(t,group_mem,Start_t,End_t,resp,1);
    end
end
figure(10);
bar(timed,CAP_n/1000);
title('Total Load Decrease Capacity of Coalitions per Time')
xlabel('Time');
ylabel('Capacity (kW)');

figure(11);
bar(timed,CAP_p/1000);
title('Total Load Increase Capacity of Coalitions per Time')
xlabel('Time');
ylabel('Capacity (kW)');


%% Plot percent improvement comparison
if scen == 3 || scen == 6
    n_coa = sum(no_coa_DR,2);
    y_coa = sum(yes_coa_DR,2);
    pi1 = immse(g,n_coa);
    pi2 = immse(g,y_coa);
    pi = [abs(100*(no_DR-pi1)/no_DR), abs(100*(no_DR-pi2)/no_DR)];
    pc = categorical({'no coalitions','with coalitions'});
    
    figure(6);
    bar(pc,pi);
    legend('Percent System Improvement')
    title('Percent Improvement Comparison')
end

%% Plot percent fulfillment per coalition
for i=1:length(avail_grp)
    group_mem = group(avail_grp(i));
    group_mem = cell2mat(group_mem);
    pipc(i) = coalition_pi(P_b, AfterDR_Final_indiv, final, group_mem);
end
figure(7);
bar(avail_grp,pipc);
xlabel('Group Number');
ylabel('Percent Fulfillment');
title('Percent Fulfillment of Each Coalition to their Corresponding CDRs')

%% Plot Difference
final_kW = sum(final,2)/1000;
afterdr_kW = sum(AfterDR_Final_indiv,2)/1000;
beforedr_kW = sum(P_b,2)/1000;
figure(12)
    hold on
    plot(timed,final_kW);
    plot(timed,beforedr_kW);
    patch([timed(:); flip(timed(:))], [final_kW; flip(beforedr_kW)], 'b', 'FaceAlpha',0.25, 'EdgeColor','none')
    legend('Desired Load Profile','No DR','Location', 'northwest');
    title('ACDR');
    xlabel('Time');
    ylabel('Power (kW)');
    hold off

    figure(13)
    hold on    
    plot(timed,final_kW);
    plot(timed,afterdr_kW);
    patch([timed(:); flip(timed(:))], [final_kW; flip(afterdr_kW)], 'b', 'FaceAlpha',0.25, 'EdgeColor','none')
    legend('Desired Load Profile','After DR','Location', 'northwest');
    title('ACDR Fulfillment')
    xlabel('Time');
    ylabel('Power (kW)');
    hold off 

%% Plot time shot histogram
    figure(14)
    hold on
    for i=1:94
        num_P(i) = num_participants(i,Participants,Start_t,End_t);
    end
    bar(timed,num_P);
    title('Active Participants per Time Slot')
    xlabel('Time');
    ylabel('Number of Participants');
    hold off

%% Plot scatter plot

sca = 0;
if auto ~= 1
    sca = input('\nDo you want to plot the scatter plot now? (1 or 0): ');
end
if sca == 1 || (ju == po && auto == 1)
    scatter(array, percent)
end

%% Plot individual participant 
while 1
    if auto ~= 1
        num = input('\nWhich participant do you wish to observe: '); %enter number of customer to plot
    end
    if num == 0
        break
    end
    
    
    figure(2)
    subplot(3,1,1)
    hold on
    stairs(timed,final(:,num),'b');
    stairs(timed,P_b(:,num));
    hold off
    legend('Desired Load Profile','Before DR','Location','northwest');
    
    if scen == 5 
        subplot(3,1,2)
        hold on
        stairs(timed,AfterDR_Final_indiv(:,num),'k');
        stairs(timed,Limit(:,num),"--");
        hold off
        legend('After DR','upper limit','lower limit','Location', 'northwest');
    else
        subplot(3,1,2)
        hold on
        stairs(timed,AfterDR_Final_indiv(:,num),'k');
        stairs(timed,Limit(:,num),"--");
        hold off
        legend('After DR','Limit','Location', 'northwest');
    end
    
    subplot(3,1,3)
    hold on
    stairs(timed,final(:,num),'b');
    stairs(timed,AfterDR_Final_indiv(:,num),'k');
    hold off
    legend('Desired Load Profile','After DR','Location', 'northwest');
end
end


%% Activation Signal Program
function [r] = activation(ACDR,prevACDR)
    %activation signal formula
    r = ((ACDR-prevACDR)/prevACDR);
end  

%% Picker function
function [picker] = coalition_response(time, discrete_response, Total_CDR, picker)  % Function for the Coalition Response Optimization
    x = length(discrete_response);
    d = zeros(1,length(discrete_response));
    while abs(Total_CDR(time)) > 0
        for num = 1:length(discrete_response)
            d(num) = abs(abs(Total_CDR(time))-abs(discrete_response(num)));
        end
        [best, min_idx] = min(d);
        if best < abs(Total_CDR(time))
            if discrete_response(min_idx) > 0 && Total_CDR(time) > 0 
                    picker(time,min_idx) = discrete_response(min_idx);
                    Total_CDR(time) = Total_CDR(time) - discrete_response(min_idx);
            elseif discrete_response(min_idx) < 0 && Total_CDR(time) < 0
                    picker(time,min_idx) = discrete_response(min_idx);
                    Total_CDR(time) = Total_CDR(time) - discrete_response(min_idx);
            end
        end
        discrete_response(min_idx) = Inf;
        x = x - 1;
        d = zeros(1,length(discrete_response));
        if x == 0
            break
        end
    end
end

function [picker] = coalition_timer(time, start, endt, picker, group)  % Function for checking time slots
    for num = 1:length(group)
       if time < start(group(num)) || time > endt(group(num))
            picker(time,num) = 0;
       end
   end
end
  
function [group_response] = coalition_responder(time, picker, group, group_response) % Function response of coalitions
    group_response(time) = 0;
    for num = 1:length(group)
        if picker(time,num) ~= 0
                group_response(time) = group_response(time) + picker(time,num);
        end
   end
end

function [Total_CDR] = Total_cdr(time, group, CDR_indiv, Total_CDR)               % Function for summing a coalition's CDR
    for num = 1:length(group)
        Total_CDR(1,time) = Total_CDR(1,time) + CDR_indiv(time,group(num));
    end
end

function [indiv_response] = indiv_responder(time, group, picker, discrete_response, indiv_response, curve)  % Function getting the individual response
    for num = 1:length(group)
        if picker(time,num) ~= 0
            indiv_response(time,num) = discrete_response(num) + curve(time,group(num));
        else 
            indiv_response(time,num) = curve(time,group(num));
        end
    end
end

function [mat] = dic2mat(time, group, dic, mat)    % Function for converting a dic to a matrix
    for num = 1:length(group)
        mat(time,group(num)) = dic(time, num);
    end
end

function [coalition_pi] = coalition_pi(P_b, AfterDR, final, group_mem)
    for num = 1:length(group_mem)
        p = group_mem(num);
        for i = 1:94
            no_resp(i,num) = P_b(i,p);
            with_resp(i,num) = AfterDR(i,p);
            ideal(i,num) = final(i,p); 
        end
    end
    ideal = sum(ideal,2);
    no_resp = sum(no_resp,2);
    with_resp = sum(with_resp,2);
    n = area(ideal,no_resp)*0.25;
    y = area(ideal,with_resp)*0.25;
    coalition_pi = 100*((n-y)/n);
end

function [cap_time] = cap_time(time,group_mem,start_time,end_time,resp,s) %returns capacity of group at time t
    cap_time = 0;
    for num = 1:length(group_mem)
        index = group_mem(num);
        if time >= start_time(index) || time <= end_time(index)
            if s == -1
                if resp(index) < 0
                    cap_time = cap_time + resp(index);
                end
            else
                if resp(index) > 0
                    cap_time = cap_time + resp(index);
                end
            end
        end
    end
end

function [area] = area(desired, DR)
    for x = 1:94
        dy(x) = abs(desired(x) - DR(x));
        dy(dy == 0) = 0;
    end
    
    area = trapz(x,dy);
end

function [num_participants] = num_participants(time,participants,start_time,end_time)
    num_participants = 0;
    for i=1:participants
        if (time >= start_time(i) && time <= end_time(i))
            num_participants = num_participants + 1;
        end
    end
end