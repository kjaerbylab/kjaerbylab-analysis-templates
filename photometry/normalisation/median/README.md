# Median baseline photometry

**Status:** Candidate — MATLAB run pending.

## Purpose and typical use

Median-based percent delta-F/F followed by linear detrending and smoothing.

## Suitable data and inputs

Workspace signal_465 and signal_fs (Hz).

## Requirements

Signal Processing Toolbox.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

Populate those variables and run `normalise_dFF_median.m`. Inspect full trace and final plot.

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

This is not reference-channel artifact correction. Detrending removes a linear trend. Plot starts at downsampled sample 1000, so short signals may produce no useful plot. Output spelling delta_465_filt differs from reference-fitting scripts.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `normalise_dFF_median.m` | Uploaded normalise_dFF_median(1).m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

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
