# Whole-trace EEG PSD

**Status:** Candidate — MATLAB run pending.

## Purpose and typical use

Welch PSD of a supplied EEG segment.

## Suitable data and inputs

Numeric EEG vector and sampling rate Hz; filter requires fs > 200 Hz.

## Requirements

Signal Processing Toolbox.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

```matlab
[f,psd_db] = PSD_EEG(eeg,fs,true);
```

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

Applies 0.5–100 Hz bandpass and returns frequencies below 45 Hz in dB relative to the input units squared/Hz. Distinct from state-bout PSD scripts with the same name.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `PSD_EEG.m` | matlab sharing.zip :: matlab sharing/functions/PSD_EEG.m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

```matlab
function [prism_freq, prism_psd] = PSD_EEG(full_trace, fs, plot_flag)
% PSD_EEG Compute EEG power spectral density and optionally plot it
```

<details>
<summary>Original help: PSD_EEG.m</summary>

```text
PSD_EEG Compute EEG power spectral density and optionally plot it

[prism_freq, prism_psd] = PSD_EEG(full_trace, fs, plot_flag)

Inputs:
full_trace : EEG signal vector
fs         : Sampling frequency in Hz
plot_flag  : Logical flag (true/false). If true, plot the PSD.

Outputs:
prism_freq : Frequencies up to 45 Hz
prism_psd  : PSD values in dB/Hz for frequencies up to 45 Hz
Bandpass filter between 0.5 and 100 Hz
```
</details>
