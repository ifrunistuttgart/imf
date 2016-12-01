classdef Quotient < imf.Product
    properties(SetAccess='private')
        
    end
    
    methods
        function obj = Quotient(varargin)
            i = 1;
            while i <= nargin
               if isa(varargin{i}, 'numeric')
                   varargin{i} = imf.DoubleConstant(varargin{i});
               end
               old = length(obj.objs);
               varargin{i} = getExpression(varargin{i});
               obj.concatenate(varargin{i});
               if i > 1
                    obj.contra(old+1:end) = obj.contra(old+1:end)+ones(size(obj.contra(old+1:end)));
                    obj.contra = mod(obj.contra, 2);
               end
               
               if i == 1 && varargin{i}.zero
                    obj.zero = 1;
               elseif varargin{i}.zero
                    error('DIVISION BY ZERO !');
               end
               i = i+1;
            end
            if nargin == 1
                obj.singleTerm = varargin{1}.singleTerm;
            end
        end
    end
    
end

