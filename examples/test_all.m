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

warning off all

tests = [];
tests{end+1} = 'inertia.m';
tests{end+1} = 'nameclash.m';
tests{end+1} = 'pendulum.m';
tests{end+1} = 'rotation.m';
tests{end+1} = 'spheric.m';
tests{end+1} = 'transformation_formulation.m';
tests{end+1} = 'two_mass_pendulum.m';

for i=1:length(tests)
    try
        disp(['Running ' tests{i} '...']);
        run(tests{i})
    catch 
        error(['Test ' tests{i} ' failed. Aborting.']);
    end
end

disp('Finished running all tests.');

warning on all