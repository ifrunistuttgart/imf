%  Licence:
%    This file is part of iFR Modelling Framework  - (http://www.ifr.uni-stuttgart.de)
%
%    IMF -- A framework for modelling dynamic mechanical systems in MATLAB.
%    Copyright (C) 2016-2017 by Pascal Gross <pascal.gross@ifr.uni-stuttgart.de>.
%    Developed within the Flight Mechanics and Controls Lab of the
%    University of Stuttgart. All rights reserved.
%
%    IMF is free software; you can redistribute it and/or
%    modify it under the terms of the GNU Lesser General Public
%    License as published by the Free Software Foundation; either
%    version 3 of the License, or (at your option) any later version.
%
%    IMF is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%    Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public
%    License along with ACADO Toolkit; If not, see <http://www.gnu.org/licenses/>.
%
%    Author: Pascal Gross <pascal.gross@ifr.uni-stuttgart.de>
%    Date: 2017

function handles = vectarrow(ah, str, p0, p1, LineSpec)

alpha = 0.03;
beta = 0.1;

handles = [];

if max(size(p0))==3
    if max(size(p1))==3
        
        p = p1 - p0;
        
        if norm(p) == 0
            return;
        end
        
        o = p / norm(p) * beta;
        
        handles(end+1) = plot3(ah, [p0(1);p1(1) - o(1)],...
            [p0(2);p1(2) - o(2)],...
            [p0(3);p1(3) - o(3)], LineSpec, 'LineWidth', 2);
        
        [hx,hy,hz] = cylinder([1 0]);
        hx = alpha * hx;
        hy = alpha * hy;
        hz = beta * (hz - 1);
        
        T = vrrotvec2mat(vrrotvec([0;0;1], p));
        
        for i=1:size(hx,1)
            for j=1:size(hx,2)
                hp = [hx(i,j); hy(i,j); hz(i,j)];
                hp = T * hp;
                
                
                hx(i,j) = hp(1);
                hy(i,j) = hp(2);
                hz(i,j) = hp(3);
            end
        end
        
        hx = hx + p1(1);
        hy = hy + p1(2);
        hz = hz + p1(3);
        
        handles(end+1) = surf(ah, hx, hy, hz, 'LineStyle', 'none', 'FaceColor', LineSpec);
        
        handles(end+1) = text(ah, p0(1) + 0.5*p(1), ...
            p0(2) + 0.5*p(2), ...
            p0(3) + 0.5*p(3), ...
            str, 'Color',LineSpec);
    else
        error('p0 and p1 must have the same dimension')
    end
else
    error('this function only accepts 3D vector')
end