function w=gyroEq(t,S,dtheta,I,J,Omega,H0)
A_BI=conj(quaternion(S(1:4)));
theta=S(5:7);

Abg(1)=quaternion([cosd(0/2)   ;0;0;sind(0/2)   ])*quaternion([cosd(theta(1)/2);0;-sind( theta(1)/2 );0]);
Abg(2)=quaternion([cosd(120/2);0;0;sind(120/2)])*quaternion([cosd(theta(2)/2);0;-sind( theta(2)/2 );0]);
Abg(3)=quaternion([cosd(-120/2) ;0;0;sind(-120/2) ])*quaternion([cosd(theta(3)/2);0;-sind( theta(3)/2 );0]);

HGb=zeros(3,1);
for i=1:3
    HGb = HGb + J*Omega(i)*RotateVector(Abg(i),[0;0;1]);
end

%w is expressed in Body refrerence frame
w=I^-1*(RotateVector(A_BI,H0)-HGb);