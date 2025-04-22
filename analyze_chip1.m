% Curve fit using the calibration structure
figN=figN+1;
figure(figN);
clf;
hold on;
    device = 3; % MZI ∆L=0 Calibration
    fig_title = 'Calibration Structure Optical Spectrum';

    wl = Chip1.data(device).wl;
    polyfit_order = 3;

    wl_fit = cell(1,2);
    base_fit = cell(1,2);
    idxs = cell(1,2);

    for i=1:2
        y = Chip1.data(device).chan{i};
        peak_val = max(y);
        idx = y >= peak_val - 10;

        wl_fit{i} = wl(idx);
        base_fit{i} = y(idx);
        idxs{i} = idx;
        
        plot(wl, y, 'LineWidth', 3);

        p = polyfit(wl_fit{i}, base_fit{i}, polyfit_order);
        fit_baseline = polyval(p, wl);
        plot(wl, fit_baseline, 'r-', 'LineWidth', 3, 'HandleVisibility','off');
    end

xlabel 'Wavelength (nm)'
ylabel 'Output Power (dB)'
title(fig_title);
legend('show');
grid on; grid minor;
set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title));
hold off;

% Subtract curve fitted baseline from MZI data
figN=figN+1;
figure(figN);
clf;
hold on;
    device = 2;
    fig_title = 'Baseline Corrected MZI Response';
    
    wl = Chip1.data(device).wl;
    y = Chip1.data(device).chan{1};
    
    y_corrected = y(idxs{1}) - base_fit{1};
    wl_corrected = wl(idxs{1});

    plot(wl_corrected, y_corrected, 'LineWidth', 3);
        
xlabel 'Wavelength (nm)'
ylabel 'Output Power (dB)'
title(fig_title);
xlim([1309, 1311]);
legend('show');
grid on; grid minor;
set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title));
hold off;

% Plot Waveguide Calibration Device
figN=figN+1;
figure(figN);
clf;
hold on;
    fig_title = 'Waveguide Loss Calibration Device';
    
    wl = Chip1.data(device).wl;
    for dev=6:9
        y = Chip1.data(dev).chan{2};
        name = Chip1.names{dev};
        tok = regexp(name, 'loss(.*?)TE', 'tokens');
        label = tok{1}{1};
        plot(wl, y, 'LineWidth', 3, 'DisplayName', strcat(label, ' {\mum}'));
    end
    
xlabel 'Wavelength (nm)'
ylabel 'Output Power (dB)'
title(fig_title);
legend('show');
grid on; grid minor;
set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title));
hold off;

% Plot Waveguide Loss at 1310nm vs Length
figN=figN+1;
figure(figN);
clf;
hold on;
    fig_title = 'Waveguide Loss at 1310nm vs Length';
    
    wl = Chip1.data(device).wl;
    polyfit_order = 3;
    n = 4;
    lengths = zeros(1,n);
    power1310 = zeros(1,n);
    idx = 0;
    for dev=6:9
        idx = idx + 1;
        y = Chip1.data(dev).chan{2};
        name = Chip1.names{dev};
        tok = regexp(name, 'loss(.*?)TE', 'tokens');
        lengths(idx) = str2double(tok{1}{1});
        p = polyfit(wl, y, polyfit_order);
        power1310(idx) = polyval(p, 1310);
    end

    p_len = polyfit(lengths, power1310, 1);
    fit_line = polyval(p_len, lengths);
    plot(lengths, power1310, 'o', 'LineWidth', 3, 'DisplayName', 'Data');
    plot(lengths, fit_line, 'r-', 'LineWidth', 3, 'HandleVisibility','off');
    slope_cm = p_len(1)*1e4;
    text(mean(lengths), max(power1310), sprintf('Slope = %.3f dB/cm', slope_cm), 'FontSize', 25);

xlabel 'Waveguide Length (\mum)'
ylabel 'Output Power at 1310nm (dB)'
title(fig_title);
legend('show');
grid on; grid minor;
set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title));
hold off;
