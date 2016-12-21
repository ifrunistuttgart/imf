
%% ------------------------------------------------------------------------
% Compute transformed coordiante system for visualization
%--------------------------------------------------------------------------
function [xt, yt, zt, t] = fun_visuKos(T, scaling)

    % Define origin coordinate system
    % Define origin
    Origin=[0; 0; 0];
    % norm x
    x= [1; 0; 0];
    x1= [Origin(1) x(1)];
    x2= [Origin(2) x(2)];
    x3= [Origin(3) x(3)];
    % norm y
    y= [0; 1; 0];
    y1= [Origin(1) y(1)];
    y2= [Origin(2) y(2)];
    y3= [Origin(3) y(3)];
    % norm z
    z= [0; 0; 1];
    z1= [Origin(1) z(1)];
    z2= [Origin(2) z(2)];
    z3= [Origin(3) z(3)];

    % Compute transformated system
    % Transformation matrix is formulated in homogenous coordinates. 
    % Usinge following description:
    %         [r11 r12 r13 t1]
    %--> T:=  [r21 r22 r23 t2]
    %         [r31 r32 r33 t3]
    %         [ 0   0   0   1]
    % Get rotation matrix
    R= [T(1,1) T(1,2) T(1,3); T(2,1) T(2,2) T(2,3); T(3,1) T(3,2) T(3,3)];
    % Get translation vector
    t= [T(1,4); T(2,4); T(3,4)];
    % Compute transformed x
    xt= R*x*scaling;
    % Compute transformed y
    yt= R*y*scaling;
    % Compute transformed z
    zt= R*z*scaling; 
    
    % Plot computed axis
    plot3([t(1) xt(1)+t(1)], [t(2) xt(2)+t(2)], [t(3) xt(3)+t(3)], 'b', 'linewidth', 2);
    hold on;
    plot3([t(1) yt(1)+t(1)], [t(2) yt(2)+t(2)], [t(3) yt(3)+t(3)], 'r', 'linewidth', 2);
    plot3([t(1) zt(1)+t(1)], [t(2) zt(2)+t(2)], [t(3) zt(3)+t(3)], 'y', 'linewidth', 2);
    % Text for axis
    text(xt(1)+t(1),...
         xt(2)+t(2),...
         xt(3)+t(3),...
         'x'); 
     text(yt(1)+t(1),...
         yt(2)+t(2),...
         yt(3)+t(3),...
         'y'); 
     text(zt(1)+t(1),...
         zt(2)+t(2),...
         zt(3)+t(3),...
         'z'); 
        
end
%%


















