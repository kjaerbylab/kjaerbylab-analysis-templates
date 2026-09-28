# Event-aligned traces

**Status:** Candidate — MATLAB run pending.

## Purpose and typical use

Extract and plot signal windows around event timestamps.

## Suitable data and inputs

Signal vector; event times in seconds on the same timeline; sample rate in Hz.

## Requirements

MATLAB and Signal Processing Toolbox (`downsample`).

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

Use `examples/run_example.m`, or:
```matlab
[epochs,t,included] = epoc_extract(events_s,signal,fs, ...
    'time_before',10,'time_after',10,'show_figure',true);
```

## Example data and outputs

See [the synthetic example](examples/README.md) for sample data, a runnable MATLAB script, and reference output. The MATLAB result has not yet been recorded.

## Parameters and limitations

Original plot shading is SD, not SEM. Keep events away from trace boundaries. Time-to-index convention must be checked against your acquisition timeline.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `epoc_extract.m` | matlab sharing.zip :: matlab sharing/functions/epoc_extract.m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

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
