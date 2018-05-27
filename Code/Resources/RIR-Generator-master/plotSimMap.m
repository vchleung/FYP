function plotSimMap(receiverPos, sourcePos, roomDim, mtype, orientation)
% Plot a 3d figure showing MCRoomSim's configuration, i.e.:
% - the room dimensions
% - the source locations (assume always omnidirectional source)
% - the receiver locations and orientations
%
% Omnidirectional sources are figured by red spheres and omnidirectional 
% receivers are figured by blue spheres. Directional sources/receivers
% are figured as red/blue spheres with an arrow showing their orientation.
%
% Referenced from N. Epain, A. Wabnitz, CARLab & University of Sydney
% Modified by Vincent Leung, 2017


%%%%%%%%%%%%%%%%%%
% INITIALISATION %
%%%%%%%%%%%%%%%%%%

% Number of sources and receivers
numSource = size(sourcePos, 1) ;
numReceiver = size(receiverPos, 1) ;

% Source and receiver locations
% Test if a source or receiver is outside the room
souWalDst = repmat(roomDim,numSource,1) - sourcePos ;
recWalDst = repmat(roomDim,numReceiver,1) - receiverPos ;
if any(any([sourcePos;receiverPos;souWalDst;recWalDst]<0))
    error('Sources and receivers cannot be outside the room.') ;
end

% Calculate the distance between the receivers, between the sources and
% between the receivers and sources.
RecSouDst = sqrt( sum(( repmat(reshape(receiverPos,numReceiver,1,3),1,numSource) ...
- repmat(permute(reshape(sourcePos,numSource,1,3),[2 1 3]),numReceiver,1)).^2 ,3 ) ) ;
RecRecDst = sqrt( sum(( repmat(reshape(receiverPos,numReceiver,1,3),1,numReceiver) ...
- repmat(permute(reshape(receiverPos,numReceiver,1,3),[2 1 3]),numReceiver,1)).^2 ,3 ) ) ;
SouSouDst = sqrt( sum(( repmat(reshape(sourcePos,numSource,1,3),1,numSource) ...
- repmat(permute(reshape(sourcePos,numSource,1,3),[2 1 3]),numSource,1)).^2 ,3 ) ) ;

% Size of the source and receiver spheres
siz = roomDim/10 ;
siz = min([siz,min(RecSouDst(RecSouDst>0))/2]) ;
siz = min([siz,min(RecRecDst(RecRecDst>0))/2]) ;
siz = min([siz,min(SouSouDst(SouSouDst>0))/2]) ;

% Sphere vertices
[xSph,ySph,zSph] = sphere ;
xSph = siz * xSph ;      
ySph = siz * ySph ;      
zSph = siz * zSph ;

% Search for source and/or receivers having the same location
SmeRec = RecRecDst==0 ;
SmeSou = SouSouDst==0 ;
RecCnt = zeros(numReceiver,1) ;
SouCnt = zeros(numSource,1) ;

% Initialise the figure
figure
set(gcf,'Color',[1 1 1])
hold on


%%%%%%%%%%%%%%%%%
% PLOT THE ROOM %
%%%%%%%%%%%%%%%%%

% Room width
width = min(roomDim(1:2)) ; 

% Regular mesh of points on the floor
stp = max(.25,(2^nextpow2(width/4))/4) ;
xFlr = (0:stp:roomDim(1))' ;
yFlr = (0:stp:roomDim(2))' ;
if roomDim(1) > max(xFlr)
    xFlr = [ xFlr ; roomDim(1) ] ;
end
if roomDim(2) > max(yFlr)
    yFlr = [ yFlr ; roomDim(2) ] ;
end

% Plot a checkered floor
for i = 1 : length(xFlr)-1
    for J = 1 : length(yFlr)-1
        % Color of the (I,J) tile
        col = [.7 .7 .7] + .1 * rem(i+J,2) ;
        % Create a patch corresponding to the (I,J) tile
        patch([xFlr(i) xFlr(i+1) xFlr(i+1) xFlr(i)], ...
              [yFlr(J) yFlr(J) yFlr(J+1) yFlr(J+1)], ...
              [0 0 0 0],'facecolor',col,'edgecolor','none') ;
    end
end
    


%%%%%%%%%%%%%%%%%%%%
% PLOT THE SOURCES %
%%%%%%%%%%%%%%%%%%%%

% Plot the sources
for i = 1 : numSource
    
    % Ith source position
    pos = sourcePos(i,:) ; 

    % Plot Ith source
    surf(pos(1)+xSph,pos(2)+ySph,pos(3)+zSph, ...
        'edgecolor','none','facecolor',[1 0 0]) ;
    
%     % Plot Ith source orientation if directional
%     if ~strcmp(Sources(i).Type,'omnidirectional') 
%         orn = Sources(i).Orientation * pi/180 ;
%         [vec(1),vec(2),vec(3)] = sph2cart(orn(1),orn(2),3*siz) ;
%         Arrow3d(pos,pos+vec,[1 0 0])
%     end
    
    % Show the source index if more than one
    if numSource > 1
        nmbSmeSou = sum(SmeSou(:,i)) ;
        if nmbSmeSou > 1
            text(pos(1)+siz*cos(2*pi*SouCnt(i)/nmbSmeSou), ...
                 pos(2)+siz*sin(2*pi*SouCnt(i)/nmbSmeSou), ...
                 pos(3)+2*siz,num2str(i),'color',[1 0 0], ...
                 'HorizontalAlignment','center') ;
        else
             text(pos(1),pos(2),pos(3)+2*siz,num2str(i), ...
                 'color',[1 0 0],'HorizontalAlignment','center') ;           
        end
        SouCnt(SmeSou(:,i)) = SouCnt(SmeSou(:,i)) + 1 ;
    end

