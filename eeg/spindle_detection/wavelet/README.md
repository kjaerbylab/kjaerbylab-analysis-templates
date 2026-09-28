# Wavelet spindle detector

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Detect spindle candidates using wavelet power and event-validation criteria.

## Suitable data and inputs

Samples-by-channels EEG and original fs Hz. Optional logical stateMask must match internally resampled signal at targetFs (default 200 Hz).

## Requirements

Signal Processing and Wavelet toolboxes; legacy cwt/centfrq and nan* function compatibility must be checked.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

```matlab
[spindle,param] = spindleDetection_Margarida(eeg,fs,'targetFs',200);
% Supply stateMask at 200 Hz for NREM-restricted analysis.
```

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

No mask means no NREM restriction. Adaptive thresholds vary by session. param threshold fields describe only the last processed channel. Verify event timing units from returned fields. This ZIP version has not been matched to the current author-approved implementation.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `spindleDetection_Margarida.m` | matlab sharing.zip :: matlab sharing/functions/spindleDetection_Margarida.m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

## Source interfaces and original help

```matlab
function [spindle, param] = spindleDetection_Margarida(inputSignal, sampRate, varargin)
% v2
```

<details>
<summary>Original help: spindleDetection_Margarida.m</summary>

```text
v2
Detect sleep spindles from one or more EEG channels using wavelet power

-------------------------------------------------------------------------
IMPORTANT CONTEXT / DATA ASSUMPTIONS
-------------------------------------------------------------------------
This detector is prepared for EEG sleep recordings where:

1) The signal is EEG sampled at a high sampling rate and then
internally resampled to targetFs, by default 200 Hz

2) Spindles are expected during NREM sleep and are detected in the
9-16 Hz range, with the main wavelet power estimated from 10-14 Hz

3) If a sleep-state mask is provided, it must already be expanded to the
target sampling rate. For example:

- 1 s scoring, targetFs = 200 Hz:
stateMask = repelem(NREM_epochs, 200);

- 2 s scoring, targetFs = 200 Hz:
stateMask = repelem(NREM_epochs, 400);

The detector does not know whether the scoring was 1 s, 2 s, or 5 s
It only expects one logical value per EEG sample after resampling

4) Thresholds are adaptive and estimated per channel/session.
This makes detection robust across animals, but it also means that
spindle counts are relative to each recording's own power distribution.
If comparing genotypes or conditions, it is recommended to also inspect
spindle amplitude, density, duration, central frequency, and threshold
values

5) For multi-channel data, spindle is returned as one cell per channel.
The param.thrL/thrH/thrM fields correspond to the last processed
channel only. This is kept intentionally to preserve the original
function behavior

-------------------------------------------------------------------------
Algorithm
-------------------------------------------------------------------------
1) Detrends and resamples the signal to a fixed sampling rate
2) Estimates spindle-band power using b-spline wavelet transform
3) Detects candidate events using adaptive thresholds
4) Validates each event by duration, cycle count, spectral content,
and optional overlap with a provided state mask

-------------------------------------------------------------------------
Inputs
-------------------------------------------------------------------------
inputSignal : samples x channels matrix, or a single vector
sampRate    : original sampling rate (Hz)

-------------------------------------------------------------------------
Name-value options
-------------------------------------------------------------------------
'targetFs'    : resampling rate used internally
default: 200 Hz

'stateMask'   : logical vector at targetFs.
If provided:
- thresholds are estimated only from masked samples
- detected events must overlap sufficiently with mask

'minMaskFrac' : minimum fraction of event inside stateMask
default: 0.8

'thrF'        : threshold multipliers [low high max]
default: [1 3 20]

-------------------------------------------------------------------------
Outputs
-------------------------------------------------------------------------
spindle : cell array, one entry per channel. Each entry contains a
struct array with one element per detected spindle.

param   : parameter struct used by the detector.
For multi-channel data, thrL/thrH/thrM correspond to the
last processed channel.
-------------------------------------------------------------------------
Parse options
-------------------------------------------------------------------------
```
</details>
