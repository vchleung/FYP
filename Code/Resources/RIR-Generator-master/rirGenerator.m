function h = rirGenerator(c, fsamp, receiverPos, sourcePos, roomDim, beta, n, mtype, order, dim, orientation, hp_filter)
%Generate the impulse response using method of images, output H is a 3-D
%array with dimension R(number of receivers) x S(number of sources) x N
numReceiver = size(receiverPos, 1);
numSource = size(sourcePos, 1);
h = zeros(numReceiver,numSource,n);
for i = 1:numSource
    if exist("rir_generator",'file') ~= 3
        mex -setup;
        mex "RIR-Generator-master/rir_generator.cpp"; % generate the function file from cpp
    end
    h(:,i,:) = rir_generator(c, fsamp, receiverPos, sourcePos(i,:), roomDim, beta, n, mtype, order, dim, orientation, hp_filter);
end
end