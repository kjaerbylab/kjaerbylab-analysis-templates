# Single-band Tort modulation index

**Status:** Candidate — MATLAB run pending.

## Purpose and typical use

Calculate phase-amplitude coupling for one phase band and one amplitude band.

## Suitable data and inputs

Continuous EEG vector, fs Hz, phase and amplitude bounds Hz.

## Requirements

Signal Processing Toolbox: hilbert, fir1, filtfilt, designfilt. Despite the source header, this is not fully toolbox-free.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

```matlab
mi = pac_tort_mi(eeg,fs,[5 9],[30 60]);
```

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

18 phase bins. No surrogate significance test. bandpass_zero returns unfiltered input if bounds are invalid; ensure requested bands are valid. Check edge artifacts and data duration before interpreting MI.

## Authors and provenance

- Source project: MSc thesis repository of **Margarida Seabra Gomes**, as credited in its README. Confirm per-file original authors and any adaptations; preserve existing credits.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `pac_tort_mi.m` | Source repository snapshot `e55d0fd019f973f90a81b8b50752584be5900375`; full path in SOURCE_MANIFEST.csv |
| `bandpass_zero.m` | Source repository snapshot `e55d0fd019f973f90a81b8b50752584be5900375`; full path in SOURCE_MANIFEST.csv |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

```matlab
function mi = pac_tort_mi(x, fs, f_phase, f_amp)
% Tort MI (KL divergence of amp-by-phase histogram), toolbox-free
```

<details>
<summary>Original help: pac_tort_mi.m</summary>

```text
Tort MI (KL divergence of amp-by-phase histogram), toolbox-free
f_phase: [low high] (e.g., [5 9]); f_amp: [30 60] or [60 100]
```
</details>

```matlab
function y = bandpass_zero(x, fs, fband)
% Zero-phase FIR bandpass with safe order; falls back to filtfilt(IIR) if needed
```

<details>
<summary>Original help: bandpass_zero.m</summary>

```text
Zero-phase FIR bandpass with safe order; falls back to filtfilt(IIR) if needed
```
</details>
