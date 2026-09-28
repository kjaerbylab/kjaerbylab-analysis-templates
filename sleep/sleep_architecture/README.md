# Sleep architecture

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Stage percentages, mean bout duration, bout rates and microarousal rates.

## Suitable data and inputs

Workspace: `wake_woMA_periods_cut`, `sws_periods_cut`, `REM_periods_cut`, `MA_periods_cut`: N-by-2 onset/offset arrays in seconds. States must be mutually exclusive.

## Requirements

Base MATLAB.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

Start with `examples/run_example.m` (synthetic data). For real data populate the four period arrays and run `sleep_quantification.m`.

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Wake excludes MA. Percentages use total scored duration, not necessarily recording duration. MA rates use either scored hours or NREM hours. Empty/single-bout arrays and zero denominators require review; the transpose/diff expression is not a general empty/single-row implementation.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `sleep_quantification.m` | Uploaded sleep_quantification.m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

## Source interfaces and original help

<details>
<summary>Original help: sleep_quantification.m</summary>

```text
Sleep quantification
Here you can do very basic quantification of the scored stages
```
</details>
