classdef AD9371Tests < HardwareTests
    
    properties
        uri = 'ip:192.168.1.208';
        SamplingRateRX = 122.88e6;
        author = 'ADI';
    end
    
    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.AD9371.Rx;
            testCase.CheckDevice('ip',Device,testCase.uri(4:end),false);
        end
    end
    
    methods (Static)
        function estFrequency(data,fs)
            nSamp = length(data);
            FFTRxData  = fftshift(10*log10(abs(fft(data))));
            df = fs/nSamp;  freqRangeRx = (-fs/2:df:fs/2-df).'/1000;
            plot(freqRangeRx, FFTRxData);
        end
    end
    
    methods (Test)
        
        function testAD9371Rx(testCase)
            % Test Rx DMA data output
            rx = adi.AD9371.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            [out, valid] = rx();
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
        
        function testAD9371RxCustomProfile1(testCase)
            % Test Rx custom profiles
            rx = adi.AD9371.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            rx.EnableCustomProfile = true;
            rx.CustomProfileFileName = ...
                'profile_TxBW50_ORxBW50_RxBW50.txt';
            [out, valid] = rx();
            rxSampleRate = rx.getAttributeLongLong('voltage0',...
                'sampling_frequency',false);
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(rxSampleRate,int64(61440000),...
                'Invalid sample rate after profile write');
        end
        
        function testAD9371RxCustomProfile2(testCase)
            % Test Rx custom profiles
            rx = adi.AD9371.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            rx.EnableCustomProfile = true;
            rx.CustomProfileFileName = ...
                'profile_TxBW100_ORxBW100_RxBW100.txt';
            [out, valid] = rx();
            rxSampleRate = rx.getAttributeLongLong('voltage0',...
                'sampling_frequency',false);
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(rxSampleRate,int64(122880000),...
                'Invalid sample rate after profile write');
        end
        
        function testAD9371RxWithTxDDS(testCase)
            % Test DDS output
            tx = adi.AD9371.Tx('uri',testCase.uri);
            tx.DataSource = 'DDS';
            toneFreq = 30e6;
            tx.DDSFrequencies = repmat(toneFreq,2,4);
            tx.AttenuationChannel0 = -10;
            tx();
            pause(1);
            rx = adi.AD9371.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            rx.kernelBuffersCount = 1;
            for k=1:10
                valid = false;
                while ~valid
                    [out, valid] = rx();
                end
            end
            rx.release();

%             plot(real(out));
%             testCase.estFrequency(out,testCase.SamplingRateRX);
            freqEst = meanfreq(double(real(out)),testCase.SamplingRateRX);

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,toneFreq,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
            
        end
        
        function testAD9371RxWithTxData(testCase)
            % Test Tx DMA data output
            amplitude = 2^15; frequency = 20e6;
            swv1 = dsp.SineWave(amplitude, frequency);
            swv1.ComplexOutput = true;
            swv1.SamplesPerFrame = 2^20;
            swv1.SampleRate = testCase.SamplingRateRX*2;
            y = swv1();
            
            tx = adi.AD9371.Tx('uri',testCase.uri);
            tx.DataSource = 'DMA';
            tx.EnableCyclicBuffers = true;
            tx.AttenuationChannel0 = -10;
            tx(y);
            rx = adi.AD9371.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            rx.kernelBuffersCount = 1;
            for k=1:20
                valid = false;
                while ~valid
                    [out, valid] = rx();
                end
            end
            rx.release();

%             plot(real(out));
%             testCase.estFrequency(out,testCase.SamplingRateRX);
            freqEst = meanfreq(double(real(out)),testCase.SamplingRateRX);
            
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,frequency,'RelTol',0.01,...
                'Frequency of ML tone unexpected')
        end
    end
    
end

