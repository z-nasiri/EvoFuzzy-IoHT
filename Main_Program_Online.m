clc
clear all
close all
warning off

Algorithm=2        % 1)HCFH   2)E-HCFH   3)H-PSG[18]   4)WOA-FSP[44]   5)FSP-GSA[29]

N=5;                    % Number of Cloud Data Centers: Max: 20
M=10;                   % Number of Fog Domains; Max: 20
K=500;                  % Number of IoHT Devices: Max: 3000
T=100;                  % Number of Time Priods (Days): Max: 360
P_Failure_Fogs=0.02;    % Probability of Failure for each Fog Node

%%% Load Data

DataName='DataFolder/FullData.mat';
load(DataName)

%%% Revise Data

model=DataSelection(model,N,M,K,T,P_Failure_Fogs);

%%% Hyperparameters

if Algorithm==1
    BN_HC=5;
    BN_MC=5;
    TH1_HC=15;
    TH2_HC=15;
    TH1_MC=15;
    TH2_MC=15;
    W_C=ones(1,5);
    W_F=ones(1,5);
    A_C=ones(1,5);
    A_F=ones(1,5);
    NumInputMFsF=3;
    NumOutputMFsF=7;
    NumInputMFsC=3;
    NumOutputMFsC=7;
end

if Algorithm==2
%     DataName=['DataFolder/MetaFIS_' num2str(N) '_' num2str(M) '_' num2str(K) '_' num2str(T) '_' '.mat'];
    DataName=['DataFolder/MetaFIS_5_10_500_100_.mat'];
    load(DataName)
end

if Algorithm>=3
    BN_HC=1;
    BN_MC=1;
    TH1_HC=1000;
    TH2_HC=1000;
    TH1_MC=1000;
    TH2_MC=1000;
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Main Program

MODEL_LOADING

NetworkInitialization

tic

t=1;

Data_Uploading

for t=2:T
    
    C_CPU_Usage(t,:)=C_CPU_Usage(t-1,:);
    C_RAM_Usage(t,:)=C_RAM_Usage(t-1,:);
    C_DISK_Usage(t,:)=C_DISK_Usage(t-1,:);
    C_POWER_Usage(t,:)=C_POWER_Usage(t-1,:);

    F_CPU_Usage(t,:)=F_CPU_Usage(t-1,:);
    F_RAM_Usage(t,:)=F_RAM_Usage(t-1,:);
    F_DISK_Usage(t,:)=F_DISK_Usage(t-1,:);
    F_POWER_Usage(t,:)=F_POWER_Usage(t-1,:);
            
    E_POWER_Usage(t)=0;
    
    for k=1:K
        
        % Check the trips 
        if Pk_FD(k,t)~=Pk_FD(k,t-1)
            Location_TD(k)=1;
        else
            Location_TD(k)=Location_TD(k)+1;
        end
        
        for d=1:D
            
            % Data Replication / Removing
            if DataAllocate_Layer(k,d)==2
                if DC(k,d)==2
                    BN=BN_MC;
                    TH1=TH1_MC;
                    TH2=TH2_MC;
                else
                    BN=BN_HC;
                    TH1=TH1_HC;
                    TH2=TH2_HC;
                end

                % Data Replication to Destination
                if Location_TD(k)==TH1
                    if Algorithm==1 | Algorithm==2
                        FuzzyHeuristicAllocation_Fog
                    end
                    if Algorithm==3
                        HPSG_Fog
                    end
                end

                % Data Removing from Source
                if Location_TD(k)==TH2                    
                    cm=Pk_FD(k,t);
                    fg=find(Fog_Domains==cm);
                    fgnot=find(Fog_Domains~=cm);                    
                    if length(find(DataAllocate_FogNodes(k,d,fg)==1))>0                    
                        Selected_Fogs=fgnot(find(DataAllocate_FogNodes(k,d,fgnot)==1));
                        if length(Selected_Fogs)>0
                            DataAllocate_FogNodes(k,d,Selected_Fogs)=0;
                            F_CPU_Usage(t,Selected_Fogs)=F_CPU_Usage(t,Selected_Fogs)-I_CPU(k,d);
                            F_RAM_Usage(t,Selected_Fogs)=F_RAM_Usage(t,Selected_Fogs)-I_RAM(k,d);
                            F_DISK_Usage(t,Selected_Fogs)=F_DISK_Usage(t,Selected_Fogs)-I_DISK(k,d);
                        end
                    end
                end
            end
            
            % Check the data Download requests (if any)        
            if Rkdt(k,d,t)==1

                m=Pk_FD(k,t);

                if DataAllocate_Layer(k,d)==1 
                    if Err_CloudResource(k,d)==0
                        SelC=DataAllocate_CloudNode(k,d);
                        ResponseSource_C(k,d,t)=SelC;
                        ResponseTime(k,d,t)=L_IE+L_EM(m)+L_MS(m)+L_SC(SelC)+I_Size(k,d)/C_CPU(SelC);
                        C_POWER_Usage(t,SelC)=C_POWER_Usage(t,SelC)+I_Size(k,d)*C_POWER(SelC);
                        E_POWER_Usage(t)=E_POWER_Usage(t)+I_Size(k,d)*E_POWER;
                    else
                        ResponseFailure(k,d,t)=1;                        
                    end
                else
                    Fogs=find(DataAllocate_FogNodes(k,d,:)==1);
                    LAT=L_MM(m,Fog_Domains(Fogs))+L_MF(Fogs)+100*F_Failure(t,Fogs);
                    if min(LAT)<100
                        SelF=Fogs(find(LAT==min(LAT),1,'first'));
                        ResponseSource_F(k,d,t)=SelF;
                        ResponseTime(k,d,t)=L_IE+L_EM(m)+L_MM(m,Fog_Domains(SelF))+L_MF(SelF)+I_Size(k,d)/F_CPU(SelF);
                        F_POWER_Usage(t,SelF)=F_POWER_Usage(t,SelF)+I_Size(k,d)*F_POWER(SelF);
                        E_POWER_Usage(t)=E_POWER_Usage(t)+I_Size(k,d)*E_POWER;
                    else
                        ResponseFailure(k,d,t)=1;
                    end
                end

            end

            % Check the data Update requests (if any)        
            if Ukdt(k,d,t)==1

                m=Pk_FD(k,t);

                if DataAllocate_Layer(k,d)==1 
                    if Err_CloudResource(k,d)==0
                        SelC=DataAllocate_CloudNode(k,d);
                        C_POWER_Usage(t,SelC)=C_POWER_Usage(t,SelC)+I_Size(k,d)*C_POWER(SelC);
                        E_POWER_Usage(t)=E_POWER_Usage(t)+I_Size(k,d)*E_POWER;
                    end
                else
                    Fogs=find(DataAllocate_FogNodes(k,d,:)==1);
                    F_POWER_Usage(t,Fogs)=F_POWER_Usage(t,Fogs)+I_Size(k,d)*F_POWER(Fogs);
                    E_POWER_Usage(t)=E_POWER_Usage(t)+I_Size(k,d)*E_POWER;
                end

            end
            
        end
    end

    ResponseDelay(:,:,t)=max(0,ResponseTime(:,:,t)-I_Deadline);

    Req=find(Rkdt(:,:,t)==1);
    RT=ResponseTime(:,:,t);
    RT=RT(Req);
    RT=RT(find(RT>0));
    
    FL=ResponseFailure(:,:,t);
    FL=FL(Req);
    
    disp(['Time = ' num2str(t) ',  MRT = ' num2str(round(10*mean(RT(:)))/10) ',  NumRequest = ' num2str(length(Req)) ',  NumFailure = ' num2str(length(find(FL==1))) ',  NumDelays = ' num2str(length(find(ResponseDelay(:,:,t)>0)))])
    
