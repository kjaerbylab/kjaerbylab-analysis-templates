# Threshold spindle detector

**Status:** Candidate — MATLAB run pending.

## Purpose and typical use

Detect spindle-band events within NREM intervals.

## Suitable data and inputs

EEG and time vectors, fs Hz, NREM on/off intervals seconds.

## Requirements

Signal Processing Toolbox; binary_to_OnOff external helper (see dependencies).

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

```matlab
[c,on,off,filtered] = spindle_detect(eeg,t,fs,nrem_periods,'show_figure',true);
```

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

Events are sample indices. Default band 10–15 Hz. Thresholds depend on window and NREM distribution. Source cites Uygun et al. 2019; confirm exact method reference. Helper has absent-transition edge cases.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `spindle_detect.m` | matlab sharing.zip :: matlab sharing/functions/spindle_detect.m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

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
