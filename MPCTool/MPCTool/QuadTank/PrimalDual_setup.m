function [H, F1, F2, F3, Lb, Ub, Lx, Ld, T, r, t] = PrimalDual_setup(Ac, Bc, Cc, Dc, Np, Q, R, Vp10, Vp20, Vmax, kc, L10, L20)

%% ----------------- Intialize Observer ------------------------
m = size(Bc,2); 
n = size(Ac,1); 
Aoc=[Ac zeros(n,m); zeros(m,n) zeros(m)]; %Augmented system matrix
Boc=[Bc; zeros(m,m)]; % Augmented Input Matrix
Coc=[Cc eye(m)]; % Augmented Output Matrix
Doc=Dc; %Augmented Feedthrough Matrix

%----------------------------------------------------------------------
% Calculating the observer gain using "place"
 Ltemp = place(Aoc',Coc',[-0.7 -0.5 -0.9 -0.7 -0.9 -0.5]');
 Ltemp=Ltemp';%observer gain with Ld=[Lx ; Ldd]
 Lx=Ltemp(1:n,:);
 Ld=Ltemp(n+1:end,:);
 
 % Calculating Matrices for Observer Implementation
 Lc = Ld * Cc;
 Aob = (Ac - Lx * Cc) ;
 Bob = Bc;

% Discretized State-Space Model 

% Using the most accurate Method
T=5; %sampling time in seconds.
J=[Ac Bc; zeros(size(Cc,1),size(Ac,2)) zeros(size(Cc,1),size(Bc,2))];
Jd=expm(T*J);
Ad=Jd(1:size(Ac,1),1:size(Ac,2));
Bd=Jd(1:size(Ac,1),size(Ac,2)+1:end);
Cd=Cc;
Dd=Dc;

P = idare(Ad,Bd,Cd'*Cd,R,[],[]);

%Matrix Filling
[H, F1, F2, F3, Lb, Ub] = condensedmpc_matrix_filler(Ac,Bc,Cc,Dc,Ad, Bd, Cd, Np, Q, R, P, Vp10, Vp20, Vmax);
%[H,E,F_o] = genMPC_Matrix(A_d,B_d,C_d,m,n,N_h,Q,R,P);

%%Trajectory specification
 
 % Set point trajectory including setpoints for u:s
s = [zeros(round(500/T),1); 2*ones(round(960/T),1)]; % This is in "cm" and as deviation from the equilibrium point.
s = [s -s]*kc; %This sets the reference of channel 1 as "s" and for channel 2 as "0"

% Input disturbance trajectory
d = [zeros(round(600/T),1); -0*ones(round(860/T),1)];
d = [zeros(length(d),1) d]*kc; %This sets the disturance for channel 1 as "0" and for channel 2 as "d"
t = 0:T:((size(s,1)-1)*T);
s = s/kc; % Converting the setpoints back to "cm"
r(:,1) = s(:,1)+L10; 
r(:,2) = s(:,2)+L20;


end 
