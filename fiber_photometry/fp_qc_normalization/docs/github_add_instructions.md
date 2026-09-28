# How to add this module to the lab GitHub repository

## Option A: add it to an existing local clone

From the root of the lab repository:

```bash
git checkout -b add-fp-qc-normalization-toolbox
mkdir -p fiber_photometry
cp -R /path/to/fp_qc_normalization fiber_photometry/
git status
git add fiber_photometry/fp_qc_normalization README.md .gitignore
git commit -m "Add fiber photometry QC normalization toolbox"
git push -u origin add-fp-qc-normalization-toolbox
```

Then open a pull request on GitHub.

## Option B: if the repo does not have this structure yet

Suggested top-level structure:

```text
repo/
├── README.md
├── fiber_photometry/
│   └── fp_qc_normalization/
├── eeg_sleep/
├── spindle_detection/
├── pac_analysis/
├── sample_data/
└── docs/
```

## Important

Do not commit raw TDT tanks, `.mat` files with full recordings, or local network paths unless the lab explicitly wants that. Use small simulated data or scripts that generate synthetic data.
