clc;
clear
fprintf('1: Number of Coalitions.\n2: Distribution of Imbalances\n3: Distribution of Discrete Responses\n4: Distribution of time slots.\n5: Amount of imbalance (less than, greater than, equal to total response).\n6: Coalition Component\n7: Width of time slots\n\n');
cv = input("Choose what to control:");

if cv == 2
    skew = (input("Choose Skewness (N SS S):\n","s"));
    multiH = round(input("Choose value scale:\n"));
      
   if skew == "ss" || skew == "SS"
       pdR = makedist('GeneralizedExtremeValue','k',0.1,'sigma',1,'mu',-2)  
       rng('shuffle')  % For reproducibility
       right = random(pdR,96,1)*multiH;
       left =-1.*right;
       figure(1)
       histfit(right,20,'GeneralizedExtremeValue')
       xlabel("Imabalance (MW)")
       ylabel("Frequency")
       title("Imbalance Histogram for the Entire Time Period (1 Day)")
       figure(2)
       histfit(left,20,'GeneralizedExtremeValue')
       xlabel("Imabalance (MW)")
       ylabel("Frequency")
       title("Imbalance Histogram for the Entire Time Period (1 Day)")
    elseif skew == "S" || skew == "s"
       pdR = makedist('GeneralizedExtremeValue','k',0.1,'sigma',1,'mu',-1)  
       rng('shuffle')  % For reproducibility
       right = random(pdR,96,1)*multiH;
       left =-1.*right;
       figure(1)
       histfit(right,20,'GeneralizedExtremeValue')
       xlabel("Imabalance (MW)")
       ylabel("Frequency")
       title("Imbalance Histogram for the Entire Time Period (1 Day)")
       figure(2)
       histfit(left,20,'GeneralizedExtremeValue')
       xlabel("Imabalance (MW)")
       ylabel("Frequency")
       title("Imbalance Histogram for the Entire Time Period (1 Day)")
    else
        std  = input('enter spread:');
        pd = makedist('Normal','mu',0,'sigma',std);        
        rng('shuffle')  % For reproducibility
        r = random(pd,96,1)*multiH;
        figure(1)
        histfit(r,20,'normal')
        xlabel("Imabalance (MW)")
        ylabel("Frequency")
        title("Imbalance Histogram for the Entire Time Period (1 Day)")
        xlim([-1e6+min(r),max(r)+1e6]);
        %set(gca,'XTick',[-100+min(r) : 200e3 : max(r)+100]);

   end
    
elseif cv == 1
    num = (input("Number of Participants:\n"));
    coal = (input("Number of coalitions:\n"));
    coal = round(coal);
    num = round(num);
    per = round(num/coal);
    c = zeros(1,num);
    idx= 1;
    for i = 1:coal
        cnt = 1;
        while cnt <= per
            c(idx) = i;
            cnt = cnt + 1;
            idx = idx +1;
        end
    end

elseif cv == 3
    skew = (input("Choose Skewness (N SS S):\n","s"));
    multiH = round(input("Choose value scale:\n"));
    num = input("Number of Participants: ")
      
   if skew == "ss" || skew == "SS"
       pdR = makedist('GeneralizedExtremeValue','k',0.1,'sigma',1,'mu',-2)  
       rng('shuffle')  % For reproducibility
       right = random(pdR,num,1)*multiH;
       left =-1.*right;
       figure(1)
       histfit(right,100,'GeneralizedExtremeValue')
       xlabel("Imabalance (MW)")
       ylabel("Frequency")
       title("Imbalance Histogram for the Entire Time Period (1 Day)")
       figure(2)
       histfit(left,100,'GeneralizedExtremeValue')
       xlabel("Imabalance (MW)")
       ylabel("Frequency")
       title("Imbalance Histogram for the Entire Time Period (1 Day)")
    elseif skew == "S" || skew == "s"
       pdR = makedist('GeneralizedExtremeValue','k',0.1,'sigma',1,'mu',-1)  
       rng('shuffle')  % For reproducibility
       right = random(pdR,num,1)*multiH;
       left =-1.*right;
       figure(1)
       histfit(right,100,'GeneralizedExtremeValue')
       xlabel("Imabalance (MW)")
       ylabel("Frequency")
       title("Imbalance Histogram for the Entire Time Period (1 Day)")
       figure(2)
       histfit(left,num,'GeneralizedExtremeValue')
       xlabel("Imabalance (MW)")
       ylabel("Frequency")
       title("Imbalance Histogram for the Entire Time Period (1 Day)")
    else
        std  = input('enter spread:');
        pd = makedist('Normal','mu',0,'sigma',std);        
        rng('shuffle')  % For reproducibility
        r = random(pd,num,1)*multiH;
        figure(1)
        histfit(r,100,'normal')
        xlabel("Imabalance (MW)")
        ylabel("Frequency")
        title("Imbalance Histogram for the Entire Time Period (1 Day)")
        xlim([-1e6+min(r),max(r)+1e6]);
        %set(gca,'XTick',[-100+min(r) : 200e3 : max(r)+100]);
   end


