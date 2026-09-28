# Shared utilities

**Status:** Candidate — MATLAB run pending. Original analysis files are byte-for-byte preserved. Upload copy suffixes were removed from destination filenames only.

## Purpose and typical use

Closest sample lookup, resampling and column-name filtering.

## Suitable data and inputs

See individual interfaces. resample_to_fs expects channels-by-samples, unlike the spindle detector.

## Requirements

Signal Processing Toolbox for resample; other helpers use base MATLAB.

MATLAB release and complete toolbox compatibility have not been verified. Add only this module and explicitly required helper directories to your path; do not recursively add the whole repository.

## How to use

```matlab
i = nearest_idx(t,event_s);
[y,fs_new] = resample_to_fs(x,fs,200);
```

Run on a copy of your data. Scripts operate on the current MATLAB workspace; inspect paths, `clear`, `save`, and variable assumptions before executing them. Function calls below are usage examples, not completed validation runs.

## Example data and outputs

No experimental data are distributed with this module. See the source help below for return variables. Where a synthetic example exists, its own README identifies the data and reference results. Otherwise a small example recording and author-confirmed plot remain to be added.

## Parameters and limitations

Array orientation differs among modules. Verify it before passing outputs between functions.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Documentation and synthetic demonstrations: prepared with OpenAI Codex assistance, 2026-09-28.
- Redistribution/license approval: see [reuse policy](../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `nearest_idx.m` | matlab sharing.zip :: matlab sharing/functions/nearest_idx.m |
| `resample_to_fs.m` | matlab sharing.zip :: matlab sharing/functions/resample_to_fs.m |
| `filterTable.m` | matlab sharing.zip :: matlab sharing/functions/filterTable.m |

Exact checksums are recorded in the root `SOURCE_MANIFEST.csv`.

## Source interfaces and original help

```matlab
function idx = nearest_idx(vec, val)
% idx = nearest_idx(vec, val)
```

<details>
<summary>Original help: nearest_idx.m</summary>

```text
idx = nearest_idx(vec, val)
Returns the index of the element in vec that is closest to val.

vec : numeric vector
val : scalar number
idx : index of closest element in vec
```
</details>

```matlab
function [data_rs, fs_new] = resample_to_fs(data, fs_in, fs_new)
% RESAMPLE_TO_FS  Resample signal(s) to a specified sampling rate with
```

<details>
<summary>Original help: resample_to_fs.m</summary>

```text
RESAMPLE_TO_FS  Resample signal(s) to a specified sampling rate with
antialias protection and automatic skip if already at target rate.

[data_rs, fs_new] = resample_to_fs(data, fs_in, fs_new)

Inputs
data   - [nCh x nSamples] numeric array (each row = one signal)
fs_in  - Original sampling rate in Hz (scalar)
fs_new - Desired sampling rate in Hz (scalar)

Outputs
data_rs - Resampled data at fs_new Hz (same nCh)
fs_new  - Output sampling rate (echoed for convenience)

Notes
- All arguments are in samples (not seconds).
- Automatically skips resampling if fs_in == fs_new.
------------------------------------------------------------
```
</details>

```matlab
function filteredTable = filterTable(T, str1, str2)
% FILTERTABLE Filters table columns based on substrings in column names.
```

<details>
<summary>Original help: filterTable.m</summary>

```text
FILTERTABLE Filters table columns based on substrings in column names.

filteredTable = filterTable(T, str1, str2) returns a table containing
only the columns from table T whose column names contain both substrings
str1 and str2.

Inputs:
T    - Input table.
str1 - First substring to search for in column names.
str2 - Second substring to search for in column names.

Outputs:
filteredTable - A table with columns whose names contain both
str1 and str2.

Example:
data = rand(10, 6);
columnNames = {'BL_KO_1', 'BL_KO_2', 'BL_WT_1', 'KO_WT_1', 'BL_KO_3', 'WT_1'};
T = array2table(data, 'VariableNames', columnNames);
filteredTable = filterTable(T, 'BL', 'KO');
disp(filteredTable);
Get column names
```
</details>
