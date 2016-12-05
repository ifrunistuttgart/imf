clear all
close all
clc

%%
g = [0 -9.81 0]';
m1 = 0.2;
l = 0.2;

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

GeneralizedCoordinate q1
CoordinateSystem I

%%
m = imf.Model(I);
m.gravity = imf.Gravity(g, I);
m.Add(imf.Mass(m1, [sin(q1)*l,-cos(q1)*l,0]', I));

%%
model = m.Compile();