end


%%%%%%%%%%%%%%%%%%%%%%
% PLOT THE RECEIVERS %
%%%%%%%%%%%%%%%%%%%%%%

% Plot the sources
for j = 1 : numReceiver
    
    % Ith receiver position
    pos = receiverPos(j,:) ; 

    % Plot Ith receiver
    surf(pos(1)+xSph,pos(2)+ySph,pos(3)+zSph, ...
        'edgecolor','none','facecolor',[0 0 1]) ;
    
    % Plot Ith receiver orientation if directional
    if ~strcmp(mtype,'omnidirectional')
        orn = orientation(j,:) * pi/180 ;
        [vec(1),vec(2),vec(3)] = sph2cart(orn(1),orn(2),10*siz) ;
        Arrow3d(pos,pos+vec,[0 0 1])
    end
    
    % Show the receiver index if more than one
    if numReceiver > 1
        nmbSmeRec = sum(SmeRec(j,:)) ;
        if nmbSmeRec > 1
            text(pos(1)+siz*cos(2*pi*RecCnt(j)/nmbSmeRec), ...
                 pos(2)+siz*sin(2*pi*RecCnt(j)/nmbSmeRec), ...
                 pos(3)+2*siz,num2str(j),'color',[0 0 1], ...
                 'HorizontalAlignment','center') ;
        else
            text(pos(1),pos(2),pos(3)+2*siz,num2str(j), ...
                'color',[0 0 1],'HorizontalAlignment','center') ;
        end
        RecCnt(SmeRec(j,:)) = RecCnt(SmeRec(j,:)) + 1 ;
    end

end


%%%%%%%%%%%% 
% AXES ETC %  
%%%%%%%%%%%% 

% Axes
axis equal
axis([0 roomDim(1) 0 roomDim(2) 0 roomDim(3)])
axis vis3d
box on

% Perspective
camproj perspective
campos([-3 -9 12].*roomDim)

% Lighting
light('Position',[0.5 0.5 0]+[0 0 1.5].*roomDim,'Style','local')
lighting phong
material dull

% Axis labels
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')


end


%%%%%%%%%%%%%%%%
% SUB-ROUTINES %
%%%%%%%%%%%%%%%%

% Sub-routine: plot a 3d arrow
function Arrow3d(xyzStart,xyzEnd,col)

    % Corresponding vector
    vec = xyzEnd-xyzStart ;
    
    % Length of the arrow
    lng = norm(vec) ;
    
    % Arrow direction
    dir = vec/lng ;
    [azm,elv] = cart2sph(dir(1),dir(2),dir(3))  ;
    
    % A set of angles around the circle
    ang = linspace(0,360,18)' * pi/180 ;
    
    % Radius of the base of the arrow
    rad = lng / 20 ;
    
    % Plot the base of the arrow
    bas = rad * [zeros(length(ang),1) cos(ang) sin(ang)] ;
    bas = bas * YaxisRotMatrix(elv)' * ZaxisRotMatrix(azm)' ;
    bas = repmat(xyzStart,length(ang),1) + bas ; 
    patch(bas(:,1),bas(:,2),bas(:,3),ones(size(bas(:,1))), ...
        'edgecol','none','facecol',col) ;

    % Plot the shaft of the arrow
    shf = bas + repmat(.72*vec,length(ang),1) ;
    for I = 1 : length(ang)-1
        patch([bas(I,1);shf(I,1);shf(I+1,1);bas(I+1,1)], ...
              [bas(I,2);shf(I,2);shf(I+1,2);bas(I+1,2)], ...
              [bas(I,3);shf(I,3);shf(I+1,3);bas(I+1,3)], ...
              ones(4,1), ...
              'edgecol','none','facecol',col) ;
    end
    
    % Plot the base of the head
    bas = 4*rad*[zeros(length(ang),1) cos(ang) sin(ang)] ;
    bas = bas * YaxisRotMatrix(elv)' * ZaxisRotMatrix(azm)' ;
    bas = bas + repmat(xyzStart,length(ang),1) ...
        + .7*repmat(vec,length(ang),1) ;
    patch(bas(:,1),bas(:,2),bas(:,3),ones(size(bas(:,1))), ...
        'edgecol','none','facecol',col) ;

   % Plot the head
   hea = xyzEnd ;
   for I = 1 : length(ang)-1
       patch([bas(I,1);hea(1);bas(I+1,1)], ...
             [bas(I,2);hea(2);bas(I+1,2)], ...
             [bas(I,3);hea(3);bas(I+1,3)], ...
             ones(3,1), ...
             'edgecol','none','facecol',col) ;
   end
    
end

% Sub-routine: z-axis rotation matrix
function RotMat = ZaxisRotMatrix(ang) 
    RotMat = [ cos(ang) -sin(ang) 0 ; ...
               sin(ang)  cos(ang) 0 ; ...
                      0         0 1 ] ;
end

% Sub-routine: y-axis rotation matrix
function RotMat = YaxisRotMatrix(ang)
    RotMat = [ cos(ang) 0 sin(ang) ; ...
                      0 1        0 ; ...
              -sin(ang) 0 cos(ang) ] ;
end