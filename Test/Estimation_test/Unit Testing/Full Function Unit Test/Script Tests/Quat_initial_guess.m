
%Author: Kylle Ashton 3/08/2020
%Title: Quaternion Initial Guess
%Description: Using my_sim.slx, this code plots the initial error of a
%quaternion for the EKF vs the true value and returns the settling times of
%each initial guess
close all


warning('off','all')
warning
clearvars -except fswParams simParams TLE
set_param('my_sim','FastRestart','on')
% Define Parameters
tfinal = 180;

dt = fswParams.sample_time_s;
t = 0:dt:tfinal;
L = length(t);
converge_time = tfinal;


% Number of iterations
num_err = 10; %number of starting error values to try

% simParams.initialConditions.q0 = [1 0 0 0]';
% q0_sim = mat2str(simParams.initialConditions.q0);
% set_param( 'UnitTestDebug/quat_propagation/Discrete-Time Integrator', ...
%     'InitialCondition', q0_sim)
% r_sun_inertial = [1;0;0];
% r_sun = mat2str(r_sun_inertial);
% set_param( 'UnitTestDebug/r_sun_inertial','Value', '[1;0;0]')
% set_param( 'UnitTestDebug/sun_valid','Value', '1')

% Allocate Space for Loop-built matrices
Mag_err = zeros(1,L);      q0_error = zeros(1,L);    
q0_minus_error = zeros(num_err,L);       Settling_time = zeros(1,num_err); 
quat_init = zeros(4,num_err);       start_error_angle = zeros(1,num_err);   
settling_time = zeros(1,num_err);     sett_time = zeros(1,num_err);


rng(0,'twister')
a = 0;
b = 1;

for k = 1:num_err
    
u = (b-a).*rand(1,1) + a;
v = (b-a).*rand(1,1) + a;
w = (b-a).*rand(1,1) + a;
% z = (b-a).*rand(1,1) + a;

    quat_init(:,k) = [sqrt(1-u)*sin(2*pi*v);
        sqrt(1-u)*cos(2*pi*v);
       sqrt(u)*sin(2*pi*w);
       sqrt(u)*cos(2*pi*w) ] ;

% norm_q(:,k) = norm(quat(:,k));
end


q_guess_vec = [0.5 0.5 0.5 0.5]';
q_guess = mat2str(q_guess_vec);
for k = 1:num_err
     quat_init(1,k) = randn/10 + q_guess_vec(1); 
     quat_init(2,k) = randn/10 + q_guess_vec(2); 
     quat_init(3,k) = randn/10 + q_guess_vec(3); 
     quat_init(4,k) = randn/10 + q_guess_vec(4); 
     quat_init (:,k)  = quat_init(:,k)./norm(quat_init(:,k),2);
end


