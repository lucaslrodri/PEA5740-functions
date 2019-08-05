function p=Plot(Signal,conf)
    
    if ~exist('conf','var')
        conf=struct;
    end
    if ~isfield(conf,'Color')
        conf.Color=[];
    end
    if ~isfield(conf,'Style')
        conf.Style={};
    end
    if ~isfield(conf,'XEmpty')
        conf.XEmpty=false;
    end
    if ~isfield(conf,'YEmpty')
        conf.YEmpty=false;
    end
    if ~isfield(conf,'cycles')
        conf.cycles=6;
    end
    if ~isfield(conf,'Degree')
        conf.Degree=false;
    elseif conf.Degree
        conf.Tick=[180,30];
    end
    if ~isfield(conf,'Tick')
        conf.Tick=[4/3,1/3];
    end
    if ~isfield(conf,'Modern')
        conf.Modern=true;
    end
    if ~isfield(conf,'ZeroLine')
        conf.ZeroLine=true;
    end
    if ~isfield(conf,'MiddleLine')
        conf.MiddleLine=true;
    end
    if ~isfield(conf,'UsePi')
        conf.UsePi=(round(max(Signal,[],'all')/pi*10)==round(max(Signal,[],'all')/pi)*10)&&(round(min(Signal,[],'all')/pi*10)==round(min(Signal,[],'all')/pi)*10);
    end
    
    if conf.Degree
        Amplif=180/pi;
    elseif conf.UsePi
        Amplif=1/pi;
    else
        Amplif=1;
    end
    
    if ~exist('linspecer')
        conf.Modern=false;
    end

    if conf.Modern
        set(gcf,'defaultAxesColorOrder',linspecer(6));
    end
    
    if ~isreal(Signal)
        Signal=[real(Signal);imag(Signal)];
    end
    
    Time=t(conf.cycles)/pi;
    
    Signal=Signal*Amplif;
    

    p=plot(Time,Signal);
    
    if ~isempty(conf.Color)
        p.Color=conf.Color;
    end
    if ~isempty(conf.Style)
        p.LineSpec=conf.Style;
    end
    hold on;
    
    if conf.YEmpty
        yticklabels([]);
    else
        ytickformat('%.2g');
        if conf.UsePi
            ytickformat('%.2gπ');
        end
        if conf.Degree
            ytickformat('%.2g°');
        end
        if conf.Degree
            ylabel('Ângulo');
        else
            ylabel('Amplitude');
        end
    end

    xlim([Time(1),Time(end)]);
    xticks(1:12);
    
    if conf.XEmpty
        xticklabels([]);
    else
        xtickformat('%.2gπ');
        xlabel('Tempo (Ciclos ✕ 2\pi)');
    end
    
    grid on;
    ylim(conf.Tick(1)*[-1,1]);
    yticks((-1*conf.Tick(1):conf.Tick(2):conf.Tick(1)));
    
    if conf.ZeroLine
        plot([0,100],[0,0],'k');
    end
    if conf.MiddleLine
        plot([4,4],[-1000,1000],'k');
        plot([8,8],[-1000,1000],'k');
    end
    
    %plot([0,100],[0,0]);
    set(gca,'children',flipud(get(gca,'children')));
    hold off;
end