# Infraslow PSD worked script

**Status:** Reference — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Walk through the infraslow PSD calculation.

## Suitable data and inputs

delta465_filt, signal_fs, sec_signal, NREMinclMA_periods workspace variables.

## Requirements

Signal Processing Toolbox.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

Populate inputs; run sections individually.

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Frequency grid differs from PSDinfraslow.m; both need boundary checks.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `PSD_infraslow_oscil.m` | Uploaded PSD_infraslow_oscil(1).m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

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
