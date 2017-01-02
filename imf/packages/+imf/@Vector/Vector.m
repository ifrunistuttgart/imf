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

classdef Vector < imf.VectorspaceElement    
    properties
       dim = 0;
    end
    
    methods
        function obj = Vector(val)
            if nargin > 0
	            global IMF_;

                if (isa(val, 'numeric') || isa(val, 'imf.Expression'))
	                IMF_.count_vector = IMF_.count_vector+1;
	                obj.name = strcat('imfdata_v', num2str(IMF_.count_vector));
                
	                [m n] = size(val);
                
	                if (m == 1)
	                    obj.dim = n;
	                    obj.items = val;
	                elseif (n == 1)
	                    obj.dim = m;
	                    obj.items = val';
	                else
	                    error('Input should be a vector');
                    end
            	else
	                error('Vector expects a numeric value'); 
            	end     
			end
        end  
        
        getInstructions(obj, cppobj, get)

    end
    
end