clear all
close all

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

GeneralizedCoordinate q1 q2 q3
CoordinateSystem I c1
Parameter m1 l k M1 ri ra

T21 = imf.Transformation(I, c1, imf.RotationMatrix.T2(q2)*imf.RotationMatrix.T3(q1), imf.Vector([-l;0;0], c1));

%%
m = imf.Model(I);

m.Add(imf.Body('b1', m1, imf.PositionVector([0;0;0], c1), imf.Inertia(diag([1 1 m1*(ri^2 + ra^2)/2]), c1), imf.Vector([0;0;q3], c1)));
%m.Add(imf.Moment('M1', imf.Vector([0 0 M1]', I), imf.Vector([0 0 q1]', I)));
%m.Add(imf.Moment('M2', imf.Vector([0 0 -k*q2]', I), imf.Vector([0 0 q2]', I)));

%%
model = m.Compile();
model.matlabFunction('model');

%%
m1v = 1;
lv = 0.5;
kv = 0.1;
M1v = 0.1;
riv = 0.2;
rav = 0.22;

xy0 = [0 0 0 0 1 0];
xyp0 = [0 0 0 0 0 0];
tspan = linspace(0,30,1000);

opt = odeset('mass',@(t,x) modelM(t, x, [m1v; lv; kv; M1v; riv; rav]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) modelF(t, x, [m1v; lv; kv; M1v; riv; rav]), tspan, xy0, opt);

figure
grid on
hold on
plot(tsol, ysol(:,1:3))
legend('q1', 'q2', 'q3');

figure
grid on
hold on
plot(tsol, ysol(:,4:6))
legend('dq1', 'dq2', 'dq3');

%%
limits = [-4 4 -2 2 -.5 4];

dt = max(tspan) / length(tspan);
fh = visualize(m, {q1, q2, q3 m1, l, k, M1, ri, ra}, [ysol(1,1), ysol(1,2), ysol(1,3), m1v, lv, kv, M1v, riv, rav], 'axis', limits, 'view', [30 30], 'revz', 1, 'grid', 1);
pause on
for i=1:length(ysol)
    fh = visualize(m, {q1, q2, q3, m1, l, k, M1, ri, ra}, [ysol(i,1), ysol(i,2), ysol(i,3), m1v, lv, kv, M1v, riv, rav], 'axis', limits, 'view', [30 30], 'revz', 1, 'grid', 1);
    pause(dt);
end

