# Pre/post event measurements

**Status:** Candidate — MATLAB run pending.

## Purpose and typical use

Measure event-related changes in mean level or AUC.

## Suitable data and inputs

Epoch matrix: samples by events; sample rate Hz; time-before-event and pre/post window boundaries in seconds.

## Requirements

Base MATLAB.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

Call the chosen function using its signature below after extracting epochs. `prepostdiff` defaults to mean; `prepostdiff_AUC` is a separate implementation.

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

State pre/post windows and units in reports. For custom `@trapz` in prepostdiff, source notes require division by sampling frequency. Inspect unequal-window interpretation.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `prepostdiff.m` | matlab sharing.zip :: matlab sharing/functions/prepostdiff.m |
| `prepostdiff_AUC.m` | matlab sharing.zip :: matlab sharing/functions/prepostdiff_AUC.m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

```matlab
function [epoc_diff_prepost, epoc_pre, epoc_post] = prepostdiff(event_epocs, epoc_fs, time_before, preTrigger_start, preTrigger_end, postTrigger_start, postTrigger_end, varargin)
```

<details>
<summary>Original help: prepostdiff.m</summary>

```text
PREPOSTDIFF_AUC
Input arguments:
event_epocs: is a matrix, where columns represent the number of epocs (=1 in case of a single mean epoc trace) and rows represent the number of samples (i.e. epoc seconds*fs).
epoc_fs: sampling frequency of the trace(s) in event_epocs.
time_before: is the number of seconds before time zero in epoc traces
preTrigger_start:  is the start time (s) for the pre-event baseline AUC calculation.
preTrigger_end: is the end time (s) for the pre-event baseline AUC calculation (set to =0 if pre baseline should end at time of epoc event).
postTrigger_start: is the start time (s) for the post-event AUC calculation (set to =0 if post level should start at time of epoc event).
postTrigger_end: is the end time (s) for the post-event  AUC calculation.
pre_method: is the function handle used for pre level calculation (is @mean by default)
post_method: is the function handle used for post level calculation (is @mean by default)

Output arguments:
EMG_diff_prepost: a vector of changes in AUC across the epoc event (post-pre). If event_epocs holds a single mean epoc trace, this output will be a single number.
EMG_pre: a vector of AUC pre the epoc event.
EMG_post: a vector of AUC post the epoc event.

Note: to use AUC as methods use @trapz, and divide the outputs by sampling frequency to normalize to timeline
```
</details>

```matlab
function [epoc_diff_prepost, epoc_pre, epoc_post] = prepostdiff_AUC(event_epocs, epoc_fs, time_before, preTrigger_start, preTrigger_end, postTrigger_start, postTrigger_end)
```

<details>
<summary>Original help: prepostdiff_AUC.m</summary>

```text
PREPOSTDIFF_AUC
Input arguments:
event_epocs: is a matrix, where columns represent the number of epocs (=1 in case of a single mean epoc trace) and rows represent the number of samples (i.e. epoc seconds*fs).
epoc_fs: sampling frequency of the trace(s) in event_epocs.
time_before: is the number of seconds before time zero in epoc traces
preTrigger_start:  is the start time (s) for the pre-event baseline AUC calculation.
preTrigger_end: is the end time (s) for the pre-event baseline AUC calculation (set to =0 if pre baseline should end at time of epoc event).
postTrigger_start: is the start time (s) for the post-event AUC calculation (set to =0 if post level should start at time of epoc event).
postTrigger_end: is the end time (s) for the post-event  AUC calculation.

Output arguments:
EMG_diff_prepost: a vector of changes in AUC across the epoc event (post-pre). If event_epocs holds a single mean epoc trace, this output will be a single number.
EMG_pre: a vector of AUC pre the epoc event.
EMG_post: a vector of AUC post the epoc event.
```
</details>
