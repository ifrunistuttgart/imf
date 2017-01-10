clear all
close all

%%
g = [0 -9.81 0]';

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
Parameter l ll m1

%%
m = imf.Model(I);
m.gravity = imf.Gravity(g, I);
m.Add(imf.Mass('m1', m1, imf.PositionVector([sin(q1)*ll*l,-cos(q1)*ll*l,0]', I)));

%%
model = m.Compile();
model.matlabFunction('model');

%%
m1 = 0.1;
l = 0.2;
ll = 0.1;

xy0 = [pi/4 0];
xyp0 = [0 0];
tspan = linspace(0,7,100);

opt = odeset('mass',@(t,x) modelM(t, x, [l;ll;m1]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) modelF(t, x, [l;ll;m1]), tspan, xy0, opt);
figure
grid on
hold on
plot(tsol, ysol)

%%
g = norm(g);
syms q1(t)
ex = diff(q1(t), t, t) + g/(l*ll)*sin(q1);
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
if all(tval == tsol) && all(all(abs(yval-ysol) < 1e-5))
    disp('Test ran successfully.')
else
    error('Test failed.')
end