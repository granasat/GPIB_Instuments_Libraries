%%Marconi-2022D Lib Test. Last update: July 19th, 2016. Javier Vargas García. Contac: javivarguitas11@hotmail.com
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
       
        case 'open'
            serialPort = instrument.serialPort;
            serialObject = serial(serialPort, 'baud', 115200,'StopBits',1 ,'DataBits', 8,'Parity', 'none');
            set(serialObject,'Timeout',30);
            fopen(serialObject);
            pause(0.5);
            fwrite(serialObject,uint8(sprintf('++addr %d\r\n',instrument.addrGPIB)));
            fwrite(serialObject,uint8(sprintf('*CLS\r\n')));
            pause(0.5);
             
        case 'close'
            fclose(serialObject);

        case 'set_SignalGenerator'
            fwrite(serialObject,uint8(sprintf('INST SG; FREQ %f%s; UNIT.POW %s; POW %f; OUTP %d\r\n',value.value, value.units, value.powerUnits, value.power, value.state))); 
            pause(0.5);            
            
        case 'set_SpectrumAnalyzer'
            fwrite(serialObject,uint8(sprintf('INST SPECT; FREQ:CENT %f%s; FREQ:START %f%s; FREQ:STOP %f%s; DISP:WIND:TRAC:Y:RLEV %0.2f%s\r\n',value.center, value.units, value.start, value.units, value.stop, value.units, value.reflevel, value.powerUnits)));             
            %fwrite(serialObject,uint8(sprintf('CALC:MARK:ACT ON; CALC:MARK:RES PEAK; CALC:MARK:MAX; CALC:PMAR:Y?\r\n')));
            pause(0.5);
            
        case 'search_Peaks'
                    
            if (strcmpi(value.axis, 'X'))
                fwrite(serialObject,uint8(sprintf('INST SPECT; CALC:MARK:PEAK:SORT:X\r\n'))); 
            end
            if (strcmpi(value.axis, 'Y'))
               fwrite(serialObject,uint8(sprintf('INST SPECT; CALC:MARK:PEAK:SORT:Y\r\n'))); 
            end
            if (strcmpi(value.axis, 'none'))
            
            end       
                         
           pause(0.5);      
        
  
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