%set up avg omega vectors (these range from 0.5 deg/s to 15.5 deg/s (9 deg/s in each axis) in magnitude
g = (0:3:9)*pi/180;
g(1) = 0.29*pi/180;
num_omega = length(g); %number of omega Vectors to try
omega = zeros(3,num_omega);  norm_omega = zeros(1,num_omega);
num_omega = 1;
 for f = 1:3
for p = 1:num_omega
    omega(f,p) = (randn/2000+g(p))*(-1)^randi(2);
  norm_omega(1,p) = round(norm(omega(:,p),2)*180/pi,2);%get into deg/s
end
 end

 
% mag_deg = 0.5; %here is desired angular velo magnitude
% mag = mag_deg*pi/180;
% for k = 1:num_omega
%     
% [x,~] = randfixedsum(3,1,mag^2,0,10);
% omega(1,k) = sqrt(x(1))*(-1)^randi(2);
% omega(2,k) = sqrt(x(2))*(-1)^randi(2);
% omega(3,k) = sqrt(x(3))*(-1)^randi(2);
% norm_omega(1,k) = round(norm(omega(:,k),2)*180/pi,2);%get into deg/s
% omega = 0*omega;
% end
%  
 
 
 

%run simulation loop for start error angles and angular velocities
for w = 1:1%num_omega
    for k = 1:num_err
        
        s = mat2str(quat_init(:,k));
        w1 = mat2str(omega(:,w)); 
%        w1 = mat2str(simParams.initialConditions.w0);
        set_param( 'my_sim/MEKF_lib/Unit Delay2', 'InitialCondition', q_guess) %these vary the initial quaternion each iteration
        set_param( 'my_sim/satelliteDynamics_lib/quat_propagation/Integrator', ...
            'InitialCondition', s)
        set_param( 'my_sim/satelliteDynamics_lib/RigidBodyDynamics/wint', 'InitialCondition', w1)
        
        % run the sim
        simOut = sim('my_sim'); 
       
        %get out data from sim
         qtrue = simOut.q_true.Data'; 
         qest = simOut.my_qest.Data';
%          q0_err = simOut.q0_error.Data';

         att_error = (simOut.qerr.Data');% these are the attitude angle errors that correspond to the 3 sigma bounds errors
         start_error_angle(1,k) = 180/pi*2*acos(simOut.q_initial_error.Data(1,1));
         qerr = simOut.q_initial_error.Data';
         if start_error_angle(1,k) >180
             start_error_angle(1,k) = 360 - start_error_angle(1,k);
         end
        
        for m = 1:L
            theta(k,m) = 2*acosd(att_error(1,m));
            if theta(k,m) >180
                theta(k,m) = 360-theta(k,m);
            end
        end

%         Get Settling Times
         sett_time(1,k) = set_time(theta(k,:),converge_time,dt,t);
         
          %pick out flagged settling times where estimate did not converge
          %under the nominal convergence time, for plotting purposes
            maximum = max(sett_time,[],1);
            [row_not_converged,col_not_converged] = find(sett_time == -1);
            [row_converged,col_converged] = find(sett_time ~= -1);
            settling_time(1,col_not_converged) = -1;
            settling_time(1,col_converged) = maximum(col_converged);
        
    end

    
    %Below this line is just plotting, plot options/configurations
    flag = -0.1;
    above_conv_time = (settling_time<flag);
    converged = settling_time;
    not_converged = settling_time;
    converged(above_conv_time) = NaN;
    not_converged(~above_conv_time) = NaN;
    
    Purple = [51;0;111]/norm([51;0;111]);
    Gold = [145 123 76]'/norm([145 123 76]');
    
    figure
    hold on
    h1 = plot(start_error_angle,converged,'o','color',Purple);
    h4 = plot(start_error_angle,not_converged,'rx','MarkerSize',10);
    h = [h1;h4];
    hleg1 = legend(h,['Estimate Converged in <',num2str(converge_time),'s'],...
        ['Estimate Not Converged in <',num2str(converge_time),'s']); % need to plot xs for the other quat values
    set(h1, 'markerfacecolor', get(h1, 'color'))
    set(hleg1,'Location','best')
    xlim([0,max(start_error_angle) + 5])
%     ylim([-2,inf])
    grid on
    ax = gca;
    ax.GridColor = Gold;
    ax.GridAlpha = 1;
    xlabel('Starting \theta error (deg)')
    ylabel('Settling Time to Within 3.5 deg Error')
    title(['Initial Quaternion Error and Convergence Time,||\omega|| = '...
        ,mat2str(norm_omega(:,w)), 'deg/s'])
    
end
tout = simOut.tout;
figure;
for i = 1:4
grid on;
subplot(2,2,i)
title('Quaternion Estimates')
hold on
plot(tout,qtrue(i,:),'k','Linewidth',1.25)
plot(tout,qest(i,:),'m--','Linewidth',1.25)
legend(['q_',num2str(i),  'true'],[ 'q_',num2str(i),  'est'])
grid on;
xlabel('Time (s)')
ylabel('Quat Value (rad)')
hold off
end