
m=Pk_FD(k,t);
Fogs=find(Fog_Domains==m);

F1=(F_CPU(Fogs)-F_CPU_Usage(t,Fogs))./F_CPU(Fogs);
F2=(F_RAM(Fogs)-F_RAM_Usage(t,Fogs))./F_RAM(Fogs);
F3=(F_DISK(Fogs)-F_DISK_Usage(t,Fogs))./F_DISK(Fogs);
F4=(max(F_POWER(Fogs))-F_POWER(Fogs))/(max(F_POWER(Fogs))-min(F_POWER(Fogs)));
F5=(max(L_MF(Fogs))-L_MF(Fogs))/(max(L_MF(Fogs))-min(L_MF(Fogs)));

Fitness=FuzzyAlgorithm(F1,F2,F3,F4,F5,W_F,A_F,NumInputMFsF,NumOutputMFsF);

NonFeasibleNodes=find((F_CPU(Fogs)-F_CPU_Usage(t,Fogs)-I_CPU(k,d))<0 | (F_RAM(Fogs)-F_RAM_Usage(t,Fogs)-I_RAM(k,d))<0 | (F_DISK(Fogs)-F_DISK_Usage(t,Fogs)-I_DISK(k,d))<0);
Fitness(NonFeasibleNodes)=-1;
NumFeasible=length(find(Fitness>0));

[val,ind]=sort(Fitness,'descend');

if NumFeasible>0
    Selected_Fogs=Fogs(ind(1:min(BN,NumFeasible)));
    DataAllocate_FogNodes(k,d,Selected_Fogs)=1;
    F_CPU_Usage(t,Selected_Fogs)=F_CPU_Usage(t,Selected_Fogs)+I_CPU(k,d);
    F_RAM_Usage(t,Selected_Fogs)=F_RAM_Usage(t,Selected_Fogs)+I_RAM(k,d);
    F_DISK_Usage(t,Selected_Fogs)=F_DISK_Usage(t,Selected_Fogs)+I_DISK(k,d);
    F_POWER_Usage(t,Selected_Fogs)=F_POWER_Usage(t,Selected_Fogs)+I_Size(k,d)*F_POWER(Selected_Fogs);
    if t==1
        E_POWER_Usage(t)=E_POWER_Usage(t)+I_Size(k,d)*E_POWER;
    end
elseif t==1
    Err_FogResource(k,d)=1;
end
