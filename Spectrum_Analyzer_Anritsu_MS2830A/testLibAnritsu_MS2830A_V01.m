clc; clear all;
%fclose(instrfind);

instrument.name = 'Anritsu_MS2830A_V01';
instrument.serialPort = 'COM4';
instrument.addrGPIB = 2;
%Marconi_2022D_V01(instrument,'help',0); 


try
    Anritsu_MS2830A_V01(instrument,'open',0)
    
    %Signal Generator:  PAGES REFERENCE TO SPECTRUM ANALIZER REMOTE MANUAL:
    
    signal.state=1; %turn Signal Generator Output on;
    signal.value=2400;
    signal.units='MHZ';
    signal.power=15;
    signal.powerUnits='DBM';
    
    Anritsu_MS2830A_V01(instrument,'set_SignalGenerator',signal);
    
    %Spectrum Analyzer: PAGES REFERENCE TO SPECTRUM ANALIZER REMOTE MANUAL:
    
    spectrum.center=1679630;
    spectrum.units=signal.units;
    spectrum.start=810.000;
    spectrum.stop=2549.260;
    spectrum.reflevel=10; %PAGE 64 - 
    spectrum.powerUnits='DBM';
    
    Anritsu_MS2830A_V01(instrument,'set_SpectrumAnalyzer',spectrum);  
 
    search.axis='y';
    search.peaks_Number=10;
    search.resolution=20; %en dB por defecto, no añadir unidades
    
    Anritsu_MS2830A_V01(instrument,'search_Peaks',search);  

    
             
    Anritsu_MS2830A_V01(instrument,'close',0)
catch err
    Anritsu_MS2830A_V01(instrument,'close',0)
    fprintf('ERROR\n')
    throw(err)
end