    ax1 = subplot(2,2,1); imshow(Iground_smoothed)
    ax2 = subplot(2,2,2); imshow(Ifilled)
    ax3 = subplot(2,2,3); imshow(BW_thin)
    ax4 = subplot(2,2,4); 

    imshow(BW_thin)
    hold on;
    plot(plot_points(:,1), plot_points(:,2), 'r*', 'MarkerSize', 3);
    hold off
    linkaxes([ax1,ax2,ax3,ax4],'xy')
    pause(3)