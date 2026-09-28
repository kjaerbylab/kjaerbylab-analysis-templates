# Interval overlap

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Find which events overlap any interval in a second set.

## Suitable data and inputs

Two N-by-2 and M-by-2 interval matrices, in matching units.

## Requirements

Base MATLAB.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

```matlab
[aOverlaps,bOverlaps] = findOverlappingPeriods([1 3;5 7],[2 4;7 9]);
% expected aOverlaps = [true;false], bOverlaps = [true;false]
```

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Intervals merely touching at an endpoint do not count as overlapping. This reports any overlap, not one-to-one event matching.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `findOverlappingPeriods.m` | matlab sharing.zip :: matlab sharing/functions/findOverlappingPeriods.m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

## Source interfaces and original help

```matlab
function [overlap1, overlap2] = findOverlappingPeriods(periods1, periods2)
% FINDOVERLAPPINGPERIODS Check which periods in two sets overlap with any period in the other set.
```

<details>
<summary>Original help: findOverlappingPeriods.m</summary>

```text
FINDOVERLAPPINGPERIODS Check which periods in two sets overlap with any period in the other set.

INPUTS:
periods1 - Nx2 matrix of [onset, offset] pairs (first set)
periods2 - Mx2 matrix of [onset, offset] pairs (second set)
Units can be samples or time, as long as consistent across both inputs.

OUTPUTS:
overlap1 - Nx1 logical vector: true if periods1(i,:) overlaps any period in periods2
overlap2 - Mx1 logical vector: true if periods2(j,:) overlaps any period in periods1

OVERLAP CONDITION:
Two periods [a_on, a_off] and [b_on, b_off] overlap if:
a_on < b_off  AND  b_on < a_off
This correctly handles all cases: containment, partial overlap,
and identical periods. Edge-touching (a_off == b_on) is NOT counted as overlap.
--- Input validation ---
```
</details>
