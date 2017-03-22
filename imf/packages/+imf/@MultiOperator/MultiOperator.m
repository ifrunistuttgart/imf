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
%    Author: Rien Quirynen
%    Date: 2012
% 
classdef MultiOperator < imf.Operator   
    properties
        
        objs = {};
        contra;
        unsorted = 1;
    end
    
    methods
        function obj = MultiOperator()
            
        end 
        
        function concatenate(obj, varargin)
            for i = 2:nargin
%                 varargin{i-1} = getExpression(varargin{i-1});
                if (isa(varargin{i-1}, 'imf.Addition') && isa(obj, 'imf.Addition')) || (isa(varargin{i-1}, 'imf.Product') && isa(obj, 'imf.Product'))
                    for j = 1:length(varargin{i-1}.objs)
                        obj.objs{length(obj.objs)+1} = varargin{i-1}.objs{j};
                    end
                    obj.contra = [obj.contra varargin{i-1}.contra];
                else
                    obj.objs{length(obj.objs)+1} = varargin{i-1};
                    obj.contra = [obj.contra 0];
                end
            end
        end
        
        function out = obj1(obj)
            if isempty(obj.objs)
                out = imf.EmptyWrapper;
            else
                out = obj.objs{1};
            end
        end
        
        function out = sortObjects(obj)
            strings = cellfun(@toString, obj.objs, 'UniformOutput', false);
            if obj.unsorted
                [~, I] = sort(strings);
                obj.objs = obj.objs(I);
                obj.contra = obj.contra(I);
                obj.unsorted = 0;
                out = strings(I);
            else
                out = strings;
            end
        end
    
    end

    
end

