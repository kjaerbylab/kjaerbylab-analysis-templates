# Lab analysis templates

A curated MATLAB starter collection for recurring sleep, EEG and photometry analyses.

**Version 0.1 — review draft.** Original analysis code is unchanged. Modules are candidates or reference workflows, not certified lab methods. MATLAB was not available for execution during assembly.

## Start here

1. Browse the catalogue below and open the relevant README.
2. Read its input schema, dependencies and known limitations.
3. Begin with a synthetic demonstration where provided.
4. Have a lab member reproduce the output in MATLAB before using a module on study data.

Two synthetic examples are included: [sleep architecture](sleep/sleep_architecture/examples/README.md) and [event-aligned traces](event_analysis/epoch_extraction/examples/README.md). Their PNGs and CSVs are independent Python reference calculations, **not outputs verified by running MATLAB**.

## Analysis catalogue

| Analysis | Typical use | Status |
|---|---|---|
| [Sleep architecture](sleep/sleep_architecture/README.md) | Stage percentages, mean bout duration, bout rates and microarousal rates. | Candidate — MATLAB run pending |
| [Event-aligned traces](event_analysis/epoch_extraction/README.md) | Extract and plot signal windows around event timestamps. | Candidate — MATLAB run pending |
| [Pre/post event measurements](event_analysis/pre_post/README.md) | Measure event-related changes in mean level or AUC. | Candidate — MATLAB run pending |
| [Interval overlap](event_analysis/overlap/README.md) | Find which events overlap any interval in a second set. | Candidate — MATLAB run pending |
| [ViewPoint import and alignment](data_import/viewpoint/README.md) | Import EEG/EMG, scoring and TTL alignment from ViewPoint recordings. | Reference — external dependencies and review required |
| [Reference-fitted photometry preprocessing](photometry/preprocessing/README.md) | Import TDT channels, trim to TTL, fit control to signal and calculate percent delta-F/F and z-score. | Candidate — MATLAB run pending |
| [Median baseline photometry](photometry/normalisation/median/README.md) | Median-based percent delta-F/F followed by linear detrending and smoothing. | Candidate — MATLAB run pending |
| [Whole-trace EEG PSD](eeg/power_spectrum/whole_trace/README.md) | Welch PSD of a supplied EEG segment. | Candidate — MATLAB run pending |
| [Hilbert band power](eeg/band_power/README.md) | Bandpass signal, amplitude envelope and instantaneous power. | Candidate — MATLAB run pending |
| [Event-related EEG spectra](eeg/event_related_power/README.md) | Extract EEG band trajectories and spectrograms around events. | Candidate — MATLAB run pending |
| [Threshold spindle detector](eeg/spindle_detection/threshold/README.md) | Detect spindle-band events within NREM intervals. | Candidate — MATLAB run pending |
| [Wavelet spindle detector](eeg/spindle_detection/wavelet/README.md) | Detect spindle candidates using wavelet power and event-validation criteria. | Candidate — MATLAB run pending |
| [Spindle trough locations](eeg/spindle_detection/characterisation/README.md) | Locate selected troughs within already detected spindle events. | Candidate — MATLAB run pending |
| [Infraslow oscillations](oscillations/infraslow/README.md) | Period-specific PSD or wavelet spectra and duration-weighted summaries. | Candidate — MATLAB run pending |
| [Mean traces with SEM](plotting/mean_traces/README.md) | Plot two means with supplied SEM shading. | Candidate — MATLAB run pending |
| [Shared utilities](utilities/README.md) | Closest sample lookup, resampling and column-name filtering. | Candidate — MATLAB run pending |
| [Batch processing skeleton](workflow_templates/batch_processing/README.md) | Loop over recordings and save selected workspace variables. | Template skeleton — user configuration required |
| [ViewPoint sleep workflow](reference_workflows/eeg_sleep_analysis/README.md) | Original experiment workflow retained for context. | Reference only — not recommended for unattended use |
| [Combined TDT workflow](reference_workflows/tdt_combined_recordings/README.md) | Original experiment workflow retained for context. | Reference only — not recommended for unattended use |
| [Log-magnitude spectrogram](reference_workflows/spectrogram/README.md) | Original experiment workflow retained for context. | Reference only — not recommended for unattended use |
| [State PSD: mean dB](reference_workflows/state_psd/mean_db/README.md) | Original experiment workflow retained for context. | Reference only — not recommended for unattended use |
| [State PSD: mean linear](reference_workflows/state_psd/mean_linear/README.md) | Original experiment workflow retained for context. | Reference only — not recommended for unattended use |
| [NE/RR correlation reference](reference_workflows/ne_rr_correlation/README.md) | Original experiment workflow retained for context. | Reference only — not recommended for unattended use |
| [Cross-correlation lag illustration](examples/cross_correlation_lag/README.md) | Interactive demonstration with two synthetic shifted pulses. | Candidate — MATLAB run pending |
| [Sigma extraction comparison](examples/sigma_extraction_comparison/README.md) | Compare alternative band-power extraction methods with synthetic or workspace EEG. | Candidate — MATLAB run pending |
| [Infraslow PSD worked script](oscillations/infraslow/worked_script/README.md) | Walk through the infraslow PSD calculation. | Reference — MATLAB run pending |
| [Single-band Tort modulation index](eeg/phase_amplitude_coupling/tort_mi/README.md) | Calculate phase-amplitude coupling for one phase band and one amplitude band. | Candidate — MATLAB run pending |
| [NREM and REM PAC comodulograms](eeg/phase_amplitude_coupling/state_comodulograms/README.md) | State-selected EEG phase/amplitude modulation-index maps. | Reference analysis — methodological review and MATLAB run pending |

## Repository conventions

Topics contain analysis modules. Each module has a README and original source files. Shared dependencies are explicit; do not use `addpath(genpath(pwd))` on the entire repository because some alternative scripts share filenames.

Upload suffixes such as `(1)` were removed from selected destination filenames. Source bytes remain unchanged. [SOURCE_MANIFEST.csv](SOURCE_MANIFEST.csv) records original filenames, origins and SHA-256 hashes.

## Contributing and review

Copy [_analysis_template](_analysis_template/README.md) for new analyses. Follow [CONTRIBUTING.md](CONTRIBUTING.md). [REVIEW_QUEUE.md](REVIEW_QUEUE.md) lists remaining checks, and [docs/SELECTION.md](docs/SELECTION.md) explains excluded files.

## Published and project analyses

- [NE-oscillations: Kjaerby et al. 2022](https://github.com/MieAndersen/NE-oscillations)
- [Margarida's sleep/ACh/warming thesis repository](https://github.com/margaridaseabra/sleep_app_ach_warm)

Keep full experiment pipelines in their project repositories. This collection contains selected reusable analyses and labelled references.

## Authors and reuse

Original authors retain credit. Authorship must be confirmed per module; the uploader is not automatically the author. No blanket software license has been assigned. See [REUSE_POLICY.md](REUSE_POLICY.md).

## Publish on GitHub

See [docs/GITHUB_SETUP.md](docs/GITHUB_SETUP.md). This package has not been published to GitHub.
