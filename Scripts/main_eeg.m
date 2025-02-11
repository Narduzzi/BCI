
function [easy,hard_assist,hard_noassist,features_extracted] = main_eeg(rawsignal,downfactor,low,high,order,text)
%This function takes EEG bdf files,extract the raw data signals with the
%header 

addpath(genpath('..\Recordings'));

%PASS

%biosig_installer
disp('Loading data...')
[signal,header] = sload(rawsignal);
signal = signal';

%CAR spatial filtering
disp('Applying car...')
signal = car(signal);


%Downsampling
downfactor = 8;
fprintf('Downsampling : Factor %0.5f',downfactor)
[header_down,signal_down] = downsampling(header,signal,downfactor);

%{
matr = load('Recordings\data_omar1.mat');
signal_down = matr.signal_down;
header_down = matr.header_down;
%}

%Bandpass filtering
low = 1;
high = 40;
order= 5;
disp('Bandpass filtering...')
Fs = header.SampleRate/downfactor;
signal_filtered = band_filter(low,high,order,Fs,signal_down);

%Partitioning by conditions
disp('Partitioning filtering...')
[easy,hard_assist,hard_noassist] = partitioning(header_down,signal_filtered,text);

%Windowing (already in feature extraction)
%{
window_size = 50;
step_size = 2;
windows_easy = split(easy,window_size,step_size);
windows_hard_assist = split(hard_noassists,window_size,step_size);
windows_hard_noassist = split(hard_noassist,window_size,step_size);
%}


%Windowing and Feature extraction...
disp('Feature extraction...(FOR NOW INVALID)')
window_size = 50;
step_size = 2;
features_extracted = features_extraction(easy,hard_noassist,hard_assist,header,window_size,step_size);

%save features to csv...
%csvwrite('Samples_extracted.csv',features);
end