close all
clear all
clc

%%
if ~exist('BEGIN_IMF','file'),
    addpath( genpath([pwd filesep 'imf']) )
    if ~exist('BEGIN_IMF','file'),
        error('Unable to find the BEGIN_IMF function. Make sure to have' + ...
            'the library as a sub folder of the current working directory.');
    end
end

%%

%%
BEGIN_IMF

GeneralizedCoordinate psi theta phi x y z th1 th2 th3 th4
CoordinateSystem I f t1 t2 t3 t4
Parameter Fa1 Ma1 Mt1 Fa2 Ma2 Mt2 Fa3 Ma3 Mt3 Fa4 Ma4 Mt4

%%
lx = 0.3; % [m] length of x-direction thruss
ly = 0.3; % [m] length of y-direction thruss
dti = 0.02; % [m] inner diameter thruss
dto = 0.022; % [m] outer diameter thruss
rho1 = 0.106 / (dto^2/4 - dti^2/4)*pi * 1; % [kg/m^4] density of thruss
mt = 0.08; % [kg] mass of tilt mechanism
me = 0.1; % [kg] mass of engine
mp = 0.08; % [kg] mass of propeller
lte = 0.01; % [m] distance tilt hinge to engine
he = 0.02; % [m] height engine
hp = 0.01; % [m] height propeller
mbc = 0.4; % [kg] mass of board computer

%%
m(1) = lx * (dto^2/4 - dti^2/4)*pi * rho1;
m(2) = ly * (dto^2/4 - dti^2/4)*pi * rho1;
m(3) = m(2);

m(4) = mt;
m(5) = mt;
m(6) = mt;
m(7) = mt;

m(8) = me;
m(9) = me;
m(10) = me;
m(11) = me;

m(12) = mp;
m(13) = mp;
m(14) = mp;
m(15) = mp;

r(:,1) = [0;0;0];
r(:,2) = [lx/2;0;0];
r(:,3) = [-lx/2;0;0];

r(:,4) = [lx/2;ly/2;0];
r(:,5) = [lx/2;-ly/2;0];
r(:,6) = [-lx/2;-ly/2;0];
r(:,7) = [-lx/2;ly/2;0];

r(:,8) = r(:,4) + [0;lte;-he];
r(:,9) = r(:,5) + [0;-lte;-he];
r(:,10) = r(:,6) + [0;-lte;-he];
r(:,11) = r(:,7) + [0;lte;-he];

r(:,12) = r(:,8) + [0;0;-hp];
r(:,13) = r(:,9) + [0;0;-hp];
r(:,14) = r(:,10) + [0;0;-hp];
r(:,15) = r(:,11) + [0;0;-hp];

M = 0;
rs = [0;0;0];
for i=1:length(m)
    M = M + m(i);
    rs = rs + m(i) * r(:,i);
end
rs = 1/M * rs;

%%
disp('Time for Transformation')
tic
imf.Transformation(I, f, imf.RotationMatrix.T3(psi), imf.RotationMatrix.T2(theta), imf.RotationMatrix.T1(phi), imf.Vector([x;y;z], I));
imf.Transformation(f, t1, imf.RotationMatrix.T2(th1), imf.Vector(r(:,4) - rs, f));
imf.Transformation(f, t2, imf.RotationMatrix.T2(th2), imf.Vector(r(:,5) - rs, f));
imf.Transformation(f, t3, imf.RotationMatrix.T2(th3), imf.Vector(r(:,6) - rs, f));
imf.Transformation(f, t4, imf.RotationMatrix.T2(th4), imf.Vector(r(:,7) - rs, f));
toc
%%
disp('Time for Model')
tic
model = imf.Model(I);
model.gravity = imf.Gravity([0; 0; 9.81], I);
model.Add(imf.Body('trx', m(1), imf.PositionVector(r(:,1) - rs, f)));
model.Add(imf.Body('try1', m(2), imf.PositionVector(r(:,2) - rs, f)));
model.Add(imf.Body('try2', m(3), imf.PositionVector(r(:,3) - rs, f)));

p10 = imf.PositionVector([0;0;0], t1);
p1e = imf.PositionVector([0;0;-he], t1);
model.Add(imf.Body('tm1', m(4), p10)); % tilt mechanism
model.Add(imf.Body('e1', m(8), p1e)); % engine
model.Add(imf.Body('p1', m(12), p1e)); % propeller
model.Add(imf.Force('Fa1', imf.Vector([0;0;Fa1], t1), p1e)); % aerodynamic force
model.Add(imf.Moment('Ma1', imf.Vector([0;0;Ma1], t1), imf.AttitudeVector([0;0;1], t1), p1e)); % aerodynamic moment
model.Add(imf.Moment('Mt1p', imf.Vector([0;Mt1;0], t1), imf.AngularVelocity([d(phi);d(theta);d(psi)], f), p10)); % tilt moment on main body
model.Add(imf.Moment('Mt1m', imf.Vector([0;-Mt1;0], t1), imf.AngularVelocity([d(phi);d(theta)+d(th1);d(psi)], f), p10)); % tilt moment on tilt body

