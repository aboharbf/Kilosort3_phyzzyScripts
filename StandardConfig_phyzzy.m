function ops = StandardConfig_phyzzy()
% ops.chanMap =
% 'D:\GitHub\KiloSort2\configFiles\neuropixPhase3A_kilosortChanMap.mat';  %
% Chan map is now assumed to be sitting in the .bin directory in a
% 'chanMap.mat' file.
% ops.chanMap = 1:ops.Nchan; % treated as linear probe if no chanMap file

ops.fs = 30000;                   % sample rate
ops.fshigh = 150;                 % frequency for high pass filtering (150)
ops.minfr_goodchannels = 0.1;     % minimum firing rate on a "good" channel (0 to skip)
ops.Th = [10 4];                  % threshold on projections (like in Kilosort1, can be different for last pass like [10 4])
ops.lam = 10;                     % how important is the amplitude penalty (like in Kilosort1, 0 means not used, 10 is average, 50 is a lot) 
ops.AUCsplit = 0.9;               % splitting a cluster at the end requires at least this much isolation for each sub-cluster (max = 1)
ops.minFR = 1/50;                 % minimum spike rate (Hz), if a cluster falls below this for too long it gets removed
ops.momentum = [20 400];          % number of samples to average over (annealed from first to second value) 
ops.sigmaMask = 30;               % spatial constant in um for computing residual variance of spike
ops.ThPre = 8;                    % threshold crossings for pre-clustering (in PCA projection space)

%% danger, changing these settings can lead to fatal errors
% options for determining PCs

ops.spkTh               = -4.5;     % spike threshold in standard deviations (-6)
ops.reorder             = 1;      % whether to reorder batches for drift correction. 
ops.nskip               = 25;     % how many batches to skip for determining spike PCs

ops.GPU                 = 1;      % has to be 1, no CPU version yet, sorry
ops.Nfilt               = 1024;   % max number of clusters
ops.nfilt_factor        = 4;      % max number of clusters per good channel (even temporary ones)
ops.ntbuff              = 64;     % samples of symmetrical buffer for whitening and spike detection
ops.NT                  = 64*1024+ ops.ntbuff; % must be multiple of 32 + ntbuff. This is the batch size (try decreasing if out of memory). 
ops.whiteningRange      = 32;     % number of channels to use for whitening each channel
ops.nSkipCov            = 25;     % compute whitening matrix from every N-th batch
ops.scaleproc           = 200;    % int16 scaling of whitened data
ops.nPCs                = 3;      % how many PCs to project the spikes into
ops.useRAM              = 0;      % not yet available
