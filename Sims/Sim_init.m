% Rigid Body Control Using Dynamics Dependent Control
%Author: Devan Tormey
clear; clc; close all;
%The biggest change here is now we determine Kp and Kd based on some
%constraints we placed on the system as well as the face we know this to be
%a second order system
addpath(genpath(pwd))
addpath(genpath('../../Libraries/'))
addpath(genpath('../../Sim'))

J = [1000,0,0;
     0,500,0;
     0,0,700]
 
qt = rand(4,1);
q0 = qt/norm(qt);
w0 = rand(3,1)

qd =[ 1;
      0;
      0;
      0];

%choices for Kp and Kd depend on zeta and wn

z = 1; %Critically Damped
% z = .7 %Damped
% z = .1 %under damped



% wn is based on the assumption that our impulses are around this frequency
% A couple different choices for wn are dependant on what kinda stuff we
% think we need ot react to
wn = .017; %this corresponds to attenuating signals above 1 degree per second
wn = .017*2 %this corresponds to doubling ^^
% wn = .007 %assuming 60 degrees in 5 minutes

Kd = 2*z*wn*J
Kp = wn.^2*J



% 
% kd = 10
% kp = 1


sim('Attitude_Control.slx')