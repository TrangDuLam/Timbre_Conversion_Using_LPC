%% LPC Synthesizer
% To synthesize the signal from given lpc matrix and excitation source
% signal 
%% Indiced by Final_Project.m

% Arguments => return
% (lpc, excitation source, valid time frame, overlapping ration,
% frame length, order of p, sampling freq) => synthesized signal

% last mdf 7.6.2022
% Yulan Chuang 30.5.2022

function yout = lpcSynthesizer(cffsFilter, enSigTarget, validFrames, lapRatio,framelen, p, sampleF)

    L = framelen * sampleF;
    win = hann(L+p);
    yout = zeros(L*validFrames+p, 1);
    yFrame = zeros(L+p, 1);

    if mod(length(enSigTarget), L) < p
        enSigTarget = vertcat(enSigTarget, zeros(p, 1)); % padding 
    end

    % overlapping operation modified Jun 7
    if lapRatio > 1
        disp("The overlapping ratio should be less than 1");
    end
    lapLength = round(lapRatio * (L+p)); % Overlapping length assignation 
    
    % build filter for synthesis
    for kk = 1:validFrames
        ind = (kk-1)*L+1:kk*L+p;
        enwin = enSigTarget(ind) .* win;
        yFrame = filter(1, cffsFilter(:, kk), enwin); % Synthesis process

        % concatenate
        if kk ~= 1
            yout(ind(1:lapLength)) = 0.5 * tmp + 0.5 * yFrame(1:lapLength);
            yout(ind(lapLength+1:end)) = yFrame(lapLength+1:end);
            tmp = yFrame(end-lapLength+1:end);
        else
            yout(ind) = yFrame;
            tmp = yFrame(end-lapLength+1:end);
        end

    end
    

end