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
 
function Marconi_2022D_V01(instrument, command, value)

global serialObject;
if (strcmpi(instrument.name, 'Marconi-2022D'))
    
    MaxCarrierFreq=1000e6;%Maximum carrier frequency 1000MHz.
    global MaxModulationFreq;%Maximum modulation frequency depends of carrier frequency.
    MaxModulationRad=9.99;%Maximum modulation radians 9.99Rad.
    MaxModulationPerc=99.5;%Maximum modulation percentage 99.5%.
    MaxRFLevel=1.8;%Maximum radio frequency level 1.8V.
    MaxRFLeveldBm=12;%Maximum radio frequency level 12dBm.
    
    switch command
       
        case 'open'
            serialPort = instrument.serialPort;
            serialObject = serial(serialPort, 'baud', 115200,'StopBits',1 ,'DataBits', 8,'Parity', 'none');
            set(serialObject,'Timeout',30);
            fopen(serialObject);
            pause(2);   
             
        case 'close'
            fclose(serialObject);
            
        case 'set_frequency'         
            try
                switch value.units
                    case 'MHz'
                        fwrite(serialObject,uint8(sprintf('CF %f MZ ',value.value)));
                        mult=1e6;
                    case 'KHz'
                        fwrite(serialObject,uint8(sprintf('CF %f KZ ',value.value)));
                        mult=1e3;
                    otherwise
                         fprintf('Error: frequency.units must be KHz or MHz\n');
                        mult=0;
                end              
                catch err 
                error('frequency.units not defined');
                throw(err)
            end
             carrierFreq=value.value*mult;
             %Maximum modulation frequency depends of actual carrier frequency
             if carrierFreq<=125e6
                 MaxModulationFreq=125e3;
             end
             if carrierFreq>125e6 & carrierFreq<=250e6
                 MaxModulationFreq=250e3;
             end
             if carrierFreq>250e6 & carrierFreq<=500e6
                 MaxModulationFreq=500e3;
             end
             if carrierFreq>500e6
                 MaxModulationFreq=999e3;
             end
            if carrierFreq > MaxCarrierFreq
                fprintf('Maximum carrier frequency of %d MHz exceeded\n',MaxCarrierFreq/1e6);
            end
            try
                switch value.modulator
                    case 'internal'
                        fwrite(serialObject,uint8(sprintf('IS\r\n')));
                    case 'external'
                        fwrite(serialObject,uint8(sprintf('XS\r\n')));
                    otherwise
                         fprintf('Error: frequency.modulator must be external or internal\n');
                end              
                catch err 
                error('frequency.modulator not defined');
                throw(err)
            end
            pause(2);
    
        case 'set_modulation'
            try
                switch value.type
                    case 'FM'
                        fwrite(serialObject,uint8(sprintf('FM ')));
                        try 
                            switch value.units
                                case 'MHz'
                                    fwrite(serialObject,uint8(sprintf('%f MZ ',value.value))); 
                                    mult=1e6;
                                case 'KHz'
                                    fwrite(serialObject,uint8(sprintf('%f KZ ',value.value))); 
                                    mult=1e3;
                                case 'Hz'
                                    fwrite(serialObject,uint8(sprintf('%f HZ ',value.value))); 
                                    mult=1; 
                                otherwise
                                   fprintf('Error: modulation.units must be Hz, KHz or MHz\n');
                                   mult=0;
                            end
                        end
                    if value.value*mult > MaxModulationFreq
                         fprintf('Maximum modulation frequency of %d KHz exceeded\n',MaxModulationFreq/1000);
                    end                                                               
                    case 'PM'
                        fwrite(serialObject,uint8(sprintf('PM %f RD ',value.value)));
                        if value.value > MaxModulationRad 
                            fprintf('Maximum radians of %f Rad exceeded\n',MaxModulationRad);
                        end                        
                    case 'AM'
                        fwrite(serialObject,uint8(sprintf('AM %f PC ',value.value)));
                        if value.value >  MaxModulationPerc 
                            fprintf('Maximum percentage of %f exceeded\n', MaxModulationPerc);
                        end               
                    otherwise
                         fprintf('Error: modulation.type must be FM, PM or AM\n');
                end              
                 catch err 
                 error('modulation.type or modulation.units not defined');
                 throw(err)
            end  
            try
                switch value.oscillator
                    case 'off'
                        fwrite(serialObject,uint8(sprintf('M0 '))); 
                    case 'on'
                        fwrite(serialObject,uint8(sprintf('M1 '))); 
                    otherwise
                        fprintf('Error: modulation.oscillator must be off or on\n');
                end
            catch err
                error('modulation.oscillator not defined');
                throw(err)
            end
            try
                switch value.modulator
                    case 'internal'
                        fwrite(serialObject,uint8(sprintf('IM ')));
                    case 'external'
                        fwrite(serialObject,uint8(sprintf('XM ')));
                    otherwise
                        fprintf('Error: modulation.modulator must be internal or external\n');
                end
            catch err
                error('modulation.modulator not defined');
                throw (err)
            end               
                  try
                    switch value.ALC
                        case 'off'
                            fwrite(serialObject,uint8(sprintf('L0\r\n'))); 
                        case 'on'
                            fwrite(serialObject,uint8(sprintf('L1\r\n')));  
                        otherwise
                            fprintf('Error: modulation.ALC must be off or on\n');
                    end
                    catch err 
                    error('modulation.ALC not defined');
                    throw(err)
                  end
                  pause(2);
                  
            case 'set_rflevel'
                try
                    switch value.units
                         case 'dBm'
                             fwrite(serialObject,uint8(sprintf('LV %f DB ',value.value))); 
                             mult=0;
                             if value.value > MaxRFLeveldBm
                                 fprintf('Maximum radio frequency level of %d dBm exceeded\n', MaxRFLeveldBm);
                             end   
                         case 'V'
                             fwrite(serialObject,uint8(sprintf('LV %f VL ',value.value)));
                             mult=1;                            
                         case 'mV'
                             fwrite(serialObject,uint8(sprintf('LV %f MV ',value.value)));
                             mult=1e-3;
                         case 'uV'
                             fwrite(serialObject,uint8(sprintf('LV %f UV ',value.value))); 
                             mult=1e-6;
                         otherwise
                            fprintf('Error: rflevel.units must be dBm, V, mV or uV\n');
                            mult=0;
                    end
                        if value.value*mult > MaxRFLevel
                        fprintf('Maximum radio frequency level of %d mV exceeded\n', MaxRFLevel*1000);
                    end
                    catch err 
                    error('rflevel.units not defined');
                    throw(err) 
                end
                try
                    switch value.carrier
                        case 'off'
                            fwrite(serialObject,uint8(sprintf('C0\r\n')));                     
                        case 'on'
                            fwrite(serialObject,uint8(sprintf('C1\r\n'))); 
                        otherwise
                            fprintf('Error: rflevel.carrier must be off or on\n');
                            
                    end
                catch err
                    error('rflevel.carrier not defined');
                    throw(err)
                end
                pause(2);  
                
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
