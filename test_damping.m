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
Parameter m1 m2 kd l

%%
% Transformation from System I to System c1
T21 = imf.Transformation(I,c1);
T21.rotation = imf.RotationMatrix.T2(q1);
% The offset of the origin of System 2 to System 1
% with regards to System 1
T21.offset = imf.Vector([0;0;-l], c1);

%%
m = imf.Model(I);
m.gravity = imf.Gravity(g, I);
m.Add(imf.Mass('m1', m1, imf.PositionVector([sin(q1)*l,0,cos(q1)*l]', I)));
m.Add(imf.Mass('m2', m2, imf.PositionVector([sin(q2)*l,0,cos(q2)*l]', c1)));

m.Add(imf.Moment('Md1', imf.Vector([0;-kd*dot(q1);0], I), imf.Vector([0;q1;0], I)));
m.Add(imf.Moment('Md2', imf.Vector([0;-kd*dot(q2);0], c1), imf.Vector([0;q2;0], c1)));

%%
model = m.Compile();
model.matlabFunction('model');

%%
m1v = 0.1;
m2v = 0.1;
kdv = 0.8;
lv = 1.0;

xy0 = [pi/4 pi/4 0 0]';
xyp0 = [0 0 0 0];
tspan = linspace(0,20,500);

opt = odeset('mass',@(t,x) modelM(t, x, [m1v;m2v;kdv;lv]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) modelF(t, x, [m1v;m2v;kdv;lv]), tspan, xy0, opt);
figure
grid on
hold on
plot(tsol, ysol(:,1:2))
legend('q1', 'q2')

figure
grid on
hold on
plot(tsol, ysol(:,3:4))
legend('dq1', 'dq2')

limits = [-4 4 -2 2 -.5 4];
fh = visualize(m, {q1, q2, dot(q1), dot(q2), m1, m2, kd, l}, [ysol(1,1), ysol(1,2), ysol(1,3), ysol(1,4), m1v, m2v, kdv, lv], 'axis', limits, 'view', [0 0], 'revz', 1);

%%
prompt = 'Do you want to create a animate? (y/n) ';
s = input(prompt, 's');
if ~strcmp(s, 'y')
    return;
end

dt = max(tspan) / length(tspan);
pause on
for i=1:length(ysol)
    fh = visualize(m, {q1, q2, dot(q1), dot(q2), m1, m2, kd, l}, [ysol(i,1), ysol(i,2), ysol(i,3), ysol(i,4), m1v, m2v, kdv, lv], 'axis', limits, 'view', [30 30], 'revz', 1);
    pause(dt);
end

%%
prompt = 'Do you want to create a movie? (y/n) ';
s = input(prompt, 's');
if ~strcmp(s, 'y')
    return;
end

if ishandle(fh)
    close fh
end


v = VideoWriter('pendulum_damping.mp4', 'MPEG-4');
v.FrameRate = 1/dt;
open(v)
for i=1:length(ysol)
    fh = visualize(m, {q1, q2, dot(q1), dot(q2), m1, m2, kd, l}, [ysol(i,1), ysol(i,2), ysol(i,3), ysol(i,4), m1v, m2v, kdv, lv], 'axis', limits, 'view', [0 0], 'revz', 1);
    frame = getframe;
    writeVideo(v,frame);
end
close(v)
