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

GeneralizedCoordinate phi r
CoordinateSystem I
Parameter m1 l

%%
m = imf.Model(I);
m.gravity = imf.Gravity(g, I);
m.Add(imf.Body('b1', m1, imf.PositionVector([cos(phi)*r;sin(phi)*r;sqrt(l^2 - r^2)], I)));

%%
model = m.Compile();
model.matlabFunction('model');

%%
m1v = 0.1;
lv = 2;

xy0 = [0 1 sqrt(norm(g)/(sqrt(2^2-1^2))) 0]; % equilibrium circular trajectory
xyp0 = [0 0 0 0];
tspan = linspace(0,7,100);

opt = odeset('mass',@(t,x) modelM(t, x, [m1v;lv]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) modelF(t, x, [m1v;lv]), tspan, xy0, opt);

figure
grid on
hold on
plot(tsol, ysol(:, 1:2))
legend('phi', 'r')

figure
grid on
hold on
plot(tsol, ysol(:, 3:4))
legend('dphi', 'dr')

%%
if all(abs(ysol(end, 3:4)-ysol(1, 3:4)) < 1e-6) && all(abs(ysol(end, 2)-ysol(1, 2)) < 1e-6)
    disp('Test ran successfully.')
else
    error('Test failed.')
end

