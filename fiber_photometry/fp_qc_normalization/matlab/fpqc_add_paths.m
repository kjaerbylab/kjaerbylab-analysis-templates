function fpqc_add_paths()
%FPQC_ADD_PATHS Add this toolbox's MATLAB folder to the path.

thisFile = mfilename('fullpath');
[thisDir,~,~] = fileparts(thisFile);
addpath(thisDir);

fprintf('Added FP QC toolbox to path:\n%s\n', thisDir);
end
