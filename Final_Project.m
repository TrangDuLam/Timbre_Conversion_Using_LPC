%% Main Function of Final Project ASAS 2022



% Last mdf 7.6.2022
% Yulan Chuang, 29.05.2022

clear; close all;


%% signal inputs
uniFs = 44100; % unified sampling freq.

% Read in the signal to extract excitation signal
[x1, fs1] = audioread("guitar_echord.wav");
if fs1 ~= uniFs
    x1 = resample(x1, uniFs, fs1);
end
% channel seperation
x1_l = x1(:, 1);
x1_r = x1(:, 2);

% Read in the signal to build the mapping filter
[x2, fs2] = audioread("Pipa_E.wav");
if fs2 ~= uniFs
    x2 = resample(x2, uniFs, fs2);
end
% Channel seperation 
x2_l = x2(:, 1);
x2_r = x2(:, 2);


%% Mutual Parameters Assignment
framelen = 0.1;
p = 30;
L = round(framelen * uniFs);
N = 2^(1+floor(log2(5*L+1)));
synOverlapRatio = 0.1;


%% Feature Extraction
[cffs1_l, excit1_l] = lpcExtractor(x1_l, framelen, synOverlapRatio, p, uniFs);
[cffs1_r, excit1_r] = lpcExtractor(x1_r, framelen, synOverlapRatio, p, uniFs);
[cffs2_l, excit2_l] = lpcExtractor(x2_l, framelen, synOverlapRatio, p, uniFs);
[cffs2_r, excit2_r] = lpcExtractor(x2_r, framelen, synOverlapRatio, p, uniFs);


%% Synthesis
validFrameNum = min(size(cffs2_l, 2), round(length(excit1_l) / L));
% min(filter, source)
% To check the valid time length of synthesis

% usage note : (to target, from source, **kwgs)
yout_l = lpcSynthesizer(cffs2_l, excit1_l, validFrameNum, synOverlapRatio, framelen, p, uniFs);
yout_r = lpcSynthesizer(cffs2_r, excit1_r, validFrameNum, synOverlapRatio, framelen, p, uniFs);
yout = [yout_l yout_r];
%audiowrite("GZ_A4_Syn.wav", yout, uniFs);


%% Signal Validation And Evaluation
[xV, fsV] = audioread("Pipa_E.wav");
if fsV ~= uniFs
    xV = resample(xV, uniFs, fsV);
end
xV_l = xV(:, 1);
xV_r = xV(:, 2);

[cffsV_l, excitV_l] = lpcExtractor(xV_l, framelen, synOverlapRatio, p, uniFs);
[cffsV_r, excitV_r] = lpcExtractor(xV_r, framelen, synOverlapRatio, p, uniFs);
frameForxV = size(cffsV_l, 2);
SynSigV_l = lpcSynthesizer(cffsV_l, excitV_l, frameForxV, synOverlapRatio, framelen, p, uniFs);
SynSigV_r = lpcSynthesizer(cffsV_r, excitV_r, frameForxV, synOverlapRatio, framelen, p, uniFs);
SynSig = [SynSigV_l SynSigV_r];
%audiowrite("GZ_A4_Valid.wav", SynSig, uniFs);

%% Plot Region
% Show spectrogram first
figure(1)
spectrogram(x1_l,hann(L),16,N,uniFs,'yaxis');
ylim([0 2]);
title("Spectrogram of Guitar (Am)", 'FontSize', 14);
%saveas(gcf, "Guitar_Am.png");

figure(2)
spectrogram(x2_l,hann(L),16,N,uniFs,'yaxis');
ylim([0 2]);
title("Spectrogram of Pipa (Em)", 'FontSize', 14);
%saveas(gcf, "Pipa_Em.png");

figure(3)
spectrogram(yout_l,hann(L),16,N,uniFs,'yaxis');
ylim([0 2]);
title("Spectrogram of Synthesized Tone", 'FontSize', 14);
%saveas(gcf, "SynPP_Am.png");


figure(4)
spectrogram(SynSigV_l,hann(L),16,N,uniFs,'yaxis');
ylim([0 2]);
title("Spectrogram of True Tone", 'FontSize', 14);
%saveas(gcf, "RealGZ_C3fromC4.png");


% Validation 
minShowLen = min([length(xV_l) length(yout_l) length(SynSigV_l)]);
timeLabel = 1/uniFs:1/uniFs:minShowLen/uniFs;

figure('Renderer', 'painters', 'Position', [10 10 1333 1000])
subplot(311)
plot(timeLabel, xV_l(1:minShowLen));
xlabel("Time (sec)");
ylabel("Amplitude");
title("Original Sample");
subplot(312)
plot(timeLabel, yout_l(1:minShowLen));
xlabel("Time (sec)");
ylabel("Amplitude");
title("Synthesized Tone");
subplot(313)
plot(timeLabel, SynSigV_l(1:minShowLen));
xlabel("Time (sec)");
ylabel("Amplitude");
title("Real Tone Recovered From LPC");
sgtitle("Signal Validation Result");
saveas(gcf, "PP_Syn.png");
