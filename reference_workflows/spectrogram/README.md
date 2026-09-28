# Log-magnitude spectrogram

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

Uses log(abs(STFT)), not linear power or dB. Requires photometry and sleep-state workspace variables.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `EEG_power_spectrogram.m` | Uploaded EEG_power_spectrogram(1).m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

<details>
<summary>Original help: EEG_power_spectrogram.m</summary>

```text
EEG power spectrum analysis
here you plot a power spectrogram (heatmap) for your EEG data and band
power traces for the defined EEG frequency bands (incl sigma trace).
```
</details>
