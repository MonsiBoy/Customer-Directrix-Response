clc;
clear
fprintf('1: Distribution of Imbalances.\n2: Coalition Composition\n3: Number of Coalitions\n4: Distribution of Discrete Responses\n5: Width of time slots.\n6: Imbalance Amount\n7: Distribution of time slots.\n\n');
cv = input("Choose what to control:");

if cv == 1
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
       trial = input("Enter Trial: ","s");
       L = strcat("16k-participants1TL",trial,".xlsx");
       R = strcat("16k-participants1TR",trial,".xlsx"); 
       xlswrite(L,left,"Generation","E2:E97")
       xlswrite(R,right,"Generation","E2:E97")
       
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
       trial = input("Enter Trial: ","s");
       L = strcat("16k-participants1L",trial,".xlsx");
       R = strcat("16k-participants1R",trial,".xlsx") ;
       xlswrite(L,left,"Generation","E2:E97")
       xlswrite(R,right,"Generation","E2:E97")
    else
        std  = input('enter spread:');
        pd = makedist('Normal','mu',0,'sigma',std);        
        rng('shuffle')  % For reproducibility
        No = random(pd,96,1)*multiH;
        figure(1)
        histfit(r,20,'normal')
        xlabel("Imabalance (MW)")
        ylabel("Frequency")
        title("Imbalance Histogram for the Entire Time Period (1 Day)")
        xlim([-1e6+min(r),max(r)+1e6]);
        %set(gca,'XTick',[-100+min(r) : 200e3 : max(r)+100]);
        trial = input("Enter Trial: ","s");
        n = strcat("16k-participants1N",trial,".xlsx");
        xlswrite(n,No,"Generation","E2:E97")
   end

elseif cv == 2
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
    trial = input("Enter Trial: ","s");
    n = strcat("16k-participants2",trial,".xlsx");
    xlswrite(n,c,"Area","A2:WQJ2")
    
elseif cv == 3
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
    trial = input("Enter Trial: ","s");
    n = strcat("16k-participants3",trial,".xlsx");
    xlswrite(n,c,"Area","A2:WQJ2")

elseif cv == 4
    skew = (input("Choose Skewness (N SS S):\n","s"));
    multiH = round(input("Choose value scale:\n"));
    num = input("Number of Participants: ")
      
   if skew == "ss" || skew == "SS"
       pdR = makedist('GeneralizedExtremeValue','k',0.1,'sigma',1,'mu',-2)  
       rng('shuffle')  % For reproducibility
       right = round(random(pdR,num,1)*multiH,-1).';
       left =-1.*right;
       figure(1)
       histfit(right,100,'GeneralizedExtremeValue')
       xlabel("Discrete Responses (W)")
       ylabel("Frequency")
       title("Occurences of Discrete Responses per Interval")
       figure(2)
       histfit(left,100,'GeneralizedExtremeValue')
       xlabel("Discrete Responses (W)")
       ylabel("Frequency")
       title("Occurences of Discrete Responses per Interval")
       trial = input("Enter Trial: ","s");
       L = strcat("16k-participants4TL",trial,".xlsx");
       R = strcat("16k-participants4TR",trial,".xlsx");
       xlswrite(L,left,"Response","A2:WQJ2")
       xlswrite(R,right,"Response","A2:WQJ2")

    elseif skew == "S" || skew == "s"
       pdR = makedist('GeneralizedExtremeValue','k',0.1,'sigma',1,'mu',-1)  
       rng('shuffle')  % For reproducibility
       right = round(random(pdR,num,1)*multiH,-1).';
       left =-1.*right;
       figure(1)
       histfit(right,100,'GeneralizedExtremeValue')
       xlabel("Discrete Responses (W)")
       ylabel("Frequency")
       title("Occurences of Discrete Responses per Interval")
       figure(2)
       histfit(left,num,'GeneralizedExtremeValue')
       xlabel("Discrete Responses (W)")
       ylabel("Frequency")
       title("Occurences of Discrete Responses per Interval")
       trial = input("Enter Trial: ","s");
       L = strcat("16k-participants4L",trial,".xlsx");
       R = strcat("16k-participants4R",trial,".xlsx") ;
       xlswrite(L,left,"Response","A2:WQJ2")
       xlswrite(R,right,"Response","A2:WQJ2")
    else
        std  = input('enter spread:');
        pd = makedist('Normal','mu',0,'sigma',std);        
        rng('shuffle')  % For reproducibility
        No = round(random(pd,num,1)*multiH,-1);
        figure(1)
        histfit(r,100,'normal')
        xlabel("Discrete Responses (W)")
        ylabel("Frequency")
        title("Occurences of Discrete Responses per Interval")
        xlim([-1e6+min(r),max(r)+1e6]);
        %set(gca,'XTick',[-100+min(r) : 200e3 : max(r)+100]);
        trial = input("Enter Trial: ","s");
        n = strcat("16k-participants4N",trial,".xlsx");
        xlswrite(n,No,"Response","A2:WQJ2")
   end

elseif cv == 5
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
        trial = input("Enter Trial: ","s");
        E = strcat("16k-participants5",int2str(ws),trial,".xlsx")
        xlswrite(E,rs,"Start Time","A2:WQJ2")
        xlswrite(E,re,"End Time","A2:WQJ2")

elseif cv == 7
    st = input("set mean start time: ");
    end_t = input("set mean end time: "); 
    std = input("spread(1 is default): ");
    num = (input("Number of Participants:\n"));
    rng('shuffle')
    pde = makedist('Normal','mu',end_t,'sigma',std);    
    pds = makedist('Normal','mu',st,'sigma',std);    
    rs = round(random(pds,1,num)).';
    re = round(random(pde,1,num)).';

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
    trial = input("Enter Trial: ","s");
    type = input("Enter set description: ","s");
    E = strcat("16k-participants7",type,trial,".xlsx")
    xlswrite(E,rs,"Start Time","A2:WQJ2")
    xlswrite(E,re,"End Time","A2:WQJ2")

elseif cv == 6
    imb = (input("Total imbalance:\n","s"));
    choice = input("What is larger (response or imbalance):\n","s");
    num = (input("Number of Participants:\n"));
    if choice == "response"
        dis = zeros(length(num),1) + (round((imb/num))*10);
    elseif choice =="imbalance"
        dis = zeros(length(num),1) + (round((imb/num))/10)
    end 
end