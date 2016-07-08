function r= reward( q,a )

    r=exp(-(q*12/pi)^2)-0.5;
%     r=-(rad2deg(q^2);
    if abs(q)>pi/2
        r=-100;
    end
   
    
end

