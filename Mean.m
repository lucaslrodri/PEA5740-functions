function c = Mean(V)
    i=(0:3)*length(V)/3;
    for k=3:-1:1
        ii=(i(k)+1):i(k+1);
        c(ii)=mean(V(ii),'all');
    end
end