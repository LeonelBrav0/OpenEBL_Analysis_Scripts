clear all;
close all;
clc;
figN = 0;

% Fetch Chip1 and Chip2 data
fetch_data;

% Fetch Simulation data
load_simulation;

analyze_chip1;

%analyze_chip2;