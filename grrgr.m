% ----------------------------------------------------------------------- %
% Loads the parameters of the estimation estimator using predefined fsw_params.
%   Any block added should be initialized and defined in here.

% UW HuskySat-1, ADCS Team
% Last Edited: T. Reynolds 8.8.17
% ----------------------------------------------------------------------- %

% Library sample time
estimation.sample_time_s = 1/10;

% Initial conditions

% estimation.ic.quat_est_init = [1 0 0 0]';

estimation.ic.quat_est_init = [0.533215448243828,0.592817248117098,0.0831095662269988,0.597780725760345]';
estimation.ic.rate_est_init = [0 0 0]';
estimation.ic.quat_est_init = [1 0 0 0]';
estimation.ic.quat_est_init = simParams.initialConditions.q0;
% estimation.ic.rate_est_init = [0 0 0]';
estimation.ic.bias_est_init = [0 0 0]';
% Initial covariance from Crassidis Ex. 7.1 pp. 460.
P_0_a = 3.0462e-6;  % attitude
P_0_b = 9.4018e-13; % bias
estimation.ic.error_cov = blkdiag(P_0_a*eye(3),P_0_b*eye(3));
    % rate transition blocks
    estimation.ic.rt_valid_gyro    = 0;
    estimation.ic.rt_valid_mag     = 0;
    estimation.ic.rt_valid_sun     = 0;
    estimation.ic.rt_mt_power_ok   = 0;
    estimation.ic.rt_sc_in_sun     = 0;
    estimation.ic.rt_w_body_radps  = zeros(3,1);
    estimation.ic.rt_mag_body      = zeros(3,1);
    estimation.ic.rt_mag_eci_est   = zeros(3,1);
    estimation.ic.rt_sun_body      = zeros(3,1);
    estimation.ic.rt_sun_eci_est   = zeros(3,1);
    estimation.ic.rt_meas_cov      = zeros(6);

% Upper bound on convergence time
estimation.converge_time_s   = 60;

% Constant matrices
estimation.G   = blkdiag(-eye(3),eye(3));
% This dt MUST be the rate at which information in the KF is updated!
estimation.dt  = estimation.sample_time_s;


% Process and measurement covariances
sig_v   = sqrt(10)*1e-7;            % angle random walk
sig_u   = sqrt(10)*1e-10;           % rate random walk
mag_err = 10^-6*[0.403053;0.240996;0.173209];
sun_err = 0.5/(sqrt(2)*3.0);



estimation.proc_cov = [(sig_v^2*dt + 1/3*sig_u^2*dt^3)*eye(3)    -(1/2*sig_u^2*dt^2)*eye(3);
                   -(1/2*sig_u^2*dt^2)*eye(3)              (sig_u^2*dt)*eye(3)];
% estimation.meas_cov = diag([(norm(mag_var)).*eye(3), sun_err*ones(1,3)]);
estimation.meas_cov =[(norm(mag_err)).*eye(3),zeros(3,3);zeros(3,3),sun_err^2*eye(3)];
fswParams.estimation = estimation;

clear estimation;
clear P_0_a P_0_b sig_v sig_u dt mag_err sun_err;   
