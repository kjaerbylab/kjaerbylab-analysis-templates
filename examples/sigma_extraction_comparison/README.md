# Sigma extraction comparison

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Compare alternative band-power extraction methods with synthetic or workspace EEG.

## Suitable data and inputs

Use a clean workspace to trigger synthetic generation, or provide EEG and fs_eeg.

## Requirements

Signal Processing and Wavelet toolboxes.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

Open the script and run with a clean workspace.

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Not a detector validation or a recommended-method ranking. Random synthetic output is not a fixed reference result.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `sigma_power_extraction_comparison.m` | matlab sharing.zip :: matlab sharing/sigma_power_extraction_comparison.m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

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
