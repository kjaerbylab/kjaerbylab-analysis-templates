# Event-related EEG spectra

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Extract EEG band trajectories and spectrograms around events.

## Suitable data and inputs

EEG vector; fs Hz; event times seconds; optional baseline intervals N-by-2 seconds.

## Requirements

Signal Processing Toolbox; Image Processing Toolbox for imgaussfilt; legacy nanmean availability may vary.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

Use the signatures below. Supply explicit normalization_periods when required by the scientific question.

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Two functions have different default output scales. epoc_extractEEGbands uses relative dB by default; its percent scale has baseline 100. mean_powerspctrgrm_epoc defaults to log magnitude. Do not compare these without defining scale and baseline.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `epoc_extractEEGbands.m` | matlab sharing.zip :: matlab sharing/functions/epoc_extractEEGbands.m |
| `mean_powerspctrgrm_epoc.m` | matlab sharing.zip :: matlab sharing/functions/mean_powerspctrgrm_epoc.m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

## Source interfaces and original help

```matlab
function [norm_band_power_epocs, time_spectrogram_zero, spectro_fs] = epoc_extractEEGbands(Time_points, EEG_trace, EEG_fs, varargin)
```

<details>
<summary>Original help: epoc_extractEEGbands.m</summary>

```text
updated on 2026-08-01
This version included dB as output format and corrected power (^2)
transformation of spectrogram output to both log_ratio and percent
outputs
EPOC_EXTRACTEEGBANDS
This function extracts power band epochs from EEG or LFP traces, allowing
for optimized windowing and resolution settings suitable for faster signals.
Input arguments:
Time_points: vector of time stamps (s) used for epoc analysis (default +/-60 s.
To change epoc size, use 'time_before' and 'time_after' input arguments)
EEG_trace: the EEG or LFP trace you want to perform epoc analysis on
EEG_fs: sampling frequency of the trace
Optional Parameters:
- 'power_bands': specify power bands in a cell array (default EEG bands:
delta, theta, sigma, beta, gamma lo, gamma hi)
- 'time_before': time in seconds leading up to event (default 60s)
- 'time_after': time in seconds following event (default 60s)
- 'analysis_window': window size for spectrogram analysis (default 5s for EEG, 0.5s recommended for LFP)
- 'window_overlap': overlap ratio for windowing (default 0.5, recommended 0.8 for LFP)
- 'normalization_periods': Nx2 matrix of [onset, offset] times (s) defining
periods to use as the baseline for normalization (e.g. NREM
bouts), independent of the epoch windows. If not provided,
baseline is computed per band by pooling across all extracted
epochs instead (see notes below).
- 'output_units': 'dB' (default), 'log_ratio', or 'percent'. All three
express power relative to baseline_mean(band); they
differ only in scale (see NORMALIZATION NOTES below).
- 'show_figure': display results (default true)
Output arguments:
norm_band_power_epocs: 3D array of epoc bands (D1 is +/- 60 s epoc trace, D2 is the epoc number, D3 is EEG band)
time_spectrogram_zero: time vector matching length of norm_band_power_epocs
spectro_fs: sampling frequency of time_spectrogram_zero.
===========================
NORMALIZATION NOTES
===========================
spectrogram() returns the complex STFT, S. abs(S) is MAGNITUDE, not power -
power is abs(S).^2. This version squares explicitly so that "power" in the
variable names (log_power, band_power_trace, etc.) is actually true power,
not magnitude. (Previous versions took log(abs(S)) directly, which is a
log-MAGNITUDE ratio - fine internally as long as you're consistent, but it
mismatched the docstring/variable naming, which described everything as
power.)

Normalization is a log-domain baseline SUBTRACTION rather than a division:
norm_band(f in band, t, epoch) = log_power(f,t,epoch) - baseline_mean(band)
This is the correct way to express "power relative to baseline" when already
working in log space (subtracting logs = dividing raw power by baseline power).

Three equivalent output scalings of that same log-power ratio are available
via 'output_units':
'dB'        (default) = ratio * (10/log(10))  -> 0 = baseline, +3.01/-3.01 = double/half power
'log_ratio'            = ratio, unscaled       -> 0 = baseline, +/-log(2) = double/half power
'percent'               = 100*exp(ratio)        -> 100 = baseline, 200 = double, 50 = half

If 'normalization_periods' is supplied, baseline_mean(band) is computed from
spectrograms of those periods (e.g. NREM bouts) directly from the raw trace -
not from a resampled continuous power trace - avoiding fs/rounding misalignment.

If 'normalization_periods' is NOT supplied, baseline_mean(band) falls back to
pooling across all extracted epochs (time + epoch dimensions), same as before,
just done separately per band now instead of with one global scalar. Note this
fallback is still somewhat circular if Time_points mark the events of interest,
since the baseline then partly reflects those events. Use 'normalization_periods'
whenever a state-defined baseline (e.g. NREM) is available.
===========================
INPUT PARSER SETUP
===========================
```
</details>

