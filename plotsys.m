%------------------------Plotar bode e step----------------------------
function plotsys(sys,type,conf,MapColor,mm)
    if ~exist('conf','var')
        conf=struct;
    end
    if ~exist('MapColor','var')
        MapColor=false;
    end
    if ~exist('type','var')
        type='bode';
    end
    
%     if ~isfield(conf,'Amp')
%         conf.Amp=1.25;
%     end
    if ~isfield(conf,'Componentes')
        conf.Componentes=[2*377;1/3];
    end
    if ~isfield(conf,'XEmpty')
        conf.XEmpty=false;
    end
    if ~isfield(conf,'Title')
        conf.Title=[];
    end
    if ~isfield(conf,'Ticks')
        conf.Ticks=sort([repmat([0.1,1,10],1,3).*[ones(1,3)*377,ones(1,3)*100,ones(1,3)*200],754]);
    end
    if ~isfield(conf,'Periodo')
        conf.Periodo=[0.5,1,2,3,4,5];
    end
    if ~isfield(conf,'ColorTitle')
        conf.ColorTitle='N - ordem do filtro';
    end
    if ~isfield(conf,'ColorTicks')
        conf.ColorTicks=split(num2str((1:3)+1,'%d '));
    end
    if ~isfield(conf,'Colors')
        conf.Colors=cool(length(sys));
    end
    if ~isfield(conf,'MarkerSize')
        conf.MarkerSize=2;
    end
    
    tam = length(sys);
    cor=linspecer(6);
    cor=cor(3,:);
    if strcmp(type,'bode')   
        if exist('mm','var')
            mediamovel=semilogx(mm.w,mm.mag,'-.','Color',cor);
            hold on;
        end
        for n=1:tam
            semilogx(sys(n).w,sys(n).mag,'Color',conf.Colors(n,:));
            hold on;
        end
        
        yline(-3,'--','-3 dB','LabelVerticalAlignment','bottom','LabelHorizontalAlignment','left');
        grid on;
        
        
        xlim([min(conf.Ticks),max(conf.Ticks)]);
        
        ylabel('Magnitude (dB)');
        ylim([-140,5]);
        yticks(-140:20:5);
        
        if MapColor
            colormap(conf.Colors(1:tam,:));
            caxis([0.5,tam+0.5]);
            c=colorbar(gca,'eastoutside','Ticks',1:tam,'TickLabels',conf.ColorTicks);% ,'Limits',[0.5,tam+0.5]
            c.Label.String = conf.ColorTitle;
        end
        
        xticks(conf.Ticks);
        if ~conf.XEmpty
            xlabel('Frequência (rad/s)');
        end
        
        if ~isempty(conf.Title)
            title(['Bode (Magnitude) - ',conf.Title]);
        end
        yyaxis right;
        ax=gca;
        ax.YAxis(2).Color='k';
        ylim([0,0.4+0.05/4]);
        stem(conf.Componentes(1,:),200*linspace(1,1,length(conf.Componentes(1,:))),'k:');
        ae=stem(conf.Componentes(1,1),conf.Componentes(2,1),'k-');
        if length(conf.Componentes(1,:))>1
            aem=stem(conf.Componentes(1,2:end),conf.Componentes(2,2:end),'k-','Marker','h');
        end
        for k=1:tam
            ate=10.^(interp1(sys(k).w,sys(k).mag,conf.Componentes(1,:))/20);
            stem(conf.Componentes(1,1),ate(1)*conf.Componentes(2,1),'-','filled','Color',conf.Colors(k,:),'MarkerSize',conf.MarkerSize);
            if length(conf.Componentes(1,:))>1
                stem(conf.Componentes(1,2:end),ate(2:end).*conf.Componentes(2,2:end),'-','filled','Color',conf.Colors(k,:),'MarkerSize',conf.MarkerSize+1,'Marker','h');
            end
        end
        if exist('mm','var')
            ate=10.^(interp1(mm.w,mm.mag,conf.Componentes(1,:))/20);
            stem(conf.Componentes(1,:),ate.*conf.Componentes(2,:),'-','filled','Color',cor,'MarkerSize',conf.MarkerSize);
        end
        aeat=stem(-3,1,'-','filled','Color','k','MarkerSize',conf.MarkerSize);
        if length(conf.Componentes(1,:))>1
            aeatm=stem(-3,1,'-','filled','Color','k','MarkerSize',conf.MarkerSize+1,'Marker','h');
        end
        yticks(0:0.05:0.5);
        ylabel('Magnitude (A_n)');
        if exist('mm','var')
            legend([ae,aeat,mediamovel],{'A_n - Seq. negativa','A_n filtrada (atenuada)','Filtro média móvel'},'Location','southwest');
        elseif length(conf.Componentes(1,:))>1
            legend([ae,aem,aeat,aeatm],{'A_n - Seq. negativa','A_h - Harmônica','A_n filtrada (atenuada)','A_h filtrada (atenuada)'},'Location','southwest');
        end
    else
%         cor=linspecer(6);
%         for n=1:length(conf.Periodo)
%             if conf.Periodo>1
%                 Plural='s';
%             else
%                 Plural='';
%             end
%             xline(1000*conf.Periodo(n)/60,'--',[num2str(conf.Periodo(n)), ' Periodo',Plural],'Color',cor(n,:));
%             hold on;
%         end
        plot([0,1000],[1,1],'k:');
        hold on;
        if exist('mm','var')
            mediamovel=plot(mm.t*60,mm.y,'-.','Color',cor);
        end
        for n=1:tam
            plot(sys(n).t*60,sys(n).y,'Color',conf.Colors(n,:));
        end
        
        xlim(60*[sys(1).t(1),sys(1).t(end)]);
        %ylim([0,1.25]);
        %yticks(0:0.25:1.25);
        xticks(sort([60*linspace(sys(1).t(1),sys(1).t(end),10),0.5]));
        grid;        
        
        if MapColor
            colormap(conf.Colors(1:tam,:));
            caxis([0.5,tam+0.5]);
            c=colorbar(gca,'eastoutside','Ticks',1:tam,'TickLabels',conf.ColorTicks);% ,'Limits',[0.5,tam+0.5]
            if ~isempty(conf.ColorTitle)
                c.Label.String = conf.ColorTitle;
            end
        end
        
        if ~conf.XEmpty
            xlabel('Tempo (Periodos)');
        end
        if ~isempty(conf.Title)
            title(['Resposta ao degrau - ',conf.Title]);
        end
        if exist('mm','var')
            legend(mediamovel,{'Filtro média móvel'},'Location','southeast');
        end
    end
    if conf.XEmpty
        xticklabels([]);
    end
end