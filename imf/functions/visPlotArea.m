function handles = visPlotArea( fh, showGrid, revZ, axisv, viewv )

if isempty(fh) || ~ishandle(fh)
    error('Provide a vailid figure handle.')
end

if ~viewv
    viewv = [30 30];
end
viewv = [0 180] + viewv;

figure(fh)
if showGrid
    handles(1) = subplot(2,2,1);
    grid on
    hold on
    xlabel('y')
    ylabel('z')
    set(handles(1),'ydir','reverse')
    handles(1).XAxisLocation = 'origin';
    handles(1).YAxisLocation = 'origin';
    axis(axisv([3 4 5 6]))
    
    handles(2) = subplot(2,2,2);
    grid on
    hold on
    xlabel('x')
    ylabel('z')
    set(handles(2),'ydir','reverse')
    set(handles(2),'xdir','reverse')
    handles(2).XAxisLocation = 'origin';
    handles(2).YAxisLocation = 'origin';
    axis(axisv([1 2 5 6]))
    
    handles(3) = subplot(2,2,3);
    grid on
    hold on
    xlabel('y')
    ylabel('x')
    handles(3).XAxisLocation = 'origin';
    handles(3).YAxisLocation = 'origin';
    axis(axisv([3 4 1 2]))
    
    handles(4) = subplot(2,2,4);
    grid on
    hold on
    xlabel('x')
    ylabel('y')
    zlabel('z')
    view(viewv)
    ah = handles(4);
else
    handles(1) = gca;
end

grid on
hold on
axis vis3d
xlabel('x')
ylabel('y')
zlabel('z')
view(viewv)
axis(axisv)

end