```matlab
function [mean_spectrogram, epoc_spectrogram_collector, time_spectrogram_zero, F] = mean_powerspctrgrm_epoc(eeg_trace, sampling_frq, time_points, varargin)
```

<details>
<summary>Original help: mean_powerspctrgrm_epoc.m</summary>

```text
Update 02-08-2026: includes dB output format and normalization to
baseline periods

MEAN_POWERSPCTRGRM_EPOC
Input arguments:
eeg_trace: full EEG trace to extract epoc spectrograms from
sampling_frq: sampling frequency (Hz) of eeg_trace
time_points: vector of time stamps (s) used for epoc analysis (default +/-60 s. To change epoc size, use 'before_epoc' and 'after_epoc' input arguments)
Optional Parameters:
- 'before_epoc' / 'after_epoc': window around each time point (default 60s each)
- 'window' / 'overlap_frac': spectrogram windowing (default 5s window, 0 overlap)
- 'smooth_sigma': gaussian smoothing sigma for the plotted heatmap (default 4)
- 'power_bands': unused directly here but kept for interface consistency
- 'output_units': 'log_magnitude' (default, matches original behavior),
'log_power', or 'dB'. See NOTES below.
- 'normalization_periods': Nx2 matrix of [onset, offset] times (s) defining
a baseline period (e.g. NREM bouts) to subtract before
output-unit conversion. Default [] = no baseline
subtraction (matches original behavior: absolute,
unreferenced values).
- 'show_figure': display heatmap (default true)

Output arguments:
mean_spectrogram: mean spectrum across epochs, in the units set by 'output_units'
epoc_spectrogram_collector: holds extracted raw complex STFT per epoch (unchanged by output_units)
time_spectrogram_zero: time vector with 0 at 'time_points'
F: frequency vector
===========================
NOTES ON OUTPUT UNITS
===========================
spectrogram() returns the complex STFT, S. abs(S) is MAGNITUDE (e.g. uV),
not power (uV^2) - power is abs(S).^2.

'log_magnitude' (default): log(abs(S)), exactly as in the original version
of this function. Absolute, unreferenced log-magnitude in
whatever units eeg_trace is in. NOT power, NOT baseline-
relative. Kept as default so existing calls/plots/clim
values reproduce unchanged.
'log_power':      log(abs(S).^2) = 2*log_magnitude. Absolute log-power,
still unreferenced unless normalization_periods is given.
'dB':             log_power * (10/log(10)). Absolute dB, unreferenced
unless normalization_periods is given.

If 'normalization_periods' is supplied, a baseline mean (in the chosen
output unit's underlying log space) is computed from those periods and
subtracted, making the output relative to that baseline (0 = baseline for
log_power/dB). If not supplied, output is absolute/unreferenced, same as
the original function.
===========================
INPUT PARSER SETUP
===========================
```
</details>
