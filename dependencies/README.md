# External dependencies

Dependencies are documented rather than silently replaced with different implementations.

- TDT `TDTbin2mat`: obtain the official MATLAB SDK appropriate to your recordings.
- ViewPoint ExpToolbox: `loadEXP`, `ExtractContinuousData`, `ExtractFullHypno`; obtain from the lab/vendor.
- `binary_to_OnOff` and `plot_sleep`: used by the threshold spindle/ViewPoint workflows. Source: https://github.com/MieAndersen/NE-oscillations/tree/main/functions . These are not bundled in this draft. The previously reviewed binary_to_OnOff assumes nonempty transition arrays; check absent states and boundary behavior. Record a pinned commit when installed.
- `DataCursor_custom`: called by the ViewPoint script, not supplied; obtain the original helper.
- `shadedErrorBar`: needed by the NE/RR reference; not supplied.
- `apply_50Hz_notch_if_needed`: optional path-dependent PAC preprocessing; not supplied. Record whether it was on the path.

MATLAB itself was unavailable during package assembly. Toolbox requirements are inferred from source calls and must be confirmed in the lab environment. Existing source claims such as 'toolbox-free' do not override actual calls to toolbox functions.
