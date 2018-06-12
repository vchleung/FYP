function y = Beamforming(y_rec,DOA,Receivers,fs,method)
c = 340;
d = norm(Receivers(1).Location-Receivers(2).Location);
numRec = size(Receivers,1);
switch lower(method)
    case 'delaysum'
        tau = d/c*sind(DOA);
        nsamp = round(tau*fs);
        y_rec1_delayed = circshift(y_rec{1},nsamp);
        y = y_rec1_delayed+y_rec{2};
        y = y./numRec;
        
    case 'delaysum_matlab'
        array = phased.ULA('NumElements',2,'ElementSpacing',d);
        beamformer = phased.TimeDelayBeamformer('SensorArray',array,...
            'SampleRate',fs,...
            'PropagationSpeed',c,...
            'Direction',[-DOA; 0],...
            'WeightsOutputPort',true);
        [y,w] = beamformer(cell2mat(y_rec)');
        y=y';
    case 'gsc_matlab'
        array = phased.ULA('NumElements',2,'ElementSpacing',d);
        
        gscbeamformer = phased.GSCBeamformer('SensorArray',array, ...
            'PropagationSpeed',c,...
            'SampleRate',fs,...
            'Direction',[-DOA; 0], ...
            'FilterLength',10);
        y = gscbeamformer(cell2mat(y_rec)');
        y = real(y)';
end
end