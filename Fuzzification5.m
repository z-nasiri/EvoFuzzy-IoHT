function infuzzy=Fuzzification5(incrisp)

    infuzzy=zeros(1,5);

    if incrisp<.1
        infuzzy(1)=1;
    end
    if incrisp>=.1 & incrisp<.3
        infuzzy(1)=-5*incrisp+1.5;
        infuzzy(2)=5*incrisp-.5;
    end
    if incrisp>=.3 & incrisp<.5
        infuzzy(2)=-5*incrisp+2.5;
        infuzzy(3)=5*incrisp-1.5;
    end
    if incrisp>=.5 & incrisp<.7
        infuzzy(3)=-5*incrisp+3.5;
        infuzzy(4)=5*incrisp-2.5;
    end
    if incrisp>=.7 & incrisp<.9
        infuzzy(4)=-5*incrisp+4.5;
        infuzzy(5)=5*incrisp-3.5;
    end
    if incrisp>=.9
        infuzzy(5)=1;
    end
    
end