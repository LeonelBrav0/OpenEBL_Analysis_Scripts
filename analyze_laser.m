close all;
device = 1;

I     = Chip2.laser_data(device).current;
V     = Chip2.laser_data(device).voltage;
temperature = Chip2.laser_data(device).temperature;
P{1}       = Chip2.laser_data(device).channel0;
P{2}       = Chip2.laser_data(device).channel1;
P{3}       = Chip2.laser_data(device).channel2;
P{4}       = Chip2.laser_data(device).channel3;
Ith         = Chip2.laser_data(device).threhold_current;

% LI curve
figure('Position', get(0, 'ScreenSize')); clf; hold on;
    fig_title = 'On-chip Laser LI Curve';
    
    chan      = 2;
    plot(I, P{chan}, 'bo', 'LineWidth', 3, 'DisplayName', strcat('ch',num2str(chan)));

    Ith       = 13;                % from datasheet
    idx       = (I >= Ith);
    P_base    = P{chan};

    dI        = I(idx) - Ith;      
    m         = sum(dI .* P_base(idx)) / sum(dI.^2);  % least-squares slope
    P_fit     = m * dI;

    plot(I(idx), P_fit, 'LineWidth', 3, 'DisplayName', strcat('Fit ch',num2str(chan)));

xlabel 'Current (mA)'
ylabel 'Power (mW)'
title(fig_title); legend('show'); grid on; grid minor; set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title)); hold off;

% VI curve
figure('Position', get(0, 'ScreenSize')); clf; hold on;
    fig_title = 'On-chip Laser VI Curve';

    plot(I, V, 'LineWidth', 3);

xlabel 'Current (mA)'
ylabel 'Voltage (V)'
title(fig_title); legend('show'); grid on; grid minor; set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title)); hold off;