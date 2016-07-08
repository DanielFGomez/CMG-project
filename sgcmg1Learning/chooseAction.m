function a = chooseAction( Q,e )
%e is the exploration factor
%Q must be the list of action values for the current state
if rand()>e
    a=find(Q==max(Q),1);
else
    a=randi(length(Q));
end

