    function [sys,x0,str,ts,simStateCompliance] = Mrot_v4(t,x,input,flag)
% 
% The function is used to calculate turbine torque Mrot by means of   
% a piecewise linear approximation of an airfoil polar diagram.
% I.e. rotor torque Mrot depends on a relative angle of attack and 
% actual wind velocity. 
% In this example, rotor torque under rated conditions Mr is found for 
% rated power capacity Pr=5e3 kW,
% rated wind velocity Vr=13 m/s,
% tip-speed ratio lambda=6.
% !!! Modify the mdlOutputs function below according to your case.
% Here, input(1)=alfa is the angle of attack,
% input(2)=theta is the pitch angle.
% input(3)=V is the instantaneous wind velocity,
% input(4)=omega is the rotor angular velocity.
% NB! Feel yourselves free to replace the approximation with real data 
% on the characterictics of commercially available blades 

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
sizes.NumOutputs     = 1;  % dynamically sized
sizes.NumInputs      = 4;  % Здесь изменено!
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
alfa=input(1);
theta=input(2);
V=input(3);
omega=input(4);
    if (alfa <= 15)        % ascending segment of the polar diagram
        Cm = alfa/15;      % linear approximation
    elseif (alfa > 15) && (alfa <= 25)  % top segment of the diagram 
        Cm = 1;
    else                   % descending segment of the polar diagram 
        Cm = 90/(90-25)-alfa/(90-65);
        
    end
    
beta = alfa + theta;   % angle between relative wind and rotor axis
Mr = 5.17e6;          % preliminarily calculated
relwind2 = V^2 + omega^2*62.1^2;   % 2nd power of relative velocity
relwind_r2 = 13^2 + (6*13)^2;      % the same under rated conditions
Mrot = Cm * Mr * sind(beta)/sin(atan(1/6))*relwind2/relwind_r2;

sys= Mrot;

% end mdlOutputs




