%  Licence:
%    This file is part of iFR Modelling Framework  - (http://www.ifr.uni-stuttgart.de)
%
%    IMF -- A framework for modelling dynamic mechanical systems in MATLAB.
%    Copyright (C) 2016-2017 by Pascal Gross <pascal.gross@ifr.uni-stuttgart.de>.
%    Developed within the Flight Mechanics and Controls Lab of the
%    University of Stuttgart. All rights reserved.
%
%    IMF is free software; you can redistribute it and/or
%    modify it under the terms of the GNU Lesser General Public
%    License as published by the Free Software Foundation; either
%    version 3 of the License, or (at your option) any later version.
%
%    IMF is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%    Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public
%    License along with ACADO Toolkit; If not, see <http://www.gnu.org/licenses/>.
%
%    Author: Pascal Gross <pascal.gross@ifr.uni-stuttgart.de>
%    Date: 2017

classdef Model < handle
    
    properties(SetAccess = 'private')
        inertialSystem@imf.CoordinateSystem
        forces@imf.Force vector = imf.Force.empty;
        moments@imf.Moment vector = imf.Moment.empty;
        bodies@imf.Body vector = imf.Body.empty;
    end
    
    properties
        gravity@imf.Gravity
    end
    
    properties(GetAccess = 'private')
        cache@imf.Cache = imf.Cache();
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
            
            if obj.cache.contains('CompiledModel')
                system = obj.cache.get('CompiledModel');
                return
            end
            
            gc = genCoordinates;
            
            if isempty(gc)
                error('There are no generalized coordinates defined. Aborting.')
            end
            
            system = imf.Expression.empty(length(obj.bodies),0);
            
            for i=1:length(obj.bodies)
                b = obj.bodies(i);
                m = b.mass;
                jac = b.translationalJacobian;
                ddr = b.translationalAcceleration;
                
                if isempty(system)
                    system = m*jac'*ddr;
                else
                    system = system + m*jac'*ddr;
                end
                
                if ~isempty(b.inertia)
                    I = b.inertia.items;
                    
                    jac = b.rotationalJacobian;
                    w = b.angularVelocity;
                    dw = b.rotationalAcceleration;
                    
                    if isempty(system)
                        system = jac'*(I*dw + cross(w,I*w));
                    else
                        system = system + jac'*(I*dw + cross(w,I*w));
                    end
                end
            end
            
            for i=1:length(obj.forces)
                F = obj.forces(i);
                jac = jacobian(F.positionVector, gc);
                
                if isempty(system)
                    system = -1 * jac'*F.value;
                else
                    system = system - jac'*F.value;
                end
            end
            
            for i=1:length(obj.moments)
                M = obj.moments(i);
                
                for j=1:length(gc)
                    dgc(j) = dot(gc(j));
                end
                jac = jacobian(M.angularVelocity, dgc);
                
                if isempty(system)
                    system = -1 * jac'*M.value;
                else
                    system = system - jac'*M.value;
                end
            end            
            
            obj.cache.insertOrUpdate('CompiledModel', system);
        end
        
        
        function matlabFunction(obj, filename, optimize)
            
            global IMF_;
            
            gc = genCoordinates;
            M = imf.Expression( zeros(length(gc)) );
            
            for i=1:length(obj.bodies)
                
                b = obj.bodies(i);
                m = b.mass;
                jac = b.translationalJacobian;
                
                M = M + m*(jac'*jac);
                
                if ~isempty(b.inertia)
                    I = b.inertia.items;
                    jac = b.rotationalJacobian;
                    
                    M = M + jac'*I*jac;
                end
            end
            
            % substitute generalized coordinate second order derivatives
            
            fidM = fopen([filename 'M.m'], 'w');
            fidF = fopen([filename 'F.m'], 'w');
            fprintf(fidM, 'function expr = %sM(t, in2, in3)\r\n', filename);
            fprintf(fidF, 'function expr = %sF(t, in2, in3)\r\n', filename);
            
            n = length(IMF_.helper.x);
            
            for i = 1:n
                fprintf(fidM, '%s = in2(%d,:);\r\n', IMF_.helper.x{i}.name, i);
                fprintf(fidF, '%s = in2(%d,:);\r\n', IMF_.helper.x{i}.name, i);
            end
            fprintf(fidF, '\r\n');
            fprintf(fidM, '\r\n');
            
            for i = 1:n
                fprintf(fidM, 'd%sdt = in2(%d,:);\r\n', IMF_.helper.x{i}.name, n+i);
                fprintf(fidF, 'd%sdt = in2(%d,:);\r\n', IMF_.helper.x{i}.name, n+i);
            end
            fprintf(fidF, '\r\n');
            fprintf(fidM, '\r\n');
            
            for i = 1:length(IMF_.helper.param)
                fprintf(fidM, '%s = in3(%d,:);\r\n', IMF_.helper.param{i}.name, i);
                fprintf(fidF, '%s = in3(%d,:);\r\n', IMF_.helper.param{i}.name, i);
            end
            fprintf(fidF, '\r\n');
            fprintf(fidM, '\r\n');
            
            fprintf(fidM, 'expr = zeros(%d);\r\n', 2*n);
            fprintf(fidM, 'expr(1:%d, 1:%d) = eye(%d);\r\n', n, n, n);            
            for i=1:n
                for j=1:n
                    fprintf(fidM, 'expr(%d,%d) = %s;\r\n', i+n, j+n, M(i,j).toString());
                end
            end
            fprintf(fidM, '\r\n');
           
            system = Compile(obj);
            fprintf(fidF, 'expr = zeros(%d, 1);\r\n', 2*n);
            for i=1:n
                    fprintf(fidF, 'expr(%d, 1) = d%sdt;\r\n', i, IMF_.helper.x{i}.name);
                    eq = system(i).toString();
                    for j=1:n
                        eq = regexprep(eq, ['(?<!(?:[a-zA-Z0-9]))(ddot\(' IMF_.helper.x{j}.name '\))(?!(?:[a-zA-Z0-9]+))'], '0');
                        eq = regexprep(eq, ['(?<!(?:[a-zA-Z0-9]))(dot\(' IMF_.helper.x{j}.name '\))(?!(?:[a-zA-Z0-9]+))'], ['d' IMF_.helper.x{j}.name 'dt']);
                    end
                    fprintf(fidF, 'expr(%d, 1) = -1*%s;\r\n', i+n, eq);
            end
            fprintf(fidF, '\r\n');
            
            fprintf(fidM, 'end\r\n');
            fprintf(fidF, 'end\r\n');
            fclose(fidM);
            fclose(fidF);            
            
            disp('======================== DONE =========================')
            disp('Generation for MATLAB function completed.')
            disp(['Two functions have been created: @' [filename 'M'] '(t,q,params) and @' [filename 'F'] '(t,q,params).'])
            disp('The states are:')
            for i=1:n
                disp(['  Parameter ' num2str(i) ': ' IMF_.helper.x{i}.name]);
            end
            for i=1:n
                disp(['  Parameter ' num2str(i+n) ': d' IMF_.helper.x{i}.name 'dt']);
            end
            disp('The function parameters are:')
            for i=1:length(IMF_.helper.param)
                disp(['  Parameter ' num2str(i) ': ' IMF_.helper.param{i}.name]);
            end
            disp('=======================================================')
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
                    obj.forces(end+1) = imf.Force(['F' b.name], imf.Vector(b.mass*obj.gravity.items, obj.gravity.coordinateSystem), b.positionVector);
                end
                
            else
                error('You can only add external forces, moments or ' + ...
                    'inertias to the model.')
            end
        end
    end
    
end

