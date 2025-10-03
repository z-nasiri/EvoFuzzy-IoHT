clc
clear all
close all

N=20;               % Maximum Number of Cloud Data Centers
M=20;               % Maximum Number of Fog Domains
Fm=[10 15];         % Number of Fog Nodes Within Each Fog Domain
K=3000;           	% Maximum Number of IoHT Devices
D=10;               % Number of Data File Types
T=360;              % Maximum Number of Time Priods (Days)

P_Trip_P=0.01;      % Probability of Each IoHT for a Permanent Trip
P_Trip_M=0.03;      % Probability of Each IoHT for a Momentary Trip
T_Trip=[1 10];      % Time Duration of a Permanent Trip

Data_Request_Frequency=30;   % Each 30 Day one Data File
Data_Update_Frequency=30;   % Each 30 Day one Data File

%%%%%%%%%%%%%%%%%%%%% Position of Nodes

Fog_Domains=[];
for m=1:M
    NumFogNodes_m=randi(Fm);   % Number of Fog Nodes Within Fog Domain m
    Fog_Domains=[Fog_Domains m*ones(1,NumFogNodes_m)];
end
F=length(Fog_Domains);     % Number of Fog Nodes

F_Failure=rand(T,F);

Pk_FD_1=randi([1,M],1,K)';   % Initial Position of IoHT Devices (# The Fog Domain).

Pk_FD=zeros(K,T);
Pk_FD(:,1)=Pk_FD_1;
for k=1:K
    t=1;
    while t<T
        t=t+1;
        if rand<P_Trip_P
            Pk_FD(k,t)=randi(M);
        elseif rand<P_Trip_M
            Trip_Duration=randi(T_Trip);
            T_End=min(t+Trip_Duration-1,T-1);
            Current_FD=Pk_FD(k,t-1);
            Pk_FD(k,t:T_End)=randi(M);
            Pk_FD(k,T_End+1)=Current_FD;
            t=T_End+1;
        else
            Pk_FD(k,t)=Pk_FD(k,t-1);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%

Dkd=randi([0,1],K,D);    % Existence of Data File d in IoHT k (0:No 1:Yes)
NonData=find(sum(Dkd')==0);
for k=1:NonData'
    Dkd(k,randi(D))=1;
end

a=rand(K,D,T).*repmat(Dkd,1,1,T);
b=find(a>1-(1/Data_Request_Frequency));
Rkdt=zeros(K,D,T);
Rkdt(b)=1;    % Request for Data for Data File d in IoHT k at time t

a=rand(K,D,T).*repmat(Dkd,1,1,T);
b=find(a>1-(1/Data_Update_Frequency));
Ukdt=zeros(K,D,T);
Ukdt(b)=1;    % Request for Data for Data File d in IoHT k at time t

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Server Details

%%% Cloud Data Centers (Ref: https://doi.org/10.1016/j.comnet.2021.108560)

CPU=[80 100 120 150];   % MIPS
RAM=[64 96 128 192 256];           % GB
DISK=[64 128 192 256];     % TB

C_CPU=CPU(randi(length(CPU),[1,N]));
C_RAM=RAM(randi(length(RAM),[1,N]));
C_DISK=DISK(randi(length(DISK),[1,N]));
C_POWER=C_CPU/1000;        % Watt/cycle

%%% Fog Servers

CPU=[30 40 50];         % MIPS
RAM=[32 64 128];            % GB
DISK=[16 24 32 40];         % TB

F_CPU=CPU(randi(length(CPU),[1,F]));
F_RAM=RAM(randi(length(RAM),[1,F]));
F_DISK=DISK(randi(length(DISK),[1,F]));
F_POWER=F_CPU/1000;        % Watt/cycle

%%% Edge Servers

E_POWER=5e-3;              % Watt/cycle

%%% IoT Devices

Size=[3 5 8 10 15];            % MI
CPU=[0.1 0.2 0.3];       % MIPS
RAM=[0.1 0.2 0.3];                   % GB
DISK=[0.05 0.1 0.2 0.3];            % TB (GB/1000)
Deadline=[5 10 15 20 30 60]; % s

I_Size=CPU(randi(length(CPU),[K,D])).*Dkd;
I_CPU=CPU(randi(length(CPU),[K,D])).*Dkd;
I_RAM=RAM(randi(length(RAM),[K,D])).*Dkd;
I_DISK=DISK(randi(length(DISK),[K,D])).*Dkd;
I_Deadline=Deadline(randi(length(Deadline),[K,D])).*Dkd;

DC=zeros(K,D);    % Data Criticality:  1)LC  2)MC  3)HC
a=find(I_Deadline>0 & I_Deadline<=10);
b=find(I_Deadline>10 & I_Deadline<=20);
c=find(I_Deadline>20);
DC(a)=3;
DC(b)=2;
DC(c)=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Link Details

%%% IoT Devices - Edge Nodes

L_IE=0.5;                   % s

%%% Edge Node - Fog Master

Latency=[1 1.2 1.3 1.5];    % s

L_EM=Latency(randi(length(Latency),[1,M]));

%%% Fog Master - Fog Master

Latency=[2 2.2 2.5 3];      % s

L_MM=Latency(randi(length(Latency),[M,M]));
for m=1:M
    L_MM(m,m)=0;
    for mm=m+1:M
        L_MM(m,mm)=L_MM(mm,m);
    end
end

%%% Fog Master - Fog Node

Latency=[0.8 1 1.2 1.5];    % s

L_MF=Latency(randi(length(Latency),[1,F]));

%%% Fog Master - Cloud Switch

Latency=[8 9 10];    % s

L_MS=Latency(randi(length(Latency),[1,M]));

%%% Cloud Switch - Cloud Data Center

Latency=[4 5 6 7];    % s

L_SC=Latency(randi(length(Latency),[1,N]));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MODEL_SAVING

DataName='DataFolder/FullData.mat';
save(DataName,'model')
