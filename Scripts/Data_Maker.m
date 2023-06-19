clc;
clear
fprintf('1: Number of Coalitions.\n2: Distribution of Imbalances\n3: Distribution of Discrete Responses\n4: Distribution of time slots.\n5: Amount of imbalance (less than, greater than, equal to total response).\n6: Coalition Component\n7: Width of time slots\n\n');
cv = input("Choose what to control:");

if cv == 2
    skew = (input("Choose Skewness (TL L N R TR ):\n","s"));
    multiH = round(input("Choose value scale:\n"));
    
    if skew == "tl" || skew == "TL"
       pd = makedist('GeneralizedExtremeValue','k',-0.5,'sigma',1,'mu',1)        
       rng('shuffle')  % For reproducibility
       r = random(pd,96,1)*multiH;
       figure(1)
       histfit(r,15,'GeneralizedExtremeValue')
       xlabel("Imabalance (MW)")
       ylabel("Frequency")
       title("Imbalance Histogram for the Entire Time Period (1 Day)")
    elseif skew == "tr" || skew == "TR"
       pd = makedist('GeneralizedExtremeValue','k',0.2,'sigma',1,'mu',-2)        
       rng('shuffle')  % For reproducibility
       r = random(pd,96,1)*multiH;
       figure(1)
       histfit(r,15,'GeneralizedExtremeValue')
       xlabel("Imabalance (MW)")
       ylabel("Frequency")
       title("Imbalance Histogram for the Entire Time Period (1 Day)")
    elseif skew == "R" || skew == "r"
       pd = makedist('GeneralizedExtremeValue','k',0.2,'sigma',1,'mu',-1)        
       rng('shuffle')  % For reproducibility
       r = random(pd,96,1)*multiH;
       figure(1)
       histfit(r,15,'GeneralizedExtremeValue')
       xlabel("Imabalance (MW)")
       ylabel("Frequency")
       title("Imbalance Histogram for the Entire Time Period (1 Day)")
    elseif skew == "l" || skew == "L"
       pd = makedist('GeneralizedExtremeValue','k',-0.5,'sigma',1,'mu',0.5)        
       rng('shuffle')  % For reproducibility
       r = random(pd,96,1)*multiH;
       figure(1)
       histfit(r,15,'GeneralizedExtremeValue') 
       xlabel("Imabalance (MW)")
       ylabel("Frequency")
       title("Imbalance Histogram for the Entire Time Period (1 Day)")
    else
        std  = input('enter spread:');
        pd = makedist('Normal','mu',0,'sigma',std);        
        rng('shuffle')  % For reproducibility
        r = random(pd,96,1)*multiH;
        figure(1)
        histfit(r,15,'normal')
        xlabel("Imabalance (MW)")
        ylabel("Frequency")
        title("Imbalance Histogram for the Entire Time Period (1 Day)")
        ar = (trapz((r),[1:1:96]));

    end
   

    if skew ~= "N"
        ar = abs(trapz((r),[1:1:96]));    
        tolerance = input("Area Tolerance (Please scale it to scale/10):");
        area = (input("Area under the curve during NO SKEW:\n"));
        while round(abs((ar) - area)) > tolerance
                if area < ar
                    check = 1;
                    if round(abs(ar - area)) >= 100
                        r = r./1.5;
                        ar = abs(trapz((r),[1:1:96]));
                    elseif round(abs(ar - area)) >= 10
                        r = r./1.2;
                        ar = abs(trapz((r),[1:1:96]));
                    elseif round(abs(ar - area)) >= 1000
                        r = r./2.5;
                        ar = abs(trapz((r),[1:1:96]));
                    end
                    if round(abs(ar - area)) < tolerance
                        break
                    end
                elseif area > ar
                    check1 = 1;
                    if round(abs(ar - area)) >= 100
                        r = r.*1.5;
                        ar = abs(trapz((r),[1:1:96]));
                    elseif round(abs(ar - area)) >= 10
                        r = r.*1.2;
                        ar = abs(trapz((r),[1:1:96]));
                    elseif round(abs(ar - area)) >= 1000
                        r = r.*2.5;
                        ar = abs(trapz((r),[1:1:96]));
                    end
                    if round(abs(area-(ar))) < tolerance
                        break
                    end
                     if check1 == 1 && check == 1
                        break
                    end
                end
                                
        end
    figure(3)
    histfit(r,15)
    xlabel("Imabalance (MW)")
    ylabel("Frequency")
    title("Imbalance Histogram for the Entire Time Period (1 Day)")
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
    skew = (input("Choose Skewness (TL L N R TR ):\n","s"));
    multiH = round(input("Choose value scale:\n"));
    num = (input("Number of Participants:\n"));

    if skew == "tl" || skew == "TL"
       pd = makedist('GeneralizedExtremeValue','k',-0.5,'sigma',1,'mu',1)        
       rng('shuffle')  % For reproducibility
       r = round(random(pd,num,1)*multiH, -1).';
       figure(1)
       histfit(r,15,'GeneralizedExtremeValue')
       xlabel("Discrete Response (W)")
       ylabel("Frequency")
       title("Discrete Response Histogram of all DR Participants")
    elseif skew == "tr" || skew == "TR"
       pd = makedist('GeneralizedExtremeValue','k',0.2,'sigma',1,'mu',-2)        
       rng('shuffle')  % For reproducibility
       r = round(random(pd,num,1)*multiH, -1).';
       figure(1)
       histfit(r,15,'GeneralizedExtremeValue')
       xlabel("Discrete Response (W)")
       ylabel("Frequency")
       title("Discrete Response Histogram of all DR Participants")
    elseif skew == "R" || skew == "r"
       pd = makedist('GeneralizedExtremeValue','k',0.2,'sigma',1,'mu',-1)        
       rng('shuffle')  % For reproducibility
       r = round(random(pd,num,1)*multiH, -1).';
       figure(1)
       histfit(r,15,'GeneralizedExtremeValue')
       xlabel("Discrete Response (W)")
       ylabel("Frequency")
       title("Discrete Response Histogram of all DR Participants")
    elseif skew == "l" || skew == "L"
       pd = makedist('GeneralizedExtremeValue','k',-0.5,'sigma',1,'mu',0.5)        
       rng('shuffle')  % For reproducibility
       r = round(random(pd,num,1)*multiH, -1).';
       figure(1)
       histfit(r,15,'GeneralizedExtremeValue')
       xlabel("Discrete Response (W)")
       ylabel("Frequency")
       title("Discrete Response Histogram of all DR Participants")
    else
        std  = input('enter spread:');
        pd = makedist('Normal','mu',0,'sigma',std);        
        rng('shuffle')  % For reproducibility
        r = round(random(pd,num,1)*multiH, -1).';
        figure(1)
        histfit(r,15,'normal')
        xlabel("Discrete Response (W)")
        ylabel("Frequency")
        title("Discrete Response Histogram of all DR Participants")
        ar = (trapz((r),[1:1:num]));
    end
   

    if skew ~= "N"
        ar = (trapz((r),[1:1:num]));    
        tolerance = input("Area Tolerance (Please scale it with your selected value scale)");
        area = (input("Area under the curve during NO SKEW:\n"));
        check = 0;
        check1= 0;
        while round(abs((ar) - area)) > tolerance
                if area < ar
                    check = 1;
                    if round(abs(ar - area)) >= 100
                        r = round(r./1.5,-1);
                        ar = abs(trapz((r),[1:1:num]));
                    elseif round(abs(ar - area)) >= 10
                        r = round(r./1.2,-1);
                        ar = abs(trapz((r),[1:1:num]));
                    elseif round(abs(ar - area)) >= 1000
                        r =round(r./2.5, -1);
                        ar = abs(trapz((r),[1:1:num]));
                    end
                    if round(abs(ar - area)) < tolerance
                        break
                    end
                elseif area > ar
                    check1 = 1;
                    if round(abs(ar - area)) >= 100
                        r = round(r.*1.5, -1);
                        ar = abs(trapz((r),[1:1:num]));
                    elseif round(abs(ar - area)) >= 10
                        r = round(r.*1.2, -1);
                        ar = abs(trapz((r),[1:1:num]));
                    elseif round(abs(ar - area)) >= 1000
                        r = round(r.*2.5, -1);
                        ar = abs(trapz((r),[1:1:num]));
                    end
                    if round(abs(area-(ar))) < tolerance
                        break
                    end
                     if check1 == 1 && check == 1
                        break
                    end
                end
                                
        end
    figure(3)
    histfit(r,15)
    histfit(r,15,'GeneralizedExtremeValue')
    xlabel("Discrete Response (W)")
    ylabel("Frequency")
    title("Discrete Response Histogram of all DR Participants")
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