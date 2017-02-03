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
Parameter m1 m2 kd l

%%
% Transformation from System I to System c1
T21 = imf.Transformation(I, c1, imf.RotationMatrix.T2(q1), imf.Vector([0;0;-l], c1));

%%
m = imf.Model(I);
m.gravity = imf.Gravity(g, I);
m.Add(imf.Body('b1', m1, imf.PositionVector([sin(q1)*l,0,cos(q1)*l]', I)));
m.Add(imf.Body('b2', m2, imf.PositionVector([sin(q2)*l,0,cos(q2)*l]', c1)));

m.Add(imf.Moment('Md1', imf.Vector([0;-kd*dot(q1);0], I), imf.Vector([0;q1;0], I)));
m.Add(imf.Moment('Md2', imf.Vector([0;-kd*dot(q2);0], c1), imf.Vector([0;q2;0], c1)));

%%
model = m.Compile();
model.matlabFunction('model');

%%
m1v = 2;
m2v = 2;
lv = 0.5;
kdv = 0.1;

xy0 = [pi/4 pi/4 0 0]';
xyp0 = [0 0 0 0];
tspan = linspace(0,20,500);

opt = odeset('mass',@(t,x) modelM(t, x, [m1v;m2v;kdv;lv]), 'RelTol', 10^(-9), 'AbsTol', 10^(-9), 'InitialSlope', xyp0);
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

%%

g = norm(g);
syms ls m1s m2s kds real
syms q1s(t) q2s(t)
r1 = [ls*sin(q1s); 0; ls*cos(q1s)];
r2 = r1 + [ls*sin(q2s + q1s); 0; ls*cos(q2s + q1s)];
y1 = [0;q1s;0];
y2 = [0;q2s;0];
ddr1 = diff(r1, t, t);
ddr2 = diff(r2, t, t);

qs = [q1s(t); q2s(t)];

f = formula(r1);
for i=1:size(f, 1)
    for j=1:size(qs, 1)
        Jr1(i,j) = functionalDerivative(f(i), qs(j));
    end
end

f = formula(r2);
for i=1:size(f, 1)
    for j=1:size(qs, 1)
        Jr2(i,j) = functionalDerivative(f(i), qs(j));
    end   
end

f = formula(y1);
for i=1:size(f, 1)
    for j=1:size(qs, 1)
        Jy1(i,j) = functionalDerivative(f(i), qs(j));
    end
end

f = formula(y2);
for i=1:size(f, 1)
    for j=1:size(qs, 1)
        Jy2(i,j) = functionalDerivative(f(i), qs(j));
    end
end

ex = m1s*Jr1'*ddr1 + m2s*Jr2'*ddr2 - Jr1'*[0;0;m1s*g] - Jr2'*[0;0;m2s*g] - Jy1'*[0;-kds*diff(q1s(t), t);0] - Jy2'*[0;-kds*diff(q2s(t), t);0];
ex = simplify(ex);
ex = subs(ex, [m1s m2s ls kds], [m1v m2v lv kdv]);

[newEqs, newVars] = reduceDifferentialOrder(ex, [q1s q2s]);
[M, F] = massMatrixForm(newEqs, newVars);
odeFunction(M, newVars, 'File', 'validateM');
odeFunction(F, newVars, 'File', 'validateF');

opt = odeset('mass', @validateM, 'RelTol', 10^(-9), 'AbsTol', 10^(-9), 'InitialSlope', xyp0);
[tval,yval] = ode15s(@validateF, tspan, xy0, opt);

figure
grid on
hold on
plot(tsol, yval(:, 1:2))
legend('q1', 'q2')

figure
grid on
hold on
plot(tsol, yval(:, 3:4))
legend('dq1', 'dq2')

%%
if all(tval == tsol) && all(all(abs(yval-ysol) < 1e-6))
    disp('Test ran successfully.')
else
    error('Test failed.')
end