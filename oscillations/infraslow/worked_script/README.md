# Infraslow PSD worked script

**Status:** Reference — MATLAB run pending.

## Purpose and typical use

Walk through the infraslow PSD calculation.

## Suitable data and inputs

delta465_filt, signal_fs, sec_signal, NREMinclMA_periods workspace variables.

## Requirements

Signal Processing Toolbox.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

Populate inputs; run sections individually.

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

Frequency grid differs from PSDinfraslow.m; both need boundary checks.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `PSD_infraslow_oscil.m` | Uploaded PSD_infraslow_oscil(1).m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

<details>
<summary>Original help: PSD_infraslow_oscil.m</summary>

```text
DESCRIPTION
This script can be used to make a power spectral density analysis on
traces that show infraslow oscillations (e.g. NE and sigma traces)
PSD on NE trace
```
</details>
