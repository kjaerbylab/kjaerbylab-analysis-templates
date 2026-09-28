# Interval overlap

**Status:** Candidate — MATLAB run pending.

## Purpose and typical use

Find which events overlap any interval in a second set.

## Suitable data and inputs

Two N-by-2 and M-by-2 interval matrices, in matching units.

## Requirements

Base MATLAB.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

```matlab
[aOverlaps,bOverlaps] = findOverlappingPeriods([1 3;5 7],[2 4;7 9]);
% expected aOverlaps = [true;false], bOverlaps = [true;false]
```

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

Intervals merely touching at an endpoint do not count as overlapping. This reports any overlap, not one-to-one event matching.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `findOverlappingPeriods.m` | matlab sharing.zip :: matlab sharing/functions/findOverlappingPeriods.m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

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
