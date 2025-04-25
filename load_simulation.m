%********************************************************
% CHIP 1 SIMULATION (BEFORE ADJUSTMENT)
%********************************************************
Chip1_sim.rundir = fullfile("Layout_Files", "chip1", "sim", "initial");
Chip1_sim.names = { ...
        'LeonelBravo_MZI1', ... % MZI Meanderline #1 [DEAD]
        'LeonelBravo_MZI2', ... % MZI Spiral #1
        'LeonelBravo_MZI3', ... % MZI ∆L=0 Calibration
        'LeonelBravo_MZI4', ... % MZI Meanderline #2 [DEAD]
        'LeonelBravo_MZI5', ... % MZI Spiral #2
    };

for i = 1:length(Chip1_sim.names)
    mat_file = dir(fullfile(Chip1_sim.rundir, strcat(Chip1_sim.names{i}, '.mat')));

    if ~isempty(mat_file)
        mat_file = fullfile(Chip1_sim.rundir, mat_file(1).name);
        Chip1_sim.mat(i) = load(mat_file);

        % Assuming all OSA fields have same number of points
        numChannels = numel(fieldnames(Chip1_sim.mat));
        for j = 1:numChannels
            chan_data = getfield(Chip1_sim.mat(i), strcat('t', num2str(j)));
            Chip1_sim.data(i).wl = chan_data.wavelength;
            Chip1_sim.data(i).chan{j} = chan_data.mode_1_gain__dB_(:).';
        end
    else
        warning('No .mat file found in folder: %s', rundir);
    end
end
