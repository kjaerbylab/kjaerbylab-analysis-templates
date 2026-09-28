# Batch processing skeleton

**Status:** Template skeleton — user configuration required.

## Purpose and typical use

Loop over recordings and save selected workspace variables.

## Suitable data and inputs

User-defined mice cell array; each mouse entry includes output path at index 6.

## Requirements

Dependencies of the preprocessing code you insert.

Check the required MATLAB release and toolboxes locally. Add this folder and its required helpers to the path; avoid adding the entire repository because some scripts share filenames.

## How to use

Fill the empty Preprocessing section, set output paths, and revise the clearvars keep-list before running.

## Example data and outputs

No example recording is included yet. Consult the function interface below for its outputs.

## Parameters and limitations

Not runnable as supplied: data is undefined until preprocessing is added. Existing output paths may be overwritten. A pasted script containing clear all would erase the loop variables.

## Authors and provenance

- Original author(s): **to confirm**; preserve existing in-file credits and cited methods.
- Contributor/adaptor roles: **to confirm** with the source owner.
- Current lab maintainer: **to assign**.
- Redistribution/license approval: see [reuse policy](../../REUSE_POLICY.md).

| Included file | Source |
|---|---|
| `batch_process.m` | Uploaded batch_process(2).m |

See `SOURCE_MANIFEST.csv` in the repository root for the original source and checksum.

## Source interfaces and original help

<details>
<summary>Original help: batch_process.m</summary>

```text
DESCRIPTION
This template is for batch processing all your recordings within an
experiment. For each mouse you will save a .mat file containing the
workspace with variables that you need for subsequent analysis.
You need to adjust which output parameters you want to keep down by the
'clearvars' function
Specify mouse data
Here you specify all the input arguments for each mouse (e.g. file locations, channel names, interval for fitting, etc.)
Make sure to adjust the file location and name of the preprocessed data - here mouse{6}
- and adjust the index numbers according to the number of input arguments.
It's also a good idea to update the data structure description for
yourself to remember what the input arguments are.
```
</details>
