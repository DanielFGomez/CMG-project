comPort = 'COM3';

delete(instrfind);
[arduino,serialFlag] = setupSerial(comPort);

fprintf(arduino,'start');q
pause(2);
fprintf(arduino,'m 1100');
fscanf(arduino,'%s')
pause(4);


dt=0.2;% Tiempo de control (s)
T=30;%Tiempo de prueba (s)

trayectoria=zeros(length(0:dt:T),4);
j=1;

% for j=1:5
%     fprintf(arduino,'pos');
%     pos=fscanf(arduino,'%f')
%     fprintf(arduino,'vel');
%     vel=fscanf(arduino,'%f')
%     j
% end

target=pi/2;


pos=fscanf(arduino,'%f')

for t=0:dt:T
   a=controlStep(arduino,qStates,dqStates,actions,Q,target)
   trayectoria(j,:)=[t,a];
   j=j+1;
   pause(dt);
end

figure
subplot(3,1,1)
plot(trayectoria(:,1),rad2deg(trayectoria(:,2)),'linewidth',2)
ylabel('Ángulo(°)','fontsize',14)

subplot(3,1,2)
plot(trayectoria(:,1),(trayectoria(:,3)),'linewidth',2)
ylabel('velocidad\n angular (rad/s)','fontsize',14,'interpreter','latex')

subplot(3,1,3)
plot(trayectoria(:,1),(trayectoria(:,4)),'linewidth',2)
xlabel('Tiempo (s)','fontsize',20)
ylabel({'Velocidad';'de cardanes (rad/s)'},'fontsize',14)


fprintf(arduino,'m 1000');
fclose(arduino)