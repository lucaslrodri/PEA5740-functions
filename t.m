function tout =t(cycles,period,density)
    if ~exist('density','var')
        density=1;
    end
    if ~exist('period','var')
        period = 2*pi;
    end
    if ~exist('cycles','var')
        cycles=1;
    end
    tout=linspace(0,period*cycles,10^(3+density)*cycles);
end