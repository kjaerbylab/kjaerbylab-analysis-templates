# Sleep architecture

**Status:** Candidate — MATLAB run pending.

## Purpose and typical use

Stage percentages, mean bout duration, bout rates and microarousal rates.

## Suitable data and inputs

Workspace: `wake_woMA_periods_cut`, `sws_periods_cut`, `REM_periods_cut`, `MA_periods_cut`: N-by-2 onset/offset arrays in seconds. States must be mutually exclusive.

## Requirements

Base MATLAB.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

Start with `examples/run_example.m` (synthetic data). For real data populate the four period arrays and run `sleep_quantification.m`.

## Example data and outputs

See [the synthetic example](examples/README.md) for sample data, a runnable MATLAB script, and reference output. The MATLAB result has not yet been recorded.

## Parameters and limitations

Wake excludes MA. Percentages use total scored duration, not necessarily recording duration. MA rates use either scored hours or NREM hours. Empty/single-bout arrays and zero denominators require review; the transpose/diff expression is not a general empty/single-row implementation.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `sleep_quantification.m` | Uploaded sleep_quantification.m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

<details>
<summary>Original help: sleep_quantification.m</summary>

```text
Sleep quantification
Here you can do very basic quantification of the scored stages
```
</details>
