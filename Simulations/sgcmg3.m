clc
clear

import quaternion
T=5;
m=0;

omega1=4186;%~40000RPM
omega2=4186;
omega3=4186;
Omega=[omega1, omega2, omega3];
J=3.6e-5; %La inercia del volante nuevo es 45.9 la del viejo es 36kgmm^2
Icmg=diag([J/2, J/2, J]);
I=[[25870,0,0];[0,25870,0];[0,0,44061]]*10^-6;
momI=diag(I);
prodI=[I(1,2),I(1,3),I(2,3)];
L1=0.115; %Todavia no esta vinculado a la sim pero tiene el mismo valor 0.115
L2=0.11;  %Todavia no esta vinculado a la sim pero tiene el mismo valor 0.11
gimbal_inertia=100*10^-6;%kg m^2
friction=0;%0.228;

theta_i=[45 45 45];
angulo=45;%Angulo entre la vertical y el soporte del gimbal

Imass=m*(L1+L2*sind(angulo))^2*[1.5 0 0;0 1.5 0;0 0 3]; %Por el momento asume que el plano de las masas esta sobre el centro de rotacion del sistema para ignorar los prductos de inercia. Si cambiamos el angulo la sim y las ecuaciones no cuadran.
Itot=I+Imass; %Se considera solo la inercia del cuerpo y la inercia por la masa de los volantes vista desde el origen, no la inercia de los volantes

g1=[0,1,0];
g2=[-sin(60),cos(60),0];
g3=[-sin(120),cos(120),0];

kp=I(end)/(J*omega1*3*1);

dtheta=0.1*[1 1 1];
gimbalRate1=dtheta(1);
gimbalRate2=dtheta(2);
gimbalRate3=dtheta(3);

gimbalRateSignal=zeros(T*1000,4);
j=1;
for i=0:0.001:T
    gimbalRateSignal(j,:)=[i,GimbalRate_Func(i,dtheta)];
    j=j+1;
end

sim('SGCMG3');

t=qstruct.time;
q=quaternion(qstruct.signals.values);
qv1=quaternion(qv1);
qv2=quaternion(qv2);
qv3=quaternion(qv3);

v1=RotateVector(qv1,[0,0,1])';
v2=RotateVector(qv2,[0,0,1])';
v3=RotateVector(qv3,[0,0,1])';



Lg=J*(omega1*v1+omega2*v2+omega3*v3);
LgI=RotateVector(q,Lg);
LcCalc=(ones(length(t),1)*Lg(1,:)-LgI);

dwcalc=zeros(length(t),3);
wcalc=zeros(length(t),3);
Torque=zeros(length(t),3);
dHcmg=zeros(length(t),3);
dHcuerpo=zeros(length(t),3);

TorqueJD=zeros(length(t),3);

dt=0;
i=1;
qPrueba(1)=quaternion([1;0;0;0]);
for i=1:length(t)
% 
% W=J*[omega1*cross(g1,v1(i,:))',omega2*cross(g2,v2(i,:))',omega3*cross(g3,v3(i,:))'];
% dwcalc(i,:)=(dtheta*W' - cross(w(i,:) , ((w(i,:)*I')+Lg(i,:))))*(Itot^-1)';
% Torque(i,:)=dtheta*W';
% dHcmg(i,:)=-cross(w(i,:) , Lg(i,:));
% dHcuerpo(i,:)=-cross(w(i,:) , ((w(i,:)*I')));
% 
% q1=theta(i,1);
% q2=theta(i,2);
% q3=theta(i,3);
% TorqueJD(i,1)=((sin(q3)+cos(q3))*sind(30)*gimbalRate3 + (sin(q2)-cos(q2))*sind(30)*gimbalRate2 - (sin(q1)+cos(q1))*gimbalRate1)*cosd(angulo)*J*omega1;
% TorqueJD(i,2)=((sin(q3)+cos(q3))*cosd(30)*gimbalRate3 + (sin(q2)+cos(q2))*cosd(30)*gimbalRate2)*cosd(angulo)*J*omega1;
% TorqueJD(i,3)=((sin(q3)-cos(q3))*gimbalRate3 + (sin(q2)-cos(q2))*gimbalRate2 + (sin(q1)-cos(q1))*gimbalRate1)*sind(angulo)*J*omega1;
%  
% dwJD=TorqueJD*(I^-1)';
end

SolODE=ode45(@(tODE,S)gyroDiffEq(tODE,S,GimbalRate_Func(tODE,dtheta),Itot,J,Omega),[0,T],[0,0,0,theta_i]);
SODE=deval(SolODE,t)';
wODE=-SODE(:,1:3);


Solq=ode45(@(tq,Sq)gyroDiffEqQuat(tq,Sq,GimbalRate_Func(tq,dtheta),Itot,J,Omega,Lg(1,:)'),[0,T],[1,0,0,0,theta_i]);
Sq=deval(Solq,t)';
qq=quaternion(Sq(:,1:4));
wq =zeros(length(t),3);


for i=1:length(t)
    dwq=gyroEq(t(i),Sq(i,:),dtheta,Itot,J,Omega,Lg(1,:)');
    wq(i,:)=dwq(1:3)';
end

SolJS=ode45(@(tJS,SJS)gyroDiffEqJSN(tJS,SJS,dtheta,Itot,J,Omega),[0,T],[0,0,0,theta_i]);
SJS=deval(SolJS,t)';
wJS=SJS(:,1:3);

    
str=sprintf(strcat('Gimbal rates (rad/s)= ', num2str([gimbalRate1,gimbalRate2,gimbalRate3])));

colors=['b- ';'y--';'k- ';'r: ';'g  '];
nomEjes=['x','y','z'];
figure

for i=1:3

    subplot(3,1,i)
    plot(t,wBody(:,i),colors(1,:),t,wODE(:,i),colors(2,:),t,wq(:,i),colors(4,:),'linewidth',2)
    xlabel(texlabel('t(s)'),'FontSize',14)
    ylabel(texlabel(strcat(nomEjes(i) ,' (rad/s)')),'FontSize',14)
    
end

 legend('Sim','A','B')
 suptitle(str);
 
 figure
 angles=rad2deg(squeeze(EulerAngles(q,'123')));
 for i=1:3

    subplot(3,1,i)
    plot(t,angles(i,:))
    title(strcat('Angle ',{' '},nomEjes(i)));
    xlabel(texlabel('t(s)'))
    ylabel(texlabel('deg'))
    
 end
 suptitle(str);
