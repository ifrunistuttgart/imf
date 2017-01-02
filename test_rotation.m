clear all
close all
clc

%%
if ~exist('BEGIN_IMF','file'),
    addpath( genpath([pwd filesep 'imf']) )
    if ~exist('BEGIN_IMF','file'),
        error('Unable to find the BEGIN_IMF function. Make sure to have' + ...
            'the library as a sub folder of the current working directory.');
    end
end

%%
BEGIN_IMF

GeneralizedCoordinate q1
CoordinateSystem I
Parameter k Izz

%%
m = imf.Model(I);
m.Add(imf.Inertia([0 0 0;0 0 0;0 0 Izz], [0 0 q1]', I));
% Be aware of the sign of the Moment induced by the spring
m.Add(imf.Moment([0 0 -k*q1]', [0 0 q1]', I)); 

%%
model = m.Compile();
model.matlabFunction('model');

%%
k = 0.1;
Izz = 0.3;

xy0 = [pi/4 0];
xyp0 = [0 0];
tspan = linspace(0,30,100);

opt = odeset('mass',@(t,x) modelM(t, x, [k;Izz]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) modelF(t, x, [k;Izz]), tspan, xy0, opt);
figure
grid on
hold on
plot(tsol, ysol)

%%
syms q1(t)
ex = Izz*diff(q1(t), t, t) + k*q1;
[newEqs, newVars] = reduceDifferentialOrder(ex, q1);
[M, F] = massMatrixForm(newEqs, newVars);
odeFunction(M, newVars, 'File', 'validateM');
odeFunction(F, newVars, 'File', 'validateF');

opt = odeset('mass', @validateM, 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tval,yval] = ode15s(@validateF, tspan, xy0, opt);
figure
grid on
hold on
plot(tval, yval)

%%
if all(tval == tsol) || all(all(abs(yval-ysol) < 1e-6))
    disp('Test ran successfully.')
else
    error('Test failed.')
end