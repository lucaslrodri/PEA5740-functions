function seq = decoup(V,Vref)  
    for j=2:-1:1
       a=(-1)^(j-1)*angle(tr(Vref));
       dq=tr(V,a);
       seq(j,:)=tr(media(dq),-a);
    end
    
    %Calcula a média em um intervalo
    function c=media(Val)
        i=round((0:3)*length(Val)/3);
        for k=3:-1:1
            c((i(k)+1):i(k+1))=mean(Val((i(k)+1):i(k+1)));
        end
    end
end