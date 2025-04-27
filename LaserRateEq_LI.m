% Laser rate equation model, Light output (L) versus current (I), 
% (LI plot)
% by Lukas Chrostowski, 2020

% Use Runge-Kutta ODE solver
% https://www.mathworks.com/help/matlab/math/choose-an-ode-solver.html

function LaserRateEq_LI

    global I;   % current
    y = [0 0; 0 0]; % initial conditions for the laser (off)
    
    % perform a sweep for the bias current, I
    I_sweep = 0:0.1e-3:20e-3;

    % record
    S_sweep = zeros (length(I_sweep),1);
    N_sweep = zeros (length(I_sweep),1);

    % Solve the rate equations with a high accuracy, until we have reached 
    % a steady-state at 10 ns, which will depend on the laser parameters
    options = odeset('RelTol',1e-6,'AbsTol',1e-6);
    time = [0 10e-9];   % simulation time

    for i = 1:length(I_sweep)
        I = I_sweep(i);

        % Solve the rate equations using the previous results as input for
        % the next simulation. Namely, don't restart from 0, but rather 
        % increase the current. Simulation time will be faster
        [t, y] = ode45(@LaserRateEqs, time, y(end,:), options);

        % Record the photon and carrier numbers, at steady-state
        S_sweep(i) = y(end,1);
        N_sweep(i) = y(end,2);
    end
    
    % Plot the Light-Current (LI) plot
    data_lumerical_LI = load('sim/DML_LI.mat');
    
    figure;
    clf;
    hold on;
    plot (I_sweep*1e3, S_sweep * 4.27e-8/2e-3, 'b', 'LineWidth',3);
    plot (data_lumerical_LI.r.current/1e-3, squeeze(data_lumerical_LI.r.power__W_(1,:,:)).' / 1e-3, 'g--', 'LineWidth', 2.5);
    legend('Matlab','Lumerical');
    title('Matlab vs Lumerical Laser LI Curve');

    xlabel ('Current [mA]')
    ylabel ('Optical output power [mW]')
    
    grid on; grid minor;
    set (gca, 'FontSize',22)
    saveas(gcf, 'LI.png')
    hold off;

end

