function [ dtheta ] = GimbalRate_Func( t,GimbalRate0 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%dtheta=[.1 0 0];

% if t<pi
% dtheta=[0.5 0 0];
% end
% if t>5+pi & t<5+2*pi
%     dtheta=[-0.5 0 0];

% if t<2
%     dtheta=[0 -0.5 0.5];
% end
% 
% if t>7
%     dtheta=[0 0.5 -0.5];
% end
dtheta=GimbalRate0.*[sin(t*4*2*pi/15),-1.5*sin(t*3*2*pi/17),sin(t*5*2*pi/20)];
    
end

