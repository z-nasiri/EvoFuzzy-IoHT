function [Cost,Penalty]=CostFunction_GSA(model,SOL)

MODEL_LOADING

t=1;

C_CPU_Usage=zeros(T,N);
C_RAM_Usage=zeros(T,N);
C_DISK_Usage=zeros(T,N);
C_POWER_Usage=zeros(T,N);

F_CPU_Usage=zeros(T,F);
F_RAM_Usage=zeros(T,F);
F_DISK_Usage=zeros(T,F);
F_POWER_Usage=zeros(T,F);

E_POWER_Usage=zeros(T,1);

DataAllocate_Layer=zeros(K,D);         % 1=Cloud Layer   2=Fog Layer


PLC=reshape(ceil(SOL),K,D);

a=find(PLC>F);
b=find(PLC<=F);
DataAllocate_Layer(a)=1;
DataAllocate_Layer(b)=2;

DataAllocate_CloudNode=zeros(K,D);
DataAllocate_FogNodes2=zeros(K,D);

DataAllocate_CloudNode(a)=PLC(a)-F;

DataAllocate_FogNodes2(b)=PLC(b);

ResponseTime=zeros(K,D);

for k=1:K
    m=Pk_FD(k,t);
    for d=1:D
       if DataAllocate_Layer(k,d)==1
           Selected_Cloud=DataAllocate_CloudNode(k,d);
           C_CPU_Usage(t,Selected_Cloud)=C_CPU_Usage(t,Selected_Cloud)+I_CPU(k,d);
           C_RAM_Usage(t,Selected_Cloud)=C_RAM_Usage(t,Selected_Cloud)+I_RAM(k,d);
           C_DISK_Usage(t,Selected_Cloud)=C_DISK_Usage(t,Selected_Cloud)+I_DISK(k,d);
           C_POWER_Usage(t,Selected_Cloud)=C_POWER_Usage(t,Selected_Cloud)+I_Size(k,d)*C_POWER(Selected_Cloud);
           E_POWER_Usage(t)=E_POWER_Usage(t)+I_Size(k,d)*E_POWER;
           ResponseTime(k,d)=L_IE+L_EM(m)+L_MS(m)+L_SC(Selected_Cloud)+I_Size(k,d)/C_CPU(Selected_Cloud);
       else
            Selected_Fogs=DataAllocate_FogNodes2(k,d);
            F_CPU_Usage(t,Selected_Fogs)=F_CPU_Usage(t,Selected_Fogs)+I_CPU(k,d);
            F_RAM_Usage(t,Selected_Fogs)=F_RAM_Usage(t,Selected_Fogs)+I_RAM(k,d);
            F_DISK_Usage(t,Selected_Fogs)=F_DISK_Usage(t,Selected_Fogs)+I_DISK(k,d);
            F_POWER_Usage(t,Selected_Fogs)=F_POWER_Usage(t,Selected_Fogs)+I_Size(k,d)*F_POWER(Selected_Fogs);
            E_POWER_Usage(t)=E_POWER_Usage(t)+I_Size(k,d)*E_POWER;
            ResponseTime(k,d)=L_IE+L_EM(m)+L_MM(m,Fog_Domains(Selected_Fogs))+L_MF(Selected_Fogs)+I_Size(k,d)/F_CPU(Selected_Fogs);
       end
    end
end

Err_C_CPU=length(find(C_CPU_Usage(1,:)>C_CPU));
Err_C_RAM=length(find(C_RAM_Usage(1,:)>C_RAM));
Err_C_DISK=length(find(C_DISK_Usage(1,:)>C_DISK));

Err_F_CPU=length(find(F_CPU_Usage(1,:)>F_CPU));
Err_F_RAM=length(find(F_RAM_Usage(1,:)>F_RAM));
Err_F_DISK=length(find(F_DISK_Usage(1,:)>F_DISK));

Penalty=Err_C_CPU+Err_C_RAM+Err_C_DISK+Err_F_CPU+Err_F_RAM+Err_F_DISK;

ReqLC=find(Rkdt(:,:,t)==1 & DC==1);
ReqMC=find(Rkdt(:,:,t)==1 & DC==2);
ReqHC=find(Rkdt(:,:,t)==1 & DC==3);

MRT=0.2*mean(ResponseTime(ReqLC))+0.3*mean(ResponseTime(ReqMC))+0.5*mean(ResponseTime(ReqHC));


POW=sum(C_POWER_Usage(:))+sum(F_POWER_Usage(:))+sum(E_POWER_Usage(:));

CST=mean(C_CPU_Usage(1,:))*mean(F_CPU_Usage(1,:));

ObjFun=MRT*POW*CST;   

Cost=ObjFun*2^Penalty;

end