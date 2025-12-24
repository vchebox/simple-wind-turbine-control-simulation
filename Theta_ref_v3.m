function [sys,x0,str,ts,simStateCompliance] = Theta_ref_v3(t,x,input,flag)
%
% The function is written to modify the non-linear regulator output    
% in region III depending on wind velocity V
% In this example, cut-in wind velocity Vin=4 m/s, 
% rated wind velocity Vr=13 m/s,
% cut-out wind velocity Vout=25 m/s.
% !!! Modify the mdlOutputs function below according to your case.
% Here, input(1) is a regulator output signal,
% input(2) is a measured wind velocity.

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
sizes.NumOutputs     = -1;  % dynamically sized
sizes.NumInputs      = 2;  % Здесь изменено!
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
    if (input(2) <= 4 || input(2) >= 25)      % shutdown
        Theta_ref = 90;    
    
    elseif (input(2) > 4 && input(2) <= 13)   % region II
        Theta_ref = input(1);
        
    else     % power is limited by gradual pitch increase up to 30 deg

        Theta_ref = 30/12*(input(2) - 13) + input(1);

    end     

sys =Theta_ref;

% end mdlOutputs

