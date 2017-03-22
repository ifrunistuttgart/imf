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
classdef Subtraction < imf.Addition
    properties(SetAccess='private')
        
    end
    
    methods
        function obj = Subtraction(varargin)
            i = 1;
            zero = nargin > 0;
            one = 0;
            while i <= nargin
               if isa(varargin{i}, 'numeric')
                   varargin{i} = imf.DoubleConstant(varargin{i});
               end
               varargin{i} = getExpression(varargin{i});
               if ~varargin{i}.zero
                   old = length(obj.objs);
                   obj.concatenate(varargin{i});
                   if i > 1
                       obj.contra(old+1:end) = obj.contra(old+1:end)+ones(size(obj.contra(old+1:end)));
                       obj.contra = mod(obj.contra, 2);
                   end
                   
                   if i == 1 && varargin{i}.one
                       one = 1;
                   else
                       zero = 0;
                   end
               end
               i = i+1;
            end
            
            if one && zero
                obj.one = 1;
            elseif zero
                obj.zero = 1;
            end
            if nargin == 1
                obj.singleTerm = varargin{1}.singleTerm;
            end
        end
    end
    
end
