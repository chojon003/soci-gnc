
close all

simParams.sample_time_s = .05;
dt = simParams.sample_time_s;

set_param(bdroot,'ShowPortDataTypes','on')
set_param(bdroot,'ShowLineDimensions','on')

tspan = [0:dt:200]; % time span
m = length(tspan);
t = tspan; % time horizon
tfinal = tspan(m); %final time

simout1=sim('simplified_sim_2018','StopTime','tfinal', ...
    'SaveTime','on','TimeSaveName','timeoutNew',...
    'SaveOutput','on','OutputSaveName','youtNew');

        time2=simout1.get('timeoutNew');
        y=simout1.get('youtNew');
        qest_simu = y{2}.Values.Data'; %get out estimated quaternions from simulink
        % the simulink estimated quaternion
        q_true = y{5}.Values.Data';
        
        sigma_simu = y{4}.Values.Data';%get out 3 sigma bounds from simulink (already multiplied by 3 and converted to degrees)

%%%%%%%%% CALCULATE THE ERROR QUATERNION FROM SIMULINK Q_EST %%%%%%%%%
% for i = 1:m
%     qmix1s = ([qest_simu(4,i);qest_simu(1,i);qest_simu(2,i);qest_simu(3,i)]');
%         qmix_true = ([q_true(4,i);q_true(1,i);q_true(2,i);q_true(3,i)]');
%         qm(i,:) = quat_err(qmix1s,qmix_true);
%         qerrs = qm(:,1:3)*2;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% CREATE FIGURE 1: ESTIMATED VS TRUE QUATERNION %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
    subplot(2,2,1)
        plot(t,q_true(1,:),'k*',t,qest_simu(1,:),'g')
        title('q1 Evolution/Estimates')
        xlabel('Time (s)')
        ylabel('q1 (rad)')
        grid on
        legend('True q_1','Estimated q_1 (simulink)','Estimated q_1 (script)','Location','southeast')

        subplot(2,2,2)
            plot(t,q_true(2,:),'k*',t,qest_simu(2,:),'g')
            title('q2 Evolution/Estimates')
            xlabel('Time (s)')
            ylabel('q2 (rad)')
            grid on
            legend('True q_2','Estimated q_2 (simulink)','Estimated q_2 (script)','Location','southwest')

            subplot(2,2,3)
                plot(t,q_true(3,:),'k*',t,qest_simu(3,:),'g')
                title('q3 Evolution/Estimates')
                xlabel('Time (s)')
                ylabel('q3 (rad)')
                grid on
                legend('True q_3','Estimated q_3 (simulink)','Estimated q_3 (script)','Location','northeast')

                subplot(2,2,4)
                    plot(t,q_true(4,:),'k*',t,qest_simu(4,:),'g')
                    title('q4 Evolution/Estimates')
                    xlabel('Time (s)')
                    ylabel('q4 (rad)')
                    grid on
                    legend('True q_4','Estimated q_4 (simulink)','Estimated q_4 (script)','Location','northwest')
                    
%%%%%%%% QUATERNION ERROR PLOTS %%%%%%%%%%%%%%%%
% figure
%  subplot(3,1,1)
%             hold all;
%             plot(t,sigma_simu(1,:),'*c')
%             plot(t,-sigma_simu(1,:),'*m')
%             plot(t,3*180/pi*vestt(1,:),':m','LineWidth',2);
%             plot(t,qerr(1:end,1)'*180/pi,'k'); %%% Script Error
%             plot(t,qerrs(1:end,1)*180/pi,'b'); %%% Simulink Error
%             plot(t,-3*180/pi*vestt(1,:),':c','LineWidth',2);
%             title('q_1 Error & 3\sigma Bounds')
%             legend('+3\sigma bound (simulink)','-3\sigma bound (simulink)','+3\sigma bound','Script q_1 Error','Simu q_1 Error',...
%                 '-3\sigma bound','Orientation','horizontal','Location','southeast')
%             xlabel('Time (s)')
%             ylabel('3 \sigma bound Error (deg)')
%             grid on
% 
%                 subplot(3,1,2)
%                     hold all;
%                     plot(t,sigma_simu(2,:),'*c')
%                     plot(t,-sigma_simu(2,:),'*m')
%                     plot(t,3*180/pi*vestt(2,:),':m','LineWidth',2);
%                     plot(t,qerr(1:end,2)*180/pi,'k'); %%% Script Error
%                     plot(t,qerrs(1:end,2)*180/pi,'b'); %%% Simulink Error
%                     plot(t,-3*180/pi*vestt(2,:),':c','LineWidth',2);
%                     title('q_2 Error & 3\sigma Bounds')
%                     legend('+3\sigma bound (simulink)','-3\sigma bound (simulink)','+3\sigma bound','Script q_2 Error','Simu q_2 Error',...
%                         '-3\sigma bound','Orientation','horizontal','Location','southeast')
%                     xlabel('Time (s)')
%                     ylabel('3 \sigma bound Error (deg)')
%                     grid on
%                 
%                         subplot(3,1,3)
%                             hold all;
%                             plot(t,sigma_simu(3,:),'*c')
%                             plot(t,-sigma_simu(3,:),'*m')
%                             plot(t,3*180/pi*vestt(3,:),':m','LineWidth',2);
%                             plot(t,qerr(1:end,3)*180/pi,'k'); %%% Script Error
%                             plot(t,qerrs(1:end,3)*180/pi,'b'); %%% Simulink Error
%                             plot(t,-3*180/pi*vestt(3,:),':c','LineWidth',2);
%                             title('q_3 Error &3\sigma Bounds')
%                             legend('+3\sigma bound (simulink)','-3\sigma bound (simulink)','+3\sigma bound','Script q_3 Error','Simu q_3 Error',...
%                                 '-3\sigma bound','Orientation','horizontal','Location','southeast')
%                             xlabel('Time (s)')
%                             ylabel('3 \sigma bound Error (deg)')
%                             grid on
%                     
%                    
% %%%%%%%%%%%%%% CREATE FIGURE 3: ESTIMATED Attitudes VS TRUE %%%%%%%%%%%%%%%%
% 
% figure
%     subplot(3,1,1)
%     hold on
%     plot(t,Rb(1,:)*180/pi,'--r',t,ytil(1,:)*180/pi,'g',t,Rb_hat(1,:)*180/pi,'--k')
%     title('Roll Angle Time Evolution/Estimates')
%     xlabel('Time (s)')
%     ylabel('Roll Angle (deg)')
%     grid on
%     legend('Noisy Roll Data', 'Estimated Roll', 'True Roll')
%     
%         subplot(3,1,2)
%             hold on
%             plot(t,Rb(2,:)*180/pi,'--r',t,ytil(2,:)*180/pi,'g',t,Rb_hat(2,:)*180/pi,'--k')%,t,omega_est(1,:),t,omega_tilda(:,1),t,x1(:,5))
%             title('Pitch Angle Time Evolution/Estimates')
%             xlabel('Time (s)')
%             ylabel('Pitch Angle (deg)')
%             grid on
%             legend('Noisy Pitch Data', 'Estimated Pitch Angle', 'True Pitch Angle')
% 
%                 subplot(3,1,3)
%                     plot(t,Rb(3,:)*180/pi,'--r',t,ytil(3,:)*180/pi,'g',t,Rb_hat(3,:)*180/pi,'--k')
%                     title('Yaw Angle Time Evolution/Estimates')
%                     xlabel('Time (s)')
%                     ylabel('Yaw Angle (deg)')
%                     grid on
%                     legend('Noisy Yaw Data', 'Estimated Yaw Angle', 'True Yaw Angle')
% 
%         