
if Algorithm<=3

for k=1:K
    
    for d=1:D
        
        % Select the Layer
        if Dkd(k,d)==1
            if Algorithm<=2
                if DC(k,d)==1
                    Layer=1;    % Cloud Layer (LC)
                else
                    Layer=2;    % Fog Layer (MC and HC)
                end
            else
                if DC(k,d)==1
                    Layer=1;    % Cloud Layer (LC)
                elseif DC(k,d)==2
                    Layer=randi(2);    % Fog or Cloud Layer (MC)
                else
                    Layer=2;    % Fog Layer (HC)
                end
            end
            
            % Data Offloading to Cloud Layer
            if Layer==2
                Domain=Pk_FD(k,1);
                Fogs=find(Fog_Domains==Domain);

                Feasiblity_Fog=zeros(3,length(Fogs));
                Feasiblity_Fog(1,:)=(F_CPU(Fogs)-F_CPU_Usage(1,Fogs))-I_CPU(k,d);
                Feasiblity_Fog(2,:)=(F_RAM(Fogs)-F_RAM_Usage(1,Fogs))-I_RAM(k,d);
                Feasiblity_Fog(3,:)=(F_DISK(Fogs)-F_DISK_Usage(1,Fogs))-I_DISK(k,d);

                if max(min(Feasiblity_Fog))<0
                    Layer=1;
                end
            end

            DataAllocate_Layer(k,d)=Layer;

            % Select the Best (Fog | Cloud) Node
            if DataAllocate_Layer(k,d)==1
                if Algorithm==1 | Algorithm==2
                    FuzzyHeuristicAllocation_Cloud
                end            
                if Algorithm==3
                    HPSG_Cloud
                end
            end
            
            if DataAllocate_Layer(k,d)==2
                if DC(k,d)==2
                    BN=BN_MC;
                else
                    BN=BN_HC;
                end
                if Algorithm==1 | Algorithm==2
                    FuzzyHeuristicAllocation_Fog
                end            
                if Algorithm==3
                    HPSG_Fog
                end
            end        

        end
    end    
end

else
    
   if Algorithm==4
       WOA
   end
   
   if Algorithm==5
       GSA    
   end
   
end