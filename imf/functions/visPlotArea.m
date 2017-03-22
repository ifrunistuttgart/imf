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

function handles = visPlotArea( fh, showGrid, revZ, axisv, viewv )

if isempty(fh) || ~ishandle(fh)
    error('Provide a vailid figure handle.')
end

if isnan(viewv)
    viewv = [30 30];
end

if revZ
    viewv = [0 180] + viewv;
end

if isnan(axisv)
    axisv = [-10 10 -10 10 -10 10];
end

figure(fh)
if showGrid
    handles(1) = subplot(2,2,1);
    grid on
    hold on
    xlabel('y')
    ylabel('z')
    set(handles(1),'ydir','reverse')
    handles(1).XAxisLocation = 'origin';
    handles(1).YAxisLocation = 'origin';
    axis(axisv([3 4 5 6]))
    
    handles(2) = subplot(2,2,2);
    grid on
    hold on
    xlabel('x')
    ylabel('z')
    set(handles(2),'ydir','reverse')
    set(handles(2),'xdir','reverse')
    handles(2).XAxisLocation = 'origin';
    handles(2).YAxisLocation = 'origin';
    axis(axisv([1 2 5 6]))
    
    handles(3) = subplot(2,2,3);
    grid on
    hold on
    xlabel('y')
    ylabel('x')
    handles(3).XAxisLocation = 'origin';
    handles(3).YAxisLocation = 'origin';
    axis(axisv([3 4 1 2]))
    
    handles(4) = subplot(2,2,4);
    grid on
    hold on
    xlabel('x')
    ylabel('y')
    zlabel('z')
    view(viewv)
    ah = handles(4);
else
    handles(1) = gca;
end

grid on
hold on
axis vis3d
xlabel('x')
ylabel('y')
zlabel('z')
view(viewv)
axis(axisv)

end