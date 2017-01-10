function out = visualize(model, variables, values, varargin)

global IMF_
persistent fh

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

if isempty(fh) || ~ishandle(fh)
    fh = figure;
end

figure(fh)
clf(fh)
grid on
hold on
axis vis3d

scale = 1;

if nargin >= 4
    for i=1:2:nargin-3
        if strcmp(varargin(i), 'axis')
            axis(varargin{i+1})
        end
        
        if strcmp(varargin(i), 'view')
            view(varargin{i+1})
        end
        
        if strcmp(varargin(i), 'scale')
            scale = varargin{i+1};
        end
        
        if strcmp(varargin(i), 'revz')
            if varargin{i+1}
                set(gca,'zdir','reverse')
                set(gca,'ydir','reverse')
            end
        end
    end
end

xlabel('x')
ylabel('y')
zlabel('z')

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
        
    plot3(origin(1), origin(2), origin(3), '.k')
    text(origin(1)-.1, origin(2)-.1, origin(3)-.1, IMF_.helper.cs{i}.name);
    
    plot3([origin(1) x(1)], [origin(2) x(2)], [origin(3) x(3)], '-g')
    plot3([origin(1) y(1)], [origin(2) y(2)], [origin(3) y(3)], '-r')
    plot3([origin(1) z(1)], [origin(2) z(2)], [origin(3) z(3)], '-b')
end

for i=1:length(model.masses)    
    positionVector = eval(model.masses(i).positionVector.items, 'caller');
    
    plot3(positionVector(1), positionVector(2), positionVector(3), '.b', 'MarkerSize', 25)
    text(positionVector(1)+0.1, positionVector(2)+0.1, positionVector(3)+0.1, model.masses(i).name, 'Color', 'blue');
end

for i=1:length(model.forces)
    
    value = eval(model.forces(i).value.items, 'caller');
    positionVector = eval(model.forces(i).positionVector.items, 'caller');
    
    vectarrow(model.forces(i).name, positionVector, positionVector + scale*value, 'r')
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
    vectarrow(model.forces(i).name, origin, origin + value, 'm')
end

out = fh;

end