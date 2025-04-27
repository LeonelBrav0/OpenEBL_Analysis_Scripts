% Laser rate equation model
% by Lukas Chrostowski, 2020

function dy = LaserRateEqs (t, y)

    global I;   % current
    S = y(1);   % Photon Number
    N = y(2);   % Carrier Number

    % laser parameters
    tp = 3e-12; % photon lifetime, s
    ts = 2e-9;  % carrier lifetime, s
    G0 = 1e4;   % Modal gain, s-1
    Ntr = 4e6;  % Transparency carrier number
    eta = 0.9;  % Quantum efficiency
    Rsp = 100e9;% Spontaneous emission rate

    % constants
    q = 1.6e-19;

    dy = zeros(2,1);
    G = G0 * ( N - Ntr);
    dy(1) = (G - 1/tp) * S + Rsp;       % dS/dt, photon number
    dy(2) = eta * I / q - N/ts - G * S; % dN/dt, carrier number
end     
      