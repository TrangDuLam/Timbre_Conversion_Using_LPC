%% 挪威的森林曲風轉換程式
% Revised from Final_Project.m


clear; close all;


%% Signal read-in
%To read "伍佰-挪威的森林" as excitation source
[x, fs] = audioread("norway_piano_sample.wav");
x(x == 0) = 0.001; % Avoid null
%sound(x, fs)
% Channel seperation
x_l = x(:, 1);
x_r = x(:, 2);

[sigMap, fs2] = audioread("GZ_mapping_filter.wav");
sigMap_l = sigMap(:, 1);
sigMap_r = sigMap(:, 2);

%% Mutual Parameters Assignment
framelen = 0.6;
p = 15;
L = round(framelen * fs);
N = 2^(1+floor(log2(5*L+1)));
synOverlapRatio = 0.25;

%% Song BKC
% 

%% Signal features extraction
[cffs_xl, en_xl] = lpcExtractor(x_l, framelen, synOverlapRatio, p, fs);
[cffs_xr, en_xr] = lpcExtractor(x_r, framelen, synOverlapRatio, p, fs);
[cffs_sigMl, en_sigMl] = lpcExtractor(sigMap_l, framelen, synOverlapRatio, p, fs);
[cffs_sigMr, en_sigMr] = lpcExtractor(sigMap_r, framelen, synOverlapRatio, p, fs);

%% Mapping filter building
filterExtension = floor(size(cffs_xl, 2) / size(cffs_sigMl, 2));
cffs_filter_l = repmat(cffs_sigMl, 1, filterExtension);
cffs_filter_r = repmat(cffs_sigMr, 1, filterExtension);
%disp(size(cffs_filter_l, 2)); => debug usage

validFrameNum = size(cffs_filter_l, 2);


%% Synthesis
yout_l = lpcSynthesizer(cffs_filter_l, en_xl, validFrameNum, synOverlapRatio, framelen, p, fs);
yout_r = lpcSynthesizer(cffs_filter_r, en_xr, validFrameNum, synOverlapRatio, framelen, p, fs);
yout = [yout_l yout_r];


%% Plot region 

figure(1)
spectrogram(x_l,hann(L),16,N,fs,'yaxis');

figure(2)
spectrogram(yout_l, hann(L),16,N,fs,'yaxis');
