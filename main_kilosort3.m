%% Batch kilosort operation
% A rewritten version of the main_kilsort3. The core of it is the same, the
% file path management, the chanMap (assumed to exist), and other path
% features are different.

% Paths to data
dataDir = 'E:\EphysDataBin';      % This folder should contain a sub directory structure where each
kiloSortDir = 'C:\OneDrive\Lab\ESIN_Ephys_Files\Analysis\Spike Sorting\Kilosort';                        % path to kilosort dir
kiloSortBatchDir = 'C:\OneDrive\Lab\ESIN_Ephys_Files\Analysis\Spike Sorting\KilosortBatchDir';           % path to kilosort dir
npyDir = 'C:\OneDrive\Lab\ESIN_Ephys_Files\Analysis\Spike Sorting\npy-matlab';                           % path to Phy for outputs, visualizing
tempDir = 'D:\kiloSortTmp';                                 % path to temporary binary file (same size as data, should be on fast SSD). This will need to be a cell array if you want to do parallel.

configFileHandle = @StandardConfig_phyzzy;                  % Changed config file from a script to a function.
% configFilePath = 'C:\OneDrive\Lab\ESIN_Ephys_Files\Analysis\Spike Sorting\KilosortBatchDir\StandardConfig_phyzzy.m';   % Config file path

% Add relevant paths
addpath(genpath(kiloSortDir))                               % Add path to kilosort folder
addpath(genpath(kiloSortBatchDir))                          % Add path to kilosort folder
addpath(genpath(npyDir))                                    % for converting to Phy

% Identify all the bin files to be processed
binFiles = dir(fullfile(dataDir, '**', '*.bin'));
binFileDir = {binFiles.folder}';
binFiles = fullfile(binFileDir, {binFiles.name}');
chanMapFiles = fullfile(binFileDir, 'chanMap.mat');         % I do this due to the variability in my chan counts, layouts, etc. This could be a single path for a more traditional recording setup.
errorMsg = cell(size(binFiles));
origDir = pwd;

for bin_i = 57:length(binFiles)
  
  fprintf('Processing File %s \n', binFiles{bin_i})
  
  % Begin defining variables
  ops = configFileHandle();
  ops.fbinary = binFiles{bin_i};   % find the binary file replaced w/ actual path.
  ops.trange    = [0 Inf]; % time range to sort
  
  ops.fproc   = fullfile(tempDir, 'temp_wh.dat');   % proc file on a fast SSD
  
  % Find the appropriate chanMap
  ops.chanMap = chanMapFiles{bin_i};
  tmp = load(chanMapFiles{bin_i});
  ops.NchanTOT  = length(tmp.chanMap); % total number of channels in your recording
  
  % main parameter changes from Kilosort2 to v2.5
  ops.sig         = 20;           % spatial smoothness constant for registration
  ops.fshigh      = 300;          % high-pass more aggresively
  ops.nblocks     = 5;            % blocks for registration. 0 turns it off, 1 does rigid registration. Replaces "datashift" option.
  ops.Th          = [9 9];        % main parameter changes from Kilosort2.5 to v3.0
  ops.spkTh       = -4;
  
  % this block runs all the steps of the algorithm
  try
    % Placed here for orderly error detection.
    if length(tmp.chanMap) < 15
      error('Not enough channels');
    end
    
    rez                = preprocessDataSub(ops);
    rez                = datashift2(rez, 1);
    [rez, st3, tF]     = extract_spikes(rez);
    rez                = template_learning(rez, tF, st3);
    [rez, st3, tF]     = trackAndSort(rez);
    rez                = final_clustering(rez, tF, st3);
    rez                = find_merges(rez, 1);
    
    % Make output appropriate for Phy.
    rezToPhy2(rez, binFileDir{bin_i});
    
    close all
    
  catch MyErr
    errorMsg{bin_i} = MyErr;
  end

end

errorInd = ~cellfun('isempty', errorMsg);
errorMsg = errorMsg(errorInd);
errorStack = [errorMsg{:}];
errorStack = [{errorStack.message}]';
files2Check = binFiles(errorInd);
