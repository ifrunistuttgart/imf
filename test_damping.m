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
T21 = imf.Transformation(I, c1, imf.RotationMatrix.T2(q1), imf.Vector([0;0;-l], c1));

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

%%

g = norm(g);
syms l m1 m2 t kd real
syms q1(t) q2(t)
r1 = [l*sin(q1); 0; l*cos(q1)];
r2 = r1 + [l*sin(q2+q1); 0; l*cos(q2+q1)];
y1 = [0;q1;0];
y2 = [0;q2;0];
ddr1 = diff(r1, t, t);
ddr2 = diff(r2, t, t);

q = [q1(t); q2(t)];

f = formula(r1);
for i=1:size(f, 1)
    for j=1:size(q, 1)
        Jr1(i,j) = functionalDerivative(f(i), q(j));
    end
end

f = formula(r2);
for i=1:size(f, 1)
    for j=1:size(q, 1)
        Jr2(i,j) = functionalDerivative(f(i), q(j));
    end   
end

f = formula(y1);
for i=1:size(f, 1)
    for j=1:size(q, 1)
        Jy1(i,j) = functionalDerivative(f(i), q(j));
    end
end

f = formula(y2);
for i=1:size(f, 1)
    for j=1:size(q, 1)
        Jy2(i,j) = functionalDerivative(f(i), q(j));
    end
end

ex = m1*Jr1'*ddr1 + m2*Jr2'*ddr2 - Jr1'*[0;0;m1*g] - Jr2'*[0;0;m2*g] - Jy1'*[0;-kd*diff(q1(t), 1);0] - Jy2'*[0;-kd*diff(q2(t), 1);0];
ex = simplify(ex);
ex = subs(ex, [m1 m2 l kd], [m1v m2v lv kdv]);

[newEqs, newVars] = reduceDifferentialOrder(ex, [q1 q2]);
[M, F] = massMatrixForm(newEqs, newVars);
odeFunction(M, newVars, 'File', 'validateM');
odeFunction(F, newVars, 'File', 'validateF');

opt = odeset('mass', @validateM, 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
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
if all(tval == tsol) && all(all(abs(yval-ysol) < 1e-5))
    disp('Test ran successfully.')
else
    error('Test failed.')
end