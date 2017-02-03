init
BEGIN_IMF

g = [0 0 9.81]';

GeneralizedCoordinate q1 q2
CoordinateSystem I c1
Parameter m1 m2 l

%%
% Transformation from System I to System c1
T21 = imf.Transformation(I, c1, imf.RotationMatrix.T2(q1), imf.Vector([0;0;-l], c1));

%%
m = imf.Model(I);
m.gravity = imf.Gravity(g, I);
m.Add(imf.Body('m1', m1, imf.PositionVector([sin(q1)*l,0,cos(q1)*l]', I)));
m.Add(imf.Body('m2', m2, imf.PositionVector([sin(q2)*l,0,cos(q2)*l]', c1)));

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

%%

g = norm(g);
syms l m1 m2 t real
syms q1(t) q2(t)
r1 = [l*sin(q1); 0; l*cos(q1)];
r2 = r1 + [l*sin(q2+q1); 0; l*cos(q2+q1)];
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

ex = m1*Jr1'*ddr1 + m2*Jr2'*ddr2 - Jr1'*[0;0;m1*g] - Jr2'*[0;0;m2*g];
ex = simplify(ex);
ex = subs(ex, [m1 m2 l], [m1v m2v lv]);

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
END_IMF

%%
if all(tval == tsol) && all(all(abs(yval-ysol) < 1e-5))
    disp('Test ran successfully.')
else
    error('Test failed.')
end