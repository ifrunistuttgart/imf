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
Parameter m1 l ri ra h

T21 = imf.Transformation(I, c1, imf.RotationMatrix.T3(q1), imf.RotationMatrix.T2(q2), imf.Vector([-l;0;0], c1));

%%
m = imf.Model(I);

Th = m1/12 * diag([3*(ra^2+ri^2)+h^2,  6*(ra^2+ri^2), 3*(ra^2+ri^2)+h^2]);
m.Add(imf.Body('b1', m1, imf.PositionVector([0;0;0], c1), imf.Inertia(Th, c1), imf.AttitudeVector([0;q3;0], c1)));

%%
model = m.Compile();
model.matlabFunction('model');

%%
m1v = 2;
lv = 0.5;
riv = 0.8;
rav = 0.9;
hv = 0.1;

xy0 = [0 0 0 10 0 30];
xyp0 = [0 0 0 0 0 0];
tspan = linspace(0,3,1000);

opt = odeset('mass',@(t,x) modelM(t, x, [m1v; lv; riv; rav; hv]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) modelF(t, x, [m1v; lv; riv; rav; hv]), tspan, xy0, opt);

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