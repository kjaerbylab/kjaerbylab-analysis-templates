# Event-aligned traces

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Extract and plot signal windows around event timestamps.

## Suitable data and inputs

Signal vector; event times in seconds on the same timeline; sample rate in Hz.

## Requirements

MATLAB and Signal Processing Toolbox (`downsample`).

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

Use `examples/run_example.m`, or:
```matlab
[epochs,t,included] = epoc_extract(events_s,signal,fs, ...
    'time_before',10,'time_after',10,'show_figure',true);
```

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Original plot shading is SD, not SEM. Keep events away from trace boundaries. Time-to-index convention must be checked against your acquisition timeline.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `epoc_extract.m` | matlab sharing.zip :: matlab sharing/functions/epoc_extract.m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

## Source interfaces and original help

```matlab
function [event_epocs, epoc_time, Time_points_incl] = epoc_extract(Time_points, trace_signal, trace_fs, varargin)
```

<details>
<summary>Original help: epoc_extract.m</summary>

```text
EPOC_EXTRACT
Input arguments:
Time_points: vector of time stamps (s) used for epoc analysis (default +/-60 s. To change epoc size, use 'time_before' and 'time_after' input arguments)
trace_signal: vector containing signal trace (e.e. delta465_filt) used for epoc analysis
trace_fs: sampling frequncy for trace_signal (Hz)

Output arguments:
event_epocs: holds extracted EEG power bands (first column is time line)
epoc_time: time vector matching length of band_power_collector
Time_points_incl: vector of time stamps (s) included in epoc analysis
(if some time points are excluded due to proximity to trace end)
```
</details>
