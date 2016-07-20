%%   --------------------------------------------------------------
%%   --------               GranaSAT                        -------
%%   --------                                               -------
%%   --------             Summer Camp 2016                  -------
%%   --------             granasat@ugr.es                   -------
%%   --------                                               -------
%%   --------                                               -------
%%   --------         University of Granada (SPAIN)         -------
%%   --------                                               -------
%%   --------         https://granasat.ugr.es               -------
%%   --------                                               -------
%%   --------------------------------------------------------------
%%
%% Marconi-2022D Lib Test. Last update: July 19th, 2016. 
%% Javier Vargas García. Contac: javivarguitas11@hotmail.com
%% This library is used in order to communicate with the signal generator
%% Marconi 2022D through an USB - GPIB bus converter.



clc; clear all;
%fclose(instrfind);

instrument.name = 'Marconi-2022D';
instrument.serialPort = 'COM6';
%Marconi_2022D_V01(instrument,'help',0); 

try
    Marconi_2022D_V01(instrument,'open',0)
    
    %Set carrier frequency characteristics:
    frequency.value=200;
    frequency.units='MHz';
    frequency.modulator='internal';    
    Marconi_2022D_V01(instrument,'set_frequency',frequency); 

    %Set modulation characteristics:
    modulation.type='FM';
    modulation.value=20;
    modulation.units='KHz';
    modulation.oscillator='on';
    modulation.modulator='internal';
    modulation.ALC='on';  
    Marconi_2022D_V01(instrument,'set_modulation',modulation); 
    
    %Set RF level characteristics:
    rflevel.value=1.5;
    rflevel.units='mV';
    rflevel.carrier='on';
    Marconi_2022D_V01(instrument,'set_rflevel',rflevel); 
       
    Marconi_2022D_V01(instrument,'close',0)
catch err
    Marconi_2022D_V01(instrument,'close',0)
    fprintf('ERROR\n')
    throw(err)
end
