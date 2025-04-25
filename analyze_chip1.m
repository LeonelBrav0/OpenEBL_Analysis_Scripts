sim_out_chan = 2;

% Simulated vs Measured
figN=figN+1; figure(figN); clf; hold on;
    device = 2;
    fig_title = 'Simulated vs Measured Response';

    wl = Chip1.data(device).wl;
    y = Chip1.data(device).chan{1};

    wl_sim = Chip1_sim.data(device).wl;
    y_sim = Chip1_sim.data(device).chan{sim_out_chan};
    
    plot(wl, y, 'DisplayName', 'Measured');
    plot(wl_sim/1e-9, y_sim, 'DisplayName', 'Simulated')
    

xlabel 'Wavelength (nm)'
ylabel 'Output Power (dB)'
xlim([1285, 1345])
title(fig_title); legend('show'); grid on; grid minor; set(gca, 'FontSize', 25); 
saveas(gcf, sprintf('plots/%s.png', fig_title)); hold off;

% Curve fit using the calibration structure
figN=figN+1; figure(figN); clf; hold on;
    device = 3; % MZI ∆L=0 Calibration
    fig_title = 'Calibration Structure Optical Spectrum';

    polyfit_order = 3;
    wl = Chip1.data(device).wl;
    y = Chip1.data(device).chan{1};

    wl_sim = Chip1_sim.data(device).wl/1e-9;
    y_sim = Chip1_sim.data(device).chan{sim_out_chan};

    plot(wl, y, 'LineWidth', 3, 'DisplayName', 'Measured');
    plot(wl_sim, y_sim, 'LineWidth', 3, 'DisplayName', 'Simulated');

    % Measured
    peak_val = max(y);
    idx = y >= peak_val - 10;

    wl_fit = wl(idx);
    base_fit = y(idx);

    p = polyfit(wl_fit, base_fit, polyfit_order);
    gc_baseline_measured = polyval(p, wl);
    plot(wl, gc_baseline_measured, 'r-', 'LineWidth', 2, 'HandleVisibility','off');

    % Simulated
    peak_val = max(y_sim);
    idx = y_sim >= peak_val - 10;

    wl_fit = wl_sim(idx);
    base_fit = y_sim(idx);

    p = polyfit(wl_fit, base_fit, polyfit_order);
    gc_baseline_simulated = polyval(p, wl_sim);
    plot(wl_sim, gc_baseline_simulated, 'r-', 'LineWidth', 2, 'HandleVisibility','off');

xlim([1285, 1345])
xlabel 'Wavelength (nm)'
ylabel 'Output Power (dB)'
title(fig_title); legend('show'); grid on; grid minor; set(gca, 'FontSize', 25); 
saveas(gcf, sprintf('plots/%s.png', fig_title)); hold off;

% Subtract curve fitted baseline from MZI data
figN=figN+1; figure(figN); clf; hold on;
    device = 2;
    fig_title = 'Baseline Corrected MZI Response';
    
    wl = Chip1.data(device).wl;
    y_corrected = Chip1.data(device).chan{1} - gc_baseline_measured;

    wl_sim = Chip1_sim.data(device).wl/1e-9;
    y_sim_corrected = Chip1_sim.data(device).chan{sim_out_chan} - gc_baseline_simulated.';

    plot(wl, y_corrected, 'LineWidth', 3, 'DisplayName', 'Measured');
    plot(wl_sim, y_sim_corrected, 'LineWidth', 3, 'DisplayName', 'Simulated');
        
xlim([1309, 1311])
xlabel 'Wavelength (nm)'
ylabel 'Output Power (dB)'
title(fig_title); legend('show'); grid on; grid minor; set(gca, 'FontSize', 25); 
saveas(gcf, sprintf('plots/%s.png', fig_title)); hold off;

% Plot Waveguide Losses Calibration Device
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

% Power Spectral Density
figN=figN+1;
figure(figN);
clf;
hold on;
    device = 2;
    fig_title = 'PSD Open-EBL MZI Response';

    wl = Chip1.data(device).wl;
    y  = Chip1.data(device).chan{2};

    c = 3e8;
    wl_m = wl * 1e-9;
    f_Hz = c ./ wl_m;
    f_GHz_unsorted = f_Hz / 1e9;
    [f_GHz, sortIdx] = sort(f_GHz_unsorted);

    P_sorted = y(sortIdx);
    f_uniform = linspace(f_GHz(1), f_GHz(end), length(f_GHz));
    P_interp = interp1(f_GHz, P_sorted, f_uniform, 'linear');
    P_interp = P_interp - mean(P_interp);

    N = length(P_interp);
    Y = fft(P_interp);
    psd2 = (1/(N * mean(diff(f_uniform)))) * abs(Y).^2;
    psd1 = psd2(1:floor(N/2)+1);
    psd1(2:end-1) = 2*psd1(2:end-1);
    psd1(1) = 0;

    df = f_uniform(2) - f_uniform(1);
    f_psd = f_uniform(1) + (0:floor(N/2)) * df;

    plot(f_psd/1e3, psd1, 'LineWidth', 3);

xlabel 'Optical Frequency (THz)'
ylabel 'Power Spectral Density'
%xlim([228.137 228.165]);
title(fig_title);
legend('show');
grid on; grid minor;
set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title));
hold off;