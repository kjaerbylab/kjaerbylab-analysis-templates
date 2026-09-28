function fpqc_make_qc_figures(raw, methods, metrics, fitInfo, cfg, figDir)
%FPQC_MAKE_QC_FIGURES Save QC and method comparison figures.

if ~exist(figDir, 'dir'); mkdir(figDir); end

idx = plotIdx(numel(raw.t), cfg.plotMaxPoints);
tmin = raw.t(idx) / 60;
methodNames = fieldnames(methods);

%% Figure 1: raw and fit
f = figure('Color','w','Position',[100 100 1400 850]);

subplot(4,1,1)
plot(tmin, raw.signal_405(idx), 'k'); grid on
ylabel('405'); title([cfg.recording_id ' raw control'], 'Interpreter','none')

subplot(4,1,2)
plot(tmin, raw.signal_465(idx), 'k'); grid on
ylabel('465'); title('Raw signal')

subplot(4,1,3)
plot(tmin, raw.signal_465(idx), 'Color',[0.3 0.3 0.3]); hold on
plot(tmin, fitInfo.linear_dff.fit(idx), 'LineWidth',1.2)
plot(tmin, fitInfo.robust_linear_dff.fit(idx), 'LineWidth',1.2)
plot(tmin, fitInfo.poly2_dff.fit(idx), 'LineWidth',1.2)
legend({'465','linear fit','robust fit','poly2 fit'}, 'Location','best')
ylabel('fit'); grid on; title('Fitted references')

subplot(4,1,4)
scatter(raw.signal_405(idx), raw.signal_465(idx), 4, 'filled', 'MarkerFaceAlpha',0.15)
xlabel('405'); ylabel('465'); grid on; title('405-vs-465 relationship')

saveFig(f, fullfile(figDir, '01_raw_and_fit.png'));

%% Figure 2: method comparison
f = figure('Color','w','Position',[100 100 1400 950]);
n = numel(methodNames);
for i = 1:n
    mn = methodNames{i};
    subplot(n,1,i)
    plot(tmin, double(methods.(mn).y(idx)), 'k')
    grid on
    ylabel(methods.(mn).unit, 'Interpreter','none')
    title([mn ': ' methods.(mn).description], 'Interpreter','none')
    if i < n
        set(gca, 'XTickLabel', [])
    else
        xlabel('Time (min)')
    end
end
saveFig(f, fullfile(figDir, '02_method_comparison.png'));

%% Figure 3: metrics
f = figure('Color','w','Position',[100 100 1450 720]);
metricNames = {'fit_r2','resid_corr_405','drift_per_hour','signal_sd','p95_minus_p5'};
for j = 1:numel(metricNames)
    vals = nan(numel(methodNames),1);
    for i = 1:numel(methodNames)
        vals(i) = metrics.(methodNames{i}).(metricNames{j});
    end
    subplot(2,3,j)
    bar(vals)
    set(gca, 'XTick',1:numel(methodNames), 'XTickLabel',methodNames, 'XTickLabelRotation',35)
    title(metricNames{j}, 'Interpreter','none')
    grid on
end
subplot(2,3,6)
axis off
text(0,0.95,'Metric guide','FontWeight','bold')
text(0,0.78,'Fit R²/RMSE: fit quality, not biological validity')
text(0,0.60,'Residual corr with 405: leftover control-like artifact')
text(0,0.42,'Drift/hour: slow residual trend')
text(0,0.24,'SD and p95-p5: dynamic range after scaling')
text(0,0.06,'Do not choose by metrics alone')
saveFig(f, fullfile(figDir, '03_metrics.png'));

%% Figure 4: zoom around event or middle
f = figure('Color','w','Position',[100 100 1400 700]);
if isfield(raw, 'eventTimes') && ~isempty(raw.eventTimes)
    center = raw.eventTimes(1);
else
    center = median(raw.t);
end
win = [center-120 center+180];
zoomIdx = raw.t >= win(1) & raw.t <= win(2);

subplot(3,1,1)
plot(raw.t(zoomIdx)-center, raw.signal_405(zoomIdx), 'k'); hold on
plot(raw.t(zoomIdx)-center, raw.signal_465(zoomIdx), 'Color',[0.4 0.4 0.4])
legend({'405','465'}); ylabel('raw'); grid on; title('Zoom: raw channels')

subplot(3,1,2)
plot(raw.t(zoomIdx)-center, double(methods.linear_dff.y(zoomIdx)), 'k'); hold on
plot(raw.t(zoomIdx)-center, double(methods.robust_linear_dff.y(zoomIdx)))
plot(raw.t(zoomIdx)-center, double(methods.linear_dff_slow_detrend.y(zoomIdx)))
legend({'linear dFF','robust dFF','slow detrend'}); ylabel('% dF/F'); grid on; title('Zoom: correction comparison')

subplot(3,1,3)
plot(raw.t(zoomIdx)-center, double(methods.zscore_after_linear_dff.y(zoomIdx)), 'k')
xlabel('Time from example event (s)'); ylabel('z'); grid on; title('Zoom: z-score view')
saveFig(f, fullfile(figDir, '04_zoom_event.png'));

close all
end

function idx = plotIdx(n, maxN)
if n <= maxN
    idx = 1:n;
else
    idx = unique(round(linspace(1,n,maxN)));
end
end

function saveFig(f, path)
try
    exportgraphics(f, path, 'Resolution', 160);
catch
    saveas(f, path);
end
end
