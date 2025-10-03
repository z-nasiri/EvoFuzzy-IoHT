function y=Mutation(x,VarMin,VarMax,NumMuteParam)
    
    y=x;

    for nm=1:NumMuteParam
        i=randi(length(x));
        y(i)=VarMin(i)+rand*(VarMax(i)-VarMin(i));
    end

end
