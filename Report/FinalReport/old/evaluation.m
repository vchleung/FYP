figure('pos',[150 300 400 300]); hold on;
plot(ans(:,1),ans(:,2),'k--','Linewidth',1.2)
plot(ans(:,1),ans(:,3),'-^','Linewidth',1.2)
plot(ans(:,1),ans(:,4),'-o','Linewidth',1.2)
plot(ans(:,1),ans(:,5),'-x','Linewidth',1.2)
plot(ans(:,1),ans(:,6),'-s','Linewidth',1.2)
xlabel('RT_{60} (ms)');
ylabel('STOI');
legend('Mixture','DSB','k-means','wFCM (Variance)','wFCM (SNR)')

figure('pos',[150 300 400 300]); hold on;
plot(ans(:,1),ans(:,2),'-^','Linewidth',1.2)
plot(ans(:,1),ans(:,3),'-o','Linewidth',1.2)
plot(ans(:,1),ans(:,4),'-x','Linewidth',1.2)
plot(ans(:,1),ans(:,5),'-s','Linewidth',1.2)
xlabel('RT_{60} (ms)');
ylabel('SNR_{gain}');
legend('DSB','k-means','wFCM (Variance)','wFCM (SNR)')