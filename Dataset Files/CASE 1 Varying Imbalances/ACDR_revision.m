
std  = input('enter spread:');
multiH = round(input("Choose value scale:\n"));

while 1 
    pd = makedist('Normal','mu',0,'sigma',std);        
    rng('shuffle')  % For reproducibility
    No = (random(pd,96,1)*multiH);
    figure(1)
    histfit(No,20,'normal')
    xlabel("Imabalance (MW)")
    ylabel("Frequency")
    title("Imbalance Histogram for the Entire Time Period (1 Day)")
    xlim([-1e6+min(No),max(No)+1e6]);

    y =input("Satisfied?: ", "s")
    if y == "yes"
        break
    end
end
     