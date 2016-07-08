function [qNew,dqNew,thetaNew]=Step(q,dq,theta,dtheta)
    
    global I;
    global J;
    global Omega;
    global friction;
    
    global dt;
    qNew=q+dq*dt;
    dqNew=dq+3*((1/I)*J*Omega*dtheta*cos(theta)-dq*friction)*dt;
    if(abs(theta*180/pi)<40)
        thetaNew=theta+dtheta*dt;
    else
        thetaNew=theta;
    end
end