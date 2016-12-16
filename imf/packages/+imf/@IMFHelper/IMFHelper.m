classdef IMFHelper < handle
    properties (SetAccess='protected')
        %setVariables
        x = {};     % generalized coordinate
        dx = {};    % diff generalized coordinate
        ddx = {};    % 2nd diff generalized coordinate
        var = {};    % variables
    end
    
    methods
        function obj = IMFHelper(varargin)

        end
        
        % Add instruction (differentialequation, ocp,... to list)
        function addInstruction(obj, set)
            obj.instructionList{length(obj.instructionList)+1} = set;
        end
        
        % Remove last instruction
        function removeInstruction(obj, set)
            found = 0;
            i = 1;
            while i <= length(obj.instructionList) && ~found
                if strcmp(class(obj.instructionList{i}), class(set)) && strcmp(obj.instructionList{i}.toString, set.toString)
                    found = 1;
                else 
                    i = i+1;
                end
            end
            if found
                obj.instructionList = {obj.instructionList{1:i-1}, obj.instructionList{i+1:end}};
            end
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
            for i = 1:length(obj.x)
            	obj.removeInstruction(obj.x{i});
            end
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
        
        % Add variable
        function addVar(obj, set)
            
            for i=1:length(obj.var)
                if (strcmp(obj.var{i}.name, set.name))
                   error('The variable you are trying to add already exists.'); 
                end
            end
            
            obj.var{length(obj.var)+1} = set;
        end
        function clearVar(obj)
            for i = 1:length(obj.var)
            	obj.removeInstruction(obj.var{i});
            end
            obj.var = {};
        end
    end
    
end