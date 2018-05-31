% TEST_PESQBIN Demonstrates the use of the PESQBIN function.
%
%   See also PESQBIN.

%   Author: Kamil Wojcicki, UTD, November 2011

clear all; close all; clc; randn('seed',0); rand('seed',0); fprintf('.\n');


    % specify reference and degraded audio files
    file.reference = 'speech.wav';
    file.degraded = 'speech_bab_0dB.wav';

    % read reference and degraded samples from audio
    [ audio.reference, fs, nbits ] = wavread( file.reference );
    [ audio.degraded, fs, nbits ] = wavread( file.degraded );
    
    % compute NB-PESQ and WB-PESQ scores
    scores.nb = pesqbin( audio.reference, audio.degraded, fs, 'nb' );
    scores.wb = pesqbin( audio.reference, audio.degraded, fs, 'wb' );

    % display results to screen
    fprintf( 'NB PESQ MOS = %5.3f\n', scores.nb(1) );
    fprintf( 'NB MOS LQO  = %5.3f\n', scores.nb(2) );
    fprintf( 'WB MOS LQO  = %5.3f\n', scores.wb );
 
    % example output
    %    NB PESQ MOS = 1.969
    %    NB MOS LQO  = 1.607
    %    WB MOS LQO  = 1.083


% EOF
