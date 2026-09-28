# NE/RR correlation reference

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

Plot uses a constructed -30..60 s axis rather than computed lags/fs and reverses correlation sign. Event pairing and mouse-specific variables require review; do not interpret plotted lag without resolving these issues.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `cross_correlation_code.m` | Uploaded cross_correlation_code.m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

<details>
<summary>Original help: cross_correlation_code.m</summary>

```text
Íntro
To run this code you need:
1) Event variables stored in a nx1 double format and they need to be in
seconds. If you want to run the plotting code as is, include 4 event
variables.
2) Your animals 3-digit name stored in the 3rd position in the loading list
so you can call it as 'mouse{3}' (or just change the code).
3) RR intervals, FP data and EEG loaded and preprocessed.
4) Add the animals you're running to a list called 'o' (that's what we're
looping over).
resample NE
Original signal
```
</details>
