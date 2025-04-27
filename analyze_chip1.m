sim_out_chan = 2;
MZI_dev = 2;
MZI_cal = 3;

% Simulated vs Measured
figure('Position', get(0, 'ScreenSize')); clf; hold on;
    device = MZI_dev;
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
figure('Position', get(0, 'ScreenSize')); clf; hold on;
    device = MZI_cal; % MZI ∆L=0 Calibration
    fig_title = 'Calibration Structure Optical Spectrum';

    polyfit_order = 3;
    wl = Chip1.data(device).wl;
    y = Chip1.data(device).chan{1};

    wl_sim = Chip1_sim.data(device).wl/1e-9;
    y_sim = Chip1_sim.data(device).chan{3};

    plot(wl(1:100:end),    y(1:100:end),    'o', 'LineWidth', 1, 'DisplayName', 'Measured');
    plot(wl_sim(1:100:end), y_sim(1:100:end), 'o', 'LineWidth', 1, 'DisplayName', 'Simulated');

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
figure('Position', get(0, 'ScreenSize')); clf; hold on;
    device = MZI_dev;
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
figure('Position', get(0, 'ScreenSize'));;
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
figure('Position', get(0, 'ScreenSize'));;
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

% Curve fitting to MZI transfer function
figure('Position', get(0, 'ScreenSize')); clf; hold on;
    device = MZI_dev;  % MZI device index
    fig_title = 'MZI Curve Fit';

    wl = Chip1.data(device).wl;    % raw is in nm
    y  = Chip1.data(device).chan{1} - gc_baseline_measured;

    % Initialize parameters
    MZI_0.dL    = 2.66659958194e-3; 
    MZI_0.ng    = 4.497;
    MZI_0.wl    = 1310;         % now in nm
    MZI_0.alpha = 2.493 * 100;  % dB/cm * cm/m
    MZI_0.b     = mean(y);

    % constrain to +/- 5 nm
    fit_window = 25;  
    idx = (wl >= MZI_0.wl - fit_window/2) & (wl <= MZI_0.wl + fit_window/2);
    wl = wl(idx);
    y  = y(idx);

    n1    =    2.43669;    
    n2    =    -1.58277099237e-3; %-(MZI_0.ng - n1)/MZI_0.wl; 
    
    dng   = 1.95046439629e-4;
    n3    = -dng/(2*MZI_0.wl);        
    alpha = MZI_0.alpha;
    b     = MZI_0.b;     
    x0    = [n1, n2, n3, alpha, b];

    % constraints
    lb = [1,   -Inf, -Inf, MZI_0.alpha    , -Inf];
    ub = [Inf,  Inf,  Inf, MZI_0.alpha+30 ,  Inf];

    mziModel = @(x, wl) 10*log10( ...
        (1/4) * ...
        abs( 1 + exp( ...
             -1i*(2*pi*( x(1) + x(2).*(wl - MZI_0.wl) + x(3).*(wl - MZI_0.wl).^2 ) ...
                       * MZI_0.dL ./ (wl*1e-9) ) ...
             - x(4)*MZI_0.dL/2 ...
        ) ).^2 ...
    ) + x(5);

    [xFit, resnorm] = lsqcurvefit(mziModel, x0, wl, y, lb, ub);

    disp( sprintf( ...
      '[FIT RESULT] n1: %.6f, n2: %.6f, n3: %.6f, b: %.6f', ...
      xFit(1), xFit(2), xFit(3), xFit(4)));

    y_fit = mziModel(xFit, wl);
    plot( wl, y, 'LineWidth', 3, 'DisplayName','measured' ); 
    plot( wl, y_fit, 'r-', 'LineWidth', 3, 'DisplayName','fit' );

xlim([1309, 1311]);
xlabel 'Wavelength (nm)'
ylabel 'Output Power (dB)'
title(fig_title); legend('show'); grid on; grid minor; set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title)); hold off;

% Calculate FSR vs Wavelength
figure('Position', get(0, 'ScreenSize')); clf; hold on;
    device    = MZI_dev;  
    fig_title = 'FSR and Group Index vs Wavelength';

    %wl    = linspace(1309.5, 1310.5, 100000);
    %wl    = linspace(1285, 1345, 100000);
    y_fit = mziModel(xFit, wl);

    [pks, pks_idx] = findpeaks(-y);
    FSR = diff(wl(pks_idx));
    FSR(end+1) = FSR(end); % padding data

    p       = polyfit(wl(pks_idx), FSR, 1);
    FSR_fit = polyval(p, wl);

    plot(wl(pks_idx), FSR,     'bo', 'LineWidth', 2, 'HandleVisibility','off');
    plot(wl,           FSR_fit, 'b-', 'LineWidth', 3, 'DisplayName', 'FSR Fit');
%ylim([.9*min(FSR), 1.1*max(FSR)]);

ylabel 'FSR (nm)';
xlabel 'Wavelength (nm)';
title(fig_title); legend('show'); grid on; grid minor; set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title)); hold off;

% n_eff and group index plot
figure('Position', get(0, 'ScreenSize')); clf; hold on;
    device    = MZI_dev;  
    fig_title = 'Effective and Group Index vs Wavelength';


    xFit(3) = n3;
    neff = xFit(1) + xFit(2).*(wl - MZI_0.wl) + xFit(3).*(wl - MZI_0.wl).^2;
    dneff = xFit(2) + 2*xFit(3).*(wl - MZI_0.wl);
    ng    = neff - wl.*dneff;

    % Load simulated results
    chip1_mode = readmatrix('sim\chip1_wg_mode_sim.txt');
    
    c = 3e8; 
    f = chip1_mode(:,1);         
    neff_real = chip1_mode(:,2); 
    ng_real = c./chip1_mode(:,8);
    lambda = c ./ f;         
    lambda_nm = lambda * 1e9;
    p = polyfit(lambda_nm, neff_real, 1);
    neff_fit = polyval(p, wl);
    p_ng = polyfit(lambda_nm, ng_real, 1);
    ng_fit = polyval(p_ng, wl);

yyaxis left;
    plot(wl, neff, 'b-', 'LineWidth', 3, 'DisplayName', 'Measured Effective Index Fit');
    plot(wl, neff_fit, 'b--', 'LineWidth', 3, 'DisplayName', 'Simulated Effective Index');
ylabel 'Effective Index';

yyaxis right;
    plot(wl, ng, 'r-', 'LineWidth', 3, 'DisplayName', 'Measured Group Index Fit');
    plot(wl, ng_fit, 'r--', 'LineWidth', 3, 'DisplayName', 'Simulated Group Index');
ylabel 'Group Index';

xlabel 'Wavelength (nm)';
title(fig_title); legend('show'); grid on; grid minor; set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title)); hold off;

% just the simulated plot
figure('Position', get(0, 'ScreenSize')); clf; hold on;
    device    = MZI_dev;  
    fig_title = 'Simulated Effective and Group Index vs Wavelength';

yyaxis left;
    plot(wl, neff_fit, 'b-', 'LineWidth', 3, 'DisplayName', 'Simulated Effective Index');
ylabel 'Effective Index';

yyaxis right;
    plot(wl, ng_fit, 'r-', 'LineWidth', 3, 'DisplayName', 'Simulated Group Index');
ylabel 'Group Index';

xlabel 'Wavelength (nm)';
title(fig_title); legend('show'); grid on; grid minor; set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title)); hold off;
    