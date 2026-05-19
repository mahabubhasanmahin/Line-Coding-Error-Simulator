%% Line Coding Error Simulator with User Interface
% Project: Line Coding Error Simulator
% Coding Schemes: Unipolar NRZ, Polar NRZ, Manchester, AMI
% Output: BER vs SNR, Signal Waveforms, Eye Diagram

clc;
clear;
close all;

disp('=== LINE CODING ERROR SIMULATOR ===');
fprintf('\n');

%% User Input Section
fprintf('Available Line Coding Schemes:\n');
fprintf('1. Unipolar NRZ\n');
fprintf('2. Polar NRZ\n');
fprintf('3. Manchester\n');
fprintf('4. AMI\n');

scheme_idx = input('Select coding scheme (1-4): ');
N = input('Enter number of bits to transmit (e.g., 1000): ');
bit_rate = input('Enter bit rate in bps (e.g., 1000): ');
Fs = input('Enter sampling frequency in Hz (e.g., 20000): ');
SNR_dB = input('Enter SNR values as array [start:step:end] (e.g., 0:2:20): ');

%% Input Validation
if scheme_idx < 1 || scheme_idx > 4
    error('Invalid coding scheme selection! Please select 1 to 4.');
end

samples_per_bit = Fs / bit_rate;

if mod(samples_per_bit, 1) ~= 0
    error('Sampling frequency divided by bit rate must be an integer.');
end

if scheme_idx == 3 && mod(samples_per_bit, 2) ~= 0
    error('For Manchester coding, samples per bit must be an even number.');
end

coding_schemes = {'Unipolar NRZ', 'Polar NRZ', 'Manchester', 'AMI'};
selected_scheme = coding_schemes{scheme_idx};

fprintf('\n=== Simulation Parameters ===\n');
fprintf('Coding Scheme: %s\n', selected_scheme);
fprintf('Number of bits: %d\n', N);
fprintf('Bit rate: %d bps\n', bit_rate);
fprintf('Sampling frequency: %d Hz\n', Fs);
fprintf('Samples per bit: %d\n', samples_per_bit);
fprintf('SNR range: %s dB\n', mat2str(SNR_dB));
fprintf('\n');

%% Generate Random Binary Data
data = randi([0 1], 1, N);

%% Simulation
BER_results = zeros(1, length(SNR_dB));

for snr_idx = 1:length(SNR_dB)

    %% Encoding
    switch scheme_idx
        case 1
            % Unipolar NRZ: 1 = +1, 0 = 0
            encoded_signal = repelem(data, samples_per_bit);

        case 2
            % Polar NRZ: 1 = +1, 0 = -1
            encoded_signal = repelem((2 * data) - 1, samples_per_bit);

        case 3
            % Manchester: 1 = high-to-low, 0 = low-to-high
            encoded_signal = [];
            half_bit = samples_per_bit / 2;

            for bit = data
                if bit == 1
                    encoded_signal = [encoded_signal ones(1, half_bit) -ones(1, half_bit)];
                else
                    encoded_signal = [encoded_signal -ones(1, half_bit) ones(1, half_bit)];
                end
            end

        case 4
            % AMI: 1 alternates +1 and -1, 0 = 0
            encoded_signal = zeros(1, N * samples_per_bit);
            polarity = 1;

            for i = 1:N
                start_idx = (i - 1) * samples_per_bit + 1;
                end_idx = i * samples_per_bit;

                if data(i) == 1
                    encoded_signal(start_idx:end_idx) = polarity;
                    polarity = -polarity;
                end
            end
    end

    if snr_idx == 1
        original_encoded = encoded_signal;
    end

    %% Add AWGN Noise
    noisy_signal = awgn(encoded_signal, SNR_dB(snr_idx), 'measured');

    %% Decoding
    switch scheme_idx
        case 1
            sample_points = round(samples_per_bit / 2):samples_per_bit:length(noisy_signal);
            decoded_bits = noisy_signal(sample_points) > 0.5;

        case 2
            sample_points = round(samples_per_bit / 2):samples_per_bit:length(noisy_signal);
            decoded_bits = noisy_signal(sample_points) > 0;

        case 3
            decoded_bits = zeros(1, N);

            for i = 1:N
                first_sample = (i - 1) * samples_per_bit + round(samples_per_bit / 4);
                second_sample = (i - 1) * samples_per_bit + round(3 * samples_per_bit / 4);

                sample1 = noisy_signal(first_sample);
                sample2 = noisy_signal(second_sample);

                decoded_bits(i) = sample1 > sample2;
            end

        case 4
            sample_points = round(samples_per_bit / 2):samples_per_bit:length(noisy_signal);
            decoded_bits = abs(noisy_signal(sample_points)) > 0.5;
    end

    %% BER Calculation
    decoded_bits = decoded_bits(1:N);
    total_errors = sum(data ~= decoded_bits);
    BER_results(snr_idx) = total_errors / N;

    if snr_idx == length(SNR_dB)
        final_noisy = noisy_signal;
        final_decoded = decoded_bits;
    end
end

%% Display BER Results
fprintf('\n=== Simulation Results ===\n');
fprintf('SNR(dB)\tBER\n');

for i = 1:length(SNR_dB)
    fprintf('%d\t\t%.6f\n', SNR_dB(i), BER_results(i));
end

%% Visualization 1: BER vs SNR
figure('Name', 'BER Performance', 'NumberTitle', 'off');
semilogy(SNR_dB, BER_results, 'b-o', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title(['BER vs SNR for ' selected_scheme ' Coding']);

%% Visualization 2: Signal Waveforms
t = (0:length(original_encoded) - 1) / Fs;

figure('Name', 'Signal Waveforms', 'NumberTitle', 'off');

subplot(3, 1, 1);
plot(t, original_encoded, 'LineWidth', 1.5);
grid on;
title(['Original ' selected_scheme ' Encoded Signal']);
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 2);
plot(t, final_noisy, 'LineWidth', 1.2);
grid on;
title(['Noisy Signal at SNR = ' num2str(SNR_dB(end)) ' dB']);
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 3);
show_bits = min(20, N);
stem(1:show_bits, data(1:show_bits), 'filled', 'MarkerSize', 5);
hold on;
stem(1:show_bits, final_decoded(1:show_bits), 'r', 'filled', 'MarkerSize', 3);
grid on;
title('First 20 Bits: Original vs Decoded');
xlabel('Bit Index');
ylabel('Bit Value');
legend('Original', 'Decoded');

%% Visualization 3: Eye Diagram
figure('Name', 'Eye Diagram', 'NumberTitle', 'off');
eye_samples = min(200 * samples_per_bit, length(original_encoded));
eyediagram(original_encoded(1:eye_samples), 2 * samples_per_bit);
title(['Eye Diagram for ' selected_scheme ' Coding']);

fprintf('\nSimulation complete! Check the figures for results.\n');
