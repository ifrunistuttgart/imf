function out = visualize(model, variables, values, varargin)

global IMF_
persistent fh ah handles

if nargin < 1 || ~isa(model, 'imf.Model')
    error('Please provide a valid model.');
end

if length(variables) ~= length(values)
    error('The length of the given variables and the values of those variables must be equal.')
end

for i=1:length(variables)
    if isa(variables{i}, 'imf.Dot') && regexp(variables{i}.toString, '^dot\(([a-zA-z0-9]+)\)')
        d = variables{i}.toString;
        var = ['d' d(5:end-1)];
        eval([var '=' num2str(values(i)) ';']);
    else
        eval([variables{i}.name '=' num2str(values(i)) ';']);
    end
end

scale = 1;
showGrid = 0;
revZ = 0;
axisv = NaN;
viewv = NaN;

if isempty(fh) || ~ishandle(fh)
    
    if nargin >= 4
        for i=1:2:nargin-3
            if strcmp(varargin(i), 'axis')
                axisv = varargin{i+1};
            end
            
            if strcmp(varargin(i), 'view')
                viewv = varargin{i+1};
            end
            
            if strcmp(varargin(i), 'scale')
                scale = varargin{i+1};
            end
            
            if strcmp(varargin(i), 'revz')
                if varargin{i+1}
                    revZ = 1;
                end
            end
            
            if strcmp(varargin(i), 'grid')
                if varargin{i+1}
                    showGrid = 1;
                end
            end
        end
    end
    
    fh = figure;
    ah = visPlotArea( fh, showGrid, revZ, axisv, viewv );
end

figure(fh)

for i=1:length(handles)
    delete(handles(i));
end
handles = [];

for i=1:length(IMF_.helper.cs)
    
    origin = imf.PositionVector([0;0;0], IMF_.helper.cs{i});
    x = imf.PositionVector([scale;0;0], IMF_.helper.cs{i});
    y = imf.PositionVector([0;scale;0], IMF_.helper.cs{i});
    z = imf.PositionVector([0;0;scale], IMF_.helper.cs{i});
    
    origin = origin.In(model.inertialSystem);
    x = x.In(model.inertialSystem);
    y = y.In(model.inertialSystem);
    z = z.In(model.inertialSystem);
    
    origin = eval(origin.items, 'caller');
    x = eval(x.items, 'caller');
    y = eval(y.items, 'caller');
    z = eval(z.items, 'caller');
    
    for j=1:length(ah)
        hs =  visCoordinateSystems( ah(j), IMF_.helper.cs{i}.name, origin, x, y, z );
        handles = [handles; hs'];
    end
end

for i=1:length(model.bodies)
    positionVector = eval(model.bodies(i).positionVector.items, 'caller');
    
    for j=1:length(ah)
        handles(end+1) = plot3(ah(j), positionVector(1), positionVector(2), positionVector(3), '.b', 'MarkerSize', 25);
        handles(end+1) = text(ah(j), positionVector(1)+0.1, positionVector(2)+0.1, positionVector(3)+0.1, model.bodies(i).name, 'Color', 'blue');
    end
end

for i=1:length(model.forces)
    
    value = eval(model.forces(i).value.items, 'caller');
    positionVector = eval(model.forces(i).positionVector.items, 'caller');
    
    for j=1:length(ah)
        hs = vectarrow(ah(j), model.forces(i).name, positionVector, positionVector + scale*value, 'r');
        handles = [handles; hs'];
    end
end

for i=1:length(model.moments)
    % dot(q1) muss irgendwie sinnvoll ersetzt werden durch dq1
    
    items = model.moments(i).value.items;
    for j=1:size(items, 2)
        item = items(j).toString;
        
        [sidx,eidx] = regexp(item, '(?<!(?:[a-z]))(?<=(?:dot\())([a-zA-Z0-9]+)(?=(?:\)))(?!(?:[a-z]+))');
        if sidx
            var = item(sidx:eidx);
            dvar = ['d' var];
            item = strrep(item, ['dot(' var ')'], dvar);
        end
        
        value(1,j) = eval(item, 'caller');
    end
    origin = eval(model.moments(i).origin.items, 'caller');
    for j=1:length(ah)
        handles(end+1) = vectarrow(ah(j), model.moments(i).name, origin, origin + value, 'm');
    end
end

out = fh;

end