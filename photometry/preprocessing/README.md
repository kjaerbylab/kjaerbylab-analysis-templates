# Reference-fitted photometry preprocessing

**Status:** Candidate — MATLAB run pending.

## Purpose and typical use

Import TDT channels, trim to TTL, fit control to signal and calculate percent delta-F/F and z-score.

## Suitable data and inputs

TDT tank path, signal/reference channel names, TTL epoc name, fitting times in seconds; optional laser channel.

## Requirements

TDTbin2mat (external); Signal Processing Toolbox.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

Open `FP_preprocess2.m`; configure `mouse`, inspect fitting interval and TTLs, and run section by section.

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

TTL seconds multiplied by sampling rate are used as indices without rounding. Fit interval must exist after trimming. Filter length is 1000 samples, not a fixed duration. Multiple TTL restarts and laser boundaries require review. Outputs include delta_465, delta465_filt, ds_delta465_filt, delta465_Zscore.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `FP_preprocess2.m` | Uploaded FP_preprocess2(1).m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

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
