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

classdef Transformation < handle
    
    properties(SetAccess='private')
        from@imf.CoordinateSystem
        to@imf.CoordinateSystem
        rotations = cell(0)
        translation@imf.Vector
    end
    
    methods
        function obj = Transformation(from, to, varargin)
            if nargin > 0
                global IMF_;
                
                if ~isa(from, 'imf.CoordinateSystem')
                    error('Provide a valid imf.CoordinateSystem for the source system.')
                end
                
                if ~isa(to, 'imf.CoordinateSystem')
                    error('Provide a valid imf.CoordinateSystem for the target system.')
                end
                
                obj.from = from;
                obj.to = to;
                
                if nargin < 3
                    error('You need to define at least a translation or rotation.');
                elseif nargin == 3
                    if isa(varargin{1}, 'imf.Vector')
                        obj.translation = varargin{1};
                    elseif isa(varargin{1}, 'imf.RotationMatrix')
                        obj.rotations{end+1} = varargin{1};
                    else
                        error('The third parameter needs to be an imf.RotationMatrix or an imf.Vector if it is the last parameter.');
                    end
                elseif nargin == 4
                    obj.rotations{end+1} = varargin{1};
                    if isa(varargin{2}, 'imf.Vector')
                        obj.translation = varargin{2};
                    elseif isa(varargin{2}, 'imf.RotationMatrix')
                        obj.rotations{end+1} = varargin{2};
                    else
                        error('The fourth parameter needs to be an imf.RotationMatrix or an imf.Vector if it is the last parameter.');
                    end
                elseif nargin == 5
                    obj.rotations{end+1} = varargin{1};
                    obj.rotations{end+1} = varargin{2};
                    if isa(varargin{3}, 'imf.Vector')
                        obj.translation = varargin{3};
                    elseif isa(varargin{3}, 'imf.RotationMatrix')
                        obj.rotations{end+1} = varargin{3};
                    else
                        error('The fourth parameter needs to be an imf.RotationMatrix or an imf.Vector if it is the last parameter.');
                    end
                elseif nargin == 6
                    obj.rotations{end+1} = varargin{1};
                    obj.rotations{end+1} = varargin{2};
                    obj.rotations{end+1} = varargin{3};
                    if isa(varargin{4}, 'imf.Vector')
                        obj.translation = varargin{4};
                    else
                        error('The sixth parameter needs to be an imf.RotationMatrix or an imf.Vector if it is the last parameter.');
                    end
                end
                
                if obj.translation.coordinateSystem == from
                    obj.translation = imf.Vector(obj.rotation * -1 * obj.translation, to);
                end
                
                IMF_.transformations(end+1) = obj;
            end
        end
        
        function out = rotation(obj)
            out = eye(3);
            for i=1:length(obj.rotations)
                out = obj.rotations{i} * out;
            end
        end
        
        function out = ctranspose(obj)
            rotations = [];
            for i=length(obj.rotations):-1:1
                rotations{end+1} = obj.rotations{i}';
            end
            out = imf.Transformation(obj.to, obj.from, rotations{:}, imf.Vector(obj.rotation' * -1 * obj.translation, obj.from));
        end
        
        
        function T = HomogeneousMatrix(obj)
            % transrotational transformation
            T = [obj.rotation.expr obj.translation.items;
                zeros(1, 3)          1];
        end
    end
    
end

