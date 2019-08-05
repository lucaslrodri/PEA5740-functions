function [C,Centro] = find_cap(Scarga,vc0,conf)
    if ~exist('vc0','var')
        vc0=1;
    end
    if ~exist('conf','var')
        conf=struct;
    end
    if ~isfield(conf,'MaxIter')
        conf.MaxIter=100;
    end
    if ~isfield(conf,'Osc')
        conf.Osc=0.1;
    end
    if ~isfield(conf,'Tol')
        conf.Tol=1e-12;
    end
    if ~isfield(conf,'CapInterval')
        conf.CapInterval=[0,1000];
    end
% % Bisseção (Não deu certo =/)
%     a=conf.CapInterval(1);
%     b=conf.CapInterval(2);
%     C=(b+a)/2;
%     for w=1:conf.MaxIter
%         if abs(find_pp_relativo(C))<conf.Tol
%             break;
%         end
%         fprintf('Iter=%d C=%f a=%f b=%f f(a)=%f f(b)=%f f(c)=%f\n',w,C,a,b,find_pp_relativo(a),find_pp_relativo(b),mean([find_pp_relativo(b),find_pp_relativo(a)]));
%         if find_pp_relativo(a)*find_pp_relativo(b)<0
%             a=C;
%         else
%             b=C;
%         end
%         C=(a+b)/2;
%     end
%     if w==100
%         error('Erro! iter=100');
%     end
    %options = optimset('Display','iter'); % show iterations
    C=fzero(@(C)(max(max(Find_pp(C)./Find_pp(C,'med')/2))-conf.Osc),[1e-6,10000]);
    Centro=vc0-Find_pp(C,'med')/2;
    function out = Find_pp(C,type)
        if ~exist('C','var')
            C=1000;
        end
        if ~exist('type','var')
            type='pp';
        end
        tt=t(6,1/60);
        vre=vcap(tt,real(Scarga)-real(media(Scarga)),C/1000,vc0);
        vim=vcap(tt,imag(Scarga),C/1000,vc0);
        [pp_re,Med_re]=find_pp(vre);
        [pp_im,Med_im]=find_pp(vim);
        pp=[pp_re;pp_im];
        Med=vc0-[Med_re;Med_im]/2;
        if ~isreal(pp)||~isreal(Med)
            pp=1000*ones(2,3);
            Med=1000*ones(2,3);
        end
        if Med<1e-3
            Med=1e-3;
        end
        if strcmp(type,'pp')
            out=pp;
        else
            out=Med;
        end
        
        function c=media(Val)
            i=round((0:3)*length(Val)/3);
            for k=3:-1:1
                c((i(k)+1):i(k+1))=mean(Val((i(k)+1):i(k+1)));
            end
        end
        function [pp,Med] = find_pp(Val)
            i=round((0:3)*length(Val)/3);
            for k=3:-1:1
                Med(k)=mean(Val((i(k)+1):i(k+1)));
                if abs(Med(k))<1e-12
                    Med(k)=Med(k)/abs(Med(k))*1e-12;
                elseif Med(k)==0
                    Med(k)=1e-12;
                end
                pp(k)=(max(Val((i(k)+1):i(k+1)))-min(Val((i(k)+1):i(k+1))))/Med(k);
            end
        end
        function v=vcap(tt,p,C, vc0)
            % v=vcap(t,p,C, vc0)
            % calcula a tensão no capacitor do lado cc do conversor
            % que atua como filtro
            % p= vetor contendo a potencia instantanea
            % t= escala de tempo
            % C valor do capacitor
            % vc0= valor inicial da tensão no capacitor
            vc2=lsim(2/C, [1 0], p, tt)+vc0^2;
            v=sqrt(vc2);
        end
    end
    function c=Media(Val)
        i=round((0:3)*length(Val)/3);
        for k=3:-1:1
            c(k)=real(mean(Val((i(k)+1):i(k+1))));
            if c(k)<1e-6
                c(k)=1e-6;
            end
        end
    end
end