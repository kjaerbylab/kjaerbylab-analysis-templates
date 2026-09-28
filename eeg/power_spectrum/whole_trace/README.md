# Whole-trace EEG PSD

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Welch PSD of a supplied EEG segment.

## Suitable data and inputs

Numeric EEG vector and sampling rate Hz; filter requires fs > 200 Hz.

## Requirements

Signal Processing Toolbox.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

```matlab
[f,psd_db] = PSD_EEG(eeg,fs,true);
```

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Applies 0.5–100 Hz bandpass and returns frequencies below 45 Hz in dB relative to the input units squared/Hz. Distinct from state-bout PSD scripts with the same name.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `PSD_EEG.m` | matlab sharing.zip :: matlab sharing/functions/PSD_EEG.m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

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
