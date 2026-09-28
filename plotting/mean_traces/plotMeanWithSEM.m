function plotMeanWithSEM(x, meanTrace1, sem1, meanTrace2, sem2)
    % plotMeanWithSEM Plots mean traces with SEM as shaded areas
    % 
    % Syntax:
    %   plotMeanWithSEM(x, meanTrace1, sem1, meanTrace2, sem2)
    %
    % Inputs:
    %   x         - Vector of x-values (1 x N or N x 1)
    %   meanTrace1 - Vector of mean values for the first trace (1 x N or N x 1)
    %   sem1       - Vector of SEM values for the first trace (1 x N or N x 1)
    %   meanTrace2 - Vector of mean values for the second trace (1 x N or N x 1)
    %   sem2       - Vector of SEM values for the second trace (1 x N or N x 1)
    %
    % Outputs:
    %   A plot with two mean traces and their respective SEM as shaded areas.
    
    % Ensure input vectors are column vectors
    x = x(:);
    meanTrace1 = meanTrace1(:);
    sem1 = sem1(:);
    meanTrace2 = meanTrace2(:);
    sem2 = sem2(:);
    
    % Check if input vectors are of equal length
    if length(x) ~= length(meanTrace1) || length(meanTrace1) ~= length(sem1) || ...
       length(meanTrace2) ~= length(sem2) || length(meanTrace1) ~= length(meanTrace2)
        error('All input vectors must be of the same length');
    end
    
    % Create the figure
    figure;
    hold on;

    % Plot the first mean trace
    plot(x, meanTrace1, 'k', 'LineWidth', 1.5);
    % Plot the first SEM as shaded area
    fill([x; flipud(x)], [meanTrace1 + sem1; flipud(meanTrace1 - sem1)], 'k', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    
    % Plot the second mean trace
    plot(x, meanTrace2, 'r', 'LineWidth', 1.5);
    % Plot the second SEM as shaded area
    fill([x; flipud(x)], [meanTrace2 + sem2; flipud(meanTrace2 - sem2)], 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    
    % Add labels and title
    xlabel('time (s)');
    ylabel('dF/F');
    %title('Mean Traces with SEM');
    
    % Add a legend
    legend('Mean Trace 1', 'SEM 1', 'Mean Trace 2', 'SEM 2');
    
    % Hold off to stop adding to the current plot
    hold off;
end