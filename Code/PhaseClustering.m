function F_output = PhaseClustering(F,clusterMethod,Receivers,numSrc,fs_output,INC,desiredSpeaker)

%% Developing Binary Mask
%Find the Cross power spectral density for each time segment
G12 = F{2}.*conj(F{1});

%Plot the Spectrogram for Phase Difference
figure;
t = (1:size(G12,1))/fs_output*INC;
f = (0:size(G12,2)-1)/(size(G12,2)-1)*fs_output/2;
phaseDiff = angle(G12);%./repmat(2*pi*f,size(G12,1),1);
PlotPhaseSpectrogram(phaseDiff,f,t,'Phase Difference Spectrogram');

%Plot SNR Spectrogram
figure;
Fpower=F{1}.*conj(F{1}); 
noiseSpect=estnoiseg(Fpower,INC/fs_output); % estimate the noise power spectrum
signalSpect=Fpower-noiseSpect;
signalSpect(signalSpect<0)=0;
SNR = signalSpect./noiseSpect;
PlotSpectrogram(SNR,f,t,'SNR Spectrogram');

%Find the DOA of the signals
dmax = norm(Receivers(1).Location-Receivers(2).Location);
c = 340;
alpha = 2*pi*dmax/c;
%timeDiff_complex = exp(1i*angle(G12)./(alpha*repmat(f,size(G12,1),1)));
timeDiff_complex = angle(G12)./(alpha*repmat(f,size(G12,1),1));
timeDiff_complex(:,1)= 0;
timeDiff_reshaped = reshape(timeDiff_complex,[],1);
timeDiff_reshaped_norm = timeDiff_reshaped/norm(timeDiff_reshaped);
%timeDiff_reshaped_norm = [real(timeDiff_reshaped_norm) imag(timeDiff_reshaped_norm)];
DOA = asind(timeDiff_complex);
DOA(imag(DOA)~=0)=NaN;
DOA = real(DOA);
figure;
histogram(DOA,60,'Normalization','probability'); %Histogram for DOAs
grid on;
xlabel('DOA (deg)');
ylabel('Probability');


%% Clustering algorithm
switch lower(clusterMethod)
    case 'naive'
    %% Naive Binary Mask
        attenuationRatio = 0.1;
        Mask_1 = double(phaseDiff<=0);
        Mask_1(Mask_1==0)=attenuationRatio; %Attenuate the unwanted TF bins
        
        Mask_2 = double(phaseDiff>=0);
        Mask_2(Mask_2==0)=attenuationRatio; %Attenuate the unwanted TF bins

    case 'kmeans'
        [U,centers] = kmeans(timeDiff_reshaped_norm,numSrc,'MaxIter',1000,'Replicates',10);
        [~,index]= sort(centers,'ascend');
        
        %Fuzzy Mask
        Mask_1 = reshape(double(U==index(1)),size(G12));
        Mask_2 = reshape(double(U==index(2)),size(G12));
        
    case 'fcm'
    %% Fuzzy c-means clustering
        options = [NaN 100 1e-10 1];
        [centers,U] = fcm(timeDiff_reshaped_norm,numSrc,options);
        
        %Set the two mask
        %DOA_result = atan2(centers(:,2),centers(:,1));
        %[~,index]= sort(DOA_result,'ascend');
        % [~,index]= sort(centers,'ascend');
        % Mask_1 = reshape([ones(1,size(G12,1)) U(index(1),:)],size(G12));
        % Mask_2 = reshape([ones(1,size(G12,1)) U(index(2),:)],size(G12));
        
        %Binary Mask
        [~,index]= sort(centers,'ascend');
        U = U(index,:);
%         maxU = max(U);
%         index1 = find(U(1,:) == maxU);
%         index2 = find(U(2,:) == maxU);
%         Mask_1 = zeros(size(G12));
%         Mask_1(index1) = 1;
%         Mask_2 = zeros(size(G12));
%         Mask_2(index2) = 1;
        
        %Fuzzy Mask
        Mask_1 = reshape(U(1,:),size(G12));
        Mask_2 = reshape(U(2,:),size(G12));
        
        
    case 'wfcm'
    %% Weighted Fuzzy c-means clustering
        timeDiff_complex_norm = timeDiff_complex./norm(timeDiff_reshaped);
        options = [NaN 100 1e-10 1];
        
        % Calculate the weights for wfcm
        w = zeros(size(timeDiff_complex_norm));
        timeWin = 4;
        freqWin = 7;
        K = 10^-3;
        for i = 1:size(w,1)
            minTimeIndex = max(1,i-timeWin);
            maxTimeIndex = min(i+timeWin,size(w,1));
            for j = 1:size(w,2)
                minFreqIndex = max(1,j-freqWin);
                maxFreqIndex = min(j+freqWin,size(w,2));
                window = timeDiff_complex_norm(minTimeIndex:maxTimeIndex,minFreqIndex:maxFreqIndex);
                window = reshape(window,[],1);
                w(i,j) = max(var(window),K);
            end
        end
        %w = max(SNR./max(max(SNR)),K);
        w = reshape(w,[],1);
        timeDiff_reshaped_norm = reshape(timeDiff_complex_norm,[],1);
        
        [centers,U] = wfcm(timeDiff_reshaped_norm,w,numSrc,options);
        
        %Soft Mask
        [~,index]= sort(centers,'ascend');
        U = U(index,:);
        
        %Fuzzy Mask
        Mask_1 = reshape(U(1,:),size(G12));
        Mask_2 = reshape(U(2,:),size(G12));
    case 'wcfcm'
    %% Weighted Contextual FCM

        timeDiff_complex_norm = timeDiff_complex./norm(timeDiff_reshaped);
        options = [2 100 1e-10 1];
        
        % Calculate the weights for wfcm
        w = zeros(size(timeDiff_complex_norm));
        C = cell(size(w));
        timeWin = 4;
        freqWin = 7;
        K = 10^-3;
        for i = 1:size(w,1)
            minTimeIndex = max(1,i-timeWin);
            maxTimeIndex = min(i+timeWin,size(w,1));
            for j = 1:size(w,2)
                minFreqIndex = max(1,j-freqWin);
                maxFreqIndex = min(j+freqWin,size(w,2));
                window = timeDiff_complex_norm(minTimeIndex:maxTimeIndex,minFreqIndex:maxFreqIndex);
                window = reshape(window,[],1);
                w(i,j) = max(var(window),K);
                window = zeros(size(timeDiff_complex_norm));
                window(minTimeIndex:maxTimeIndex,minFreqIndex:maxFreqIndex)=1;
                C{i,j} = find(window==1);
            end
        end
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
        [~,index]= sort(centers,'ascend');
        U = U(index,:);
%         maxU = max(U);
%         index1 = find(U(1,:) == maxU);
%         index2 = find(U(2,:) == maxU);
%         Mask_1 = zeros(size(G12));
%         Mask_1(index1) = 1;
%         Mask_2 = zeros(size(G12));
%         Mask_2(index2) = 1;
        
        %Fuzzy Mask
        Mask_1 = reshape(U(1,:),size(G12));
        Mask_2 = reshape(U(2,:),size(G12));
end
%% Apply the Mask
%Plot the masks
t = (1:size(G12,1))/fs_output*INC;
f = (0:size(G12,2)-1)/(size(G12,2)-1)*fs_output/2;
figure('pos',[150 300 400 300]);
PlotMask(Mask_1.',f,t,['Mask for Source ' num2str(desiredSpeaker)]);

%Apply the mask and Put them back into a cell array
F_output = {F{1}.*Mask_1;F{1}.*Mask_2};
