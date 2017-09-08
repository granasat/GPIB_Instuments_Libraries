clc; clear all;
%fclose(instrfind);

instrument.name = 'Anritsu_MS2830A_V01';
%From device manager
instrument.serialPort = 'COM4';
%From the instrument Interface Menu
instrument.addrGPIB = 3;
%Marconi_2022D_V01(instrument,'help',0); 


try
    %%
    Anritsu_MS2830A_V01(instrument,'open',0)
    
    %%Signal Generator Setting up:  
    
    signal.state=1;             %Turn Signal Generator Output On(1)/Off(0)
    signal.value=2400;          %Frequency of SG Output
    signal.units='MHZ';         %Frequency unit
    signal.power=15;            %Power ot SG Output
    signal.powerUnits='DBM';    %Power unit
    
    %Now the function "Anritsu_MS2830A_V01" is used, to send the signal parameters to the case "set_SignalGenerator"
    Anritsu_MS2830A_V01(instrument,'set_SignalGenerator',signal); 
    
    %%
    
    %%Spectrum Analyzer Setting up:
    
    spectrum.center=1679630;    %Center Frequency
    spectrum.units=signal.units;%Frequency units
    spectrum.start=810.000;     %Start Frequency
    spectrum.stop=2549.260;     %Stop Frequency
    spectrum.reflevel=10;       %Reference Level
    spectrum.powerUnits='DBM';  %Power units for Reference Level
    spectrum.points=101;       %Points number for the displayed trace. OPTIONS: 11,21,41,51,101,201,251,401,501,1001,2001,5001,10001  
    
    %Now the function "Anritsu_MS2830A_V01" is used, to send the spectryum analyzer configuration to the case "set_SpectrumAnalyzer"    
    Anritsu_MS2830A_V01(instrument,'set_SpectrumAnalyzer',spectrum);  
    
    %%
        
    %Now the function "Anritsu_MS2830A_V01" is used, to send spectryum analyzer peaks search configuration to the case "search_Peaks"    
    %To perform an automatic peaks Search:
    
    search.axis='none';         %Desired axis for the peaks search X/Y/NONE
    search.peaks_Number=10;     %Number of desided peaks marked  
    search.resolution=10;       %Resolution for the peaks search, automatically in dB, units no needed, DO NOT ADD units
     
    Anritsu_MS2830A_V01(instrument,'peaks_Search',search);  
    
    %%
    %Now the function "Anritsu_MS2830A_V01" is used, to set the width of
    %the marker desired using the case "set_width"
    
    marker.number=1;            %Desired marker
    marker.width=55;            %Desired width
    marker.width_units='MHZ';   %Units for the width set
    
    Anritsu_MS2830A_V01(instrument,'set_width',marker);  
    
    %%  
    %Now the function "Anritsu_MS2830A_V01" is used, to center the spectrum
    %analyzer around the most powerful peak, using the case "center_peak"
    
    Anritsu_MS2830A_V01(instrument,'center_peak');      
    
    %%   
    
    %Now the function "Anritsu_MS2830A_V01" is used, to query for a trace, using the case "trace_Query"    
    %To query for a trace, set the trace desired:
    
    query.trace_number='TRAC1'; %OPTIONS: TRAC1=Trace A, TRAC2=Trace B, TRAC3=Trace C, TRAC4=Trace D, TRAC5=Trace E, TRAC6=Trace F.    
    
    Anritsu_MS2830A_V01(instrument,'trace_Query',query)      
    
catch err
    Anritsu_MS2830A_V01(instrument,'close',0)
    fprintf('ERROR\n')
    throw(err)
end