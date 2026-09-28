# Combined TDT workflow

**Status:** Reference only — not recommended for unattended use.

## Purpose and typical use

Original experiment workflow retained for context.

## Suitable data and inputs

Existing workspace variables and/or experiment-specific files specified in source.

## Requirements

See source calls; ViewPoint, TDT and plotting helpers may be external.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

Read source sections and configure paths/variables before attempting a run.

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

TTL channel lookup uses mouse{12} on both rigs although description lists index 13 for EEG TTL. Review configuration and indexing.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `Load_combined_FP_EEG.m` | Uploaded Load_combined_FP_EEG(1).m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

<details>
<summary>Original help: Load_combined_FP_EEG.m</summary>

```text
data structure:
1) TDT file FP
2) TDT file including EEG/EMG
3) 1: 465 channel name
4) 1: 405 channel name
5) 1: 560 channel name
6) 2: 465 channel name
7) 2: 405 channel name
8) 2: 560 channel name
9) EEG channel name
10) EEG channel
11) EMG channel name
12) synchronization channel name FP rig
13) synchronization channel name EEG rig
14) interval for fitting (polyfit)
build-up
```
</details>
