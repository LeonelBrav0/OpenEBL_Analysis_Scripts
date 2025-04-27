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

% OSA sweep vs Bias Current
figure('Position', get(0, 'ScreenSize')); clf; hold on;
    fig_title = 'On-Chip Laser OSA Sweep for Different Bias Currents';

    OSA_sweep_size = size(Chip2.OSA.data.optical_power_dBm);
    for i=1:OSA_sweep_size(1)
        plot(Chip2.OSA.data.wavelength_nm(i,:), Chip2.OSA.data.optical_power_dBm(i,:), ...
                'LineWidth', 2, 'DisplayName', strcat(num2str(Chip2.OSA.data.current_mA(i)), ' mA'))

        [pk, pk_idx] = max(Chip2.OSA.data.optical_power_dBm(i,:));

        plot(Chip2.OSA.data.wavelength_nm(i,pk_idx), Chip2.OSA.data.optical_power_dBm(i,pk_idx), ...
                'ro', 'LineWidth', 5, 'MarkerSize', 15, 'HandleVisibility','off');
    end
xlim([1307.5, 1308.5])
xlabel 'Wavelength (nm)'
ylabel 'Power (dBm)'
title(fig_title); legend('show'); grid on; grid minor; set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title)); hold off;

% wl vs I curve
figure('Position', get(0, 'ScreenSize')); clf; hold on;
    fig_title = 'Lasing Wavelength vs Bias Current';

    plot(Chip2.OSA.data.current_mA, Chip2.OSA.data.peak_wavelength, 'bo', 'LineWidth', 3, ...
            'DisplayName', 'Peak Wavelength', 'MarkerSize', 15);

    p = polyfit(Chip2.OSA.data.current_mA, Chip2.OSA.data.peak_wavelength, 2);
    f = polyval(p, Chip2.OSA.data.current_mA);

    plot(Chip2.OSA.data.current_mA, f, 'LineWidth', 3, 'DisplayName', 'Peak Wavelength Fit');

    xlabel 'Current (mA)'
    ylabel 'Lasing Wavelength (nm)'
title(fig_title); legend('show'); grid on; grid minor; set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title)); hold off;