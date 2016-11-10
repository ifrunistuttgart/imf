classdef Model < handle
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess = 'private')
        forces@imf.Force vector = imf.Force.empty;
        moments@imf.Moment vector = imf.Moment.empty;
        inertias@imf.Inertia vector = imf.Inertia.empty;
        masses@imf.Mass vector = imf.Mass.empty;
    end
    
    properties
        gravity
    end
    
    methods
        function obj = Model()
            global IMF_;
            if isnan(IMF_.model)
                IMF_.model = obj;
            else
                error('There is already a model defined.' + ...
                    'You can only have one model at a time.');
            end
                
        end
        
        function Compile(obj, refSys)
            
            if nargin < 2
                error('Please provide the inertial coordinate system.');
            end
                        
            iforces = imf.Force.empty;            
            for i=1:length(obj.forces)
                if obj.forces(i).coordinateSystem ~= refSys
                    T = getTransformation(obj.forces(i).coordinateSystem, refSys);
                    iforces(end+1) = T.Transform(obj.forces(i));
                else
                    iforces(end+1) = obj.forces(i);
                end
            end
            
            imasses = imf.Mass.empty;
            for i=1:length(obj.masses)
                if obj.masses(i).coordinateSystem ~= refSys
                    T = getTransformation(obj.masses(i).coordinateSystem, refSys);
                    imasses(end+1) = T.Transform(obj.masses(i));
                else
                    imasses(end+1) = obj.masses(i);
                end
            end
        end
        
        function Add(obj, external)
            if isa(external, 'imf.Force')
                obj.forces(end+1) = external;
            elseif isa(external, 'imf.Moment')
                obj.moments(end+1) = external;
            elseif isa(external, 'imf.Inertia')
                obj.inertias(end+1) = external;
            elseif isa(external, 'imf.Mass')
                obj.masses(end+1) = external;
            else
                error('You can only add external forces, moments or ' + ...
                    'inertias to the model.')
            end
        end
    end
    
end

