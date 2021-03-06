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

classdef Cache < handle
    properties(GetAccess = 'private')
        values@imf.CacheValue vector = imf.CacheValue.empty;
    end
    
    methods
        function out = get(obj, name)
            for i=1:length(obj.values)
                if strcmp(obj.values(i).name, name)
                    out = obj.values(i).value;
                end
            end
        end
        
        function insertOrUpdate(obj, name, value)
            if obj.contains(name)
                for i=1:length(obj.values)
                    if strcmp(obj.values(i).name, name)
                        obj.values(i).value = value;
                    end
                end
            else
                obj.values(end+1) = imf.CacheValue(name, value);
            end
        end
        
        function out = contains(obj, name)
            out = 0;
            for i=1:length(obj.values)
                if strcmp(obj.values(i).name, name)
                    out = 1;
                end
            end
        end
    end
end
