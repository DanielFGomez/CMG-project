% %%%%%%%%%%%%%%%%%%%%
%PID test
u=3*(1/I)*J*Omega;
kp=1/u;
kd=2/u;

num_PID_tray=5;
PIDTray=zeros(ceil(10/dt),num_PID_tray);

if (show)
    figure
end
for j=1:num_PID_tray
    %Inicialize Sc and Sd
    q=rand()*pi-pi/2;
    dq=0.0;
    theta=0;
    t=0;
    n=1;
    totalReward=0;
    failure=0;
    
    sq=discreteState(q,qStates);
    sdq=discreteState(dq,dqStates);
    stheta=discreteState(theta,thetaStates);
    eligibilityTrace=zeros(size(Q));
    %
    while(~failure)
        
        a=-kp*q-kd*dq;
        if a>actions(end)
            a=actions(end);
        end
        if a<actions(1)
            a=actions(1);
        end
        
        
        for i=0:floor(dtc/dt)
            PIDTray(n,j)=q;
            [q,dq,theta]=Step(q,dq,theta,a);
            t=t+dt;
            n=n+1;
            
            if(show)
                xpos=sin(q);
                ypos=cos(q);
                gimbalX=xpos+0.2*sin(theta);
                gimbalY=ypos+0.2*cos(theta);

                plot([0 xpos],[0 ypos],[0 50*a],[0 0],[xpos,gimbalX],[ypos,gimbalY],'LineWidth',8);

                title(strcat('r=',num2str(r),'Total reward',num2str(totalReward), 'dq=',num2str(dq), ' sq=', num2str(discreteState(q,qStates)),' sdq=',num2str(discreteState(dq,dqStates)) ));
                axis([-1,1,0,2]);
                pause(dt)
            end
         end
        
        sqNew=discreteState(q,qStates);
        sdqNew=discreteState(dq,dqStates);
        sthetaNew=discreteState(theta,thetaStates);
        
        r=reward(q,a);
        
        
        
        totalReward=totalReward+r*discountRate^t;
      
        if abs(q)<5*pi/180
            tiempoEstable=tiempoEstable+dtc;
        else
            tiempoEstable=0;
        end
        if tiempoEstable>successT;
            totalReward=totalReward+20;
            failure=1;
        end
        %Breaking conditions
        if(or(t>maxT,abs(q)>pi/2))
            failure=1;
        end     
    end
end

figure
plot(dt*(0:(length(PIDTray)-1)),PIDTray)
xlabel('Time (s)')
ylabel('Yaw angle (rad)')