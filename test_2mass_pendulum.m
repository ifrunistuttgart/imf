clear all
close all
clc

%%
g = [0 0 9.81]';

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

GeneralizedCoordinate q1 q2
CoordinateSystem I c1
Variable m1 m2 l

%%
% Transformation from System 2 to System 1
T12 = imf.Transformation(c1,I);
T12.rotation = imf.DCM.T2(q1);
% The offset of the origin of System 2 to System 1
% with regards to System 1
T12.offset = imf.Vector(l*[sin(q1);0;cos(q1)]);

%%
m = imf.Model(I);
m.gravity = imf.Gravity(g, I);
m.Add(imf.Mass(m1, [sin(q1)*l,0,cos(q1)*l]', I));
m.Add(imf.Mass(m2, [sin(q2)*l,0,cos(q2)*l]', c1));

%%
model = m.Compile();
model.matlabFunction('model');

%%
m1 = 1;
m2 = 1;
l = 0.2;

xy0 = [pi/12 pi/12 0 0]';
xyp0 = [0 0 0 0];
tspan = linspace(0,40,4000);

opt = odeset('mass',@(t,x) modelM(t, x, [m1;m2;l]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) modelF(t, x, [m1;m2;l]), tspan, xy0, opt);
figure
grid on
hold on
plot(tsol, ysol)
legend('q1', 'q2', 'dq1', 'dq2')

%%
figure
pause on
for i=1:length(ysol)
    q1 = ysol(i, 1);
    T = eval(T12.rotation.fun);
    offset = eval(T12.offset.items);
    R = [T offset; 0 0 0 1];
    
    grid on
    visualizeCoordinateSystem(R, 1)
    pause(0.1)
end