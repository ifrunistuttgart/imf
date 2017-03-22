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

%  Licence:
%    This file is part of ACADO Toolkit  - (http://www.acadotoolkit.org/)
%
%    ACADO Toolkit -- A Toolkit for Automatic Disturbance and Dynamic Optimization.
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
%    Date: 2009-2012
%
classdef DoubleConstant < imf.Operator
    properties(SetAccess='private')
        val;
        callByValue = 0;
    end
    
    methods
        function obj = DoubleConstant(val)
            if nargin > 0
                global IMF_;
                
                if (isa(val, 'numeric'))
                    
                    obj.callByValue = 1;
                    obj.val = val;
                    if val == 0
                        obj.zero = 1;
                    elseif val == 1
                        obj.one = 1;
                    end
                    obj.name = num2str(val);
                    
                else
                    error('DoubleConstant expects a numeric value');
                end
                obj.singleTerm = 1;
            end
        end
        
        function out = copy(obj)
            out = imf.DoubleConstant(obj.val);
        end
        
        function s = toString(obj)
            % toString is used in epxressions (eg 2 + x -> DoubleConstant +
            % DifferentialState)
            global IMF_;
            
            if obj.callByValue
                if obj.val < 0
                    s = ['(' num2str(obj.val) ')'];
                else
                    s = num2str(obj.val);
                end
            else
                s = obj.name;
            end
            
        end
        
        function jac = jacobian(obj, var)
            if ~isvector(obj)
                error('A jacobian can only be computed of a vector function.');
            end
            jac = zeros(length(obj), length(var));
        end
        
        function setToAbsoluteValue(obj)
            obj.val = abs(obj.val);
            obj.name = num2str(obj.val);
            if obj.val == 1
                obj.one = 1;
            end
        end
    end
end

