clear all
close all
clc

%%
g = [0 0 9.81]';
r1 = [0.6 0.6 0]';
r2 = [0 0 0.1]';
r3 = [0 0.1 0]';
m1 = 0.1;

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

GeneralizedCoordinate x1 x2 x3
CoordinateSystem c1 c2 c3 c4

% Transformation from System 2 to System 1
T12 = imf.Transformation(c2,c1);
T12.rotation = imf.DCM.T1(x1);
% The offset of the origin of System 2 to System 1
% with regards to System 1
T12.offset = imf.Vector(r1);

T23 = imf.Transformation(c3,c2);
T23.rotation = imf.DCM.T3(x3);
T23.offset = imf.Vector(r2);

T34 = imf.Transformation(c4,c3);
T34.rotation = imf.DCM.T2(x2);
T34.offset = imf.Vector(r3);

%%
m = imf.Model();
m.gravity = g;
m.Add(imf.Force([1 2 3]', [1,0,0]', c3));
m.Add(imf.Mass(m1, [1,0,0]', c3));

%%
m.Compile(c1);