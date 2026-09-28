# Fiber photometry QC and normalization toolbox

This module helps the lab **visualize raw photometry signals, compare correction/normalization methods, and choose a method based on QC rather than habit**.

It is designed to sit next to the existing sleep preprocessing workflow. It does **not** replace `preprocess_sleep_data.m` immediately. Instead, it adds a QC step before deciding which corrected trace should be used for downstream analysis.

## Why this exists

In our current preprocessing workflow, the FP part fits the 405/control channel to the 465/sensor channel with a linear `polyfit`, smooths the fitted control, computes `%ΔF/F`, and then smooths/downsamples the result. This toolbox lets us compare that default with alternatives such as robust fitting, polynomial fitting, baseline subtraction, z-scoring, and anchored centering.

## Folder structure

```text
fiber_photometry/fp_qc_normalization/
├── README.md
├── matlab/
│   ├── fpqc_add_paths.m
│   ├── fpqc_generate_simulated_signal.m
│   ├── fpqc_compare_methods_from_raw.m
│   ├── fpqc_apply_methods.m
│   ├── fpqc_make_qc_figures.m
│   ├── fpqc_load_tdt_streams.m
│   ├── fpqc_run_batch.m
│   └── fpqc_write_method_summary.m
├── examples/
│   ├── run_demo_simulated_fp_qc.m
│   └── run_batch_template_real_data.m
├── docs/
│   ├── method_decision_guide.md
│   └── github_add_instructions.md
├── sample_data/
│   └── README.md
└── figures/
    └── README.md
```

## Quick start: simulated signal

Run this first. It does not require TDT data.

```matlab
cd path/to/repo/fiber_photometry/fp_qc_normalization/examples
run_demo_simulated_fp_qc
```

This creates a synthetic 405/465 photometry recording with bleaching, motion artifacts, noise, and REM-like ACh events. It then compares several processing methods and saves QC figures.

## Quick start: real TDT data

Edit:

```matlab
examples/run_batch_template_real_data.m
```

Then run:

```matlab
run_batch_template_real_data
```

## What methods are compared?

- `linear_dff`  
  Linear 405 → 465 fit, then `%ΔF/F`.

- `robust_linear_dff`  
  Robust linear fit. Useful when movement spikes/outliers bias ordinary linear regression.

- `poly2_dff`  
  Second-degree fit. Useful only when nonlinear control-sensor relationship is justified.

- `linear_dff_slow_detrend`  
  Sensitivity analysis for slow drift after standard `%ΔF/F`.

- `baseline_subtracted_linear_dff`  
  Linear `%ΔF/F` minus a baseline mean. Useful for paired intervention comparisons.

- `zscore_after_linear_dff`  
  Linear `%ΔF/F`, expressed relative to baseline SD. Useful for detection/timing, but risky for amplitude comparisons.

- `anchored_center_linear_dff`  
  Linear `%ΔF/F` minus a shared reference value. Useful when you want a common zero while preserving amplitude differences.

## Outputs

For each recording, the toolbox saves:

```text
outputs/<recording_id>/
├── <recording_id>_fpqc_results.mat
├── <recording_id>_fpqc_metrics.csv
├── <recording_id>_method_summary.txt
└── figures/
    ├── 01_raw_and_fit.png
    ├── 02_method_comparison.png
    ├── 03_metrics.png
    └── 04_zoom_event.png
```

## Suggested lab rule

Do not choose the method that gives the expected biological result. Choose the simplest justified method, then check whether the conclusion survives reasonable alternatives.
