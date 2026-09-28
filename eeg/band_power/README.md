# Hilbert band power

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Bandpass signal, amplitude envelope and instantaneous power.

## Suitable data and inputs

Signal vector, fs Hz, band edges Hz.

## Requirements

Signal Processing Toolbox.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

```matlab
out = powerTrans_byHilbert(eeg,fs,[10 15]);
```

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Choose band below Nyquist. Filtering and smoothing affect temporal resolution; check edge artifacts and baseline mask. Envelope amplitude and squared-envelope power differ.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `powerTrans_byHilbert.m` | matlab sharing.zip :: matlab sharing/functions/powerTrans_byHilbert.m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

## Source interfaces and original help

```matlab
function out = powerTrans_byHilbert(x, fs, band_hz, varargin)
% POWERTRANS_BYHILBERT  Stable band-pass -> Hilbert envelope -> power (+ dB)
```

<details>
<summary>Original help: powerTrans_byHilbert.m</summary>

```text
POWERTRANS_BYHILBERT  Stable band-pass -> Hilbert envelope -> power (+ dB)
Gives a power trace with higher temporal resolution than from 'spectrogram'

out = powerTrans_byHilbert(x, fs, [f1 f2], Name,Value, ...)

Inputs
x         : vector (EEG), row or col
fs        : sampling frequency (Hz)
[f1 f2]   : passband in Hz (e.g., [0.5 4], [10 15], [65 80])

Name-Value options (all optional)
'Order'         : IIR Butterworth order per pass (default 4). Use higher order for narrow bands
'NotchHz'       : scalar 50 or 60 to notch line noise (default [])
'NotchQ'        : quality factor for notch (default 30)
'HighpassHz'    : pre-highpass to remove drift (e.g., 0.1) (default [])
'SmoothSec'     : movmean window (sec) on power, 0 = none (default 0)
'BaselineMask'  : logical vector same length as x for baseline (default [])
'Eps'           : epsilon for dB calc (default 1e-20)

Outputs (struct)
out.band        : bandpassed signal
out.env         : Hilbert envelope (amplitude)
out.power       : instantaneous power (env.^2) in units of x^2
out.power_dB    : 10*log10(power + eps) [dB re 1 (unit^2)]
out.power_dB_rel: if BaselineMask provided, dB relative to baseline median
out.sos         : IIR SOS coefficients for the bandpass
out.g           : SOS gain

Notes
- Uses SOS + filtfilt for numerical stability and zero-phase.
- For delta/theta or narrow bands, SOS is strongly recommended.
- If you set 'NotchHz', the notch runs BEFORE bandpass.

Example:
out = powerTrans_byHilbert(EEG, fs, [10 15], 'Order', 4, 'NotchHz', 50, ...
'SmoothSec', 0.2, 'BaselineMask', t<100);
---- Parse inputs
```
</details>
