function Xnew=UpdateSolutionWOA(X,Xstar,Xrand,n,IterWOA,MIN,MAX)

    a=2-2*n/IterWOA;
    
    r=rand(size(X));
    p=rand;
    C=2*r;
    A=2*a*r-a;
   
    b=1;
    if p<0.5
        if mean(abs(A(:)))<1
            D=C.*Xstar-X;
            Xnew=Xstar-A.*D;
        else
            D=C.*Xrand-X;
            Xnew=Xrand-A.*D;
        end
    else
        D=Xstar-X;
        l=2*rand-1;
        Xnew=D*exp(b*l)*cos(2*pi*l)+Xstar;
    end
    
    Xnew=min(Xnew,MAX);
    Xnew=max(Xnew,MIN);
    
end