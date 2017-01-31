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

GeneralizedCoordinate q1 q2 q3 q4
CoordinateSystem I c1
Parameter m1 l ri ra h

T21 = imf.Transformation(I, c1, imf.RotationMatrix.T3(q1), imf.RotationMatrix.T2(q2), imf.RotationMatrix.T1(q3), imf.Vector([-l;0;0], c1));

%%
m = imf.Model(I);

Th = m1/12 * diag([3*(ra^2+ri^2)+h^2,  6*(ra^2+ri^2), 3*(ra^2+ri^2)+h^2]);
m.Add(imf.Body('b1', m1, imf.PositionVector([0;0;0], c1), imf.Inertia(Th, c1), imf.AttitudeVector([0;q4;0], c1)));

%%
model = m.Compile();
model.matlabFunction('model');

%%
m1v = 2;
lv = 4;
riv = 0.8;
rav = 0.9;
hv = 0.1;

xy0 = [0 0 0 0 10 0 0 60];
xyp0 = [0 0 0 0 0 0];
tspan = linspace(0,5,1000);

opt = odeset('mass',@(t,x) modelM(t, x, [m1v; lv; riv; rav; hv]), 'RelTol', 10^(-9), 'AbsTol', 10^(-9), 'InitialSlope', xyp0);
[tsol,ysol] = ode45(@(t,x) modelF(t, x, [m1v; lv; riv; rav; hv]), tspan, xy0, opt);

figure
grid on
hold on
plot(tsol, ysol(:,1:4))
legend('q1', 'q2', 'q3', 'q4');

figure
grid on
hold on
plot(tsol, ysol(:,5:8))
legend('dq1', 'dq2', 'dq3', 'dq4');

%% Test conservation of angular momentum
syms sra sri sh sm1 sl real
syms sq1(t) sq2(t) sq3(t) sq4(t)

Th = sm1/12 * diag([3*(sra^2+sri^2)+sh^2,  6*(sra^2+sri^2), 3*(sra^2+sri^2)+sh^2]);

ww = [0;0;diff(sq1,t)] + T3(sq1)'*[0;diff(sq2,t);0] +  T2(sq2)'*T3(sq1)'*[diff(sq3,t);0;0] + T3(sq1)'*T2(sq2)'*T1(sq3)'*[0;diff(sq4,t);0];

r = T3(sq1)'*T2(sq2)'*T1(sq3)' * [sl;0;0];
dr = diff(r, t);

Lw = T3(sq1)'*T2(sq2)'*T1(sq3)'*Th*T1(sq3)*T2(sq2)*T3(sq1) * ww;
L = Lw + cross(r, sm1*dr);

L = subs(L, [sra sri sh sm1 sl], [rav riv hv m1v lv]);
L = subs(L, [conj(sq1(t)) conj(sq2(t)) conj(sq3(t)) conj(sq4(t))], [sq1(t) sq2(t) sq3(t) sq4(t)]);
L = subs(L, [diff(conj(sq1(t)),t) diff(conj(sq2(t)),t) diff(conj(sq3(t)),t) diff(conj(sq4(t)),t)], [diff(sq1(t),t) diff(sq2(t),t) diff(sq3(t),t) diff(sq4(t),t)]);
L = subs(L, [conj(diff(sq1(t),t)) conj(diff(sq2(t),t)) conj(diff(sq3(t),t)) conj(diff(sq4(t),t))], [diff(sq1(t),t) diff(sq2(t),t) diff(sq3(t),t) diff(sq3(t),t)]);

%%
Lvstart = eval(subs(L, [sq1(t) sq2(t) sq3(t) sq4(t) diff(sq1(t),t) diff(sq2(t),t) diff(sq3(t),t) diff(sq4(t),t)], ysol(1,:)));
Lvend = eval(subs(L, [sq1(t) sq2(t) sq3(t) sq4(t) diff(sq1(t),t) diff(sq2(t),t) diff(sq3(t),t) diff(sq4(t),t)], ysol(end,:)));

%%
if all(abs(Lvstart-Lvend) < 1e-3)
    disp('Test ran successfully.')
else
    error('Test failed.')
end
