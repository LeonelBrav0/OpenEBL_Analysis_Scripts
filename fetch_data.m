
%********************************************************
% CHIP 1 DATA FETCHER
%********************************************************
Chip1.url = 'https://qdot-nexus.phas.ubc.ca:25683/s/qioaZK3zJJQc44M/download';
Chip1.download_dir = 'chip1_data/';
Chip1.polarization = 'TE';
Chip1.center_wl = '1310';
Chip1.temp = '25C';
Chip1.rundir = fullfile(Chip1.download_dir, 'die_1', strcat(Chip1.polarization, '_', Chip1.center_wl, '_', Chip1.temp));
Chip1.names = { ...
        'LeonelBravo_MZI1', ... % MZI Meanderline #1 [DEAD]
        'LeonelBravo_MZI2', ... % MZI Spiral #1
        'LeonelBravo_MZI3', ... % MZI ∆L=0 Calibration
        'LeonelBravo_MZI4', ... % MZI Meanderline #2 [DEAD]
        'LeonelBravo_MZI5', ... % MZI Spiral #2
        'PCM_StraightLongWGloss40521TE' , ... % Straight Waveguide Loss Calibration
        'PCM_StraightLongWGloss20504TE' , ... % Straight Waveguide Loss Calibration
        'PCM_StraightLongWGloss10304TE' , ... % Straight Waveguide Loss Calibration
        'PCM_StraightLongWGloss0TE', ... % GC Pair Calibration
    };

% LOAD CHIP1 DATA
data_fetcher(Chip1.url, Chip1.download_dir);

for i = 1:length(Chip1.names)
    rundir = fullfile(Chip1.rundir, Chip1.names{i});
    mat_file = dir(fullfile(rundir, '*.mat'));

    if ~isempty(mat_file)
        mat_file = fullfile(rundir, mat_file(1).name);
        Chip1.mat(i) = load(mat_file);
        Chip1.data(i).wl = Chip1.mat(i).testResult.header.wavelength;

        % Extract all channels dynamically
        channelFields = fieldnames(Chip1.mat(i).testResult.rows);
        for j = 1:length(channelFields)
            chanName = channelFields{j};
            Chip1.data(i).chan{j} = Chip1.mat(i).testResult.rows.(chanName);
        end
    else
        warning('No .mat file found in folder: %s', rundir);
    end
end

%********************************************************
% CHIP 2 DATA FETCHER
%********************************************************
Chip2.url = "https://qdot-nexus.phas.ubc.ca:25683/s/KwY62AbE3b7NMNS/download";
Chip2.download_dir = 'chip2_data/';
Chip2.polarization = 'TE';
Chip2.center_wl = '1310';
Chip2.temp = '25C';
Chip2.rundir = fullfile(Chip2.download_dir, '2025-03-31_On-Chip_and_Off-chip_Laser_Measurement_Data', ...
                            'Chip2b_bottom', 'Sweeps');
Chip2.names = { ...
        'LeonelBravo_MZI1', ... % On-chip laser MZI
    };

% LOAD CHIP1 DATA
data_fetcher(Chip2.url, Chip2.download_dir);

for i = 1:length(Chip2.names)
    rundir = fullfile(Chip2.rundir, Chip2.names{i});
    mat_file = dir(fullfile(rundir, '*.mat'));

    if ~isempty(mat_file)
        mat_file = fullfile(rundir, mat_file(1).name);
        Chip2.mat(i) = load(mat_file);
        Chip2.data(i).wl = Chip2.mat(i).testResult.header.wavelength;

        % Extract all channels dynamically
        channelFields = fieldnames(Chip2.mat(i).testResult.rows);
        for j = 1:length(channelFields)
            chanName = channelFields{j};
            Chip2.data(i).chan{j} = Chip2.mat(i).testResult.rows.(chanName);
        end
    else
        warning('No .mat file found in folder: %s', rundir);
    end
end

function downloadedFile = data_fetcher(url, output_dir)
% FETCH_DATA Downloads a ZIP file from the given URL,
% extracts its contents directly into output_dir,
% and deletes the ZIP file afterward.
% Only runs if output_dir does NOT already exist.
%
% Args:
%     url (char): The URL to download from.
%     output_dir (char): The directory to save and extract the contents to.
%
% Returns:
%     downloadedFile (char): The path to the downloaded ZIP file before deletion,
%     or empty if nothing was downloaded or an error occurred.

    if nargin < 2
        output_dir = 'downloaded_files';
    end

    % Check if the output directory already exists
    if exist(output_dir, 'dir')
        fprintf('Directory "%s" already exists. Skipping download.\n', output_dir);
        downloadedFile = '';
        return;
    end

    % Create output directory
    mkdir(output_dir);

    % Temporary ZIP file path
    zipFilePath = fullfile(output_dir, 'temp_download.zip');

    try
        % Download the ZIP file
        websave(zipFilePath, url);
        fprintf('Downloaded file saved to %s\n', zipFilePath);

        % Extract contents directly into output_dir
        unzip(zipFilePath, output_dir);
        fprintf('Extracted contents to %s\n', output_dir);

        % Delete the ZIP file after extraction
        delete(zipFilePath);
        fprintf('Deleted ZIP file: %s\n', zipFilePath);

        downloadedFile = zipFilePath;

    catch ME
        fprintf('Error: %s\n', ME.message);
        downloadedFile = '';
    end
end
