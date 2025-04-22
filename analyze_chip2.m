% Curve fit using the calibration structure
figN=figN+1;
figure(figN);
clf;
hold on;
    device = 1;
    fig_title = 'On-chip Laser MZI Response';

    wl = Chip2.data(device).wl;

    for i=1:2
        y = Chip2.data(device).chan{i};
        plot(wl, y, 'LineWidth', 3);
    end

xlabel 'Wavelength (nm)'
ylabel 'Output Power (dB)'
title(fig_title);
legend('show');
grid on; grid minor;
set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title));
hold off;