function y=Crossover(x1,x2)

    mask=randi([0 1],size(x1));
    
    y=mask.*x1+(1-mask).*x2;

end
