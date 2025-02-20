clear all
%% Generate A,B,C Matrices based on Quad-Tank system
[Ac, Bc, Cc, Dc, L10, L20, L30, L40, Vp10, Vp20, gamma1, gamma2, g, Kp, kc, Ao1, Ao2, Ao3, Ao4, At1, At2, At3, At4] = Process_setup(); %Generates A,B,C,D matrixes of CT system
 %Cc=eye(2,4); Cd=Cc;
 
%% Common MPC Parameters.
%Size Parameters
m = size(Bc,2); 
n = size(Ac,1); 
rdim=n+m;
% Limit Parameters
Vmax=22;
umax=3;
alpha=Vmax/umax; % Scaling factor for control optimization

%Control Weights Generation
Q = 10*eye(n); 
R = 1*eye(m);

tau = 1000;

% Defining Control Horizons
Np1 = input('Enter First Prediciton Horizon:    ');
Np2 = input('Enter Second Prediciton Horizon:    ');
Np3 = input('Enter Third Prediciton Horizon:    ');

Np = Np1;

%% Primal-Dual Solver Set Up.
[H, F1, F2, F3, Lb, Ub, Lx, Ld, T, r, t]=PrimalDual_setup(Ac, Bc, Cc, Dc, Np, Q, R, Vp10, Vp20, Vmax, kc, L10, L20);
% Generate H, E and Fo Matrices 
mdl_ch1 = 'nonlinear_obs_primaldual_2019b';
%open_system(mdl);
%in = Simulink.SimulationInput('nonlinear_obs_primaldual_2019b');
%in = in.setExternalInput('r.getElement(1),r.getElement(2)');
sim_primaldual_ch1 = [t' r];
sim_opts_ch1 = simset;
tic; 
out_ch1 = sim(mdl_ch1,[0 t(end)],sim_opts_ch1,sim_primaldual_ch1);
time1 = toc; 
PrimalDual_t_ch1 = out_ch1.tout;
PrimalDual_out_ch1 = out_ch1.yout{1}.Values;
%PrimalDual_x=Simulink.SimulationData.Dataset(out.yout{1}.Values)
PrimalDual_x_ch1=PrimalDual_out_ch1.data;


%Define Second Control Horizon 
Np = Np2;

%% Primal-Dual Solver Set Up.
[H, F1, F2, F3, Lb, Ub, Lx, Ld, T, r, t]=PrimalDual_setup(Ac, Bc, Cc, Dc, Np, Q, R, Vp10, Vp20, Vmax, kc, L10, L20);
% Generate H, E and Fo Matrices 
mdl_ch10 = 'nonlinear_obs_primaldual_2019b';
%open_system(mdl);
%in = Simulink.SimulationInput('nonlinear_obs_primaldual_2019b');
%in = in.setExternalInput('r.getElement(1),r.getElement(2)');
sim_primaldual_ch10 = [t' r];
sim_opts_ch10 = simset;
tic;
out_ch10 = sim(mdl_ch10,[0 t(end)],sim_opts_ch10,sim_primaldual_ch10);
time2=toc; 
PrimalDual_t_ch10 = out_ch10.tout;
PrimalDual_out_ch10 = out_ch10.yout{1}.Values;
%PrimalDual_x=Simulink.SimulationData.Dataset(out.yout{1}.Values)
PrimalDual_x_ch10 = PrimalDual_out_ch10.data;

%Define Third Control Horizon 
Np = Np3; 

%% Primal-Dual Solver Set Up.
[H, F1, F2, F3, Lb, Ub, Lx, Ld, T, r, t]=PrimalDual_setup(Ac, Bc, Cc, Dc, Np, Q, R, Vp10, Vp20, Vmax, kc, L10, L20);
% Generate H, E and Fo Matrices 
mdl_ch100 = 'nonlinear_obs_primaldual_2019b';
%open_system(mdl);
%in = Simulink.SimulationInput('nonlinear_obs_primaldual_2019b');
%in = in.setExternalInput('r.getElement(1),r.getElement(2)');
sim_primaldual_ch100 = [t' r];
sim_opts_ch100 = simset;
tic;
out_ch100 = sim(mdl_ch100,[0 t(end)],sim_opts_ch100,sim_primaldual_ch100);
time3 = toc; 
PrimalDual_t_ch100 = out_ch100.tout;
PrimalDual_out_ch100 = out_ch100.yout{1}.Values;
%PrimalDual_x=Simulink.SimulationData.Dataset(out.yout{1}.Values)
PrimalDual_x_ch100 = PrimalDual_out_ch100.data;

%Scaling to Seconds
% Height Plots


str1 = strcat('Np =  ', num2str(Np1));
str2 = strcat('Np =  ', num2str(Np2));
str3 = strcat('Np =  ', num2str(Np3));


subplot(3,2,1)
p = plot(PrimalDual_t_ch1/T, PrimalDual_x_ch1(:,3), 'g',  PrimalDual_t_ch10/T, PrimalDual_x_ch10(:,3),  'r',PrimalDual_t_ch100/T, PrimalDual_x_ch100(:,3),  'b')
p(1).LineWidth = 1 
p(2).LineWidth = 1
p(3).LineWidth = 1
ylabel('{x_\xi}_3 [c]')
grid
axis([0 1200/T 0 8])
legend(str1, str2, str3)


subplot(3,2,2)
p = plot(PrimalDual_t_ch1/T, PrimalDual_x_ch1(:,4),  'g', PrimalDual_t_ch10/T, PrimalDual_x_ch10(:,4),  'r',PrimalDual_t_ch100/T, PrimalDual_x_ch100(:,4),  'b')
p(1).LineWidth = 1 
p(2).LineWidth = 1
p(3).LineWidth = 1
ylabel('{x_\xi}_4 [c]')
grid
axis([0 1200/T 0 5])
subplot(3,2,3)
legend(str1, str2, str3)

subplot(3,2,4)
hold on
p = plot(PrimalDual_t_ch1/T, PrimalDual_x_ch1(:,2),  'g', PrimalDual_t_ch10/T, PrimalDual_x_ch10(:,2),  'r',PrimalDual_t_ch100/T, PrimalDual_x_ch100(:,2),  'b')
p(1).LineWidth = 1 
p(2).LineWidth = 1
p(3).LineWidth = 1
z=plot(t/T,r(1:max(PrimalDual_t_ch1)/T+1,2)','-.');
z.LineWidth=1
hold off
grid
axis([0 1200/T 0 16])
ylabel('{x_\xi}_2 [c]')
legend(str1, str2, str3)


subplot(3,2,3)
hold on
p=plot(PrimalDual_t_ch1/T, PrimalDual_x_ch1(:,1),  'g', PrimalDual_t_ch10/T, PrimalDual_x_ch10(:,1),  'r',PrimalDual_t_ch100/T, PrimalDual_x_ch100(:,1),  'b')
p(1).LineWidth = 1 
p(2).LineWidth = 1
p(3).LineWidth = 1
z=plot(t/T,r(1:max(PrimalDual_t_ch1)/T+1,1)','-.');
z.LineWidth=1
hold off
grid
axis([0 1200/T 6 16])
ylabel('{x_\xi}_1 [c]')
legend(str1, str2, str3)


subplot(3,2,5)
p=plot(PrimalDual_t_ch1/T, PrimalDual_x_ch1(:,5),  'g', PrimalDual_t_ch10/T, PrimalDual_x_ch10(:,5), 'r',PrimalDual_t_ch100/T, PrimalDual_x_ch100(:,5),  'b')
p(1).LineWidth = 1 
p(2).LineWidth = 1
p(3).LineWidth = 1
grid
axis([0 1200/T 0 22])
ylabel('{u_\xi}_1 [c]')
xlabel('t [s]')

legend(str1, str2, str3)


subplot(3,2,6)
p=plot(PrimalDual_t_ch1 / T, PrimalDual_x_ch1(:,6),  'g', PrimalDual_t_ch10 / T , PrimalDual_x_ch10(:,6),  'r',PrimalDual_t_ch100 / T , PrimalDual_x_ch100(:,6),  'b')
p(1).LineWidth = 1 
p(2).LineWidth = 1
p(3).LineWidth = 1
axis([0 1200/T 2 22])
grid on
ylabel('{u_\xi}_2 [c]')
xlabel('t [s]')
legend(str1, str2, str3)

time1
time2
time3