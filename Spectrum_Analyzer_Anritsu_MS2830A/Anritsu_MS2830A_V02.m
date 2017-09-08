%%Marconi-2022D Lib Test. 
%%Last update: May 14th, 2017. José Carlos Martínez Durillo
%%Contact: linkedin.com/in/jcmartinezdurillo
%%With colaboration of Javier Vargas García, javivarguitas11@hotmail.com.

%%This library is used in order to communicate with the signal generator
%%Marconi 2022D through an USB - GPIB bus converter.

%COMMANDS AVAILABLE:

%Open: Start serial comunication.

%Close: Close serial comunication.

%set_frequency:
    %frequency.value=7 digits plus decimal point;
    %frequency.units='KHz' or 'MHz;
    %frequency.modulator='internal' or 'external;
    
%set_modulation:
    %modulation.type='FM','PM' or 'AM';
    %modulation.value=3 digits plus decimal point;
    %modulation.units='Hz', 'KHz', 'MHz', '%' or 'Rad';
    %modulation.oscillator='off' or 'on';
    %modulation.modulator='internal' or 'external';
    %modulation.ALC='off' or 'on';
    
%set_rflevel:
    %rflevel.value=4 digits plus decimal point;
    %rflevel.units='dBm', 'V', 'mV', 'uV';
    %rflevel.carrier='off', 'on';
   
 %help: Return all commands available.
 
function Anritsu_MS2830A_V01(instrument, command, value)

