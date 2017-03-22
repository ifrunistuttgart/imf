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

GeneralizedCoordinate b % blade flap angle
CoordinateSystem H B1 F1
Parameter Vu a O e R m Ab

%%
Vuv = 10; % [m/s] rotor velocity with respect to the air
av = 8*pi/180; % [rad] rotor disk plane angle of attack, positive forward
Ov = 6 * 2*pi; % [rad/s] rotor rotational speed
ev = 0.4; % [m] flap hinge offset
Rv = 5.5; % [m] rotor radius
mv = 80; % [kg] rotor blade mass
Abv = Rv*0.3; % [m^2] roto blade area
rhov = 1.22; % [] air density

%%
imf.Transformation(H, B1, imf.RotationMatrix.T3(O*t), imf.Vector([-e 0 0]', B1));
imf.Transformation(B1, F1, imf.RotationMatrix.T2(b), imf.Vector([-0.7*R 0 0]', F1));

%%
model = imf.Model(H);
model.gravity = imf.Gravity([0 0 9.81]', H);

r = imf.PositionVector([0 0 0]', F1);
model.Add(imf.Body('b1', m, r));

vu = imf.Vector(Vu*[cos(a); 0; -sin(a)], H);
dr = d(r.In(H));
v = dr + vu;
v = v.In(F1);
v.items(1) = 0; % ignore airflow parallel to the blade

vsq = v'*v;
nv = sqrt(vsq);
yf1 = imf.Vector([0;1;0], F1);
sig = 1/sqrt(v.items(3)*v.items(3)) * v.items(3);
alpha = sig * acos((1/nv) * v'*yf1);
A = pi*alpha*rhov*vsq*Abv;
W = (1/Abv^2) * 2*pi*alpha^2*Abv^2*vsq;
model.Add(imf.Force('FW', imf.Vector([0;cos(alpha)*W + sin(alpha)*A;-cos(alpha)*A - sin(alpha)*W], F1), r));
%model.Add(imf.Force('FW', imf.Vector([0;sin(alpha)*A;-cos(alpha)*A], F1), r));

%%
c = model.Compile();
c.matlabFunction('model');

%%
xy0 = [0 0];
xyp0 = [0 0];
tspan = linspace(0,4,1000);

opt = odeset('mass',@(t,x) modelM(t, x, [Vuv; av; Ov; ev; Rv; mv; Abv]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) modelF(t, x, [Vuv; av; Ov; ev; Rv; mv; Abv]), tspan, xy0, opt);

figure
subplot(2,1,1)
grid on
hold on
plot(tsol, ysol(:,1).*180/pi)
h = legend('$\beta$');
set(h,'Interpreter','latex')

subplot(2,1,2)
grid on
hold on
plot(tsol, ysol(:,2))
h = legend('$\dot{\beta}$');
set(h,'Interpreter','latex')