function i=RouletteWheelSelection(PR)

    r=rand;
    
    PR=PR/sum(PR);
    
    c=cumsum(PR);
    
    c=sort([c r]);
    
    i=find(c==r,1,'first');

end