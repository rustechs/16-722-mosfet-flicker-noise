%% keithley2400SerialLogger.m
%
% Communicates with a Keithley 2400 SMU over a serial RS232 link in order 
% to perform R_DS(on) measurements on a deep-triode biased MOSFET.
%
% Alexander Volkov
% 16-722

%% Clean up
clc;clear;close all

%% Parameters
port = '/dev/ttyUSB0';
experimentDuration = 3*3600; % [sec]
vds = 0.5; % [V]
imax = 1; % [A]
saveName = '../data/trial2.mat';

%% Set up serial
SMU = serial(port,'BaudRate',57600);

%% Set up interface timer
t = keithleyInterfaceTimer(SMU,experimentDuration,vds,imax,saveName);

% Start the timer
start(t);