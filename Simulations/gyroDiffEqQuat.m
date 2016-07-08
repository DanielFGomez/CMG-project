%El estado S es concatenar quaternion de orientacion y angulos de gimbal
function dS=gyroDiffEqQuat(t,S,dtheta,I,J,Omega,H0)
wB=gyroEq(t,S,dtheta,I,J,Omega,H0);
q=quaternion(S(1:4));
dq=Derivative(q,wB);

%dq=Derivative(q,RotateVector(q,wB));
dS=[real(dq);vector(dq);dtheta'*180/pi];
