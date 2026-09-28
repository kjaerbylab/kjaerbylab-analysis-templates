# Initial selection

The catalogue selects small reusable functions plus clearly labelled workflows. Original source files are unchanged; the manifest identifies each selected version.

Exact duplicate upload copies were omitted. TempDir files, autosaves, full result exports, Prism projects and sample path-only definitions are not included. Larger Astro_sleep projects, backup/failed scripts and experiment-specific conversion scripts remain in the user's original archive.

Specific exclusions: spindle_charac (undefined internal variables); plotting copies (incorrect axes handles); original FP_preprocess variants (naming/optional-laser inconsistencies); batch_process(1) (not the batch skeleton); practice_example (settings only); earlier EEG_sleep_analysis (undefined selected mouse); templates (large exploratory script).

PSD variants are deliberately separate. ZIP functions/PSD_EEG is a callable whole-trace function. Uploaded PSD_EEG averages bout dB spectra; uploaded PSD_EEG(1) overwrites dB with linear PSD. Their output scales are different.

Wavelet spindle source: colleague ZIP. PAC source: selected files from Margarida's thesis repository, commit e55d0fd019f973f90a81b8b50752584be5900375. No filename-matching spindle implementation was found in that repository tree; this does not establish that no spindle code is embedded elsewhere.

Remote optional/third-party helpers are not silently synthesized. See dependencies/README.md.
