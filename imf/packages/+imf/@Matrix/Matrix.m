classdef Matrix < imf.VectorspaceElement    
    properties
       matrixIsPrinted=0;
    end
    
    methods
        function obj = Matrix(val)
            if nargin > 0
                global IMF_;
                
                if (isa(val, 'numeric') || isa(val, 'imf.Expression'))
                    IMF_.count_matrix = IMF_.count_matrix+1;
                    obj.name = strcat('imfdata_M', num2str(IMF_.count_matrix));
                    
                    obj.items = val;
                    
                else
                    error('Matrix expects a numeric value');
                    
                end
            end
        end         
    end
    
end

