# Single-band Tort modulation index

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Calculate phase-amplitude coupling for one phase band and one amplitude band.

## Suitable data and inputs

Continuous EEG vector, fs Hz, phase and amplitude bounds Hz.

## Requirements

Signal Processing Toolbox: hilbert, fir1, filtfilt, designfilt. Despite the source header, this is not fully toolbox-free.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

```matlab
mi = pac_tort_mi(eeg,fs,[5 9],[30 60]);
```

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

18 phase bins. No surrogate significance test. bandpass_zero returns unfiltered input if bounds are invalid; ensure requested bands are valid. Check edge artifacts and data duration before interpreting MI.

## Authors and provenance

- Source project: MSc thesis repository of **Margarida Seabra Gomes**, as credited in its README. Confirm per-file original authors and any adaptations; preserve existing credits.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `pac_tort_mi.m` | Source repository snapshot `e55d0fd019f973f90a81b8b50752584be5900375`; full path in SOURCE_MANIFEST.csv |
| `bandpass_zero.m` | Source repository snapshot `e55d0fd019f973f90a81b8b50752584be5900375`; full path in SOURCE_MANIFEST.csv |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

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
