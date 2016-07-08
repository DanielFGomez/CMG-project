explore=0;
ramps=false;

show=input('Show animation? write 1 for yes or 0 for no ');
 
%%STEPS
numTrayStep=5;
StepTray=zeros(ceil(15/dt),numTrayStep);

for ep=1:numTrayStep
    %Inicialize Sc and Sd
    q=rand()*2*pi-pi;
    dq=(rand()-0.5)*0.2;
    theta=0;
    t=0;
    totalReward=0;
    failure=0;
    
    
    sq=discreteState(q,qStates);
    sdq=discreteState(dq,dqStates);
    stheta=discreteState(theta,thetaStates);
    
    %
    tiempoEstable=0;
    tt=1;
    while(t<10)
        
        
        a=chooseAction(Q(sq,sdq,:),0);
        r=0;
        aAction=actions(a)/cos(theta);
        
        for i=0:floor(dtc/dt)
            
            [q,dq,theta]=Step(q,dq,theta,aAction);
            t=t+dt;
            
            r=reward(q,actions(a));
            StepTray(tt,ep)=q;
            tt=tt+1;
            if (ramps)
            aAction=aAction-aAction/floor(dtc/dt);
            end
           
        end 
        
        
        sqNew=discreteState(q,qStates);
        sdqNew=discreteState(dq,dqStates);
        sthetaNew=discreteState(theta,thetaStates);
               
        totalReward=totalReward+r*discountRate^t;
        sq=sqNew;
        sdq=sdqNew;
        stheta=sthetaNew;
        
              
    end
end

   %Inicialize Sc and Sd
qReal=-pi/2;
q=pi/2;
dq=0;
theta=0;
t=0;
totalReward=0;

qTarget=0;

sq=discreteState(q,qStates);
sdq=discreteState(dq,dqStates);
stheta=discreteState(theta,thetaStates);

%
tiempoEstable=0;
tt=0;
j=1;
ramp_time=10;
ramp_spd=pi/ramp_time;
RampTray=zeros(ceil(ramp_time/dt),3);
%%%RAMP
for t=0:dtc:ramp_time
    
    a=chooseAction(Q(sq,sdq,:),explore);
    r=0;
    aAction=actions(a)/cos(theta);
    tt=t;
    
    for i=0:floor(dtc/dt)
        qTarget=tt*ramp_spd-pi/2;
        q=qReal-qTarget;
        [q,dq,theta]=Step(q,dq,theta,aAction);
        qReal=q+qTarget;
        
        r=reward(q,actions(a));

        if (ramps)
        aAction=aAction-aAction/floor(dtc/dt);
        end
        tt=tt+dt;
        RampTray(j,:)=[tt,deg2rad(qReal),deg2rad(qTarget)];
        j=j+1;
        if(show)
            target_xpos=sin(qTarget);
            target_ypos=cos(qTarget);


            xpos=sin(qReal);
            ypos=cos(qReal);
            gimbalX=xpos+0.2*sin(theta);
            gimbalY=ypos+0.2*cos(theta);

            plot([0 xpos],[0 ypos],[0 10*aAction],[0 0],[xpos,gimbalX],[ypos,gimbalY],'LineWidth',8);
            patchline([0 target_xpos],[0 target_ypos],'linestyle','-','edgecolor','g','linewidth',8,'edgealpha',0.2);

            title(strcat('r=',num2str(r),'Total reward',num2str(totalReward), 'dq=',num2str(dq), ' sq=', num2str(ceil(discreteState(q,qStates)-length(qStates)/2-1)),' sdq=',num2str(ceil(discreteState(dq,dqStates)-length(dqStates)/2-1)) ));
            axis([-1.2,1.2,-0.2,1.2]);
            pause(dt)
        end


    end



    sqNew=discreteState(q,qStates);
    sdqNew=discreteState(dq,dqStates);
    sthetaNew=discreteState(theta,thetaStates);

    totalReward=totalReward+r*discountRate^t;
    sq=sqNew;
    sdq=sdqNew;
    stheta=sthetaNew;

