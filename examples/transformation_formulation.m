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

GeneralizedCoordinate q1 q2
CoordinateSystem I c1
Parameter m1 m2 l

%%
% Transformation from System I to System c1
imf.Transformation(I, c1, imf.RotationMatrix.T2(q1), imf.Vector([0;0;-l], c1));

%%
m = imf.Model(I);
m.gravity = imf.Gravity(g, I);
m.Add(imf.Body('b1', m1, imf.PositionVector([sin(q1)*l,0,cos(q1)*l]', I)));
m.Add(imf.Body('b2', m2, imf.PositionVector([sin(q2)*l,0,cos(q2)*l]', c1)));

%%
model = m.Compile();
model.matlabFunction('model');

%%
m1v = 0.1;
m2v = 0.1;
lv = 1;

xy0 = [pi/12 pi/12 0 0]';
xyp0 = [0 0 0 0];
tspan = linspace(0,10,1000);

opt = odeset('mass',@(t,x) modelM(t, x, [m1v;m2v;lv]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) modelF(t, x, [m1v;m2v;lv]), tspan, xy0, opt);

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

END_IMF;

%%

BEGIN_IMF

GeneralizedCoordinate q1 q2
CoordinateSystem I c1
Parameter m1 m2 l

%%
% Transformation from System I to System c1
imf.Transformation(I, c1, imf.RotationMatrix.T2(q1), imf.Vector([sin(q1)*l;0;cos(q1)*l], I));

%%
m = imf.Model(I);
m.gravity = imf.Gravity(g, I);
m.Add(imf.Body('b1', m1, imf.PositionVector([sin(q1)*l,0,cos(q1)*l]', I)));
m.Add(imf.Body('b2', m2, imf.PositionVector([sin(q2)*l,0,cos(q2)*l]', c1)));

%%
model = m.Compile();
model.matlabFunction('model');

%%
m1v = 0.1;
m2v = 0.1;
lv = 1;

xy0 = [pi/12 pi/12 0 0]';
xyp0 = [0 0 0 0];
tspan = linspace(0,10,1000);

opt = odeset('mass',@(t,x) modelM(t, x, [m1v;m2v;lv]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tval,yval] = ode15s(@(t,x) modelF(t, x, [m1v;m2v;lv]), tspan, xy0, opt);

figure
grid on
hold on
plot(tval, yval(:, 1:2))
legend('q1', 'q2')

figure
grid on
hold on
plot(tval, yval(:, 3:4))
legend('dq1', 'dq2')

%%
END_IMF

%%
if all(tval == tsol) && all(all(abs(yval-ysol) < 1e-5))
    disp('Test ran successfully.')
else
    error('Test failed.')
end