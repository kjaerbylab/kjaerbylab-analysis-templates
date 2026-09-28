# ViewPoint import and alignment

**Status:** Reference — external dependencies and review required.

## Purpose and typical use

Import EEG/EMG, scoring and TTL alignment from ViewPoint recordings.

## Suitable data and inputs

ViewPoint .exp and associated recording/scoring files. Assumes EMG channel 1, EEG channel 2, TTL channel 3, and one-second state vectors.

## Requirements

ViewPoint ExpToolbox: loadEXP, ExtractContinuousData, ExtractFullHypno; external helpers binary_to_OnOff, plot_sleep, DataCursor_custom. See dependencies/README.md.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

Open the script. Set `mouse` and toolbox path, verify channel order, then run section by section.

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

Personal paths require configuration. MA is wake shorter than 15 seconds. Raw states 1/2/4 map to Wake/NREM/REM; later custom labels differ. TTL edge/gap selection, absent states and data durations need testing. DataCursor_custom is not supplied.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `load_EEGdata_Viewpoint.m` | Uploaded load_EEGdata_Viewpoint(3).m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

<details>
<summary>Original help: load_EEGdata_Viewpoint.m</summary>

```text
DESCRIPTION
This script can be used for loading EEG/EMG data and sleepscoring that
are recorded and scored using Sleepscore by Viewpoint. The data is
subsequently cut in order to align with fiber photometry data.
Specify mouse data
```
</details>
