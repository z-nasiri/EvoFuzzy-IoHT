function infuzzy=Fuzzification3(incrisp)

    infuzzy=zeros(1,3);

    if incrisp<.1
        infuzzy(1)=1;
    end
    if incrisp>=.1 & incrisp<.5
        infuzzy(1)=-2.5*incrisp+1.25;
        infuzzy(2)=2.5*incrisp-.25;
    end
    if incrisp>=.5 & incrisp<.9
        infuzzy(2)=-2.5*incrisp+2.25;
        infuzzy(3)=2.5*incrisp-1.25;
    end
    if incrisp>=.9
        infuzzy(3)=1;
    end
    
end