# Example recording variables

`example_scored_recording.mat` contains a 180-second real recording excerpt. Samples are column vectors. No filtering, resampling or normalisation was applied during extraction.

| Variable | Shape / value | Meaning |
|---|---|---|
| `eeg` | 109863 x 1, single | Stored EEG samples; physical units unspecified |
| `emg` | 109863 x 1, single | Stored EMG samples; physical units unspecified |
| `ne` | 183105 x 1, double | Stored photometry-channel samples; sensor and normalisation unspecified |
| `eeg_frequency` | 610.3515625 Hz | Native EEG sampling rate |
| `emg_frequency` | 610.3515625 Hz | Assumed equal to EEG; source has no separate EMG rate |
| `ne_frequency` | 1017.2526245117188 Hz | Native rate for `ne` |
| `sleep_scores` | 180 x 1, uint8 | 0 Wake, 1 NREM, 2 REM; confirmed by uploader |
| `sleep_epoch_s` | 1 s | Inferred epoch duration |
| `state_codes` | struct | Named code mapping |
| `duration_s` | 180 s | Scored excerpt duration |
| `eeg_time_offset_s`, `emg_time_offset_s`, `ne_time_offset_s` | scalar seconds | First sample's offset from excerpt start |
| `source_excerpt_start_s`, `source_excerpt_stop_s` | 317, 497 | Crop boundaries relative to the source signal arrays |
| `source_start_time_original` | 7000 | Uninterpreted source metadata; not added to plot time |
| `source_filename` | text | Original uploaded filename |
| `signal_units`, `timing_notes` | text | Unit and timing qualifications |

Construct time for a channel with `t = (0:numel(eeg)-1)'/eeg_frequency + eeg_time_offset_s`, and equivalently for the others.

`sleep_scores.csv` contains the same scoring with `time_s,score` columns. A label at time `t` covers `[t, t+1)` seconds. The excerpt transitions are NREM `[0,90)`, REM `[90,150)`, and Wake `[150,180)`.

The full source has approximately 23330 seconds of signal but 23331 score labels. The crop excludes the final label beyond signal coverage. The source's `start_time` field is retained for provenance, not interpreted as an offset; synchronisation beyond the stored common origin has not been independently verified.
