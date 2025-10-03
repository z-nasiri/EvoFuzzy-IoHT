
Location_TD=100*ones(1,K);                  % Number of Days each IoT Devise is in the last position (100=initial value)

ResponseTime=zeros(K,D,T);        % Response Time for data d of IoT k at time t

ResponseDelay=zeros(K,D,T);       % Delay (Deviation from Deadline)
ResponseFailure=zeros(K,D,T);     % 1=Failure

ResponseSource_C=zeros(K,D,T);    % Response Source (Cloud Node) 
ResponseSource_F=zeros(K,D,T);    % Response Source (Fog Node)

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

DataAllocate_CloudNode=zeros(K,D);     % Cloud Data Center Num
DataAllocate_FogNodes=zeros(K,D,F);    % Binary Matrix (1= Existence of data)

Err_CloudResource=zeros(K,D);
Err_FogResource=zeros(K,D);
