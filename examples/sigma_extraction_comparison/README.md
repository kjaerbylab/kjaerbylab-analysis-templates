# Sigma extraction comparison

**Status:** Candidate — MATLAB run pending.

## Purpose and typical use

Compare alternative band-power extraction methods with synthetic or workspace EEG.

## Suitable data and inputs

Use a clean workspace to trigger synthetic generation, or provide EEG and fs_eeg.

## Requirements

Signal Processing and Wavelet toolboxes.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

Open the script and run with a clean workspace.

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

Not a detector validation or a recommended-method ranking. Random synthetic output is not a fixed reference result.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `sigma_power_extraction_comparison.m` | matlab sharing.zip :: matlab sharing/sigma_power_extraction_comparison.m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

<details>
<summary>Original help: sigma_power_extraction_comparison.m</summary>

```text
compare_sigma_methods.m
Benchmarks 4 ways of extracting 10-15 Hz "sigma" power from an EEG trace:
1) designfilt (IIR, explicit stopband attenuation) + Hilbert
2) Butterworth (order 4) + Hilbert
3) FIR (Hamming) + Hilbert
4) CWT squared envelope (restricted freq range for speed)
5) (reference only) spectrogram-based log-power, interpolated to full fs

Loads EEG_rawtrace and fs_eeg if they exist in the workspace; otherwise
generates a synthetic trace with embedded ~12 Hz spindle bursts so you
can sanity-check the methods even without real data.
--- Get / generate data -------------------------------------------------
```
</details>
