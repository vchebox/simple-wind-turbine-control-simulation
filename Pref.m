function [sys,x0,str,ts,simStateCompliance] = Pref(t,x,V,flag)
% 
% In this function, a reference power Pref corresponding instantenious 
% wind velocity V is calculated. 
% Swept area of the wind turbine A=12,144 sq.m which
% has been calculated preliminarily from rated conditions as follows:
% A=Pr/(0,5*Ñð*i*ro*Vr^3),
% where Pr=5e3 kW  is rated power; 
% Cp=0.4 is power cofficient
% i=0.77 is overall efficiency
% ro=1.22 kg/m^3 is air density
% Vr is rated wind velocity.
% From the swept area we have the turbine radius R=62.1 m.
% !!! Modify the mdlOutputs function below according to your case.
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
    sys=mdlOutputs(t,x,V);

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
sizes.NumOutputs     = -1;  % dynamically sized
sizes.NumInputs      = -1;  % dynamically sized
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
function sys = mdlOutputs(~,~,V)
    if (V <= 4 || V >= 25)     % regions I or IV
        Pref = 0; 
        
    elseif (V > 13 && V < 25)  % rated power in region III
        Pref = 0.5*0.4*0.77*1.22*12114*13^3;
    
    else                        % region II
        Pref = 0.5*0.4*0.77*1.22*12114*V^3;
        
    end     

sys =Pref;

% end mdlOutputs

