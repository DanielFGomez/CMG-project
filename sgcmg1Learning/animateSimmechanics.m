
m=0.0;
sinePeriod=40;

omega1=Omega;
omega2=Omega;
omega3=Omega;

J=3.6e-5;
Icmg=diag([J/2, J/2, J]);
I=[[25870,0,0];[0,25870,0];[0,0,44061]]*10^-6;
momI=diag(I);
prodI=[I(1,2),I(1,3),I(2,3)];
I=I(end);
friction=0.22;

T=40;

L1=0.115; %Todavia no esta vinculado a la sim pero tiene el mismo valor 0.115
L2=0.11;  %Todavia no esta vinculado a la sim pero tiene el mismo valor 0.11


theta_i=[90,90,90];
angulo=45;%Angulo entre la vertical y el soporte del gimbal

Imass=m*(L1+L2*sind(angulo))^2*[1.5 0 0;0 1.5 0;0 0 3]; %Por el momento asume que el plano de las masas esta sobre el centro de rotacion del sistema para ignorar los prductos de inercia. Si cambiamos el angulo la sim y las ecuaciones no cuadran.
Itot=I+Imass; %Se considera solo la inercia del cuerpo y la inercia por la masa de los volantes vista desde el origen, no la inercia de los volantes

target=zeros(100,2);

for i=1:100
    target(i,:)=[T/100,pi/2];
end
figure
sim('QlearningSimmechanics');
plot(simQlearning(:,1),rad2deg(simQlearning(:,2)),simQlearning(:,1),rad2deg(simQlearning(:,3)),'linewidth',2)
hold all
kp=0.2038;
ki=0;
kd=0.4076;
sim('PID');
plot(simPID(:,1),rad2deg(simPID(:,3)),'linewidth',2)

hold all

plot(trayectoria(:,1),rad2deg(trayectoria(:,2)),'linewidth',2)




