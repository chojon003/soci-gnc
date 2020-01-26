%Author: Devan Tormey
%Title: Simulation Initialization 
%Description:

clear; clc; close all;

% ~~~~~~~~~~~~~~~~~~
% Add Paths
% ~~~~~~~~~~~~~~~~~~
addpath(genpath(pwd))
addpath(genpath('../Lib/'))
addpath(genpath('../Include/'))
addpath(genpath('../Test/'))

init_params;

% sim('Main_Sim.slx', 'StopTime', '10', 'debug', 'on')
% sldebug('Main_Sim.slx')