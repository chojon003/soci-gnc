% Initializes various FSW parameters that don't have
% a dedicated init file.
%
%
% Author: Cole Morgan


mode_select       = struct;
target_generation = struct;
command_gen       = struct;

mode_select.sc_mode_ic                    = int8(1.0);
mode_select.body_rate_threshold_max       = 9*pi/180;  %rad/s
mode_select.body_rate_threshold_min       = .5*pi/180; %rad/s
mode_select.RWA_RPM_threshold_max_inf     = 5000;    %RPM. limits max indv rpm
mode_select.RWA_RPM_threshold_min_inf     = 1100;    %RPM.
mode_select.RWA_RPM_threshold_max_2norm   = 2*3000;  %RPM. limits total power
mode_select.RWA_RPM_threshold_min_2norm   = 2*1100;  %RPM. 
mode_select.orbital_period_s              = 91*60.0; %seconds
mode_select.desat_timer_buffer_s          = 30;      %seconds

command_gen.spindown_torque_Nm            = 0.01*fswParams.actuators.rwa.max_torque_Nm;
        % Limits how quickly spindown happens. limits power consumption
        % and limits oscillations once at nominal rpm but not out of desat.
command_gen.spindown_tol                  = ...
    400*fswParams.constants.convert.RPM2RPS*fswParams.actuators.rwa.inertia(1); 
        % sets limit on max angular momentum error of wheels in body frame to begin
        % spindown. too high, wheel rpms wont be in null space. too low,
        % you might get stuck oscillating about the nullspace. 

% Define our orbit
% YMDHMS  = [ 2020; 1; 1; 0; 0; 0 ];
% INC     = 54.6146;  % inclination
% RAAN    = 247.4627; % right ascension of ascending node
% ECC     = 0006703; % keep this w/o decimals and 7 digits
% AOP     = 130.5360; % arg of perigee
% MNA     = 325.0288; % mean anomaly
% MNM     = 15.72125391; % mean motion
% 
% % Generate TLE (saved as text file in /adcs_sim/matlab/include/TLEs/
% tle = TLE_gen(YMDHMS, INC, RAAN, ECC, AOP, MNA, MNM);

[orbit_tle,~]               = get_tle(TLE);
 

fswParams.mode_select       = mode_select;
fswParams.target_generation = target_generation;
% fswParams.tle               = tle;
fswParams.tle               = orbit_tle;
fswParams.command_gen       = command_gen;

clear orbit_tle
clear mode_select
clear target_generation  
clear command_gen
clear YMDHMS INC RAAN ECC AOP MNA MNM tle