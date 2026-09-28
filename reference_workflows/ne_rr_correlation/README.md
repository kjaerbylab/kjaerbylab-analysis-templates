# NE/RR correlation reference

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

Plot uses a constructed -30..60 s axis rather than computed lags/fs and reverses correlation sign. Event pairing and mouse-specific variables require review; do not interpret plotted lag without resolving these issues.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `cross_correlation_code.m` | Uploaded cross_correlation_code.m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

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
