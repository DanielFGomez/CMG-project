%El estado S es concatenar velocidad angular y angulos de gimbal
function dS=gyroDiffEq(t,S,dtheta,I,J,Omega)

w=S(1:3);
theta=S(4:6);

Abg1=quaternion([cosd(0/2)   ;0;0;sind(0/2)   ])*quaternion([cosd(theta(1)/2);0;-sind( theta(1)/2 );0]);
Abg2=quaternion([cosd(120/2);0;0;sind(120/2)])*quaternion([cosd(theta(2)/2);0;-sind( theta(2)/2 );0]);
Abg3=quaternion([cosd(-120/2) ;0;0;sind(-120/2) ])*quaternion([cosd(theta(3)/2);0;-sind( theta(3)/2 );0]);

dw=I^-1*(cross(w,I*w)...
         -J*(cross(w,RotateVector(Abg1,[0;0;1])*Omega(1) + RotateVector(Abg2,[0;0;1])*Omega(2) + RotateVector(Abg3,[0;0;1])*Omega(3))) ...
         -J*(RotateVector(Abg1,[1;0;0])*Omega(1)*dtheta(1) + RotateVector(Abg2,[1;0;0])*Omega(2)*dtheta(2) + RotateVector(Abg3,[1;0;0])*Omega(3)*dtheta(3))); 
     
dS=[dw;dtheta'*180/pi];



