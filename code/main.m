% This script combines data, screens those data for quality(/inclusion),
% and then performs frequency (and control analyses for the potential 
% effect of eye movements) to compare SSVEP strength after an injection 
% of saline to SSVEP strength after an injection of ketamine
%
% Companion code for:
%
% N-methyl d-aspartate receptor hypofunction reduces steady state visual
% evoked potentials (2024)
% Alexander Schielke & Bart Krekelberg
% Center for Molecular and Behavioral Neuroscience
% Rutgers University - Newark 
%
%
% Instructions:
%
% 1. Download steadyState data ('/ssLFP/' and '/ssEYE/') and put those 
%    folders in '/data/
%    Data for this project can be found at: 
%    https://drive.google.com/drive/u/4/folders/1oGcN_CchvkYyogD087VsHLMIy9cPJ7xw
%
% 2. Before running code, step into the folder '/code/' of this project, so
%    that all functions are available without adding them them to the path
%
% 3. After that all functions should run, generate and populate folders 
%    with intermediate data, results and plots


%% 1. combine lfp recordings and edf files

    %make sure that data folders with lfp (ssLFP) and eye (ssEYE) data exist
    sourceFolder = strrep(pwd,'code','data\');
    if ~exist([sourceFolder 'ssLFP\'],'dir') || ~exist([sourceFolder 'ssEYE\'],'dir')
        error('Please download and add data for this project to /nmdaSSVEP/data/')
    end 
    
    %if data exist the we combine
    combineFiles    %combine data for further analyses

%% 2. screen files for artifacts 
%     to determine whether files should be included in further analyses
    screenFiles
    
%3. perform frequency analyses and analyze eye movements (~30 minutes)
    processData

%4. use linear mixed effects models to test hypothesis that ketamine
%   reduces strength of steady state visual evoked potentials (15 minutes)
    analyzeData

%5. visualize example data, data quality, frequency spectra and results
    createFigures