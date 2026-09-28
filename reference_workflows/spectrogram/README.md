# Log-magnitude spectrogram

**Status:** Reference only — not recommended for unattended use. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Original experiment workflow retained for context.

## Suitable data and inputs

Existing workspace variables and/or experiment-specific files specified in source.

## Requirements

See source calls; ViewPoint, TDT and plotting helpers may be external.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

Read source sections and configure paths/variables before attempting a run.

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Uses log(abs(STFT)), not linear power or dB. Requires photometry and sleep-state workspace variables.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `EEG_power_spectrogram.m` | Uploaded EEG_power_spectrogram(1).m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

## Source interfaces and original help

<details>
<summary>Original help: EEG_power_spectrogram.m</summary>

```text
EEG power spectrum analysis
here you plot a power spectrogram (heatmap) for your EEG data and band
power traces for the defined EEG frequency bands (incl sigma trace).
```
</details>
