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
    eval([variables{i}.name '=' num2str(values(i)) ';']);
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
    
    if ~isnumeric(origin.items)
        origin = imf.PositionVector(eval(origin.items, 'caller'), model.inertialSystem);
    end
    if ~isnumeric(x.items)
        x = imf.PositionVector(eval(x.items, 'caller'), model.inertialSystem);
    end
    if ~isnumeric(y.items)
        y = imf.PositionVector(eval(y.items, 'caller'), model.inertialSystem);
    end
    if ~isnumeric(z.items)
        z = imf.PositionVector(eval(z.items, 'caller'), model.inertialSystem);
    end
    
    plot3(origin.items(1), origin.items(2), origin.items(3), '.k')
    text(origin.items(1)-.1, origin.items(2)-.1, origin.items(3)-.1, IMF_.helper.cs{i}.name);
    
    plot3([origin.items(1) x.items(1)], [origin.items(2) x.items(2)], [origin.items(3) x.items(3)], '-g')
    plot3([origin.items(1) y.items(1)], [origin.items(2) y.items(2)], [origin.items(3) y.items(3)], '-r')
    plot3([origin.items(1) z.items(1)], [origin.items(2) z.items(2)], [origin.items(3) z.items(3)], '-b')
end

for i=1:length(model.masses)
    
    positionVector = imf.PositionVector(eval(model.masses(i).positionVector.items, 'caller'), model.inertialSystem);
    
    plot3(positionVector.items(1),positionVector.items(2),positionVector.items(3), '.b', 'MarkerSize', 25)
    text(positionVector.items(1)+0.1,positionVector.items(2)+0.1,positionVector.items(3)+0.1, model.masses(i).name, 'Color', 'blue');
end

for i=1:length(model.forces)
    
    value = imf.Vector(eval(model.forces(i).value.items, 'caller'), model.inertialSystem);
    positionVector = imf.PositionVector(eval(model.forces(i).positionVector.items, 'caller'), model.inertialSystem);
    
    vectarrow(positionVector.items, positionVector.items + scale*value.items, 'r')
    text(positionVector.items(1) + 0.5*scale*value.items(1), ...
        positionVector.items(2) + 0.5*scale*value.items(2), ...
        positionVector.items(3) + 0.5*scale*value.items(3), ...
        model.forces(i).name, 'Color','red');
end

out = fh;

end