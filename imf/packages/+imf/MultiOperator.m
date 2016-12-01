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

