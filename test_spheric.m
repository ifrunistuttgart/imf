clear all
close all

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
CoordinateSystem I
%CoordinateSystem I c1
Parameter m1 l

%%
%T21 = imf.Transformation(I, c1, imf.RotationMatrix.T1(q2)*imf.RotationMatrix.T2(q1), imf.Vector([0;0;0], c1));

%%
m = imf.Model(I);
m.gravity = imf.Gravity(g, I);
%m.Add(imf.Mass('m1', m1, imf.PositionVector([0;0;l], c1)));
m.Add(imf.Mass('m1', m1, imf.PositionVector([sin(q1);sin(q2);cos(q1)*cos(q2)], I)));

%%
model = m.Compile();
model.matlabFunction('model');

%%
m1v = 0.1;
lv = 2;

xy0 = [pi/4 0 0 1];
xyp0 = [0 0 0 0];
tspan = linspace(0,7,100);

opt = odeset('mass',@(t,x) modelM(t, x, [m1v;lv]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) modelF(t, x, [m1v;lv]), tspan, xy0, opt);

figure
grid on
hold on
plot(tsol, ysol(:, 1:2))
legend('q1', 'q2')

figure
grid on
hold on
plot(tsol, ysol(:, 3:4))
legend('dq1', 'dq2')

% %%
prompt = 'Do you want to create a animate? (y/n) ';
s = input(prompt, 's');
if ~strcmp(s, 'y')
    return;
end

limits = [-2 2 -2 2 -.5 4];

dt = max(tspan) / length(tspan);
fh = visualize(m, {q1, q2, m1, l}, [ysol(1,1), ysol(1,2), m1v, lv], 'axis', limits, 'view', [0 90], 'revz', 1);
pause on
for i=1:length(ysol)
    fh = visualize(m, {q1, q2, m1, l}, [ysol(i,1), ysol(i,2),m1v, lv], 'axis', limits, 'view', [0 90], 'revz', 1);
    pause(dt);
end


