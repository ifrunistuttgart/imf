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