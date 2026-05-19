# Line Coding Error Simulator MATLAB Project

This project simulates digital line coding and transmission errors using MATLAB.

## Coding Schemes

1. Unipolar NRZ
2. Polar NRZ
3. Manchester
4. AMI

## Features

- Random binary data generation
- Line coding signal generation
- AWGN noise simulation
- Decoding received signal
- BER calculation
- BER vs SNR graph
- Signal waveform graph
- Eye diagram

## How to Run

Open MATLAB, go to the project folder, and run:

```matlab
line_coding_error_simulator
```

Example input:

```text
Select coding scheme (1-4): 1
Enter number of bits to transmit: 1000
Enter bit rate in bps: 1000
Enter sampling frequency in Hz: 20000
Enter SNR values as array: 0:2:20
```

## GitHub Upload Commands

```bash
git init
git add .
git commit -m "Add Line Coding Error Simulator MATLAB project"
git branch -M main
git remote add origin https://github.com/mahabubhasanmahin/Line-Coding-Error-Simulator.git
git push -u origin main
```
