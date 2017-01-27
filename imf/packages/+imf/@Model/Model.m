classdef Model < handle
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = 'private')
        inertialSystem@imf.CoordinateSystem
        forces@imf.Force vector = imf.Force.empty;
        moments@imf.Moment vector = imf.Moment.empty;
        bodies@imf.Body vector = imf.Body.empty;
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
            
            system = imf.Expression.empty(length(obj.bodies),0);
            
            for i=1:length(obj.bodies)
                b = obj.bodies(i);
                m = b.mass;
                jac = jacobian(b.positionVector.items, gc);
                dr = functionalDerivative(b.positionVector.items, gc);
                ddr = functionalDerivative(dr, gc);
                
                if isempty(system)
                    system = m*jac'*ddr';
                else
                    system = system + m*jac'*ddr';
                end
                
                if ~isempty(b.inertia)
                    I = b.inertia.items;
                    
                    for j=1:length(gc)
                        dgc(j) = dot(gc(j));
                    end
                    
                    jac = jacobian(b.angularVelocity.items, dgc);
                    w = b.angularVelocity.items;
                    dw = functionalDerivative(w, gc);
                    
                    if isempty(system)
                        system = jac'*(I*dw' + cross(w',I*w'));
                    else
                        system = system + jac'*(I*dw' + cross(w',I*w'));
                    end
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
        end
        
        function Add(obj, external)
            if isa(external, 'imf.Force')
                
                obj.forces(end+1) = external.In(obj.inertialSystem);
                
            elseif isa(external, 'imf.Moment')
                
                obj.moments(end+1) = external.In(obj.inertialSystem);
                                
            elseif isa(external, 'imf.Body')
                
                obj.bodies(end+1) = external.In(obj.inertialSystem);
                
                if ~isempty(obj.gravity)
                    b = obj.bodies(end);
                    obj.forces(end+1) = imf.Force(['F' b.name], imf.Vector(b.mass*obj.gravity.items, b.positionVector.coordinateSystem), b.positionVector);
                end
                
            else
                error('You can only add external forces, moments or ' + ...
                    'inertias to the model.')
            end
        end
    end
    
end

