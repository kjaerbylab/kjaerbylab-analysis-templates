# Spindle trough locations

**Status:** Candidate — MATLAB run pending.

## Purpose and typical use

Locate selected troughs within already detected spindle events.

## Suitable data and inputs

Filtered EEG vector; N-by-2 spindle bounds in sample indices; troughType lowest/first/last.

## Requirements

MATLAB; inspect findpeaks usage for Signal Processing Toolbox.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

```matlab
i = spindle_trough_detect(filtered_eeg,event_samples,'lowest');
```

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

Input event bounds must be valid sample indices of the supplied filtered trace.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `spindle_trough_detect.m` | matlab sharing.zip :: matlab sharing/functions/spindle_trough_detect.m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

```matlab
function trough_samples = spindle_trough_detect(filtered_signal, spindle_onoff, troughType)
% FIND_SPINDLE_TROUGHS
```

<details>
<summary>Original help: spindle_trough_detect.m</summary>

```text
FIND_SPINDLE_TROUGHS
Inputs:
filtered_signal : vector, bandpass-filtered EEG/LFP
spindle_onoff   : n x 2 matrix of [onset, offset] samples
troughType      : 'lowest' (default), 'first', or 'last'
- 'lowest': global minimum within the spindle (original behavior)
- 'first' : first local minimum within the spindle
- 'last'  : last local minimum within the spindle
Output:
trough_samples  : n x 1 vector of sample indices of the minimum per spindle
```
</details>
