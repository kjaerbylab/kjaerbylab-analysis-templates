# Mean traces with SEM

**Status:** Candidate — MATLAB run pending.

## Purpose and typical use

Plot two means with supplied SEM shading.

## Suitable data and inputs

Equal-length time, mean1, sem1, mean2, sem2 vectors.

## Requirements

Base MATLAB.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

```matlab
plotMeanWithSEM(t,mean1,sem1,mean2,sem2);
```

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

Function does not calculate SEM. Specify the independent unit (mouse, session, trial) in figure captions.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `plotMeanWithSEM.m` | matlab sharing.zip :: matlab sharing/functions/plotMeanWithSEM.m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

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
