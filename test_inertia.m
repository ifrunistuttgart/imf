clear all
close all

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

GeneralizedCoordinate q1 q2 q3
CoordinateSystem I c1
Parameter m1 l ri ra h

T21 = imf.Transformation(I, c1, imf.RotationMatrix.T3(q1), imf.RotationMatrix.T1(q2), imf.Vector([-l;0;0], c1));

%%
m = imf.Model(I);

Th = m1/12 * diag([3*(ra^2+ri^2)+h^2,  6*(ra^2+ri^2), 3*(ra^2+ri^2)+h^2]);
m.Add(imf.Body('b1', m1, imf.PositionVector([0;0;0], c1), imf.Inertia(Th, c1), imf.AttitudeVector([0;q3;0], c1)));

%%
model = m.Compile();
model.matlabFunction('model');

%%
m1v = 2;
lv = 4;
riv = 0.8;
rav = 0.9;
hv = 0.1;

xy0 = [0 0 0 10 0 30];
xyp0 = [0 0 0 0 0 0];
tspan = linspace(0,5,1000);

opt = odeset('mass',@(t,x) modelM(t, x, [m1v; lv; riv; rav; hv]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) modelF(t, x, [m1v; lv; riv; rav; hv]), tspan, xy0, opt);

figure
grid on
hold on
plot(tsol, ysol(:,1:3))
legend('q1', 'q2', 'q3');

figure
grid on
hold on
plot(tsol, ysol(:,4:6))
legend('dq1', 'dq2', 'dq3');

%%
syms ra ri h m1 l real
syms q1(t) q2(t) q3(t)

Th = m1/12 * diag([3*(ra^2+ri^2)+h^2,  6*(ra^2+ri^2), 3*(ra^2+ri^2)+h^2]);
ww = [0;0;diff(q1,t)] + T3(q1)'*[diff(q2,t);0;0] + T3(q1)'*T1(q2)'*[0;diff(q3,t);0];

r = T3(q1)'*T1(q2)' * [l;0;0];
dr = diff(r, t);

Lw = T3(q1)'*T1(q2)'*Th*T1(q2)*T3(q1) * ww;
L = Lw + cross(r, m1*dr);

L = subs(L, [ra ri h m1 l], [rav riv hv m1v lv]);
L = subs(L, [conj(q1(t)) conj(q2(t)) conj(q3(t))], [q1(t) q2(t) q3(t)]);
L = subs(L, [diff(conj(q1(t)),t) diff(conj(q2(t)),t) diff(conj(q3(t)),t)], [diff(q1(t),t) diff(q2(t),t) diff(q3(t),t)]);
L = subs(L, [conj(diff(q1(t),t)) conj(diff(q2(t),t)) conj(diff(q3(t),t))], [diff(q1(t),t) diff(q2(t),t) diff(q3(t),t)]);

%%
Lv = eval(subs(L, [q1(t) q2(t) q3(t) diff(q1(t),t) diff(q2(t),t) diff(q3(t),t)], ysol(1,:)))
Lvn = norm(Lv)
Lv = eval(subs(L, [q1(t) q2(t) q3(t) diff(q1(t),t) diff(q2(t),t) diff(q3(t),t)], ysol(end,:)))
Lvn = norm(Lv)

%%
figure
grid on
hold on
for i=1:size(ysol, 1)
Lv = eval(subs(L, [q1(t) q2(t) q3(t) diff(q1(t),t) diff(q2(t),t) diff(q3(t),t)], ysol(i,:)));
Lvn = norm(Lv);
plot(tsol(i), Lvn, '.b');
end