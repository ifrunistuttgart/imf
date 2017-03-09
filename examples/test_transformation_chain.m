%%
init
BEGIN_IMF

GeneralizedCoordinate q1 q2
CoordinateSystem I c1 c2

%%
% Transformation from System I to System c1
imf.Transformation(I, c1, imf.RotationMatrix.T3(q1), imf.Vector([0;0;5], c1));
imf.Transformation(c1, c2, imf.RotationMatrix.T2(q2), imf.Vector([0;0;5], c2));

%%
T = getTransformation(I, c2);
T32 = [ cos(q1)*cos(q2), cos(q2)*sin(q1), -sin(q2);
        -sin(q1),        cos(q1),         0;
        cos(q1)*sin(q2), sin(q1)*sin(q2), cos(q2)];
[m,n] = size(T.rotation);
Tf = T.rotation;

if Tf ~= T32
    error('FAILED: transformation rotation test.');
end

%%
r = imf.PositionVector([1;1;0], I);
rcf = r.In(c1);
rcs = [cos(q1)*cos(q2) + cos(q2)*sin(q1);
       cos(q1) - sin(q1);
       cos(q1)*sin(q2) + sin(q1)*sin(q2) + 5];
if rcf ~= rcs
    error('FAILED: position vector transformation.');
end

%%
disp('Test ran successfully.')