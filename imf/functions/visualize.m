function visualize(model, variables, values, varargin)

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
    
    origin = imf.Vector([0;0;0]);
    x = imf.Vector([scale;0;0]);
    y = imf.Vector([0;scale;0]);
    z = imf.Vector([0;0;scale]);
    
    if IMF_.helper.cs{i} ~= model.inertialSystem
        T = getTransformation(IMF_.helper.cs{i}, model.inertialSystem);
        origin = T.Transform(origin);
        x = T.Transform(x);
        y = T.Transform(y);
        z = T.Transform(z);
        
        origin = imf.Vector(eval(origin.items, 'caller'));
        x = imf.Vector(eval(x.items, 'caller'));
        y = imf.Vector(eval(y.items, 'caller'));
        z = imf.Vector(eval(z.items, 'caller'));
    end
    
    plot3(origin.items(1), origin.items(2), origin.items(3), '.k')
    text(origin.items(1)-.1, origin.items(2)-.1, origin.items(3)-.1, IMF_.helper.cs{i}.name);
    
    plot3([origin.items(1) x.items(1)], [origin.items(2) x.items(2)], [origin.items(3) x.items(3)], '-g')
    plot3([origin.items(1) y.items(1)], [origin.items(2) y.items(2)], [origin.items(3) y.items(3)], '-r')
    plot3([origin.items(1) z.items(1)], [origin.items(2) z.items(2)], [origin.items(3) z.items(3)], '-b')
end

for i=1:length(model.masses)
    
    positionVector = imf.Vector(eval(model.masses(i).positionVector.items, 'caller'));
    
    plot3(positionVector.items(1),positionVector.items(2),positionVector.items(3), '.b', 'MarkerSize', 25)
    text(positionVector.items(1)+0.1,positionVector.items(2)+0.1,positionVector.items(3)+0.1, model.masses(i).name, 'Color', 'blue');
end

for i=1:length(model.forces)
    
    value = imf.Vector(eval(model.forces(i).value.items, 'caller'));
    positionVector = imf.Vector(eval(model.forces(i).positionVector.items, 'caller'));
    
    vectarrow(positionVector.items, positionVector.items + scale*value.items, 'r')
    text(positionVector.items(1) + 0.5*scale*value.items(1), ...
        positionVector.items(2) + 0.5*scale*value.items(2), ...
        positionVector.items(3) + 0.5*scale*value.items(3), ...
        model.forces(i).name, 'Color','red');
end

end