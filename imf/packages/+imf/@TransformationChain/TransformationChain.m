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

classdef TransformationChain < handle
    
    properties(SetAccess='private')
        from@imf.CoordinateSystem
        to@imf.CoordinateSystem
    end
    properties(SetAccess='public')
        transformations@imf.Transformation vector = imf.Transformation.empty
    end
    
    methods
        function obj = TransformationChain(from, to)
            if nargin > 0
                global IMF_;
                
                obj.from = from;
                obj.to = to;
                
                IMF_.transformationChains(end+1) = obj;
            end
        end
        
        function obj = ctranspose(a)
            obj = imf.TransformationChain(a.to, a.from);
            obj.transformations = obj.transformations';
        end
        
        function R = HomogeneousMatrix(obj)
            
            R = eye(4);
            for i=1:length(obj.transformations)
                R = R * obj.transformations(i).HomogeneousMatrix;
            end
            
        end
        
        function T = rotation(obj)
            T = eye(3);
            for i=1:length(obj.transformations)
                T = T * obj.transformations(i).rotation.expr;
            end
            T = imf.RotationMatrix(T);
        end
        
        function out = rotations(obj)
            out = cell(0);
            for i=1:length(obj.transformations)
                for j=1:length(obj.transformations(i).rotations)
                    out{end+1} = obj.transformations(i).rotations{j};
                end
            end
        end
    end
    
end

