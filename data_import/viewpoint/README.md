# ViewPoint import and alignment

**Status:** Reference — external dependencies and review required. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Import EEG/EMG, scoring and TTL alignment from ViewPoint recordings.

## Suitable data and inputs

ViewPoint .exp and associated recording/scoring files. Assumes EMG channel 1, EEG channel 2, TTL channel 3, and one-second state vectors.

## Requirements

ViewPoint ExpToolbox: loadEXP, ExtractContinuousData, ExtractFullHypno; external helpers binary_to_OnOff, plot_sleep, DataCursor_custom. See dependencies/README.md.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

Open the script. Set `mouse` and toolbox path, verify channel order, then run section by section.

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Personal paths require configuration. MA is wake shorter than 15 seconds. Raw states 1/2/4 map to Wake/NREM/REM; later custom labels differ. TTL edge/gap selection, absent states and data durations need testing. DataCursor_custom is not supplied.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `load_EEGdata_Viewpoint.m` | Uploaded load_EEGdata_Viewpoint(3).m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

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