p20 = imf.PositionVector([0;0;0], t2);
p2e = imf.PositionVector([0;0;-he], t2);
model.Add(imf.Body('tm2', m(5), p20)); % tilt mechanism
model.Add(imf.Body('e2', m(9), p2e)); % engine
model.Add(imf.Body('p2', m(13), p2e)); % propeller
model.Add(imf.Force('Fa2', imf.Vector([0;0;Fa2], t2), p2e)); % aerodynamic force
model.Add(imf.Moment('Ma2', imf.Vector([0;0;Ma2], t2), imf.AttitudeVector([0;0;1], t2), p2e)); % aerodynamic moment
model.Add(imf.Moment('Mt2p', imf.Vector([0;Mt2;0], t2), imf.AngularVelocity([d(phi);d(theta);d(psi)], f), p20)); % tilt moment on main body
model.Add(imf.Moment('Mt2m', imf.Vector([0;-Mt2;0], t2), imf.AngularVelocity([d(phi);d(theta)+d(th1);d(psi)], f), p20)); % tilt moment on tilt body

p30 = imf.PositionVector([0;0;0], t3);
p3e = imf.PositionVector([0;0;-he], t3);
model.Add(imf.Body('tm3', m(6), p30)); % tilt mechanism
model.Add(imf.Body('e3', m(10), p3e)); % engine
model.Add(imf.Body('p3', m(14), p3e)); % propeller
model.Add(imf.Force('Fa3', imf.Vector([0;0;Fa3], t3), p3e)); % aerodynamic force
model.Add(imf.Moment('Ma3', imf.Vector([0;0;Ma3], t3), imf.AttitudeVector([0;0;1], t3), p3e)); % aerodynamic moment
model.Add(imf.Moment('Mt3p', imf.Vector([0;Mt3;0], t3), imf.AngularVelocity([d(phi);d(theta);d(psi)], f), p30)); % tilt moment on main body
model.Add(imf.Moment('Mt3m', imf.Vector([0;-Mt3;0], t3), imf.AngularVelocity([d(phi);d(theta)+d(th1);d(psi)], f), p30)); % tilt moment on tilt body

p40 = imf.PositionVector([0;0;0], t4);
p4e = imf.PositionVector([0;0;-he], t4);
model.Add(imf.Body('tm4', m(7), p40)); % tilt mechanism
model.Add(imf.Body('e4', m(11), p4e)); % engine
model.Add(imf.Body('p4', m(15), p4e)); % propeller
model.Add(imf.Force('Fa4', imf.Vector([0;0;Fa4], t4), p4e)); % aerodynamic force
model.Add(imf.Moment('Ma4', imf.Vector([0;0;Ma4], t4), imf.AttitudeVector([0;0;1], t4), p4e)); % aerodynamic moment
model.Add(imf.Moment('Mt4p', imf.Vector([0;Mt4;0], t4), imf.AngularVelocity([d(phi);d(theta);d(psi)], f), p40)); % tilt moment on main body
model.Add(imf.Moment('Mt4m', imf.Vector([0;-Mt4;0], t4), imf.AngularVelocity([d(phi);d(theta)+d(th1);d(psi)], f), p40)); % tilt moment on tilt body
toc
%%
disp('Time for Compile')
tic
sdeq = model.Compile();
toc
%%
disp('Time for Matlab Function')
for level=0:5
    disp(['Level ' num2str(level)]);
    tic; model.matlabFunction(['benchmark' num2str(level)], level); toc
end
%%
x = randn(20, 1);
p = randn(12, 1);
t = randn(1);

f = [];
m = [];

disp('Time to run Matlab Function')
for level=0:5
    funF = str2func(['@benchmark' num2str(level) 'F']);
    funM = str2func(['@benchmark' num2str(level) 'M']);
    disp(['Level ' num2str(level)]);
    tic; f{level+1} = funF(t,x,p); toc
    tic; m{level+1} = funM(t,x,p); toc
end
%%
for level=1:5
    if ~all(f{1} == f{level+1})
        error(['Optimized right hand side solution for level ' num2str(level) ' differs!']);
    end
    
    if ~all(all(m{1} == m{level+1}))
        error(['Optimized mass matrix solution for level ' num2str(level) ' differs!']);
    end
end

%%
return;
Fa1v = 1;
Ma1v = 1;
Mt1v = 1;
O1v = 1;

Fa2v = 1;
Ma2v = 1;
Mt2v = 1;
O2v = 1;

Fa3v = 1;
Ma3v = 1;
Mt3v = 1;
O3v = 1;

Fa4v = 1;
Ma4v = 1;
Mt4v = 1;
O4v = 1;

xy0 = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
xyp0 = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
tspan = linspace(0,1,10);

disp('Time for Simulation')
tic
opt = odeset('mass',@(t,x) benchmarkM(t, x, [Fa1v; Ma1v; Mt1v; O1v; Fa2v; Ma2v; Mt2v; O2v; Fa3v; Ma3v; Mt3v; O3v; Fa4v; Ma4v; Mt4v; O4v]), 'RelTol', 10^(-6), 'AbsTol', 10^(-6), 'InitialSlope', xyp0);
[tsol,ysol] = ode15s(@(t,x) benchmarkF(t, x, [Fa1v; Ma1v; Mt1v; O1v; Fa2v; Ma2v; Mt2v; O2v; Fa3v; Ma3v; Mt3v; O3v; Fa4v; Ma4v; Mt4v; O4v]), tspan, xy0, opt);
toc

figure
grid on
hold on
plot(tsol, ysol)