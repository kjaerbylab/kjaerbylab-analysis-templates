# Mean traces with SEM

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Plot two means with supplied SEM shading.

## Suitable data and inputs

Equal-length time, mean1, sem1, mean2, sem2 vectors.

## Requirements

Base MATLAB.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

```matlab
plotMeanWithSEM(t,mean1,sem1,mean2,sem2);
```

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Function does not calculate SEM. Specify the independent unit (mouse, session, trial) in figure captions.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `plotMeanWithSEM.m` | matlab sharing.zip :: matlab sharing/functions/plotMeanWithSEM.m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

## Source interfaces and original help

```matlab
function plotMeanWithSEM(x, meanTrace1, sem1, meanTrace2, sem2)
    % plotMeanWithSEM Plots mean traces with SEM as shaded areas
```

<details>
<summary>Original help: plotMeanWithSEM.m</summary>

```text
plotMeanWithSEM Plots mean traces with SEM as shaded areas

Syntax:
plotMeanWithSEM(x, meanTrace1, sem1, meanTrace2, sem2)

Inputs:
x         - Vector of x-values (1 x N or N x 1)
meanTrace1 - Vector of mean values for the first trace (1 x N or N x 1)
sem1       - Vector of SEM values for the first trace (1 x N or N x 1)
meanTrace2 - Vector of mean values for the second trace (1 x N or N x 1)
sem2       - Vector of SEM values for the second trace (1 x N or N x 1)

Outputs:
A plot with two mean traces and their respective SEM as shaded areas.
Ensure input vectors are column vectors
```
</details>
