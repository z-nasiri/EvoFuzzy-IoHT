function Fitness=FuzzyAlgorithm(F1,F2,F3,F4,F5,W,A,NumInputMFs,NumOutputMFs)

    DefuzzyMethod=1;

    NumOptions=length(F1);

    Fitness=zeros(1,NumOptions);

    in1=F1;
    in2=F2;
    in3=F3;
    in4=F4;
    in5=F5;

    %%%%%%%% Normalization of Inputs

    if min(F1)~=max(F1)
        in1=(F1-min(F1))/(max(F1)-min(F1));
    else
        in1(:)=0.5;
    end
    if min(F2)~=max(F2)
        in2=(F2-min(F2))/(max(F2)-min(F2));
    else
        in2(:)=0.5;
    end
    if min(F3)~=max(F3)
        in3=(F3-min(F3))/(max(F3)-min(F3));
    else
        in3(:)=0.5;
    end
    if min(F4)~=max(F4)
        in4=(F4-min(F4))/(max(F4)-min(F4));
    else
        in4(:)=0.5;
    end
    if min(F5)~=max(F5)
        in5=(F5-min(F5))/(max(F5)-min(F5));
    else
        in5(:)=0.5;
    end

    %%%%%%%% Fuzzy Rules Design

    WF=zeros(NumInputMFs,NumInputMFs,NumInputMFs,NumInputMFs,NumInputMFs);
    for i1=1:NumInputMFs
        for i2=1:NumInputMFs
            for i3=1:NumInputMFs
                for i4=1:NumInputMFs
                    for i5=1:NumInputMFs
                        WF(i1,i2,i3,i4,i5)=W(1)*(i1-1)^A(1)+W(2)*(i2-1)^A(2)+W(3)*(i3-1)^A(3)+W(4)*(i4-1)^A(4)+W(5)*(i5-1)^A(5);
                    end
                end
            end
        end
    end
    WF=round(((WF-min(WF(:)))/(max(WF(:))-min(WF(:))))*(NumOutputMFs-1))+1;

    %%%%%%%% Fuzzy Calculation for each Requested Node

    for ij=1:NumOptions

        %%%%%%%% Fuzzification

        if NumInputMFs==3
            infuzzy1=Fuzzification3(in1(ij));
            infuzzy2=Fuzzification3(in2(ij));
            infuzzy3=Fuzzification3(in3(ij));
            infuzzy4=Fuzzification3(in4(ij));
            infuzzy5=Fuzzification3(in5(ij));
        end    
        if NumInputMFs==5
            infuzzy1=Fuzzification5(in1(ij));
            infuzzy2=Fuzzification5(in2(ij));
            infuzzy3=Fuzzification5(in3(ij));
            infuzzy4=Fuzzification5(in4(ij));
            infuzzy5=Fuzzification5(in5(ij));
        end

        %%%%%%%% Rule Base Table

        outmat=zeros(NumInputMFs,NumInputMFs,NumInputMFs,NumInputMFs,NumInputMFs);
        for i1=1:NumInputMFs
            for i2=1:NumInputMFs
                for i3=1:NumInputMFs
                    for i4=1:NumInputMFs
                        for i5=1:NumInputMFs
                            if DefuzzyMethod==1
                                outmat(i1,i2,i3,i4,i5)=min([infuzzy1(i1),infuzzy2(i2),infuzzy3(i3),infuzzy4(i4),infuzzy5(i5)]);
                            end
                            if DefuzzyMethod==2
                                outmat(i1,i2,i3,i4,i5)=prod([infuzzy1(i1),infuzzy2(i2),infuzzy3(i3),infuzzy4(i4),infuzzy5(i5)]);
                            end
                        end
                    end
                end
            end
        end

        %%%%%%%% Defuzzification

        Centers=0:(1/(NumOutputMFs-1)):1;

        Values=zeros(1,NumOutputMFs);
        for i1=1:NumInputMFs
            for i2=1:NumInputMFs
                for i3=1:NumInputMFs
                    for i4=1:NumInputMFs
                        for i5=1:NumInputMFs
                            Values(WF(i1,i2,i3,i4,i5))=Values(WF(i1,i2,i3,i4,i5))+outmat(i1,i2,i3,i4,i5);
                        end
                    end
                end
            end
        end

        Fitness(ij)=sum(Values.*Centers);

    end

end