end     
 
%Inicialize Sc and Sd
qReal=0;
dqReal=0;

q=pi/2;
dq=0;
theta=0;
t=0;
totalReward=0;

qTarget=0;

sq=discreteState(q,qStates);
sdq=discreteState(dq,dqStates);
stheta=discreteState(theta,thetaStates);

%
tiempoEstable=0;



%SINE
sine_period=15;
sineTray=zeros(ceil(sine_period/dt),3);
sineError=zeros(length(sineTray),1);
j=1;
theta=0;
for t=0:dtc:sine_period
    
    a=chooseAction(Q(sq,sdq,:),explore);
    r=0;
    aAction=actions(a)/cos(theta);
    tt=t;
    for i=0:floor(dtc/dt)
        
        
        qTarget=pi/2*sin(t*2*pi/sine_period);
        dqTarget=pi^2/sine_period*cos(t*2*pi/sine_period);
        q=qReal-qTarget;
        dq=dqReal-dqTarget;

        [q,dq,theta]=Step(q,dq,theta,aAction);
        tt=tt+dt;
        r=reward(q,actions(a));
        
        

        if (ramps)
        aAction=aAction-aAction/floor(dtc/dt);
        end
        qReal=q+qTarget;
        dqReal=dq+dqTarget;
        
        if(show)
            target_xpos=sin(qTarget);
            target_ypos=cos(qTarget);

            
            xpos=sin(qReal);
            ypos=cos(qReal);
            gimbalX=xpos+0.2*sin(theta);
            gimbalY=ypos+0.2*cos(theta);

            plot([0 xpos],[0 ypos],[0 10*aAction],[0 0],[xpos,gimbalX],[ypos,gimbalY],'LineWidth',8);
            patchline([0 target_xpos],[0 target_ypos],'linestyle','-','edgecolor','g','linewidth',8,'edgealpha',0.2);

            title(strcat('r=',num2str(r),'Total reward',num2str(totalReward), 'dq=',num2str(dq), ' sq=', num2str(ceil(discreteState(q,qStates)-length(qStates)/2-1)),' sdq=',num2str(ceil(discreteState(dq,dqStates)-length(dqStates)/2-1)) ));
            axis([-1.2,1.2,-1.2,1.2]);
            pause(dt)
        end

        sineTray(j,:)=[tt, rad2deg(qReal), rad2deg(qTarget)];
        sineError(j)=abs(qReal-qTarget);
        j=j+1;

    end



    sqNew=discreteState(q,qStates);
    sdqNew=discreteState(dq,dqStates);
    sthetaNew=discreteState(theta,thetaStates);

    totalReward=totalReward+r*discountRate^t;
    sq=sqNew;
    sdq=sdqNew;
    stheta=sthetaNew;

end

figure
plot(dt*(0:(length(StepTray)-1)),StepTray*180/pi)
xlabel('Time (s)','FontSize',14)
ylabel('Yaw angle (°)','FontSize',14)

figure
plot(dt*(0:(length(RampTray)-1)),RampTray(:,2),'-b',dt*(0:(length(RampTray)-1)),RampTray(:,3),'--r')
xlabel('Time (s)','FontSize',14)
ylabel('Yaw angle (°)','FontSize',14)
legend('Trajectory','Target')

error=round(10*rad2deg(mean(sineError)))/10;
figure
plot(dt*(0:(length(sineTray)-1)),sineTray(:,2),'-b' ,dt*(0:(length(sineTray)-1)),sineTray(:,3),'--r')
title(strcat('Number of episodes=',num2str(numEpisodes),'  Average error=', num2str(error),'°'))
xlabel('Time (s)','FontSize',14)
ylabel('Yaw angle (rad)','FontSize',14)
legend('Trajectory','Target')
