classdef Model < handle
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = 'private')
        inertialSystem@imf.CoordinateSystem
        forces@imf.Force vector = imf.Force.empty;
        moments@imf.Moment vector = imf.Moment.empty;
        inertias@imf.Inertia vector = imf.Inertia.empty;
        masses@imf.Mass vector = imf.Mass.empty;
    end
    
    properties
        gravity@imf.Gravity
    end
    
    methods
        function obj = Model(inertialSystem)
            global IMF_;
            
            if nargin < 1
                error('Please provide the inertial coordinate system.');
            end
            
            obj.inertialSystem = inertialSystem;
            
            if isnan(IMF_.model)
                IMF_.model = obj;
            else
                error('There is already a model defined.' + ...
                    'You can only have one model at a time.');
            end
            
        end
        
        function system = Compile(obj)
            
            gc = genCoordinates;
            
            system = imf.Expression.empty(length(obj.masses),0);
            
            for i=1:length(obj.masses)
                m = obj.masses(i);
                jac = jacobian(m.positionVector.items, gc);
                dr = functionalDerivative(m.positionVector.items, gc);
                ddr = functionalDerivative(dr, gc);
                
                if isempty(system)
                    system = m.value*jac'*ddr';
                else
                    system = system + m.value*jac'*ddr';
                end
            end
                        
            for i=1:length(obj.forces)
                F = obj.forces(i);
                jac = jacobian(F.positionVector.items, gc);
                
                if isempty(system)
                    system = -1 * jac'*F.value';
                else
                    system = system - jac'*F.value.items';
                end
            end
            
            for i=1:length(obj.moments)
                M = obj.moments(i);
                jac = jacobian(M.attitudeVector.items, gc);
                
                if isempty(system)
                    system = -1 * jac'*M.value.items';
                else
                    system = system - jac'*M.value.items';
                end
            end
            
            for i=1:length(obj.inertias)
                I = obj.inertias(i);
                jac = jacobian(I.attitudeVector.items, gc);
                dg = functionalDerivative(I.attitudeVector.items, gc);
                ddg = functionalDerivative(dg, gc);
                
                if isempty(system)
                    system = jac'*(I.value*ddg' + cross(dg,I.value*dg));
                else
                    system = system + jac'*(I.value.items*ddg' + cross(dg,I.value.items*dg')');
                end
            end
        end
        
        function Add(obj, external)
            if isa(external, 'imf.Force')
                
                if external.coordinateSystem ~= obj.inertialSystem
                    T = getTransformation(external.coordinateSystem, obj.inertialSystem);
                    obj.forces(end+1) = T.Transform(external);
                else
                    obj.forces(end+1) = external;
                end
                
            elseif isa(external, 'imf.Moment')
                
                if external.coordinateSystem ~= obj.inertialSystem
                    T = getTransformation(external.coordinateSystem, obj.inertialSystem);
                    error('Not yet implemented.');
                else
                    obj.moments(end+1) = external;
                end
                
            elseif isa(external, 'imf.Inertia')
                
                if external.coordinateSystem ~= obj.inertialSystem
                    T = getTransformation(external.coordinateSystem, obj.inertialSystem);
                    error('Not yet implemented.');
                else
                    obj.inertias(end+1) = external;
                end
                
            elseif isa(external, 'imf.Mass')
                
                if external.coordinateSystem ~= obj.inertialSystem
                    T = getTransformation(external.coordinateSystem, obj.inertialSystem);
                    obj.masses(end+1) = T.Transform(external);
                else
                    obj.masses(end+1) = external;
                end
                
                if ~isempty(obj.gravity)
                    m = obj.masses(end);
                    obj.forces(end+1) = imf.Force(['F' m.name], m.value*obj.gravity.value.items, m.positionVector, m.coordinateSystem);
                end
                
            else
                error('You can only add external forces, moments or ' + ...
                    'inertias to the model.')
            end
        end
    end
    
end

