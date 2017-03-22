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

function [ T ] = getTransformation( from, to )
global IMF_;

T = nan;

for i=1:length(IMF_.transformations)
    t = IMF_.transformations(i);
    if t.from == from && t.to == to
        T = t;
        return;
    elseif t.from == to && t.to == from
        T = t';
        return;
    end
end

% there was no direct transformation, try to find a chain
chain = imf.Transformation.empty;
while isempty(chain) || chain(end).from ~= from
    
    if ~isempty(chain)
        curto = chain(end).from;
        
        for i=1:length(IMF_.transformations)
            t = IMF_.transformations(i);
            % make sure to prevent circular dependencies
            % therefore don't add transformations resulting in something
            % already in the chain
            if t.to == curto && t.from ~= chain(end).to
                chain(end+1) = t;
            elseif t.from == curto && t.to ~= chain(end).to
                chain(end+1) = t';
            end
            
            if chain(end).from == from
                break;
            end
        end
        
    else
        
        for i=1:length(IMF_.transformations)
            t = IMF_.transformations(i);
            if t.to == to
                chain(end+1) = t;
                break;
            elseif t.from == to
                chain(end+1) = t';
                break;
            end
        end
        
        if isempty(chain)
            break;
        end
        
    end
end

if ~isempty(chain)
    T = imf.TransformationChain(chain(end).from, chain(1).to);   
    T.transformations = chain;
end

if ~isobject(T) && isnan(T)
    error(['No transformation from ' from.name ' to ' to.name ' could be found.']);
end
end