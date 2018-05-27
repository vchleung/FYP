%Plot the spectrogram for Binary Mask
function PlotMask(S,F,T,titleText)

%Plot the Binary Mask
surf(T,F,S,'edgecolor','flat'); 
axis tight; 
view(0,90);
colormap(flipud(gray));
colorbar;
title(titleText,'Interpreter','latex')
xlabel('Time (s)','Interpreter','latex')
ylabel('Frequency (Hz)','Interpreter','latex')

end