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
Parameter m1 m2 l

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
m.Add(imf.Mass('m1', m1, [sin(q1)*l,0,cos(q1)*l]', I));
m.Add(imf.Mass('m2', m2, [sin(q2)*l,0,cos(q2)*l]', c1));

%%
model = m.Compile();
model.matlabFunction('model');

%%
m1v = 0.1;
m2v = 0.1;
lv = 1;

xy0 = [pi/12 -pi/12 0 0]';
xyp0 = [0 0 0 0];
tspan = linspace(0,10,500);

opt = odeset('mass',@(t,x) modelM(t, x, [m1v;m2v;lv]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) modelF(t, x, [m1v;m2v;lv]), tspan, xy0, opt);
figure
grid on
hold on
plot(tsol, ysol)
legend('q1', 'q2', 'dq1', 'dq2')

%%
limits = [-2 2 -2 2 -.5 4];
dt = max(tspan) / length(tspan);

v = VideoWriter('2mass_pendulum.mp4', 'MPEG-4');
v.FrameRate = 1/dt;
open(v)
for i=1:length(ysol)
    visualize(m, {q1, q2, m1, m2, l}, [ysol(i,1), ysol(i,2), m1v, m2v, lv], 'axis', limits, 'view', [0 0], 'revz', 1)
    frame = getframe;
    writeVideo(v,frame);
end
close(v)
