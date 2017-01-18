function handle = visCoordinateSystems( ah, name, origin, x, y, z )
handle(1) = plot3(ah, origin(1), origin(2), origin(3), '.k');
handle(2) = plot3(ah, [origin(1) x(1)], [origin(2) x(2)], [origin(3) x(3)], '-g');
handle(3) = plot3(ah, [origin(1) y(1)], [origin(2) y(2)], [origin(3) y(3)], '-r');
handle(4) = plot3(ah, [origin(1) z(1)], [origin(2) z(2)], [origin(3) z(3)], '-b');
handle(5) = text(ah, origin(1)-.1, origin(2)-.1, origin(3)-.1, name);
end

