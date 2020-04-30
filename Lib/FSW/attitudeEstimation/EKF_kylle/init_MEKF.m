
%%%%% THIS SCRIPT SETS UP PARAMETERS AND INITIAL CONDITIONS FOR the simulink estimator
                                     
estimation = struct;

%%%% Initial Conditions %%%%%
   
estimation.ic.Beta_init = 0.0*[1;1;1];%Initialize gyro Bias
estimation.ic.quat_est_init = [1;0;0;0]; 
% estimation.ic.quat_est_init = simParams.initialConditions.q0;

estimation.ic.w_init = [0.00;0.00;0.00];

% estimation.sampleTime_s = .001;


        P = [(0.1*pi/180)^2*eye(3) zeros(3,3);
        zeros(3,3),(0.2*pi/180/3600)*eye(3)];
        estimation.P_sq = chol(P,'lower'); %create square root form of cov matrix
estimation.ic.P_sq_init = estimation.P_sq; %initial value of cov matrix for simulink
 P_0_a = 3.0462e-6;  % attitude
P_0_b = 9.4018e-13; % bias
estimation.ic.P_init = blkdiag(P_0_a*eye(3),P_0_b*eye(3));

% Process and measurement covariances

sig_v = sqrt(10)*1e-7;     % angle random walk
sig_u = sqrt(10)*1e-10;    % rate random walk

sun_sensor_var = 0.5/(sqrt(2)*3.0); % sun sensor measurement covariance (radians)
mag_var =  10^-6*[0.403053;0.240996;0.173209]; % magnetometer covariance (micro tesla)


%%Time step that the MEKF is ran at
estimation.dt = fswParams.sample_time_s; 
dt = estimation.dt;

estimation.Q_k = [(sig_v^2*dt + 1/3*sig_u^2*dt^3)*eye(3)    -(1/2*sig_u^2*dt^2)*eye(3);
                   -(1/2*sig_u^2*dt^2)*eye(3)              (sig_u^2*dt)*eye(3)]; %create dynamic nnoise measurement matrix
%Constant MAtrices
%  [(sig_v^2*estimation.dt + 1/3*sig_u^2*estimation.dt^3)*eye(3), -(0.5*sig_u^2*estimation.dt^2)*eye(3);
%         -(0.5*sig_u^2*estimation.dt^2)*eye(3), (sig_u^2*estimation.dt)*eye(3)]; 
estimation.gamma = blkdiag(-eye(3),eye(3));
estimation.Q_sq = chol((estimation.gamma*estimation.Q_k*estimation.gamma'),'lower'); %square root dynamic noise matrix
estimation.Qg = estimation.gamma*estimation.Q_k*estimation.gamma';
R = [sun_sensor_var^2*eye(3),zeros(3,3);zeros(3,3),(norm(mag_var)).*eye(3)]; %create measurment error cov matrix
estimation.R_sq = chol(R,'lower');  % reate square root form of measurement cov matrix  

estimation.R = [sun_sensor_var^2*eye(3),zeros(3,3);zeros(3,3),((mag_var.^2)).*eye(3)]; %create measurment error cov matrix
fswParams.estimation = estimation;
clear estimation
clear sig_v sig_u sun_sensor_var mag_var zero R Beta P