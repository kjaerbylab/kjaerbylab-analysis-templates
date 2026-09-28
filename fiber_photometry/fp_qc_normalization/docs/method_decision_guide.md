# Method decision guide

## 1. First define the question

### Event amplitude
Use `%ΔF/F`, baseline-subtracted `%ΔF/F`, or anchored centering.  
Avoid using z-score as the only amplitude output because it divides by each recording's own variability.

### Event timing or detection
Z-score can be useful because it asks whether the signal deviates from baseline variability.

### Paired intervention effect
Use own-baseline subtraction or percent change from baseline.

### Cross-genotype comparison
Use matched-state `%ΔF/F` or common-anchor centering if amplitude differences are biologically meaningful.

## 2. Then define the artifact model

### Linear fit
Default. Assumes the 405-control and 465-sensor share a mostly linear technical component.

### Robust linear fit
Use when spikes/outliers pull the ordinary fit.

### Polynomial fit
Use only when independent QC supports a nonlinear artifact relation.

### Slow detrending
Use as sensitivity analysis. It can remove real slow biology.

## 3. QC checklist

For each recording, check:

- raw 405/control trace
- raw 465/sensor trace
- fitted control over 465
- corrected trace for each method
- residual relationship to 405
- baseline interval
- whether denominator/reference ever gets close to zero
- whether the biological conclusion survives at least one reasonable alternative

## 4. Reporting checklist

Report:

- sensor/control channels
- sampling rate
- fit interval
- excluded bad intervals
- correction method
- baseline/reference definition
- output unit
- smoothing/downsampling
- sensitivity method
- method limitations
