# NREM and REM PAC comodulograms

**Status:** Reference analysis — methodological review and MATLAB run pending.

## Purpose and typical use

State-selected EEG phase/amplitude modulation-index maps.

## Suitable data and inputs

MAT with eeg or EEG and fs_eeg or eeg_frequency. CSV columns time_s,score; one-column scores imply 1-second epochs. CODES maps your actual state labels. Segment boundaries in seconds.

## Requirements

Signal Processing Toolbox. NREM optionally calls apply_50Hz_notch_if_needed if present on your MATLAB path; that optional helper is not bundled. Record whether it was available.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

```matlab
% EXAMPLE labels only: replace with your scoring convention.
CODES = struct('WK',0,'NREM',1,'REM',2,'MA',3);
COM = ach_pac_comod_nrem_segment('recording.mat','scores.csv', ...
    0,600,CODES,'doPlot',true);
% For REM use ach_pac_comod_rem_segment with the same arguments.
```

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

Both concatenate selected state samples before filtering, creating boundaries between noncontiguous bouts. No surrogate significance test is implemented. NREM and REM use different bandwidths/preprocessing. REM can convert failed/undefined entries to zero, which must not be interpreted as evidence of absent coupling. NREM requires recognized MAT variable names. Five seconds is only a software minimum, not a justified scientific duration.

## Authors and provenance

- Source project: MSc thesis repository of **Margarida Seabra Gomes**, as credited in its README. Confirm per-file original authors and any adaptations; preserve existing credits.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `ach_pac_comod_nrem_segment.m` | Source repository snapshot `e55d0fd019f973f90a81b8b50752584be5900375`; full path in SOURCE_MANIFEST.csv |
| `ach_pac_comod_rem_segment.m` | Source repository snapshot `e55d0fd019f973f90a81b8b50752584be5900375`; full path in SOURCE_MANIFEST.csv |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

```matlab
function COM = ach_pac_comod_nrem_segment(mat_file, scores_csv, ...
                                           t_start, t_end, CODES, varargin)
```

<details>
<summary>Original help: ach_pac_comod_nrem_segment.m</summary>

```text
ACH_PAC_COMOD_NREM_SEGMENT
-------------------------------------------------------------
Compute a NREM-only PAC comodulogram (phase × amplitude)
for ONE recording segment and ONE condition.

- phase frequencies: default 0.5:0.5:4 Hz (slow/delta)
- amp   frequencies: default 7:1:25 Hz  (sigma-centered)
- state: NREM (CODES.NREM)

INPUTS
mat_file   : path to .mat with EEG (+ fs_eeg)
scores_csv : 1-Hz scoring CSV (time_s,score) or just score
t_start    : segment start (s)
t_end      : segment end (s)
CODES      : struct with fields .WK .NREM .REM .MA

OPTIONAL name/value:
'phase_freqs' : vector of phase freqs (Hz), default 0.5:0.5:4
'amp_freqs'   : vector of amp freqs (Hz),   default 7:1:25
'nbins'       : #phase bins for PAC,       default 18
'doPlot'      : true/false, make figure    default true
'label'       : string for figure title    default ''

OUTPUT
COM.phase_freqs
COM.amp_freqs
COM.MI         : nP × nA modulation index
COM.nSamples   : # of EEG samples used
COM.fs         : sampling rate used
COM.state      : 'NREM'
COM.t_start, COM.t_end

(if ROI later: you can compute mean MI in e.g. 0.5–1.5 Hz × 11–16 Hz)
-------------------------------------------------------------
parse options
```
</details>

```matlab
function COM = ach_pac_comod_rem_segment(mat_file, scores_csv, t_start, t_end, CODES, varargin)
% ACH_PAC_COMOD_REM_SEGMENT  Robust REM theta–gamma PAC comodulogram
```

<details>
<summary>Original help: ach_pac_comod_rem_segment.m</summary>

```text
ACH_PAC_COMOD_REM_SEGMENT  Robust REM theta–gamma PAC comodulogram
--------------------------------------------------------------------
Computes PAC (Modulation Index, Tort et al.) for REM epochs between
t_start and t_end, using EEG theta phase and gamma amplitude.

This version is robust to zeros in the phase–amplitude histogram and
converts 0*log(0) situations into MI ~ 0 instead of NaN.

INPUTS
mat_file   : .mat file with EEG and sampling rate
scores_csv : scoring CSV (time_s, score) or (score only, 1 Hz)
t_start    : start time (s)
t_end      : end time (s)
CODES      : struct with fields .REM (and others, not used here)

NAME/VALUE PAIRS
'phase_freqs' : vector of phase frequencies (Hz), e.g. 6:0.5:10
'amp_freqs'   : vector of amp frequencies (Hz),   e.g. 30:2:80
'nbins'       : number of phase bins, default 18
'doPlot'      : logical, plot comodulogram if true
'label'       : optional title for plot

OUTPUT
COM struct with fields:
.MI          : [nPhase x nAmp] modulation index
.phase_freqs : phase frequencies (Hz)
.amp_freqs   : amplitude frequencies (Hz)
.nSamples    : # of REM samples used
.fs          : sampling rate (Hz)
-------------------------------------------------------------
Parse options
-------------------------------------------------------------
```
</details>
