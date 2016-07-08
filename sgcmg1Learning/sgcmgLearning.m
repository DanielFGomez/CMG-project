clc
clear



%Learning parameters
global learningRate
global discountRate
explore0=0.7;
numEpisodes=300;
numPreTrain=10;

%Environment parameters
global I
global J
global Omega
global dt
global friction

%Discretization parameters
qStates=[-180,-90,-45:5:45,90,180]*pi/180;
dqStates=[-0.5:0.2:0.5];
thetaStates=[-45,45]*pi/180;
actions=2.5*[-0.1,-0.02,0,0.02,0.1];

learningRate=0.4;
discountRate=0.4;

I=44061*10^-6;
J=3.6e-5;
Omega=785;
dt=0.05;
friction=0.22; %dw=-w*friction

maxT=50;
dtc=0.5;
successT=5*dtc;
successAngle=5*pi/180;

ramps=0;
%Inicialize Q
Q=rand(length(qStates)+1,length(dqStates)+1,length(actions));
timesVisited=zeros(length(qStates)+1,length(dqStates)+1,length(actions));


exploreHistory=[0];
performance=[0,0];
History=zeros(floor(numEpisodes*maxT/dt),5);
n=1;
ep=1;

%Non actuated episodes to pre train
% for numEp=1:numPreTrain
%     %Inicialize Sc and Sd
%     if numEp<5
%         q=-70*pi/180;
%     else
%         q=70*pi/180;
%     end
%     dq=0.6-0.1*numEp;
%     theta=0;
%     t=0;
%     totalReward=0;
%     failure=0;
%     
%     eligibilityTrace=zeros(size(Q));
%     
%     
%     performance(ep)=totalReward;
%     ep=ep+1
% end

%%%%%%%%%%%%%%

for numEp=1:numEpisodes
    %Inicialize Sc and Sd
    q=rand()*pi-pi/2;
    dq=(rand()-0.5)*0.2;
    theta=0;
    t=0;
    totalReward=0;
    failure=0;
    
    sq=discreteState(q,qStates);
    sdq=discreteState(dq,dqStates);
  
    
    explore=explore0;
    if numEp>numEpisodes/3
         explore=explore0*(2-3*numEp/numEpisodes);
    end
    if numEp>numEpisodes*2/3

        explore=0;
    end
    exploreHistory(ep)=explore;
    
    %
    tiempoEstable=0;
    
    while(~failure)
        
        
        a=chooseAction(Q(sq,sdq,:),explore);
        r=0;
        aAction=actions(a)/cos(theta);
        
        for i=0:floor(dtc/dt)
            
            [q,dq,theta]=Step(q,dq,theta,aAction);
            t=t+dt;
            History(n,:)=[q,dq,theta,actions(a),ep];
            n=n+1;
            r=reward(q,actions(a));
            
            if ramps
            aAction=aAction-aAction/floor(dtc/dt);% Esta linea hace que el
            %gimbal rate sea una rampa decreciente.
            end
            
        end
        
        sqNew=discreteState(q,qStates);
        sdqNew=discreteState(dq,dqStates);
       
       
        
        Q(sq,sdq,a)=Q(sq,sdq,a)+learningRate*(r+discountRate*Q(sqNew,sdqNew,a)-Q(sq,sdq,a));
           
        
        totalReward=totalReward+r*discountRate^t;
        timesVisited(sq,sdq,a)=timesVisited(sq,sdq,a)+1;
        sq=sqNew;
        sdq=sdqNew;
        
        
        if abs(q)<successAngle
            tiempoEstable=tiempoEstable+dtc;
        else
            tiempoEstable=0;
        end
        if tiempoEstable>successT;
            totalReward=totalReward+20;
            failure=1;
        end
        
        %Breaking conditions
        if(t>maxT)
            failure=1;
            t=maxT;
        end     
        if(abs(q)>pi)
            failure=1;
            t=maxT;
            totalReward=totalReward-20;
        end
        
    end
    performance(ep,1)=totalReward;
    performance(ep,2)=t;
    ep=ep+1
end

actionMatrix=zeros(length(qStates),length(dqStates));
for i=1:length(qStates)+1
    for j=1:length(dqStates)+1
        actionMatrix(i,j)=actions(chooseAction(Q(i,j,:),0));
    end
end

figure
subplot(2,1,1)
plot(performance(:,1));
title(strcat('Premio total'),'FontSize',20)
xlabel('Numero de episodios','FontSize',20)
ylabel('Premio Total','FontSize',20)

subplot(2,1,2)
plot(performance(:,2));
title(strcat('Tiempo de estabilización'),'FontSize',20)
xlabel('Episode Number','FontSize',20)
ylabel('Time (s)','FontSize',20)

        
     