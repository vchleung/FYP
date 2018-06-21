% Chi Hang Leung, EE4, 2018, Imperial College.
% 18/6/2018
%%%%%%%%%%%%%%%%%%%%%%%%
% Perform beamforming on the received signals
%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% y_rec (2x1 cell array) = the received signals at two microphones stored
% in cell array
% method = beamforming method
% Receivers = Structure from MCRoomSim containing information about the
%             microphpones
% fs = sampling frequency of the signal
% DOA = the DOA of the desired speaker
%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% y = Beamformed Signal in time domain
%%%%%%%%%%%%%%%%%%%%%%%%

function y = Beamforming(y_rec,DOA,Receivers,fs,method,fc)
c = 340;
d = norm(Receivers(1).Location-Receivers(2).Location);
numRec = size(Receivers,1);
switch lower(method)
    case 'delaysum' %Delay Sum Beamformer
        tau = d/c*sind(DOA);
        nsamp = round(tau*fs);
        y_rec1_delayed = circshift(y_rec{1},nsamp);
        if nsamp >0
            y_rec1_delayed(1:nsamp)=0;
        else
            y_rec1_delayed(end-nsamp+1:end)=0;
        end
        y = y_rec1_delayed+y_rec{2};
        y = y./numRec;
        
        
    case 'delaysum_matlab' %Delay Sum Beamformer - MATLAB version
        array = phased.ULA('NumElements',2,'ElementSpacing',d);
        beamformer = phased.TimeDelayBeamformer('SensorArray',array,...
            'SampleRate',fs,...
            'PropagationSpeed',c,...
            'Direction',[-DOA; 0],...
            'WeightsOutputPort',true);
        [y,] = beamformer(cell2mat(y_rec)');
        y=y';
        
        tau = d/c*sind(DOA);
        w = [exp(-1j*2*pi*fc*tau);1];
        figure;
        [PAT,AZ_ANG,~]=pattern(array,fc,[-180:180],0,...
            'Type','power',...
            'PropagationSpeed',c,...
            'Weights',w);
        polarplot(deg2rad(AZ_ANG),PAT,'LineWidth',1.2)
        ax = gca;
        ax.ThetaZeroLocation='Top';
        ax.ThetaLim = [-180 180];
        
    case 'gsc_matlab' %Generalised Sidelobe Canceller
        array = phased.ULA('NumElements',2,'ElementSpacing',d);
        
        gscbeamformer = phased.GSCBeamformer('SensorArray',array, ...
            'PropagationSpeed',c,...
            'SampleRate',fs,...
            'Direction',[-DOA; 0], ...
            'FilterLength',10);
        y = gscbeamformer(cell2mat(y_rec)');
        y = real(y)';
        
    case 'mvdr_matlab' %Minimum Variance Distortionless Response
        array = phased.ULA('NumElements',2,'ElementSpacing',d);
        
        % Define the MVDR beamformer
        mvdrbeamformer = phased.MVDRBeamformer('SensorArray',array,...
            'Direction',[-DOA; 0],...
            'PropagationSpeed',c,...
            'OperatingFrequency',fc,...
            'WeightsOutputPort',true);
        [y, w] = mvdrbeamformer(cell2mat(y_rec)');
        y = real(y)';
        
        %Plot the array pattern
        figure;
        [PAT,AZ_ANG,~]=pattern(array,fc,[-180:180],0,...
            'Type','power',...
            'PropagationSpeed',c,...
            'Weights',conj(w),...
            'Normalize',false);
        polarplot(deg2rad(AZ_ANG),PAT,'LineWidth',1.2)
        ax = gca;
        ax.ThetaZeroLocation='Top';
        ax.ThetaLim = [-180 180];
        
    case 'lcmv_matlab' %Linear Constrained Minimum Variance
        array = phased.ULA('NumElements',2,'ElementSpacing',d);
        steer_vec = phased.SteeringVector('SensorArray',array,...
            'PropagationSpeed',c);
        LCMVbeamformer = phased.LCMVBeamformer('Constraint',steer_vec(fc,[-DOA; 0]),...
            'DesiredResponse',1,...
            'WeightsOutputPort',true);
        [y,w] = LCMVbeamformer(cell2mat(y_rec)');
        y = real(y)';
        
        %Plot the array pattern
        figure;
        [PAT,AZ_ANG,~]=pattern(array,fc,[-180:180],0,...
            'Type','power',...
            'PropagationSpeed',c,...
            'Weights',w);
        polarplot(deg2rad(AZ_ANG),PAT,'LineWidth',1.2)
        ax = gca;
        ax.ThetaZeroLocation='Top';
        ax.ThetaLim = [-180 180];
        
    case 'null-steering' %Null Steering Beamforming
        array = phased.ULA('NumElements',2,'ElementSpacing',d);
        lambda = c/fc;  % wavelength
       
        thetaad = -30:5:30;     % look directions
        thetaan = 45;           % interference direction
       
        elementPos = getElementPosition(array);
        % Calculate the steering vector for null directions
        wn = steervec(elementPos/lambda,thetaan);
        
        % Calculate the steering vectors for lookout directions
        wd = steervec(elementPos/lambda,thetaad);
        
        % Compute the response of desired steering at null direction
        rn = wn'*wd/(wn'*wn);
        
        % Sidelobe canceller - remove the response at null direction
        w = wd-wn*rn;
        
        % Plot the pattern
        figure;
        pattern(array,fc,-180:180,0,'PropagationSpeed',c,'Type','powerdb',...
            'CoordinateSystem','rectangular','Weights',w);
        hold on; legend off;
        plot([40 40],[-100 0],'r--','LineWidth',2)
        text(40.5,-5,'\leftarrow Interference Direction','Interpreter','tex',...
            'Color','r','FontSize',10)
        
        y = real(y_rec{1}-w'*cell2mat(y_rec));
end
end