
Y=[qStates, nan];

titulos=[nan, dqStates, nan];
pltN1=ceil(sqrt(length(dqStates)));
pltN2=ceil(length(dqStates)/pltN1);


actionIndexMatrix=zeros(length(qStates),length(dqStates));
StateValue=zeros(length(qStates),length(dqStates));
Visited=zeros(length(qStates),length(dqStates));


for i=1:length(qStates)
    for j=1:length(dqStates)
        actionIndexMatrix(i,j)=chooseAction(Q(i,j,:),0);
        StateValue(i,j)=sum(Q(i,j,:));
        Visited(i,j)=sum(timesVisited(i,j,:));
    
    end
end
   


figure
surf(rad2deg([qStates(1)-0.01,qStates]),[dqStates(1)-0.01,dqStates],actionMatrix')
ylabel('Velocity (rad/s)','FontSize',14)
xlabel('Position (°)','FontSize',14)
title('Action Map')
colormap('jet')
h = colorbar;
ylabel(h, 'Gimbal Rate (rad/s)','FontSize',14) 

figure
surf(rad2deg(qStates),dqStates,StateValue')
ylabel('Velocity (rad/s)')
xlabel('Position (°)')
title('State Value')

figure
surf(rad2deg(qStates),dqStates,Visited')
ylabel('Velocity (rad/s)')
xlabel('Position (°)')
title('Times Visited')
colormap('jet')
colorbar()
caxis([0 200])
