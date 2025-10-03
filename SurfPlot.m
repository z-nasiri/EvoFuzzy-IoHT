clc
clear all
close all

x=[200 500 1000 1500 2000];
y=[5 7 10 15 20];

z1=[0.055	0.055	0.055	15.65	33.89
    0.027	0.022	0.027	9.40	21.7
    0.000	0.022	0.016	9.36	15.43
    0.000	0.022	0.006	9.35	15.21
    0.000	0.032	0.033	9.35	15.2];

z2=[0.363	0.372	1.15	2.81	3.24
    0.208	0.182	0.258	0.897	1.67
    0.224	0.258	0.269	0.316	0.64
    0.241	0.299	0.304	0.315	0.412
    0.202	0.177	0.279	0.279	0.249];

figure(1)
surf(x,y,z1)
ylabel('Number of Fog Domains')
xlabel('Number of IoHT Devices')
zlabel('Failure Rate (%)')

figure(2)
surf(x,y,z2)
ylabel('Number of Fog Domains')
xlabel('Number of IoHT Devices')
zlabel('Delay Rate (%)')
