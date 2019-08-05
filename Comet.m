%%-----------------------Anima as trajegetórias---------------
function Comet(V,Title,conf,Vel)
    global COMET
    global INTERRUPT
    INTERRUPT=0;
    if COMET
        Cores=linspecer(6);
        close all;
        if ~exist('conf','var')
            conf=struct;
        end
        if ~exist('Title','var')
            Title=[];
        end
        if ~isfield(conf,'amp')
            conf.amp=4/3;
        end
        if ~isfield(conf,'Div')
            conf.Div=8;
        end
        if ~isfield(conf,'Ticks')
            conf.Ticks=-conf.amp:((conf.amp)/conf.Div):conf.amp;
        end
        if ~isfield(conf,'eixo')
            conf.eixo='ab';
        end
        if ~isfield(conf,'Vref')
            conf.Vref=[];
        end
        if ~isfield(conf,'Filter')
            conf.Filter=false;
        end
        
        if ~isempty(Title)
            figure('Name',Title,'CloseRequestFcn',@close_comet);
        else
            figure('CloseRequestFcn',@close_comet);
        end
        
        if ~isempty(conf.Vref)
            seq=decoup(V,conf.Vref);
            
            xseq=real(seq);
            yseq=imag(seq);
        end
        
        V_atb = vel_calc(V);
        
        if ~exist('Vel','var')
            Vel=1;
        end
        
        periodo=1/50/Vel;
        amp=conf.amp*[-1 1 -1 1];
        set(gcf,'Visible','on');
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
        x=real(V);
        y=imag(V);
        ptos=round(length(x)*(1/(6*50))^2/periodo);

        plot([0,0],8*amp(3:4),'k');
        hold on;
        plot(8*amp(1:2),[0,0],'k');

        grid on;
        xticks(conf.Ticks);
        yticks(conf.Ticks);
        xlim(conf.amp*[-1 1]);
        ylim(conf.amp*[-1 1]);
        ytickformat('%.2g');
        xtickformat('%.2g');
        axis('equal');
        if(Vel~=1)
            if ~isempty(Title)
                title({Title,['(',num2str(Vel),'x da velocidade normal',')']});
            else
                title([num2str(Vel),'x da velocidade normal']);
            end
        elseif ~isempty(Title)
            title(Title);
        end
        if strcmp(conf.eixo,'dq')
            xlabel('Eixo d');
            ylabel('Eixo q');
            eixos={'d','q'};
        elseif strcmp(conf.eixo,'PQ')
            xlabel('Eixo P');
            ylabel('Eixo Q');
            eixos={'P','Q'};
        else
            xlabel('Eixo \alpha');
            ylabel('Eixo \beta');
            eixos={'\alpha','\beta'};
        end
        
        hvec=animatedline('Color',Cores(3,:),'MaximumNumPoints',2);
        htraj=animatedline('Color','k','LineStyle',':');
        hvecp=animatedline('Marker','o','MarkerFaceColor','white','Color',Cores(3,:),'MaximumNumPoints',1);
        
        if ~isempty(conf.Vref)||strcmp(conf.eixo,'dq')||strcmp(conf.eixo,'PQ')
            for i=2:-1:1
                hsec(i)=animatedline('Color',Cores(i,:),'LineStyle','-.','MaximumNumPoints',2);
                hsecl(i)=animatedline('Color',Cores(i,:),'LineStyle',':','MaximumNumPoints',2);
                hsecb(i)=animatedline('Color',Cores(i,:),'Marker','+','MaximumNumPoints',1);
            end
        end

        htext=text(0,0.9*conf.amp,tooltip(x(1),y(1),V_atb.vel_angle(1),V_atb.vel_abs(1),V_atb.centro(1),eixos),'BackgroundColor','white','HorizontalAlignment','center','EdgeColor','k');
        if conf.Filter
            filterlegend=' (Média Movel)';
        else
            filterlegend='';
        end
        if ~isempty(conf.Vref)||strcmp(conf.eixo,'dq')
            legend([htraj,hvec,hsec(1),hsec(2)],{'Trajetória','Vetor',['Seq. Positiva',filterlegend],['Seq. Negativa',filterlegend]},'Location','southoutside','Orientation','Horizontal');
        elseif strcmp(conf.eixo,'PQ')
            legend([htraj,hvec,hsecb(1)],{'Trajetória','Vetor',['Pot. média',filterlegend]},'Location','southoutside','Orientation','Horizontal');
        end
        
        for k=1:ptos:length(x)-ptos+1
            tic;
            
            addpoints(htraj,x(k:k+ptos-1),y(k:k+ptos-1));
            addpoints(hvec,[0,x(k+ptos-1)],[0,y(k+ptos-1)]);
            
            if ~isempty(conf.Vref)
                for i=1:2
                    addpoints(hsec(i),[0,xseq(i,k+ptos-1)],[0,yseq(i,k+ptos-1)]);
                    addpoints(hsecl(i),[xseq(i,k+ptos-1),x(k+ptos-1)],[yseq(i,k+ptos-1),y(k+ptos-1)]);
                    addpoints(hsecb(i),xseq(i,k+ptos-1),yseq(i,k+ptos-1));
                end
            end
            addpoints(hvecp,x(k+ptos-1),y(k+ptos-1));
            
            if strcmp(conf.eixo,'dq')
                xc=real(V_atb.centro(k+ptos-1));
                yc=imag(V_atb.centro(k+ptos-1));
                addpoints(hsec(1),[0,xc],[0,yc]);
                addpoints(hsecb(1),xc,yc);
                addpoints(hsec(2),[xc,x(k+ptos-1)],[yc,y(k+ptos-1)]);
                addpoints(hsecb(2),x(k+ptos-1),y(k+ptos-1));
            end
            
            if strcmp(conf.eixo,'PQ')
                xc=real(V_atb.centro(k+ptos-1));
                yc=imag(V_atb.centro(k+ptos-1));
                addpoints(hsecb(1),xc,yc);
            end
            
            
            delete(htext);
            %htext=annotation('textbox',[0.5,0.75,0.1,0.5],'String',tooltip(x(k+ptos-1),y(k+ptos-1),V_atb.vel_angle(k+ptos-1),V_atb.vel_abs(k+ptos-1),V_atb.centro(k+ptos-1),eixos),'FitBoxToText','on');
            htext=text(0,0.9*conf.amp,tooltip(x(k+ptos-1),y(k+ptos-1),V_atb.vel_angle(k+ptos-1),V_atb.vel_abs(k+ptos-1),V_atb.centro(k+ptos-1),eixos),'BackgroundColor','white','HorizontalAlignment','center','EdgeColor','k');
            
            drawnow;
            if INTERRUPT==1
                break;
            end
            time_elapsed=toc;
            pause(max(0,periodo-time_elapsed));
        end
        
        if INTERRUPT==0
            pause(2);
        end
        set(gcf,'Visible','off');
        close;
    end

    %------------------------Close function----------------------------
    %'CloseRequestFcn',@my_closereq
    function close_comet(src,callbackdata)
        INTERRUPT=1;
        delete(gcf);
    end
    
    %------------------------Decompoem Seq positiva e negativa----------
    function seq = decoup(V,Vref)
        for j_=2:-1:1
           a=(-1)^(j_-1)*angle(tr(Vref));
           dq=tr(V,a);
           seq(j_,:)=tr(media(dq),-a);
        end

        %Calcula a média em um intervalo
        function c=media(Val)
            i_=round((0:12)*length(Val)/12);
            if conf.Filter
                B=1/5000*ones(1,5000);
                c = filter(B,1,Val);
                %[B,A]=butter(9,1/12);
                %c = filter(B,A,real(Val))+1j*filter(B,A,imag(Val));
            else
                for k_=12:-1:1
                    c((i_(k_)+1):i_(k_+1))=mean(Val((i_(k_)+1):i_(k_+1)));
                end
            end
        end
    end

    %------------------------Calcula velocidades e centros----------
    function V_atb = vel_calc(V)
        VelBasex6=2*pi/length(V);
        int=length(V)*[1/3,2/3,1];
        B=1/5000*ones(1,5000);
        V_atb.centro=filter(B,1,V);
        for w=3:-1:1
            if w==1
                ii=1:int(w);
            else
                ii=(int(w-1)+1):int(w);
            end
            if ~conf.Filter
                center = mean(V(ii));
            else
                center = V_atb.centro(ii);
            end
            V_atb.vel_angle(ii)=gradient(Angle(round(100000*(V(ii)-center))/100000))/VelBasex6;
            V_atb.vel_abs(ii)=gradient(sqrt(real(V(ii)-center).^2+imag(V(ii)-center).^2))/VelBasex6*2*pi;
            
        end
    end

    %------------------------Legenda dinâmica----------
    function txt = tooltip(re,im,vel_angle,vel_abs,centro,eixos)
        if abs(centro)>1e-2
            rec=real(centro);
            imc=imag(centro);
            rer=re-rec;
            imr=im-imc;
            if eixos{1}=='P'
                txt = ['{\bf Pos.:} (P: ',n(re),',Q: ',n(im),',S: ',n(abs(sqrt(re^2+im^2)),'',2),',fp: ',a(im,re,true),')\newline',...
                '{\bf Centro:} (P: ',n(rec),',Q: ',n(imc),',S: ',n(abs(sqrt(rec^2+imc^2)),'',2),',fp: ',a(imc,rec,true),')\newline',...
                '{\bf Pos. Rel.:} |',(n(sqrt(rer^2+imr^2),'',0)),'|','∠',a(imr,rer),...
                '{\bf Vel. ang.:} ',n(vel_angle/6,'v')%,...
    %            ['Vel. mod.: ',n(round(vel_abs/6*10)/10)]
                ];
            else
                txt = ['{\bf Pos.:} |',(n(sqrt(re^2+im^2),'',2)),'|','∠',a(im,re),...
                '{\bf Centro:} |',(n(sqrt(rec^2+imc^2),'',0)),'|','∠',a(imc,rec),...
                '{\bf Pos. Rel.:} |',(n(sqrt(rer^2+imr^2),'',0)),'|','∠',a(imr,rer),...
                '{\bf Vel. ang.:} ',n(vel_angle/6,'v')%,...
    %            ['Vel. mod.: ',n(round(vel_abs/6*10)/10)]
                ];
            end
        else
            txt = ['{\bf Pos.:} |',(n(sqrt(re^2+im^2),'',2)),'|','∠',a(im,re),...
            '{\bf Vel. ang.:} ',n(vel_angle/6,'v'),'   ',...
            '{\bf Vel. mod.:} ',n(vel_abs/6,'v')
            ];
        end
        function str = a(im,re,fp)
            if ~exist('fp','var')
                fp=false;
            end
            if abs(im)<1e-3
                if abs(re)<1e-3
                    at=0;
                elseif re>=0
                    at=0;
                elseif re<0
                    at=-180;
                end
            else
                at=atan2(im,re)*180/pi;
            end
            if fp
                if at<0
                   cn=2;
                elseif at==0
                    cn=1;
                else
                    cn=3;
                end
                str=['{',cstr(cn),num2str(cos(at*pi/180),'%4.2f'),'}'];
            else
                str=[n(at,'%.3g'),'°   '];
            end
        end
        function str = n(num,pr,color)
            if ~exist('pr','var')
                pr='';
            end
            if isempty(pr)
                pr='%4.2f';
            end
            if ~exist('color','var')
                color=1;
            end
            if strcmp(pr,'v')
                num=round(num*10)/10;
                pr='%3.1f';
            else
                num=round(num*100)/100;
            end
            if abs(num)<1e-3
                pr='%4.2f';
                num=0;
            end
            cn=1;
            if color==1
                if num==0
                elseif num>0
                    cn=3;
                else
                    cn=2;
                end
            elseif color==2
                if num==0
                elseif num<0.25
                    cn=2;
                elseif num<0.6
                    cn=4;
                elseif num<1
                    cn=3;
                elseif num>=1
                    cn=5;
                end
            end
            str=['{',cstr(cn),num2str(num,pr),'}'];
        end
        function str = cstr(n)
            % 1 - Azul | 2 - Vermelho | 3 - Verde | 4 - Laranja | 5 - Roxo
            cores=linspecer(5);
            str=['\color[rgb]{',num2str(cores(n,1)),',',num2str(cores(n,2)),',',num2str(cores(n,3)),'}'];
        end
    end
end