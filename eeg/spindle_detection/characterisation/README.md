# Spindle trough locations

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Locate selected troughs within already detected spindle events.

## Suitable data and inputs

Filtered EEG vector; N-by-2 spindle bounds in sample indices; troughType lowest/first/last.

## Requirements

MATLAB; inspect findpeaks usage for Signal Processing Toolbox.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

```matlab
i = spindle_trough_detect(filtered_eeg,event_samples,'lowest');
```

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Input event bounds must be valid sample indices of the supplied filtered trace.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `spindle_trough_detect.m` | matlab sharing.zip :: matlab sharing/functions/spindle_trough_detect.m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

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