global serialObject;
if (strcmpi(instrument.name, 'Anritsu_MS2830A_V01'))
     
    switch command
        %%Case 'open'. Sets the information needed for the GPIB
        %%comunication. Initially, no need to change for this instrument.
        
            case 'open'
            serialPort = instrument.serialPort;
            serialObject = serial(serialPort, 'baud', 115200,'StopBits',1 ,'DataBits', 8,'Parity', 'none', 'InputBufferSize',100000,'OutputBufferSize',1000); %
            set(serialObject,'Terminator','LF');
            set(serialObject,'Timeout',900);
            fopen(serialObject);
            pause(0.5);
            fwrite(serialObject,uint8(sprintf('++addr %d\r\n',instrument.addrGPIB)));
            fwrite(serialObject,uint8(sprintf('*CLS\r\n')));
            pause(0.5);
            
        %%Case 'close'. Close GPIB Comunication.             
        case 'close'
            fclose(serialObject);
            delete(instrfind);
            
        %%Case 'set_SignalGenerator'. Sets the configuration supplied by
        %%the user for Signal Generator. It takes the variables and put them 
        %%together into a STRING which is send to the instrument. List of parameters:
        
        %(PAGES REFERENCE TO SIGNAL ANALYZER REMOTE MANUAL:)
        
        %INST SG - Sets the instrument which is goint to receive the string
        %FREQ - Page (P) 14
        %UNIT.POW - P23
        %POW - P33
        %OUTP - P22
        %\r\n - Compound string is send after them.     
        
        
        case 'set_SignalGenerator'
            fwrite(serialObject,uint8(sprintf('INST SG; FREQ %f%s; UNIT.POW %s; POW %f; OUTP %d\r\n',value.value, value.units, value.powerUnits, value.power, value.state))); 
            
            %Little pause is needed after fwrite command in order to allow
            %the interface to process the following line.
            
            pause(0.5);
            
        %%Case 'set_SpectrumAnalyzer'. Sets the configuration supplied by
        %%the user for the Spectrum Analyzer. It takes the variables and put them 
        %%together into a STRING which is send to the instrument. List of parameters:
        
        %(PAGES REFERENCE TO SPECTRUM ANALIZER REMOTE MANUAL:)
        
        %INST SPECT - Sets the instrument which is goint to receive the string
        %FREQ:CENT - P42
        %FREQ:START - P52
        %FREQ:STOP - P54
        %DISP:WIND:TRAC:Y:RLEV - P64
        %\r\n - Compound string is send after them.    
            
            
        case 'set_SpectrumAnalyzer'
            fwrite(serialObject,uint8(sprintf('INST SPECT; FREQ:CENT %f%s; FREQ:START %f%s; FREQ:STOP %f%s; DISP:WIND:TRAC:Y:RLEV %0.2f%s;\r\n',value.center, value.units, value.start, value.units, value.stop, value.units, value.reflevel, value.powerUnits)));             
            pause(0.5);
            fwrite(serialObject,uint8(sprintf('INST SPECT; SWE:POIN %d\r\n', value.points))); 
            
            %pause(0.5);
            %fwrite(serialObject,uint8(sprintf('CALC:MARK:ACT ON; CALC:MARK:RES PEAK; CALC:MARK:MAX; CALC:PMAR:Y?\r\n')));
            
            
            
        %%Case 'peaks_Search'. Sets the configuration supplied by
        %%the user for the search of peaks in the Spectrum Analyzer. Depending
        %%on the axis chosen, it enters to one condition or other. It takes 
        %%the variables and put them together into a STRING which is send to 
        %%the instrument. List of parameters:
        
        %(PAGES REFERENCE TO SPECTRUM ANALIZER REMOTE MANUAL:)
        
        %INST SPECT - Sets the instrument which is goint to receive the string
        %CALC:MARK:PEAK:SORT:COUN - P188
        %CALC:MARK:PEAK:RES - P179
        %CALC:MARK:PEAK:SORT:X - P188
        %CALC:MARK:PEAK:SORT:Y - P187
        %\r\n - Compound string is send after them.
            
        case 'peaks_Search'
            
            fwrite(serialObject,uint8(sprintf('INST SPECT; CALC:MARK:PEAK:SORT:COUN %d; CALC:MARK:PEAK:RES %.3f\r\n',value.peaks_Number, value.resolution))); 
            pause(0.5);
            
            if (strcmpi(value.axis, 'X'))
                fwrite(serialObject,uint8(sprintf('INST SPECT; CALC:MARK:PEAK:SORT:X\r\n'))); 
            end
            if (strcmpi(value.axis, 'Y'))
               fwrite(serialObject,uint8(sprintf('INST SPECT; CALC:MARK:PEAK:SORT:Y\r\n'))); 
            end
            
            pause(0.5);
            
        %%Case 'trace_Query'. Sets the configuration supplied by
        %%the user for the search of peaks in the Spectrum Analyzer. Depending
        %%on the axis chosen, it enters to one condition or other. It takes 
        %%the variables and put them together into a STRING which is send to 
        %%the instrument. List of parameters:
        
        %(PAGES REFERENCE TO SPECTRUM ANALIZER REMOTE MANUAL:)
        
        %INST SPECT - Sets the instrument which is goint to receive the string
        %CALC:MARK:PEAK:SORT:COUN - P188
        %CALC:MARK:PEAK:RES - P179
        %CALC:MARK:PEAK:SORT:X - P188
        %CALC:MARK:PEAK:SORT:Y - P187
        %\r\n - Compound string is send after them.
            
        case 'trace_Query'
            
            set(serialObject,'Timeout',360000);
            fwrite(serialObject,uint8(sprintf('INST SPECT; FORM ASC; TRAC? %s\r\n',value.trace_number))); 
            trace=fscanf(serialObject);
            trace=str2num(trace);
            x=1:length(trace);
            plot(x,trace);
            axis([1 max(x) (min(trace)-10) (max(trace)+10)])
            pause(0.5);  
            
        %%Case 'set_width'. Sets the witdh (frequency) indicated for the marker
        %%desired
        
        %(PAGES REFERENCE TO SPECTRUM ANALIZER REMOTE MANUAL:)
        
        %INST SPECT - Sets the instrument which is going to receive the string
        %CALC:MARK%d:WIDT P139
        %\r\n - Compound string is send after them.
            
        case 'set_width'
                       
            fwrite(serialObject,uint8(sprintf('INST SPECT; CALC:MARK%d:WIDT %f%s\r\n',value.number,value.width,value.width_units))); 
            pause(0.5);     
            
        %%Case 'center_peak'. Sets the spectrum analyzer so the main peak
        %%is displayed. It is calculated through a for loop with 3
        %%iterations.
        
        %(PAGES REFERENCE TO SPECTRUM ANALIZER REMOTE MANUAL:)
        
        %INST SPECT - Sets the instrument which is goint to receive the string
        %CALC:MARK:AOFF - P160
        %CALC:MARK:ACT - P115
        %CALC:MARK:RES PEAK - P147
        %CALC:MARK:MAX - P171
        %CALC:PMAR:Y? - P158
        %CALC:MARK:X - P121
        %CALC:MARK:WIDT? - P140
        %\r\n - Compound string is send after them.
        
        case 'center_peak'   
            
            clc
            
            for i=1:3
                
            pause(1);           
            fwrite(serialObject,uint8(sprintf('INST SPECT; CALC:MARK:AOFF\r\n')));
            pause(1);         
            fwrite(serialObject,uint8(sprintf('INST SPECT; CALC:MARK:ACT ON; CALC:MARK:RES PEAK; CALC:MARK:MAX\r\n'))); %; CALC:PMAR:Y?
            pause(1);
            %fwrite(serialObject,uint8(sprintf('INST SIGANA; SYST:COMM:GPIB:SELF:DEL LF\r\n')));
            fwrite(serialObject,uint8(sprintf('INST SPECT; CALC:MARK:X?\r\n'))); 
            fcenter=fscanf(serialObject);     
            pause(1);
            fcenter=str2double(fcenter)            
            fwrite(serialObject,uint8(sprintf('INST SPECT; CALC:MARK:WIDT?\r\n')));
            pause(1);
            marker_span=fscanf(serialObject);
            pause(1);
            marker_span=str2double(marker_span)
            f0=fcenter-marker_span
            f1=fcenter
            f2=fcenter+marker_span
            fwrite(serialObject,uint8(sprintf('INST SPECT; FREQ:START %.0f HZ; FREQ:CENT %.0f HZ; FREQ:STOP %.0f HZ\r\n',f0,f1,f2)));             
            pause(1.5); 
            
            end    
  
        case 'set_SignalAnalyzer'
            fwrite(serialObject,uint8(sprintf('INST SIGANA\r\n'))); pause(0.5); 
            
        case 'help'
            s = ['Available commands:\n' ...
                '\topen\n'...
                '\t\tStart serial comunication.\n'...
                '\tclose\n'...
                '\t\tClose serial comunication.\n'...
                '\tset_frequency\n' ...
                '\t\tNeed to define: frequency.value \tfrequency.units \tfrequency.modulator \n'...
                '\tset_modulation\n' ...
                '\t\tNeed to define: modulation.type \tmodulation.value \tmodulation.units \tmodulation.oscillator \tmodulation.modulator \tmodulation.ALC \n'...
                '\tset_rflevel\n' ...
                '\t\tNeed to define: rflevel.value \trflevel.units \trflevel.carrier \n'...
                '\t\n'];            
         fprintf(s);  
        otherwise
            fprintf('command not recognized, put command "help" for more information.\n');
    end
end