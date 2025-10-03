
F1=(C_CPU-C_CPU_Usage(t,:))./C_CPU;
F2=(C_RAM-C_RAM_Usage(t,:))./C_RAM;
F3=(C_DISK-C_DISK_Usage(t,:))./C_DISK;
F4=(max(C_POWER)-C_POWER)/(max(C_POWER)-min(C_POWER));
F5=(max(L_SC)-L_SC)/(max(L_SC)-min(L_SC));

% Fitness=(F1+F2+F3+F4+F5)/5;
Fitness=(F4+F5)/2;

NonFeasibleNodes=find((C_CPU-C_CPU_Usage(t,:)-I_CPU(k,d))<0 | (C_RAM-C_RAM_Usage(t,:)-I_RAM(k,d))<0 | (C_DISK-C_DISK_Usage(t,:)-I_DISK(k,d))<0);
Fitness(NonFeasibleNodes)=-1;
NumFeasible=length(find(Fitness>0));

[val,ind]=sort(Fitness,'descend');

if NumFeasible>0
    Selected_Cloud=ind(1);
    DataAllocate_CloudNode(k,d)=Selected_Cloud;
    C_CPU_Usage(t,Selected_Cloud)=C_CPU_Usage(t,Selected_Cloud)+I_CPU(k,d);
    C_RAM_Usage(t,Selected_Cloud)=C_RAM_Usage(t,Selected_Cloud)+I_RAM(k,d);
    C_DISK_Usage(t,Selected_Cloud)=C_DISK_Usage(t,Selected_Cloud)+I_DISK(k,d);
    C_POWER_Usage(t,Selected_Cloud)=C_POWER_Usage(t,Selected_Cloud)+I_Size(k,d)*C_POWER(Selected_Cloud);
    if t==1
        E_POWER_Usage(t)=E_POWER_Usage(t)+I_Size(k,d)*E_POWER;
    end
else
    Err_CloudResource(k,d)=1;
end
