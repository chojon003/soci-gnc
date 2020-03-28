clc
close all
clearvars -except fswParams simParams TLE
warning('off','all')
warning
tfinal = 100;
dt = fswParams.sample_time_s;
t = 0:dt:tfinal;
num_err = 20;
x = linspace(0,pi/2,num_err);
L = length(t);
Mag_err = zeros(1,L);
q0_error = zeros(1,L);

Settling_time = zeros(1,num_err);
quat_init = zeros(4,num_err);
q0 = sin(x);
q1 = cos(x);
for j = 1:num_err
    quat_init(1,j) = q0(j); 
    quat_init(2,j) = q1(j);
    norm(quat_init(:,j),2);
end
omega = [[-0.003;0.02;0.01],[-0.05;0.1;0.1],[-0.07;0.12;0.5]];
start_error_angle = zeros(1,num_err); settling_time = zeros(1,num_err);
converge_time = 50;
tic
t = 0:fswParams.sample_time_s:tfinal;
num_omega = 1;
for w = 1:num_omega
for k = 1:num_err

s = mat2str([quat_init(:,k)]);
w1 = mat2str([omega(:,w)]);


set_param( 'UnitTestDebug/MEKF_lib/Unit Delay2', 'InitialCondition', s)
set_param( 'UnitTestDebug/Omega', 'Value',w1)
simParams.initialConditions.q0 = [1 0 0 0]';

simOut = sim('UnitTestDebug');

qtrue = simOut.my_qtrue.Data';
qest = simOut.my_qest.Data';
q_init_est = simOut.my_qest_init.Data';
q0_err = simOut.q0_error.Data';
alpha_error = (simOut.qerr_deg.Data')*2*180/pi;
% q1e = q_error(2,:); % these are the alpha angle errors that correspond to 3 sigma bounds errors
% q2e = q_error(3,:);
% q3e = q_error(4,:);


        %Get Settling Times
        for c = 2:4
        sett_time(c-1,k) = set_time(alpha_error(c,:),converge_time,dt,t);
        end
        maximum = max(sett_time,[],1);
        [row_not_converged,col_not_converged] = find(sett_time == -1);
        [row_converged,col_converged] = find(sett_time ~= -1);
        settling_time(1,col_not_converged) = -1;
        settling_time(1,col_converged) = maximum(col_converged);
for i = 1:L
% Mag_err(:,i) = (quat_err(qtrue(:,i)',qest(:,i)'))*180/pi;
q0_error(k,i) = norm(2*acos(qtrue(1,i)) - 2*acos(qest(1,i)),2)*180/pi;
q0_minus_error(k,i) = norm(2*acos(qtrue(1,i)) - 2*acos(q_init_est(1,i)),2)*180/pi;
start_error_angle(:,k) = q0_minus_error(k,1); 
end
end
toc

figure
flag = -0.1;
above_conv_time = (settling_time<flag);
converged = settling_time;
not_converged = settling_time;
converged(above_conv_time) = NaN;
not_converged(~above_conv_time) = NaN;

% C = {'[0.4940, 0.1840, 0.5560]','[0.3010 0.7450 0.9330]','m'};
C = [51;0;111]/norm([51;0;111]);
S = 'o';

hold on
h1 = plot(start_error_angle,converged,S,'color',C);
% h2 = plot(start_error_angle,settling_time(2,:),S{2},'color',C{2});
% h3 = plot(start_error_angle,settling_time(3,:),S{3},'color',C{3});
%  legendInfo{v}=['q_',num2str(v)]; % or whatever is appropriate
h4 = plot(start_error_angle,not_converged,'rx','MarkerSize',20);
% h = [h1;h2;h3;h4];
h = [h1;h4];
     legend(h,'Error of Vector Part of q','Initial \theta Error Not Converged',...
         'Location','northwest') % need to plot xs for the other quat values
set(h1, 'markerfacecolor', get(h1, 'color'))
% set(h2, 'markerfacecolor', get(h2, 'color'))
% set(h3, 'markerfacecolor', get(h3, 'color'))
xlim([0,max(start_error_angle) + 5])
ylim([-2,inf])
grid on
xlabel('Starting \theta error (deg)')
ylabel('Settling Time to Within 3.5 deg Error')
title(['Initial Quaternion Error and Convergence Time,||\omega|| = '...
    ,mat2str(norm(omega(:,w)))])
end

tout = simOut.tout;
figure; 

grid on;
subplot(2,2,1)
title('constant \omega = [-0.1;0.2;0.12]')
hold on
plot(tout,simOut.my_qtrue.Data(:,1),'k','Linewidth',1.5)
plot(tout,simOut.my_qest.Data(:,1),'m--','Linewidth',1.5)
legend('q1 true', 'q1 est')
grid on;
hold off

subplot(2,2,2)
hold on
plot(tout,simOut.my_qtrue.Data(:,2),'k','Linewidth',1.5)
plot(tout,simOut.my_qest.Data(:,2),'m--','Linewidth',1.5)
legend('q2 true', 'q2 est')
grid on;
hold off

subplot(2,2,3)
hold on
plot(tout,simOut.my_qtrue.Data(:,3),'k','Linewidth',1.5)
plot(tout,simOut.my_qest.Data(:,3),'m--','Linewidth',1.5)
legend('q3 true', 'q3 est')
grid on;
hold off

subplot(2,2,4)
hold on
plot(tout,simOut.my_qtrue.Data(:,4),'k','Linewidth',1.5)
plot(tout,simOut.my_qest.Data(:,4)','m--','Linewidth',1.5)
legend('q4 true', 'q4 est')
grid on;
hold off