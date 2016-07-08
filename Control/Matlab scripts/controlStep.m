function [ output ] = controlStep(s,qStates,dqStates,actions,Q,target)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

fprintf(s,'pos');
pos=fscanf(s,'%f')-target
fprintf(s,'vel');
vel=fscanf(s,'%f');


Spos=discreteState(pos,qStates)
Svel=discreteState(vel,dqStates);

a=chooseAction(Q(Spos,Svel,:),0);
gimbalRate=actions(a);

fprintf(s,['action ',num2str(-1*gimbalRate)]);%%Un detalle del sentido de giro del servo

output=[pos,vel,gimbalRate];
end

