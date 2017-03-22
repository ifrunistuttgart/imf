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

%    This File contains modified source code from the ACADO Toolkit.

%
%  Licence:
%    This file is part of ACADO Toolkit  - (http://www.acadotoolkit.org/)
%
%    ACADO Toolkit -- A Toolkit for Automatic Control and Dynamic Optimization.
%    Copyright (C) 2008-2009 by Boris Houska and Hans Joachim Ferreau, K.U.Leuven.
%    Developed within the Optimization in Engineering Center (OPTEC) under
%    supervision of Moritz Diehl. All rights reserved.
%
%    ACADO Toolkit is free software; you can redistribute it and/or
%    modify it under the terms of the GNU Lesser General Public
%    License as published by the Free Software Foundation; either
%    version 3 of the License, or (at your option) any later version.
%
%    ACADO Toolkit is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%    Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public
%    License along with ACADO Toolkit; if not, write to the Free Software
%    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
%
%    Author: David Ariens, Rien Quirynen
%    Date: 2012

classdef IMFHelper < handle
    properties (SetAccess='protected')
        %setVariables
        x = {};     % generalized coordinate
        dx = {};    % diff generalized coordinate
        ddx = {};   % 2nd diff generalized coordinate
        var = {};   % variables
        param = {}; % parameters
        cs = {};    % coordinate systems
    end
    
    methods
        function obj = IMFHelper(varargin)

        end
        
        % Add differential state
        function addX(obj, set)
            
            for i=1:length(obj.x)
                if (strcmp(obj.x{i}.name, set.name))
                   error('The differential state you are trying to add already exists.'); 
                end
            end
            
            obj.x{length(obj.x)+1} = set;
        end
        function clearX(obj)
            obj.x = {};
        end
        
        % Add differential state derivative
        function addDX(obj, set)
            
            if(~isa(set, 'imf.GeneralizedCoordinate'))
                error('ERROR: A generalized coordinate derivative must be created using an existing generalized coordinate.');
            end
            foundX = 0;
            for i = 1:length(obj.x)
                if (strcmp(obj.x{i}.name, set.name))
                   foundX = 1;
                end
            end
            if ~foundX
                error('The generalized coordinate derivative, you are trying to add, has no corresponding generalized coordinate.');
            end
            foundDX = 0;
            for i = 1:length(obj.dx)
                if (strcmp(obj.dx{i}.name, set.name))
                   foundDX = 1;
                end
            end
            
            if ~foundDX
                obj.dx{length(obj.dx)+1} = set;
            end
        end        
        function clearDX(obj)
            obj.dx = {};
        end
        
        % Add second order differential state derivative
        function addDDX(obj, set)
            
            if(~isa(set, 'imf.GeneralizedCoordinate'))
                error('ERROR: A generalized coordinate derivative must be created using an existing generalized coordinate.');
            end
            foundX = 0;
            for i = 1:length(obj.x)
                if (strcmp(obj.x{i}.name, set.name))
                   foundX = 1;
                end
            end
            if ~foundX
                error('The generalized coordinate second order derivative, you are trying to add, has no corresponding generalized coordinate.');
            end
            
            foundDX = 0;
            for i = 1:length(obj.dx)
                if (strcmp(obj.dx{i}.name, set.name))
                   foundDX = 1;
                end
            end
            if ~foundDX
                obj.dx{length(obj.dx)+1} = set;
            end
            
            foundDDX = 0;
            for i = 1:length(obj.ddx)
                if (strcmp(obj.ddx{i}.name, set.name))
                   foundDDX = 1;
                end
            end
            if ~foundDDX
                obj.ddx{length(obj.ddx)+1} = set;
            end
        end        
        function clearDDX(obj)
            obj.ddx = {};
        end
        
        % Add parameter
        function addParam(obj, set)
            
            for i=1:length(obj.param)
                if (strcmp(obj.param{i}.name, set.name))
                   error('The parameter you are trying to add already exists.'); 
                end
            end
            
            obj.param{length(obj.param)+1} = set;
        end
        function clearParam(obj)
            obj.param = {};
        end
        
        % Add parameter
        function addCS(obj, set)
            
            for i=1:length(obj.cs)
                if (strcmp(obj.cs{i}.name, set.name))
                   error('The coordinate system you are trying to add already exists.'); 
                end
            end
            
            obj.cs{length(obj.cs)+1} = set;
        end
        function clearCS(obj)
            obj.param = {};
        end
    end
    
end