# Threshold spindle detector

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Detect spindle-band events within NREM intervals.

## Suitable data and inputs

EEG and time vectors, fs Hz, NREM on/off intervals seconds.

## Requirements

Signal Processing Toolbox; binary_to_OnOff external helper (see dependencies).

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

```matlab
[c,on,off,filtered] = spindle_detect(eeg,t,fs,nrem_periods,'show_figure',true);
```

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Events are sample indices. Default band 10–15 Hz. Thresholds depend on window and NREM distribution. Source cites Uygun et al. 2019; confirm exact method reference. Helper has absent-transition edge cases.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `spindle_detect.m` | matlab sharing.zip :: matlab sharing/functions/spindle_detect.m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

## Source interfaces and original help

```matlab
function [spindle_center_filtered, spindle_onset_filtered, spindle_offset_filtered, eeg_data_spindlefilt] = spindle_detect(eeg_data, eeg_time, eeg_fs, sws_periods, varargin)
```

<details>
<summary>Original help: spindle_detect.m</summary>

```text
Spindle detection
based on Uygun et al., Sleep Research Society 2019
SPINDLE_DETECT
Input arguments:
eeg_data: vector containing EEG trace
eeg_time: time vector matching eeg_data (used for plotting)
eeg_fs: sampling frequency (Hz) for eeg_data
sws_periods: n-by-2 matrix containing on-/offsets (s) of periods to include in detection
Optional inputs:
'first_passband': spindle frequency range lower boundary (Hz), default 10 Hz
'second_passband': spindle frequency range upper boundary (Hz), default 15 Hz
'segment_length': segmentation window length (min)
'segment_overlap': fraction overlap between segmentation windows, e.g., 0.5 for 50%
'detection_thres': This factor determines event detection
'coherence_thres': This factor determines events duration (i.e. coupling of adjecent events).
'threshold_method': 'per_segment' (default) computes threshold from NREM data within
each sliding window (original method). 'global_nrem' concatenates
all NREM periods first, then uses sliding windows over that
NREM-only signal to compute thresholds (script method). Note that
with 'global_nrem', envelope and candidate detection still operate
on the full EEG segment — only the threshold mean changes.
'show_figure': true/false whether to plot figure

Output arguments:
spindle_center_filtered: center point of detected spindles during specified periods. NB! Center is given as samples, not seconds
spindle_onset_filtered: onset of spindles given in samples, not seconds
spindle_offset_filtered: offset of spindles given in samples, not seconds
eeg_data_spindlefilt: full EEG trace filtered using the filter design applied for spindle detection
```
</details>
