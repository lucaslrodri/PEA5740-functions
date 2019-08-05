function vout = tr(v,a)
    if ~exist('a','var')
        a=[];
    end
    [m,~]= size(v);
    if isreal(v)&&m==3
        vout=2/3*(v(1,:)+v(2,:)*exp(1j*2*pi/3)+v(3,:)*exp(-1j*2*pi/3));
    elseif (~isreal(v))&&(~isempty(a))
        vout=abs(v).*exp(1j*(angle(v)-a));
    else
        vout(1,:)=real(v);
        vout(2,:)=(-real(v)+sqrt(3)*imag(v))/2;
        vout(3,:)=(-real(v)-sqrt(3)*imag(v))/2;
    end
end