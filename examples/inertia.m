init
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
syms ras ris hs m1s ls real
syms q1s(t) q2s(t) q3s(t) q4s(t)

Th = m1s/12 * diag([3*(ras^2+ris^2)+hs^2,  6*(ras^2+ris^2), 3*(ras^2+ris^2)+hs^2]);

ww = [0;0;diff(q1s,t)] + T3(q1s)'*[0;diff(q2s,t);0] +  T2(q2s)'*T3(q1s)'*[diff(q3s,t);0;0] + T3(q1s)'*T2(q2s)'*T1(q3s)'*[0;diff(q4s,t);0];

r = T3(q1s)'*T2(q2s)'*T1(q3s)' * [ls;0;0];
dr = diff(r, t);

Lw = T3(q1s)'*T2(q2s)'*T1(q3s)'*Th*T1(q3s)*T2(q2s)*T3(q1s) * ww;
L = Lw + cross(r, m1s*dr);

L = subs(L, [ras ris hs m1s ls], [rav riv hv m1v lv]);
L = subs(L, [conj(q1s(t)) conj(q2s(t)) conj(q3s(t)) conj(q4s(t))], [q1s(t) q2s(t) q3s(t) q4s(t)]);
L = subs(L, [diff(conj(q1s(t)),t) diff(conj(q2s(t)),t) diff(conj(q3s(t)),t) diff(conj(q4s(t)),t)], [diff(q1s(t),t) diff(q2s(t),t) diff(q3s(t),t) diff(q4s(t),t)]);
L = subs(L, [conj(diff(q1s(t),t)) conj(diff(q2s(t),t)) conj(diff(q3s(t),t)) conj(diff(q4s(t),t))], [diff(q1s(t),t) diff(q2s(t),t) diff(q3s(t),t) diff(q3s(t),t)]);

%%
Lvstart = eval(subs(L, [q1s(t) q2s(t) q3s(t) q4s(t) diff(q1s(t),t) diff(q2s(t),t) diff(q3s(t),t) diff(q4s(t),t)], ysol(1,:)));
Lvend = eval(subs(L, [q1s(t) q2s(t) q3s(t) q4s(t) diff(q1s(t),t) diff(q2s(t),t) diff(q3s(t),t) diff(q4s(t),t)], ysol(end,:)));

%%
END_IMF

%%
if all(abs(Lvstart-Lvend) < 1e-3)
    disp('Test ran successfully.')
else
    error('Test failed.')
end
