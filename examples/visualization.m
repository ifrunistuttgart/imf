%  Licence:
%    This file is part of iFR Modelling Framework  - (http://www.ifr.uni-stuttgart.de)
%
%    IMF -- A framework for modelling dynamic mechanical systems in MATLAB.
%    Copyright (C) 2016-2017 by Pascal Gross <pascal.gross@ifr.uni-stuttgart.de>.
%    Developed within the Flight Mechanics and Controls Lab of the
%    University of Stuttgart. All rights reserved.
%
%    IMF is free software; you can redistribute it and/or
%    modify it under the terms of the GNU Lesser General Public
%    License as published by the Free Software Foundation; either
%    version 3 of the License, or (at your option) any later version.
%
%    IMF is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%    Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public
%    License along with ACADO Toolkit; If not, see <http://www.gnu.org/licenses/>.
%
%    Author: Pascal Gross <pascal.gross@ifr.uni-stuttgart.de>
%    Date: 2017

init
BEGIN_IMF

g = [0 0 9.81]';

GeneralizedCoordinate q1 q2 q3
CoordinateSystem I c1 c2
Parameter m1 m2 m3 l

%%
% Transformation from System I to System c1
imf.Transformation(I, c1, imf.RotationMatrix.T2(q1), imf.Vector([0;0;-l], c1));

%%
% Transformation from System c1 to System c2
imf.Transformation(c1, c2, imf.RotationMatrix.T2(q2), imf.Vector([0;0;-l], c2));

%%
m = imf.Model(I);
m.gravity = imf.Gravity(g, I);
m.Add(imf.Body('b1', m1, imf.PositionVector([sin(q1)*l,0,cos(q1)*l]', I)));
m.Add(imf.Body('b2', m2, imf.PositionVector([sin(q2)*l,0,cos(q2)*l]', c1)));
m.Add(imf.Body('b3', m3, imf.PositionVector([sin(q3)*l,0,cos(q3)*l]', c2)));

%%
model = m.Compile();
model.matlabFunction('model');

%%
END_IMF

%%
m1v = 0.1;
m2v = 0.1;
m3v = 0.1;
lv = 1;

xy0 = [pi/4 pi/4 pi/4 0 0 0]';
xyp0 = [0 0 0 0 0 0];
tspan = linspace(0,10,500);

opt = odeset('mass',@(t,x) modelM(t, x, [m1v;m2v;m3v;lv]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) modelF(t, x, [m1v;m2v;m3v;lv]), tspan, xy0, opt);
figure
grid on
hold on
plot(tsol, ysol(:,1:3))
legend('q1', 'q2', 'q3')

figure
grid on
hold on
plot(tsol, ysol(:,4:6))
legend('dq1', 'dq2', 'dq3')

limits = [-4 4 -2 2 -.5 4];
fh = visualize(m, {q1, q2, q3, m1, m2, m3, l}, [ysol(1,1), ysol(1,2), ysol(1,3), m1v, m2v, m3v, lv], 'axis', limits, 'view', [0 0], 'revz', 1);

%%
prompt = 'Do you want to create a animate? (y/n) ';
s = input(prompt, 's');
if ~strcmp(s, 'y')
    return;
end

dt = max(tspan) / length(tspan);
fh = visualize(m, {q1, q2, q3, m1, m2, m3, l}, [ysol(1,1), ysol(1,2), ysol(1,3), m1v, m2v, m3v, lv], 'axis', limits, 'view', [0 0], 'revz', 1);
pause on
for i=1:length(ysol)
    fh = visualize(m, {q1, q2, q3, m1, m2, m3, l}, [ysol(i,1), ysol(i,2), ysol(i,3), m1v, m2v, m3v, lv], 'axis', limits, 'view', [0 0], 'revz', 1);
    pause(dt);
end

%%
prompt = 'Do you want to create a movie? (y/n) ';
s = input(prompt, 's');
if ~strcmp(s, 'y')
    return;
end

v = VideoWriter('visualization.mp4', 'MPEG-4');
v.FrameRate = 1/dt;
open(v)
for i=1:length(ysol)
    fh = visualize(m, {q1, q2, q3, m1, m2, m3, l}, [ysol(i,1), ysol(i,2), ysol(i,3), m1v, m2v, m3v, lv], 'axis', limits, 'view', [0 0], 'revz', 1);
    fh.PaperUnits = 'points';
    fh.PaperPosition =[0 0 921.6 518.4];
    frame = print('-RGBImage');
    writeVideo(v,frame);
end
close(v)