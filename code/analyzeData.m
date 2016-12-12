%% analyzeData.m
%
% Processes collected FET on-resistance datasets, computes FFTs.
%
% Alexander Volkov
% 16-722

% Clean up
clc;clear;close all

% Find data files
dataDir = '../data/';
dataFiles = dir(fullfile(dataDir,'trial*.mat'));

for i = 1:length(dataFiles)
    
    % Load measurements, stored in data matrix
    load([dataDir dataFiles(i).name]);
    
    % Offset to relative time
    tRaw = data(:,2)-data(1,2);
    tRaw(19)
    
    % Create fixed timebase
    Fs = 100; % [Hz]
    T = 1/Fs;
    tFixedStep = 0:T:max(tRaw);
    L = length(tFixedStep);
    
    if (mod(L,2))
        tFixedStep(1:end-1);
        L = L-1;
    end
    
    % interpolate data for fixed timestep
    dataInterp = interp1(tRaw,data(:,1),tFixedStep);
    
    %figure
    %plot(tFixedStep,dataInterp,tRaw,data(:,1));
    
    % Compute FFT
    ampSpectrumFull = abs(fft(dataInterp)/L);
    ampSpectrum = ampSpectrumFull(1:L/2+1);
    ampSpectrum(2:end-1) = 2*ampSpectrum(2:end-1);
    powerSpectrum = ampSpectrum.^2;
    
    % Compute frequency domain
    f = Fs*(0:(L/2))/L;

    % Plot FFT
    figure
    semilogx(f,10*log10(powerSpectrum));
    hold on
    grid minor
    
    % Compute best fit
    % powerSpectrumFit = fit(f',powerSpectrum','a*x^(-b)','Lower',[1e0 0.5],'Upper',[1e4 1.5]);
    %fprintf('\nBest fit results (log(P) = -b*log(f)+a): a = %.4f\tn = %.4f\n',powerSpectrumFit.a,powerSpectrumFit.b);
    
    % Manual best fit
    switch i
        case 1
            aMan = 1e-4;
            bMan = 1.6;
        case 2
            aMan = 2e-12;
            bMan = 1.9;
    end
    
    semilogx(f,10*log10(aMan*f.^(-bMan)));
    
    name = sprintf('Trial %g',i);
    
    xlabel('Frequency [Hz]');
    ylabel('Noise Power [dB_{W/Hz}]');
    legend(name,'Manual Best Fit');
    
    figname = sprintf('trial%g-spectral-power',i);
    
    print(figname,'-depsc'); 
    
end