# Median baseline photometry

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Median-based percent delta-F/F followed by linear detrending and smoothing.

## Suitable data and inputs

Workspace signal_465 and signal_fs (Hz).

## Requirements

Signal Processing Toolbox.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

Populate those variables and run `normalise_dFF_median.m`. Inspect full trace and final plot.

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

This is not reference-channel artifact correction. Detrending removes a linear trend. Plot starts at downsampled sample 1000, so short signals may produce no useful plot. Output spelling delta_465_filt differs from reference-fitting scripts.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `normalise_dFF_median.m` | Uploaded normalise_dFF_median(1).m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

## Source interfaces and original help

<details>
<summary>Original help: normalise_dFF_median.m</summary>

```text
DESCRIPTION
This script can be used as an alternative to the normalisation that is
based on fitting the 405 nm channel. Instead the median of signal is used
to get dF/F. This should only be used when 405 is not available or if it
cannot be used due to artefacts in the 405 channel.
Normalisation (dF/F) using the median
```
</details>
