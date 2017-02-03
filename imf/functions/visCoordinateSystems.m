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

function handle = visCoordinateSystems( ah, name, origin, x, y, z )
handle(1) = plot3(ah, origin(1), origin(2), origin(3), '.k');
handle(2) = plot3(ah, [origin(1) x(1)], [origin(2) x(2)], [origin(3) x(3)], '-g');
handle(3) = plot3(ah, [origin(1) y(1)], [origin(2) y(2)], [origin(3) y(3)], '-r');
handle(4) = plot3(ah, [origin(1) z(1)], [origin(2) z(2)], [origin(3) z(3)], '-b');
handle(5) = text(ah, origin(1)-.1, origin(2)-.1, origin(3)-.1, name);
end

