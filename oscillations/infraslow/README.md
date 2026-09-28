# Infraslow oscillations

**Status:** Candidate — MATLAB run pending.

## Purpose and typical use

Period-specific PSD or wavelet spectra and duration-weighted summaries.

## Suitable data and inputs

Trace and time vector, periods N-by-2 in seconds, fs Hz, minimum period duration seconds.

## Requirements

Signal Processing Toolbox; Wavelet Toolbox for InfraslowWavelet.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

```matlab
[p,f,peak,fpeak] = PSDinfraslow(x,t,periods,fs,120,'show_figure_mean',true);
```

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

Both detrend with a fifth-order polynomial. PSD indices can be zero for periods starting at zero. Empty qualifying periods require review. Wavelet downsampling assumes input fs at least 10 Hz; not a generic low-rate input function.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `PSDinfraslow.m` | matlab sharing.zip :: matlab sharing/functions/PSDinfraslow.m |
| `InfraslowWavelet.m` | matlab sharing.zip :: matlab sharing/functions/InfraslowWavelet.m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

```matlab
function [psd_trace, psd_freq, PXX_pk_mean, PXX_f_mean] = PSDinfraslow(trace, trace_t, periods, trace_fs, min_dur, varargin)
```

<details>
<summary>Original help: PSDinfraslow.m</summary>

```text
PSDINFRASLOW
Input arguments:
trace: is the trace you want to assess for infraslow oscillations
trace_t: time trace (s) matching lenght of trace
periods: is an n by 2 matrix where n is the number of periods,
column 1 contains onset and coulmn 2 offset of each period (in s).
These periods determine which part of the data is analyzed
trace_fs: is the sample frequency for the trace.
min_dur: is the minimum duration for a bout to be included
Output arguments:
psd_trace: mean PSD trace (weighted based on period durations)
psd_freq: psd frequencies (x-axis for plotting)
PXX_pk_mean: peak value from PSD trace
PXX_f_mean: peak frequency from PSD trace
```
</details>

```matlab
function [wavelt_trace, wavelt_freq, wavelt_pk_mean, wavelt_f_mean] = InfraslowWavelet(trace, trace_t, periods, trace_fs, min_dur, varargin)
%INFRASLOWWAVELET
```

<details>
<summary>Original help: InfraslowWavelet.m</summary>

```text
INFRASLOWWAVELET
Performs wavelet analysis on a trace to assess infraslow oscillations
during specified periods. Uses Morlet wavelet transform to extract
power and frequency estimates, replacing PSD analysis.
Input arguments:
trace         - signal vector
trace_t       - time vector (same length as trace)
periods       - n x 2 matrix [start_time, end_time] in seconds
trace_fs      - sampling frequency (Hz)
min_dur       - minimum period duration to include (s)

Optional name-value pairs:
'show_figure_mean'   - plot the mean wavelet spectrum (default: false)
'show_figure_indvdl' - plot individual bout traces and spectra (default: false)

Output arguments:
wavelt_trace   - weighted mean wavelet power spectrum
wavelt_freq    - corresponding frequencies (Hz)
wavelt_pk_mean - peak power in mean wavelet spectrum
wavelt_f_mean  - frequency of the peak power
--- Input parsing ---
```
</details>
