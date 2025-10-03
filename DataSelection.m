function model=DataSelection(model,NewN,NewM,NewK,NewT,P_Failure_Fogs)

MODEL_LOADING

N=NewN;
M=NewM;
K=NewK;
T=NewT;

a=find(Fog_Domains>M);
Fog_Domains(a)=[];
F=length(Fog_Domains);

F_Failure=F_Failure(1:T,1:F);
a=find(F_Failure<=P_Failure_Fogs);
b=find(F_Failure>P_Failure_Fogs);
F_Failure(a)=1;
F_Failure(b)=0;

Pk_FD=Pk_FD(1:K,1:T);
PrevM=max(Pk_FD(:));
Pk_FD=ceil(Pk_FD*M/PrevM);

Dkd=Dkd(1:K,:);

Rkdt=Rkdt(1:K,:,1:T);

C_CPU=C_CPU(1:N);
C_RAM=C_RAM(1:N);
C_DISK=C_DISK(1:N);
C_POWER=C_POWER(1:N);

F_CPU=F_CPU(1:F);
F_RAM=F_RAM(1:F);
F_DISK=F_DISK(1:F);
F_POWER=F_POWER(1:F);

I_Size=I_Size(1:K,1:D);
I_CPU=I_CPU(1:K,1:D);
I_RAM=I_RAM(1:K,1:D);
I_DISK=I_DISK(1:K,1:D);
I_Deadline=I_Deadline(1:K,1:D);

DC=DC(1:K,1:D);

L_EM=L_EM(1:M);
L_MM=L_MM(1:M,1:M);
L_MF=L_MF(1:F);
L_MS=L_MS(1:M);
L_SC=L_SC(1:N);

MODEL_SAVING

end
