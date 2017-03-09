%    You should have received a copy of the GNU Lesser General Public
%    License along with ACADO Toolkit; If not, see <http://www.gnu.org/licenses/>.
%
%    Author: Pascal Gross <pascal.gross@ifr.uni-stuttgart.de>
%    Date: 2017

init
BEGIN_IMF

GeneralizedCoordinate q1
CoordinateSystem I c1

%%
% Transformation from System I to System c1
imf.Transformation(I, c1, imf.RotationMatrix.T3(q1), imf.Vector([0;0;5], c1));

%%
T = getTransformation(I, c1);
T3 = [cos(q1)   sin(q1) 0;
    -sin(q1)  cos(q1) 0;
    0         0       1];
[m,n] = size(T.rotation);
Tf = T.rotation;

if Tf ~= T3
    error('FAILED: transformation rotation test.');
end

%%
r = imf.Vector([1;1;0], I);
rcf = r.In(c1);
rcs = [cos(q1)+sin(q1); cos(q1)-sin(q1); 0];

if rcf ~= rcs
    error('FAILED: vector transformation test.');
end

%%
r = imf.Vector([1,1,0], I);
try
    rc = r.In(c1);
catch ex
    if ~strcmp(ex.message, 'ERROR: Invalid imf.Product. Check your dimensions.')
        error('FAILED: wrong dimension test.')
    end
end

END_IMF;

%%
init
BEGIN_IMF

GeneralizedCoordinate q1 q2
CoordinateSystem I c1

%%
% Transformation from System I to System c1
imf.Transformation(I, c1, imf.RotationMatrix.T3(q1), imf.RotationMatrix.T2(q2), imf.Vector([0;0;5], c1));

%%
T = getTransformation(I, c1);
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