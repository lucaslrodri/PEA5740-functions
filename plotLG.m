function plotLG(V,Title,conf)
    global COMET
    global FIGNUM
    if ~exist('conf','var')
        conf=struct;
    end
    if ~isfield(conf,'SubFig')
        conf.SubFig=false;
    end
    if ~conf.SubFig
        if ~exist('Title','var')
            Title=[];
            fig=figure('Units', 'Normalized','color','w', 'OuterPosition', [0, 0, 0.75, 0.75]);
        else
            fig=figure('Name',Title,'Units', 'Normalized','color','w', 'OuterPosition', [0, 0, 0.75, 0.75]);
        end
    end
    if ~isfield(conf,'Eixo')
        conf.Eixo='ab';
    end
    if ~isfield(conf,'Amp')
        conf.Amp=4/3;
    end
    if ~isfield(conf,'Div')
        conf.Div=8;
    end
    if ~isfield(conf,'Ticks')
        conf.Ticks=-conf.Amp:((conf.Amp)/conf.Div):conf.Amp;
    end
    if ~isfield(conf,'XEmpty')
        conf.XEmpty=false;
    end
    if ~isfield(conf,'YEmpty')
        conf.YEmpty=false;
    end
    if ~isfield(conf,'Centro')
        conf.Centro=[];
    end
    if ~isfield(conf,'CPlot')
        conf.CPlot=false;
    end
    if ~isfield(conf,'InfColor')
        conf.InfColor=true;
    end
    if ~isfield(conf,'External')
        conf.External=false;
    end
    if ~isfield(conf,'ColorBar')
        conf.ColorBar=true;
    end
    
    if COMET&&~conf.SubFig
        set(gcf,'Visible','on');
    end
    
    amp=conf.Amp*[-1 1 -1 1];
    
    VelBasex6=2*pi/length(V);
    
    plot([0,0],3*amp(3:4),'k');
    hold on;
    plot(3*amp(1:2),[0,0],'k');
    ytickformat('%.2g');
    xtickformat('%.2g');
    
    int=length(V)*[1/3,2/3,1];
    

    for k=3:-1:1
        if k==1
            ii=1:int(k);
        else
            ii=(int(k-1)+1):int(k);
        end
        if isempty(conf.Centro)
            center = mean(V(ii));
        else
            center=zeros(size(V(ii)));
        end
        if abs(center) >0.1
            x=scatter(real(center),imag(center),32,'magenta');
        else
            center=0;
        end
        vel_angle(ii)=gradient(Angle(round(100000*(V(ii)-center))/100000))/VelBasex6;
        vel_abs(ii)=gradient(sqrt(real(V(ii)-center).^2+imag(V(ii)-center).^2))/VelBasex6*2*pi;
        centro(ii)=center;
        %             if conf.InfColor&&k~=1
        %                 if mean(vel_angle(ii)>0)
        %                     InfColor(k-1)=1;
        %                 else
        %                     InfColor(k-1)=-1;
        %                 end
        %             end
    end
     
    vel_cor=scalecolor(vel_angle);
    clims=scalecolor(40*[-1;1]);
    cores = jet(80+1);
    
    if conf.CPlot
        vel_lims=linspace(clims(1),clims(end),length(cores)-1);
    end
    
    
    Vre=real(V);
    Vim=imag(V);
    
    if conf.InfColor
        for k=1:2
            ix=(int(k)-1):(int(k)+1);
            if mean(diff(atan2(Vim(ix),Vre(ix))))>0
                plot(Vre(ix),Vim(ix),'Color',cores(end,:),'LineWidth',2);
            else
                plot(Vre(ix),Vim(ix),'Color',cores(1,:),'LineWidth',2);
            end
        end 
    end
    
    if conf.CPlot
        cplot(Vre,Vim,vel_cor<=vel_lims(1),cores(1,:));
        for k=2:length(vel_lims)
           cplot(Vre,Vim,vel_cor>=vel_lims(k-1)&vel_cor<=vel_lims(k),cores(k,:));
        end
        cplot(Vre,Vim,vel_cor>=vel_lims(end),cores(end,:));   
    end
    
    scatter(Vre,Vim,8,vel_cor,'filled'); %(que é equivalente a plot (Real(v), Imag(v)),type
    
    grid on;
    %axis(amp);
    axis('equal');
    xlim(conf.Amp*[-1 1]);
    ylim(conf.Amp*[-1 1]);
    xticks(conf.Ticks);
    yticks(conf.Ticks);
    hold off;
    
    if conf.ColorBar
        c = colorbar;
        %Ticks=[20,5,2,1,10,3,7.5];
        Ticks=6:6:36;
        Ticks=[sort(-Ticks),0,sort(Ticks)];
        c.Ticks=scalecolor(Ticks);
        c.TickLabels=split(num2str(Ticks/6));
    end
    colormap(cores);
    caxis(clims);
    
    if ~conf.XEmpty
        if strcmp(conf.Eixo,'dq')
            xlabel('Eixo d');
        elseif strcmp(conf.Eixo,'ab')
            xlabel('Eixo \alpha');
        elseif length(conf.Eixo)==2
            xlabel(['Eixo ',conf.Eixo(1)]);
        end
    else
        xticklabels([]);
    end
    if ~conf.YEmpty
        if strcmp(conf.Eixo,'dq')
            ylabel('Eixo q');
        elseif strcmp(conf.Eixo,'ab')
            ylabel('Eixo \beta');
        elseif length(conf.Eixo)==2
            ylabel(['Eixo ',conf.Eixo(2)]);
        end
    else
        yticklabels([]);
    end
    if exist('x','var')
        %x=scatter(real(center),imag(center),8,'magenta');
        legend(x,{'Baricentros fora da origem'},'Location','north');%,'AutoUpdate','off'
        if conf.ColorBar
            c.Label.String = 'Vel. Angular em relação aos baricentros (Normalizada)';
        end
        elseif conf.ColorBar
        if ~conf.SubFig
            c.Label.String = 'Vel. Angular em relação à origem (Normalizada)';
        else
            c.Label.String = {'Vel. Angular em relação','à origem (Normalizada)'};
        end
    end
    if ~conf.SubFig
        if ~isempty(Title)
            title(['Figura ',num2str(FIGNUM,'%d'),': ',Title]);
        end
        if ~COMET
            FIGNUM=FIGNUM+1;
        end
        dcm_obj = datacursormode(fig);
        set(dcm_obj,'UpdateFcn',{@tooltipfun,conf,vel_angle,vel_abs,centro});
    else
        title(Title);
    end
    
%     if COMET&&(~conf.External)
%         conf.External=true;
%         plotLG(V,Title,conf);
%     end

    %%-----------------------Calcula o ângulo---------------
    function a = Angle(V)
        a=angle(V);
        for i=2:length(V)
            if abs(a(i-1)-a(i))>1.9*pi
                a(i:end)=a(i:end)+2*pi*round((a(i-1)-a(i))/abs(a(i-1)-a(i)));
            end
        end
        a(abs(V)==0)=a(abs(V)==0)-2*pi;
    end
    
    %%-----------------------Plota intervalo com cor---------------
    function cplot(x,y,ii,cor)
        x(~ii)=NaN;
        y(~ii)=NaN;
        if length(x(~isnan(x)))>1&&length(y(~isnan(y)))>1
            plot(x,y,'Color',cor,'LineWidth',2);
        end
    end
    
    %%-----------------------Função de escala de cor (Sigmoide ou similar)---------------
    function f = scalecolor(z)
        %f=1./(1+exp(-0.25*z));
        %f=atan(0.25*z);
        f=z;
    end

    %%-----------------------Editar tooltip---------------
    function txt = tooltipfun(~,event_obj,conf,vel_angle,vel_abs,centro)
        % Customizes text of data tips
        pos = get(event_obj,'Position');
        I = get(event_obj, 'DataIndex');
        if strcmp(conf.Eixo,'ab')
            eixos={'\alpha: ','\beta: '};
        elseif length(conf.Eixo)==2
            eixos={[conf.Eixo(1),': '],[conf.Eixo(2),': ']};
        else
            eixos={'x','y'};
        end
        re=pos(1);
        im=pos(2);
        if abs(centro(I))>1e-2
            rec=real(centro(I));
            imc=imag(centro(I));
            rer=pos(1)-rec;
            imr=pos(2)-imc;
            if strcmp(conf.Eixo,'PQ')
                txt = {['(',eixos{1},n(re),',',eixos{2},n(im),',S: ',n(sqrt(re^2+im^2)),',fp: ',n(cos(atan2(im,re))),')'],...
                ['Centro: (',eixos{1},n(rec),',',eixos{2},n(imc),',S: ',n(sqrt(rec^2+imc^2)),',fp: ',n(cos(atan2(imc,rec))),')'],...
                ['Pos. Rel.: |',(n(sqrt(rer^2+imr^2))),'|','∠',n(atan2(imr,rer)*180/pi,'%.3g'),'°'],...
                ['Vel. angular: ',n(vel_angle(I)/6,'v')]%,...
    %            ['Vel. modular: ',n(round(vel_abs(I)/6*10)/10)]
                };
            else
                txt = {['(',eixos{1},n(re),',',eixos{2},n(im),')'],...
                ['Centro: |',(n(sqrt(rec^2+imc^2))),'|','∠',n(atan2(imc,rec)*180/pi,'%.3g'),'°'],...
                ['Pos. Rel.: |',(n(sqrt(rer^2+imr^2))),'|','∠',n(atan2(imr,rer)*180/pi,'%.3g'),'°'],...
                ['Vel. angular: ',n(vel_angle(I)/6,'v')]%,...
    %            ['Vel. modular: ',n(round(vel_abs(I)/6*10)/10)]
                };
            end
        else
            txt = {['(',eixos{1},n(re),',',eixos{2},n(im),')'],...
            ['|',(n(sqrt(re^2+im^2))),'|','∠',n(atan2(im,re)*180/pi,'%.3g'),'°'],...
            ['Vel. ang.: ',n(vel_angle(I)/6,'v')],...
            ['Vel. mod.: ',n(vel_abs(I)/6,'v')]
            };
        end
        function str = n(num,pr)
            
            if ~exist('pr','var')
                pr='%.2f';
            end
            if strcmp(pr,'v')
                num=round(num*10)/10;
                pr='%.1f';
            else
                num=round(num*100)/100;
            end
            if abs(num)<1e-3
                pr='%.2f';
                num=0;
            end
            str=num2str(num,pr);
        end
    end
end