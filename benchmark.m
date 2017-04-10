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

GeneralizedCoordinate psi theta phi x y z th1
CoordinateSystem I f t1
Parameter Fa1 Ma1 Mt1 O1

%%
lx = 0.3; % [m] length of x-direction thruss
ly = 0.3; % [m] length of y-direction thruss
dti = 0.02; % [m] inner diameter thruss
dto = 0.022; % [m] outer diameter thruss
rho1 = 0.106 / (dto^2/4 - dti^2/4)*pi * 1; % [kg/m^4] density of thruss
mt = 0.08; % [kg] mass of tilt mechanism
me = 0.1; % [kg] mass of engine
lte = 0.01; % [m] distance tilt hinge to engine
he = 0.02; % [m] height engine
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
toc
%%
disp('Time for Model')
tic
model = imf.Model(I);
model.gravity = imf.Gravity([0; 0; 9.81], I);
model.Add(imf.Body('trx', m(1), imf.PositionVector(r(:,1) - rs, f)));

model.Add(imf.Body('tm1', m(4), imf.PositionVector([0;0;0], t1)));

model.Add(imf.Force('Fa1', imf.Vector([0;0;Fa1], t1), imf.PositionVector([0;0;-he], t1)));

model.Add(imf.Moment('Ma1', imf.Vector([0;0;Ma1], t1), imf.AttitudeVector([0;0;1], t1), imf.PositionVector([0;0;-he], t1)));
toc
%%
disp('Time for Compile')
tic
sdeq = model.Compile();
toc
%%
disp('Time for Matlab Function')
tic
model.matlabFunction('benchmark');
toc
%%

Fa1v = 1;
Ma1v = 1;
Mt1v = 0;
O1 = 1;

xy0 = [0 0 0 0 0 0 0 0 0 0 0 0 0 0];
tspan = linspace(0,7,100);

disp('Time for Simulation')
tic
%opt = odeset('mass',@(t,x) benchmarkM(t, x, [Fa1v; Ma1v; Mt1v; O1]));
[tsol,ysol] = ode45(@(t,x) benchmarkM(t, x, [Fa1v; Ma1v; Mt1v; O1]) \ benchmarkF(t, x, [Fa1v; Ma1v; Mt1v; O1]), tspan, xy0);
toc

figure
grid on
hold on
plot(tsol, ysol)