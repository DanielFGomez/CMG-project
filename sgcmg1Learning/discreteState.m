%S=0 means fail state
function S=discreteState(variable, list)
    S=find(list>=variable,1);
    if isempty(S)
        S=length(list)+1;
    end
end