elseif cv == 4
    st = input("set mean start time: ");
    end_t = input("set mean end time: "); 
    std = input("spread(1 is default): ");
    num = (input("Number of Participants:\n"));
    rng('shuffle')
    pde = makedist('Normal','mu',end_t,'sigma',std);    
    pds = makedist('Normal','mu',st,'sigma',std);    
    rs = round(random(pds,1,num));
    re = round(random(pde,1,num));

    check = zeros(num,96);
    for p = 1:num
        if rs(p) < 0
            rs(p) = 0;
        end
        if re(p) > 96
            re(p) = 96;
        end
        if rs(p) > re(p)
            re(p) = re(p)+10;
            if re(p) > 96
                re(p) = 96;
            end
        end
        
        for t = 1:96
            if rs(p) <= t && re(p) >= t
                check(p,t) = t;
            else
                check(p,t) = NaN;
            end
        end
    end
    figure(1)
    histogram(check,100);
    ylabel("Available Participannts")
    xlabel("Time Interval")
    xlim([0 96])
    ylim([0 num+(num*.01)])

elseif cv == 5
    imb = (input("Total imbalance:\n","s"));
    choice = input("What is larger (response or imbalance):\n","s");
    num = (input("Number of Participants:\n"));
    if choice == "response"
        dis = zeros(length(num),1) + (round((imb/num))*10);
    elseif choice =="imbalance"
        dis = zeros(length(num),1) + (round((imb/num))/10)
    end
    
elseif cv == 6
    num = round(input("Number of Participants:\n"));
    y = round(input("Discrete Response:\n"));
    per = round(num/25);
    idx = 1;
    resp = zeros(1,num);
    for i = 1:25
        cnt = 1;
        while cnt <= per
            c(idx) = i;
            if i <= 5
                resp(idx) = y;
                if cnt > (0.5*per)
                    resp(idx) = -y;
                end
            elseif i <= 10
                resp(idx) = y;
                if cnt > (0.8*per)
                    resp(idx) = -y;
                end
            elseif i <= 15
                resp(idx) = y;
                if cnt > (0.2*per)
                    resp(idx) = -y;
                end
            elseif i <= 20
                resp(idx) = y;
            elseif i <= 25
                resp(idx) = -y;
            end

            cnt = cnt + 1;
            idx = idx +1;
        end
    end
   elseif cv == 7
        st = input("set mean time: ");
        ws = input("width: "); 
        std  = input('enter spread:');
        num = (input("Number of Participants:\n"));
        rng('shuffle')
        pds = makedist('Normal','mu',st,'sigma',std);
        rd = round(random(pds,num,1));
        rs = round(rd-ws).';
        re = round(rd+ws).';
        check = zeros(num,96);
        for p = 1:num
            if rs(p) < 0
                rs(p) = 0;
            end
            if re(p) > 96
                re(p) = 96;
            end
            if rs(p) > re(p)
                re(p) = re(p)+10;
                if re(p) > 96
                    re(p) = 96;
                end
            end
            
            for t = 1:96
                if rs(p) <= t && re(p) >= t
                    check(p,t) = t;
                else
                    check(p,t) = NaN;
                end
            end
        end
        figure(1)
        histogram(check,100);
        ylabel("Available Participannts")
        xlabel("Time Interval")
        xlim([-5 100])
        ylim([0 17000])
end