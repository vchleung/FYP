% Chi Hang Leung, EE4, 2018, Imperial College.
% 18/6/2018
%%%%%%%%%%%%%%%%%%%%%%%%
% Perform Clustering on TDOA found by Phase Difference of the input signals
%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% F (2x1 cell array) = STFT (using VOICEBOX) of the received signals at two microphones
% clusterMethod = 'naive'/'kmeans'/'FCM'/'wFCM'/'wcFCM'
% Receivers = Structure from MCRoomSim containing information about the
%             microphpones
% numSrc = number of Speakers
% fs = sampling frequency of the signal
% INC = windows increment
% desiredDOA = the DOA of the desired speaker
%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% F_output = the STFT representation after TF mask
%%%%%%%%%%%%%%%%%%%%%%%%

function F_output = PhaseClustering(F,clusterMethod,Receivers,numSrc,fs,INC,desiredDOA)

%% Developing Binary Mask
%Find the Cross power spectral density for each time segment
G12 = F{2}.*conj(F{1});

%Plot the Spectrogram for Phase Difference
figure('pos',[150 300 400 300]);
t = (0:size(G12,1)-1)/fs*INC;
f = (0:size(G12,2)-1)/(size(G12,2)-1)*fs/2;
phaseDiff = angle(G12);%./repmat(2*pi*f,size(G12,1),1);
PlotPhaseSpectrogram(phaseDiff,f,t,'Phase Difference Spectrogram');

%Plot SNR Spectrogram
figure('pos',[150 300 400 300]);
Fpower=F{1}.*conj(F{1}); 
noiseSpect=estnoiseg(Fpower,INC/fs); % estimate the noise power spectrum
signalSpect=Fpower-noiseSpect;
signalSpect(signalSpect<0)=0;
SNR = signalSpect./noiseSpect;
PlotSpectrogram(SNR,f,t,'SNR Spectrogram');

%Find the TDOA of the signals for clustering
dmax = norm(Receivers(1).Location-Receivers(2).Location);
c = 340;
alpha = 2*pi;
timeDiff_complex = -angle(G12)./(alpha*repmat(f,size(G12,1),1));
timeDiff_complex(:,1)= 0; %Avoid error in clustering
timeDiff_reshaped = reshape(timeDiff_complex,[],1);
timeDiff_reshaped_norm = timeDiff_reshaped/norm(timeDiff_reshaped);
timeDiff_complex_norm = timeDiff_complex/norm(timeDiff_reshaped);

timeWin = 4;
freqWin = 3;

%Plot Histogram for DOA
timeDiff_complex(:,1)= NaN;
DOA = asind(timeDiff_complex/dmax*c);
DOA(imag(DOA)~=0)=NaN;
DOA = real(DOA);
figure;
histogram(DOA,60,'Normalization','probability');
grid on;
xlabel('DOA (deg)');
ylabel('Probability');