end

if Algorithm<4
    ResponseTimePeriod=toc/T
else
    ResponseTimePeriod=ResponseTime_Eachperiod
end

DCT=repmat(DC,1,1,T);

Req=find(Rkdt==1);
ReqLC=find(Rkdt==1 & DCT==1);
ReqMC=find(Rkdt==1 & DCT==2);
ReqHC=find(Rkdt==1 & DCT==3);

NumErr_CloudResource=sum(Err_CloudResource(:))
NumErr_FogResource=sum(Err_FogResource(:))

MRT_LC=ceil(100*mean(ResponseTime(ReqLC)))/100
MRT_MC=ceil(100*mean(ResponseTime(ReqMC)))/100
MRT_HC=ceil(100*mean(ResponseTime(ReqHC)))/100
MRT=0.2*mean(ResponseTime(ReqLC))+0.3*mean(ResponseTime(ReqMC))+0.5*mean(ResponseTime(ReqHC));
MRT=ceil(100*MRT)/100

NumRF=length(find(ResponseFailure(Req)==1))
FailureRate=100*NumRF/sum(Rkdt(:))

NumRD=length(find(ResponseDelay>0))
if NumRD>0
    MRD=mean(ResponseDelay(find(ResponseDelay>0)));
    MRD=ceil(100*MRD)/100
else
    MRD=0
end
DelayRate=100*NumRD*MRD/sum(Rkdt(:))

TP=sum(C_POWER_Usage(:))+sum(F_POWER_Usage(:))+sum(E_POWER_Usage)

MeanCPU_Usage_C=mean(C_CPU_Usage)./C_CPU;
MeanRAM_Usage_C=mean(C_RAM_Usage)./C_RAM;
MeanDISK_Usage_C=mean(C_DISK_Usage)./C_DISK;

LB_C=(std(MeanCPU_Usage_C)+std(MeanRAM_Usage_C)+std(MeanDISK_Usage_C))/3

MeanCPU_Usage_F=mean(F_CPU_Usage)./F_CPU;
MeanRAM_Usage_F=mean(F_RAM_Usage)./F_RAM;
MeanDISK_Usage_F=mean(F_DISK_Usage)./F_DISK;

LB_F=(std(MeanCPU_Usage_F)+std(MeanRAM_Usage_F)+std(MeanDISK_Usage_F))/3

ObjFun=0.5*MRT/10+0.2*LB_C+0.2*LB_F+0.1*TP/(2*T*K)

figure
bar(100*MeanCPU_Usage_C)
xlabel('Cloud Data Centers')
ylabel('CPU Usage (%)')
figure
bar(100*MeanRAM_Usage_C)
xlabel('Cloud Data Centers')
ylabel('RAM Usage (%)')
figure
bar(100*MeanDISK_Usage_C)
xlabel('Cloud Data Centers')
ylabel('DISK Usage (%)')

figure
bar(100*MeanCPU_Usage_F)
xlabel('Fog Nodes')
ylabel('CPU Usage (%)')
figure
bar(100*MeanRAM_Usage_F)
xlabel('Fog Nodes')
ylabel('RAM Usage (%)')
figure
bar(100*MeanDISK_Usage_F)
xlabel('Fog Nodes')
ylabel('DISK Usage (%)')

FailureRate=FailureRate
DelayRate=DelayRate
MRT=MRT