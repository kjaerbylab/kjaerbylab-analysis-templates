function filteredTable = filterTable(T, str1, str2)
% FILTERTABLE Filters table columns based on substrings in column names.
%
%   filteredTable = filterTable(T, str1, str2) returns a table containing
%   only the columns from table T whose column names contain both substrings 
%   str1 and str2.
%
%   Inputs:
%       T    - Input table.
%       str1 - First substring to search for in column names.
%       str2 - Second substring to search for in column names.
%
%   Outputs:
%       filteredTable - A table with columns whose names contain both
%                       str1 and str2.
%
%   Example:
%       data = rand(10, 6);
%       columnNames = {'BL_KO_1', 'BL_KO_2', 'BL_WT_1', 'KO_WT_1', 'BL_KO_3', 'WT_1'};
%       T = array2table(data, 'VariableNames', columnNames);
%       filteredTable = filterTable(T, 'BL', 'KO');
%       disp(filteredTable);

% Get column names
columnNames = T.Properties.VariableNames;

% Find columns that contain both 'BL' and 'KO'
columnsToKeep = contains(columnNames, str1) & contains(columnNames, str2);

% Filter the table
filteredTable = T(:, columnsToKeep);

end
