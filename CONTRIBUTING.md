# Adding an analysis

1. Create a topic/analysis folder using `_analysis_template`.
2. Identify the original author, contributors, maintainer and exact source version.
3. Document data format, dimensions, units, sampling rate, labels and required preprocessing.
4. Include dependency locations and tested MATLAB/toolbox versions.
5. Supply a small synthetic or shareable dataset and a single entry-point example.
6. Include a reference plot and explain what it shows, including units and uncertainty.
7. Document defaults, limitations, external state/path dependencies and scientific assumptions.
8. Submit a branch and pull request. Ask another lab member to follow the README.

## Status labels

- Candidate: documented analysis awaiting an example run.
- Template skeleton: intentionally requires implementation/configuration.
- Reference: retained for context; not an endorsed general analysis.
- Example reproduced: reviewer ran the documented example and recorded environment and output.
- Method validation: a separate scientific assessment; successful execution alone does not establish it.

Preserve original credits and source lineage. Explain changes to analysis code in the pull request.