delay = dmax/c*sind(desiredDOA);
%% Clustering algorithm
switch lower(clusterMethod)
    case 'naive'
    %% Naive Binary Mask
        attenuationRatio = 0;
        Mask = double(phaseDiff<=0);
        Mask(Mask==0)=attenuationRatio; %Attenuate the unwanted TF bins
        
    case 'kmeans'
        [U,centers] = kmeans(timeDiff_reshaped_norm,numSrc,'MaxIter',1000,'Replicates',10);
        [~,index]= min(abs(centers*norm(timeDiff_reshaped)-delay));
        
        %Binary Mask
        Mask = reshape(double(U==index),size(G12));
        
    case 'fcm'
    %% Fuzzy c-means clustering
        options = [NaN 100 1e-10 1];
        [centers,U] = fcm(timeDiff_reshaped_norm,numSrc,options);
        
        %Soft Mask
        [~,index]= min(abs(centers*norm(timeDiff_reshaped)-delay));
        Mask = reshape(U(index,:),size(G12));
       
    case 'wfcm'
    %% Weighted Fuzzy c-means clustering
        options = [NaN 100 1e-10 1];
        
        % Calculate the weights for wfcm
        w = zeros(size(timeDiff_complex_norm));
        K = 10^-4;
        SNRmax = 100;
        for i = 1:size(w,1)
            minTimeIndex = max(1,i-timeWin);
            maxTimeIndex = min(i+timeWin,size(w,1));
            for j = 1:size(w,2)
                minFreqIndex = max(1,j-freqWin);
                maxFreqIndex = min(j+freqWin,size(w,2));
                window = timeDiff_complex_norm(minTimeIndex:maxTimeIndex,minFreqIndex:maxFreqIndex);
                window = reshape(window,[],1);
                w(i,j) = var(window);
            end
        end
        w = max(w,K);
        w = 1+1./w;
          w = min(SNR,SNRmax); %SNR weighted
        w = reshape(w,[],1);
        timeDiff_reshaped_norm = reshape(timeDiff_complex_norm,[],1);
        
        [centers,U] = wfcm(timeDiff_reshaped_norm,w,numSrc,options);
        
        %Soft Mask
        [~,index]= min(abs(centers*norm(timeDiff_reshaped)-delay));
        Mask = reshape(U(index,:),size(G12));

    case 'wcfcm'
    %% Weighted Contextual FCM
        options = [2 100 1e-10 1];
        
        % Calculate the weights for wfcm
        w = zeros(size(timeDiff_complex_norm));
        C = cell(size(w));
        K = 10^-3;
        for i = 1:size(w,1)
            minTimeIndex = max(1,i-timeWin);
            maxTimeIndex = min(i+timeWin,size(w,1));
            for j = 1:size(w,2)
                minFreqIndex = max(1,j-freqWin);
                maxFreqIndex = min(j+freqWin,size(w,2));
                window = timeDiff_complex_norm(minTimeIndex:maxTimeIndex,minFreqIndex:maxFreqIndex);
                window = reshape(window,[],1);
                w(i,j) = var(window);
                window = zeros(size(timeDiff_complex_norm));
                window(minTimeIndex:maxTimeIndex,minFreqIndex:maxFreqIndex)=1;
                C{i,j} = find(window==1);
            end
        end
        w = max(w,K);
        w = 1+1./w;
        w = reshape(w,[],1);
        C = reshape(C,[],1);
        timeDiff_reshaped_norm = reshape(timeDiff_complex_norm,[],1);
       
        %Validation
        omega = length(timeDiff_reshaped_norm);
        idx_ = randsample(omega,round(omega/10));
        idx_v = false(size(timeDiff_reshaped_norm));
        idx_v(idx_)= true;
        idx_e = ~idx_v;
        beta = 1e-2; %initial value of beta
        
        [~,~,J_wfcm] = wfcm(timeDiff_reshaped_norm,w,numSrc,options);
        [~,~,J_wcfcm] = wcfcm(timeDiff_reshaped_norm,w,beta,C,numSrc,options);

        
        beta_inc = 0.001*J_wfcm(end)/(J_wcfcm(end)-J_wfcm(end))*beta;
        beta = beta_inc;
        q = options(1);
        E_cv_best = Inf;
        U=[];
        for i=1:100
            [centers,U] = wcfcmval(timeDiff_reshaped_norm,w,beta,C,idx_e,U,numSrc,options);
            dist = distfcm(centers, timeDiff_reshaped_norm(idx_v));
            dist = dist.^2;
            E_cv = sum(sum(dist.*[w(idx_v) w(idx_v)]'.*(U(:,idx_v).^q)));
            if E_cv <E_cv_best
               E_cv_best = E_cv;
               beta_best = beta;
            else
                break;
            end
            beta = beta+beta_inc;
        end
        
        [centers,U] = wcfcm(timeDiff_reshaped_norm,w,beta_best,C,numSrc,options);
        
        %Soft Mask
        [~,index]= min(abs(centers*norm(timeDiff_reshaped)-delay));
        Mask = reshape(U(index,:),size(G12));
        
end
%% Apply the Mask
%Plot the masks
t = (1:size(G12,1))/fs*INC;
f = (0:size(G12,2)-1)/(size(G12,2)-1)*fs/2;
figure('pos',[150 300 400 300]);
PlotMask(Mask.',f,t,'TF Mask');

%Apply the mask and Put them back into a cell array
F_output = F{1}.*Mask;

