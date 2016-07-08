explore=0;
figure;
ramps=false;


while(1) 
    %Inicialize Sc and Sd
    q=rand()*pi-pi/2;
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
    
    while(~failure)
        
        
        a=chooseAction(Q(sq,sdq,:),explore);
        r=0;
        aAction=actions(a)/cos(theta);
        
        for i=0:floor(dtc/dt)
            
            [q,dq,theta]=Step(q,dq,theta,aAction);
            t=t+dt;
            r=reward(q,actions(a));
            
            if (ramps)
            aAction=aAction-aAction/floor(dtc/dt);
            end
            
            xpos=sin(q);
            ypos=cos(q);
            gimbalX=xpos+0.2*sin(theta);
            gimbalY=ypos+0.2*cos(theta);

            plot([0 xpos],[0 ypos],[0 10*aAction],[0 0],[xpos,gimbalX],[ypos,gimbalY],'LineWidth',8);
            
            title(strcat('r=',num2str(r),'Total reward',num2str(totalReward), 'dq=',num2str(dq), ' sq=', num2str(ceil(discreteState(q,qStates)-length(qStates)/2-1)),' sdq=',num2str(ceil(discreteState(dq,dqStates)-length(dqStates)/2-1)) ));
            axis([-1,1,0,2]);
            pause(dt)
        end
            
        
        
        sqNew=discreteState(q,qStates);
        sdqNew=discreteState(dq,dqStates);
        sthetaNew=discreteState(theta,thetaStates);
            
        totalReward=totalReward+r*discountRate^t;
        sq=sqNew;
        sdq=sdqNew;
        stheta=sthetaNew;
        
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
            t=maxT;
            totalReward=totalReward-20;
        end     
    end
end
