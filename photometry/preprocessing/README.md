# Reference-fitted photometry preprocessing

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Import TDT channels, trim to TTL, fit control to signal and calculate percent delta-F/F and z-score.

## Suitable data and inputs

TDT tank path, signal/reference channel names, TTL epoc name, fitting times in seconds; optional laser channel.

## Requirements

TDTbin2mat (external); Signal Processing Toolbox.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

Open `FP_preprocess2.m`; configure `mouse`, inspect fitting interval and TTLs, and run section by section.

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

TTL seconds multiplied by sampling rate are used as indices without rounding. Fit interval must exist after trimming. Filter length is 1000 samples, not a fixed duration. Multiple TTL restarts and laser boundaries require review. Outputs include delta_465, delta465_filt, ds_delta465_filt, delta465_Zscore.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `FP_preprocess2.m` | Uploaded FP_preprocess2(1).m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

## Source interfaces and original help

<details>
<summary>Original help: FP_preprocess2.m</summary>

```text
DESCRIPTION
In this script you load fiber photometry traces and normalize them to get
dF/F (or Z-score). The traces will also be aligned by cutting the first
chunk of data leading up to the first TTL pulse
Specify mouse data
Below you specify input arguments for each recording. Make sure to update
the name of the channels according to your specific recordings. Adjust
the fitting interval used for polyfit if the plotted fit looks off.
```
</details>
