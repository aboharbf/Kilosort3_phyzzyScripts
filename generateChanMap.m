function chanMap = generateChanMap(chanCount, fileName)
% a function which returns the appropriate channel map vector for use with
% kilosort. Only necessary due to the differences in recording across days
% and monkeys in my particular dataset.

if contains(fileName, 'Mo')
  monkey = 'Mo';
else
  monkey = 'Sam';
end

Nchannels = chanCount;
fs = 30000; % sampling frequency

if strcmp(monkey, 'Sam') && Nchannels == 16
  % 1 16 channel probe
  connected = true(Nchannels, 1);
  chanMap   = [1 9 2 10 3 11 4 12 5 13 6 14 7 15 8 16];
  chanMap0ind = chanMap - 1;
  xcoords   = ones(Nchannels,1);
  ycoords   = [0:Nchannels-1] * -100;
  kcoords   = ones(Nchannels,1); % grouping of channels (i.e. tetrode groups)
  
  % save('chanMap_Sam_16x1.mat', 'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs')
  
elseif strcmp(monkey, 'Sam') && Nchannels == 32
  % 2 16 channel probe
  Nchannels = 16;
  connected = true(Nchannels*2, 1);
  chanMap   = [1 9 2 10 3 11 4 12 5 13 6 14 7 15 8 16];
  chanMap   = [chanMap, chanMap + length(chanMap)];
  chanMap0ind = chanMap - 1;
  xcoords   = [ones(Nchannels,1); ones(Nchannels,1)*20]; % if 1 = 100 um, 10 = 1 mm, 20 = 2 mm
  ycoords   = [[1:Nchannels]' * -100; [1:Nchannels]' * -100];
  kcoords   = [ones(Nchannels,1); ones(Nchannels,1)*2]; % grouping of channels (i.e. tetrode groups)
  Nchannels = 32;
  
  % save('chanMap_Sam_16x2.mat', 'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs')
  
elseif strcmp(monkey, 'Mo') && Nchannels == 32
  % Mo Layouts
  % 1 32 channel probe
  Nchannels = 32;
  connected = true(Nchannels, 1);
  chanMap   = [1 9 2 10 3 11 4 12 5 13 6 14 7 15 8 16];
  chanMap   = [chanMap, chanMap + length(chanMap)];
  chanMap0ind = chanMap - 1;
  xcoords   = ones(Nchannels,1);
  ycoords   = [1:Nchannels]' * -100;
  kcoords   = ones(Nchannels,1); % grouping of channels (i.e. tetrode groups)
  
  %   save('chanMap_Mo_32x1.mat', 'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs')
  
elseif strcmp(monkey, 'Mo') && Nchannels == 64
  
  % 1 32 channel probe
  Nchannels = 32;
  connected = true(Nchannels*2, 1);
  chanMap   = [1 9 2 10 3 11 4 12 5 13 6 14 7 15 8 16];
  chanMap   = [chanMap, chanMap + length(chanMap)];
  chanMap   = [chanMap, chanMap + length(chanMap)];
    
  chanMap0ind = chanMap - 1;
  xcoords   = [ones(Nchannels,1); ones(Nchannels,1)*20]; % if 1 = 100 um, 10 = 1 mm, 20 = 2 mm
  ycoords   = [[1:Nchannels]' * -100; [1:Nchannels]' * -100];
  kcoords   = [ones(Nchannels,1); ones(Nchannels,1)*2];         % grouping of channels (i.e. tetrode groups)
  Nchannels = 64;
  
  %   save('chanMap_Mo_32x2.mat', 'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs')
  
else
  if strcmp(monkey, 'Mo')
    warning('Running script for non-standard number of channels')
    % Mo recording w/ less than 32 channels, or 33 channels
    switch Nchannels
      case 33
        %         Nchannels = 32;
        Nchannels = 32;
        connected = [true(Nchannels, 1); true];       
        chanMap   = [1 9 2 10 3 11 4 12 5 13 6 14 7 15 8 16];
        chanMap   = [chanMap, chanMap + length(chanMap), 33];
        
        chanMap0ind = chanMap - 1;
        xcoords   = [ones(32,1); 20];
        ycoords   = [[[1:Nchannels]' * -100]; 0];
        kcoords   = [ones(Nchannels,1); 1]; % grouping of channels (i.e. tetrode groups)
        
      otherwise
        connected = true(Nchannels, 1);
        chanMap   = 1:Nchannels;        
        chanMap0ind = chanMap - 1;
        xcoords   = 1:Nchannels * 200;
        ycoords   = 1:Nchannels * 200;
        kcoords   = 1:Nchannels; % grouping of channels (i.e. tetrode groups)
    end
    
  else
    error('Sam recording registering as non-standard number, investigate')
  end
  
end

save('chanMap.mat', 'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs')

  

