% On Chip Laser MZI Response Raw Plot
figN=figN+1;
figure(figN);
clf;
hold on;
    device = 1;
    fig_title = 'On-chip Laser MZI Response';

    wl = Chip2.data(device).wl;

    for i=3:3
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

% Power Spectral Density
figN=figN+1;
figure(figN);
clf;
hold on;
    device = 1;
    fig_title = 'PSD On-chip Laser MZI Response';

    wl = Chip2.data(device).wl;
    y  = Chip2.data(device).chan{3};

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
xlim([228.137 228.165]);
title(fig_title);
legend('show');
grid on; grid minor;
set(gca, 'FontSize', 25);
saveas(gcf, sprintf('plots/%s.png', fig_title));
hold off;