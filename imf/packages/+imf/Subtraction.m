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
