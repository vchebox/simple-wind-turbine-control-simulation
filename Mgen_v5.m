   function [sys,x0,str,ts,simStateCompliance] = Mgen_v5(t,x,input,flag)
% 
% The function is intended to calculate the load torque and 
% the generator torque both reduced to the turbine shaft.  
% In this example, constant tip-speed ratio lambda=6 is assumed while
% the generator torque is changed depending on the rotor angular velocity. 
% Gearbox ratio i=1/48. Turbine radius R= 62.1 m.
% Rated wind velocity Vr=13 m/s. Rated power capacity Pr= 5e6 W.
% Power coefficient Сp=0.4. Overall efficiency ita=0.77
% ro=1.22 kg/m^3 is air density.
% Intermediate coefficient of generator Kgen is introduced as follows:
% Kgen=0.5*Cp*pi*R^5*ro/lambda^3.
%
% !!! Modify the mdlOutputs function below according to your case.
% Here, input(1)=omega is the rotor angular velocity,
% input(2)=V is the instantaneous wind velocity,
% input(3)=Mrot is the rotor torque.
%
% Dispatch the flag. The switch function controls the calls to 
% S-function routines at each simulation stage of the S-function.
%
switch flag
  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  % Initialize the states, sample times, and state ordering strings.
  case 0
    [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes;

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  % Return the outputs of the S-function block.
  case 3
    sys=mdlOutputs(t,x,input);

  %%%%%%%%%%%%%%%%%%%
  % Unhandled flags %
  %%%%%%%%%%%%%%%%%%%
  % There are no termination tasks (flag=9) to be handled.
  % Also, there are no continuous or discrete states,
  % so flags 1,2, and 4 are not used, so return an empty
  % matrix 
  case { 1, 2, 4, 9 }
    sys=[];

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Unexpected flags (error handling)%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Return an error message for unhandled flag values.
  otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));

end

% end timestwo

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts,simStateCompliance] = mdlInitializeSizes()

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 2;  % Здесь изменено
sizes.NumInputs      = 3;  % Здесь изменено
sizes.DirFeedthrough = 1;   % has direct feedthrough
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
str = [];
x0  = [];
ts  = [-1 0];   % inherited sample time

% specify that the simState for this s-function is same as the default
simStateCompliance = 'DefaultSimState';

% end mdlInitializeSizes

%
%=============================================================================
% mdlOutputs
% Return the output vector for the S-function
%=============================================================================
%
function sys = mdlOutputs(~,~,input)
omega = input(1);
V= input(2);
Mrot = input(3);
Kgen=0.5*0.4*3.1415*62.1^5*1.22/6^3;        % Intermediate coefficient  
    if (V < 4)                              % region I 
        Mload = Mrot;
        Mgen = 0;    

    elseif (V >= 25 && omega ~= 0)          % braking in region IV 
        Mgen = min (5e6*62.1/0.77/(13*6), Kgen*omega^2);
        Mload = Mgen;                
             
    elseif (V >= 25 && omega == 0)          % shutdown in region IV 
        Mload = Mrot;
        Mgen = 0;                
        
    elseif (V >= 13 && V < 25)              % region III
        Mgen = min (5e6*62.1/0.77/(13*6), Kgen*omega^2);      
        Mload = Mgen;
    
    else                                    % region II
        Mgen = Kgen*omega^2;     
        Mload = Mgen;
        
    end     

sys = [Mload, Mgen];

% end mdlOutputs

