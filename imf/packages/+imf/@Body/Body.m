classdef Body < handle
    %MASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = 'private')
        name
        mass
        positionVector@imf.PositionVector
        inertia@imf.Inertia
        attitudeVector@imf.Vector
    end
    
    methods
        
        function obj = Body(name, mass, positionVector, inertia, attitudeVector)
            
            if ischar(name) && ~isempty(mass)
                obj.name = name;
            end
            
            if isnumeric(mass) && length(mass) == 1
                obj.mass = mass;
            elseif isa(mass, 'imf.Variable')
                obj.mass = mass;
            else
                error('The mass must be a numeric scalar or an imf.Parameter');
            end
            
            if isa(positionVector, 'imf.PositionVector')
                obj.positionVector = positionVector;
            else
                error('The positionVector must be an imf.PositionVector');
            end
            
            if nargin > 3
                
                if nargin < 5
                    error('An attitude vector is mendatory for inertia.');
                end
                
                if isa(inertia, 'imf.Inertia')
                    obj.inertia = inertia;
                    obj.inertia.body = obj;
                else
                    error('The inertia must be an imf.Inertia');
                end
                
                if isa(attitudeVector, 'imf.Vector')
                    obj.attitudeVector = attitudeVector;
                else
                    error('The attitudeVector must be an imf.Vector');
                end
                
            end
        end
        
        function out = In(obj, coordinateSystem)
            if isempty(obj.inertia) && obj.positionVector.coordinateSystem ~= coordinateSystem
                out = imf.Body(obj.name, obj.mass, obj.positionVector.In(coordinateSystem));
            elseif ~isempty(obj.inertia) && (obj.positionVector.coordinateSystem ~= coordinateSystem || obj.inertia.coordinateSystem ~= coordinateSystem)
                out = imf.Body(obj.name, obj.mass, obj.positionVector.In(coordinateSystem), obj.inertia.In(coordinateSystem), obj.attitudeVector.In(coordinateSystem));
            else
                out = obj;
            end
        end
        
    end
    
end