function [ output ] = sgcmgCrossValidation( learningRate,discountRate,explore )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%Learning parameters
numEpisodes=300;

%Environment parameters
global I
global J
global Omega
global dt

%Discretization parameters
qStates=[-90,-45:5:45,90]*pi/180;
dqStates=[-0.05:0.02:0.05];
thetaStates=[-45,45]*pi/180;
actions=[-0.1,-0.02,0,0.02,0.1];

I=44061*10^-6;
J=3.6e-5;
Omega=4188;
dt=0.05;
maxT=50;
dtc=0.5;


%Inicialize Q
Q=rand(length(qStates)+1,length(dqStates)+1,length(thetaStates)+1,length(actions));
timesVisited=zeros(length(qStates)+1,length(dqStates)+1,length(thetaStates)+1,length(actions));
%%Intentar inicializando Q con el premio


performance=zeros(floor(numEpisodes*maxT/dt),1);
History=zeros(floor(numEpisodes*maxT/dt),5);
n=1;
ep=1;

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
    stheta=discreteState(theta,thetaStates);
    
    if numEp>0.7*numEpisodes
        explore=0;
    end
    %
    tiempoEstable=0;
    
    while(~failure)
        
        
        a=chooseAction(Q(sq,sdq,stheta,:),explore);
        r=0;
        aAction=actions(a);
        
        for i=0:floor(dtc/dt)
            
            [q,dq,theta]=Step(q,dq,theta,aAction);
            t=t+dt;
            History(n,:)=[q,dq,theta,actions(a),ep];
            n=n+1;
            r=reward(q,actions(a));
            aAction=aAction-aAction/floor(dtc/dt);
            
        end
        
        sqNew=discreteState(q,qStates);
        sdqNew=discreteState(dq,dqStates);
        sthetaNew=discreteState(theta,thetaStates);
       
        
        Q(sq,sdq,stheta,a)=Q(sq,sdq,stheta,a)+learningRate*(r+discountRate*Q(sqNew,sdqNew,sthetaNew,a)-Q(sq,sdq,stheta,a));
           
        
        totalReward=totalReward+r*discountRate^t;
        timesVisited(sq,sdq,stheta,a)=timesVisited(sq,sdq,stheta,a)+1;
        sq=sqNew;
        sdq=sdqNew;
        stheta=sthetaNew;
        
        if abs(q)<5*pi/180
            tiempoEstable=tiempoEstable+1;
        else
            tiempoEstable=0;
        end
        if tiempoEstable>5;
            totalReward=totalReward+20;
            failure=1;
        end
        
        %Breaking conditions
        if(or(t>maxT,abs(q)>pi/2))
            failure=1;
        end     
    end
    performance(ep)=totalReward;
    ep=ep+1;
end

performance=performance(performance~=0);

output=[mean(performance),std(performance),sum(performance>0),min(performance),find(performance>5,1)];


end

