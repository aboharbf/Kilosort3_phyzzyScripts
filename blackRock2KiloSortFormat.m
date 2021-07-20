function blackRock2KiloSortFormat()
% A function which processes the typical output of blackrock files which
% contains the raw traces of data (x.ns5, if sampled @ 30 kHz), and
% produces a file in a similarly structured directory tree which can be read by kilosort (x.bin)

% Path to Blackrock file reading tools
blackrockDir = 'C:\OneDrive\Lab\ESIN_Ephys_Files\Analysis\phyzzyML\dependencies\NPMK';
addpath(genpath(blackrockDir))

% Directory of Interest with x.ns5 files
dataDir = 'D:\EphysData\Data';      % The structure which is searched for
dataDirOut = 'E:\EphysDataBin';     % The structure which replaces the line above in the data file paths

% Identify files to be converted
files2ProcStruct = dir(fullfile(dataDir, '**', '*.ns5'));
files2Proc = fullfile({files2ProcStruct.folder}, {files2ProcStruct.name})';

% Generate the full path for the output
fileCoreName = extractBefore({files2ProcStruct.name}, '.ns5');
fileOutPaths = fullfile({files2ProcStruct.folder}', fileCoreName');
fileOutName = strcat(extractBefore({files2ProcStruct.name}, '.ns5'), '.bin')';
dataOutDirs = cellfun(@(x) strrep(x, dataDir, dataDirOut), fileOutPaths, 'UniformOutput', false); % Swap to E drive for output
fileOutName = fullfile(dataOutDirs, fileOutName);

% Don't worry about recordings prior to 2020, since those were single
% channel
keepInd = contains(files2Proc, {'2020', '2021'});
fileOutName = fileOutName(keepInd);
files2Proc = files2Proc(keepInd);

% Identify channels per recording to actually take
largerChSet = contains(files2Proc, 'Mo');

% for every file...
for file_i = 1:length(files2Proc)
  
  % If the file has already been processed, skip
  if exist(fileOutName{file_i}, 'file')
    delete(fileOutName{file_i})
  end
  
  % Open the file
  nsxStruct = openNSx(files2Proc{file_i}, 'uV');
  electrodeNum = [nsxStruct.ElectrodesInfo.ElectrodeID];
  
  if largerChSet(file_i)
    dataInd = electrodeNum <= 128;
  else
    dataInd = electrodeNum <= 96;
  end
  
  % Extract the relevant data
  dat = nsxStruct.Data(dataInd, :);
  
  % Make sure the folders exist.
  outDir = fileparts(fileOutName{file_i});
  if ~exist(outDir, 'dir')
    mkdir(outDir)
  end
  
  % write it to a binary appropriate for kiloSort (code pulled from kiloSort github page)
  datI = int16(dat);
  fid = fopen(fileOutName{file_i}, 'w');
  fwrite(fid, datI, 'int16');
  fclose(fid);  
  
  % Generate the channel map appropriate for the file, and save it in the
  % same folder as the .bin file.
  generateChanMap(sum(dataInd), fileOutName{file_i});
  
end

end