%% LPC Extractor
% To compute the linear prediction coefficient matrix and excitation signal
% of a given signal
%% Induced by Final_Project.m


% (singal, frame length, order of p, sampling freq) => (lpc, excitation signal)

function [lpcffs, exSig] = lpcExtractor(sigIn, framelen, lapRatio, p, sampleF)
    
    L = framelen * sampleF;
    if L<=p
    disp('Linear prediction requires the num of equations to be greater than the number of variables.');
    end

    numFrames = floor(length(sigIn) / L);

    % variable to return
    lpcffs = zeros(p+1, numFrames);
    exSig = zeros(size(sigIn));
    e_n = zeros(p+L, 1);

    if mod(length(sigIn), L) < p
        sigIn = vertcat(sigIn, zeros(p, 1)); % padding 
    end

    % pre-emphasis
    sigEm = filter([1 -0.95],1,sigIn);

    % window selectiom
    win = hann(L+p);
    lapLength = round(lapRatio * (L+p));


    %% Linear prediction and smooth synthesis of the estimated source e_n
    for kk = 1:numFrames

        ind = (kk-1)*L+1:kk*L+p;
        sigwin = sigEm(ind) .* win;

        A = lpc(sigwin, p);
        lpcffs(:, kk) = A'; % To record the lpc in each frame

        e_n = sigwin - filter([0 -A(2:end)], 1, sigwin); % computing the excitation vector 
        e_n = filter(1, [1 -0.95], e_n);

        if kk ~= 1
            exSig(ind(1:lapLength)) = 0.5 * tmp + 0.5 * e_n(1:lapLength);
            exSig(ind(lapLength+1:end)) = e_n(lapLength+1:end);
            tmp = e_n(end-lapLength+1:end); % for doing overlapping operation	    
        else
            exSig(ind) = e_n;
            tmp = e_n(end-lapLength+1:end); % for doing overlapping operation
        end

    end



end