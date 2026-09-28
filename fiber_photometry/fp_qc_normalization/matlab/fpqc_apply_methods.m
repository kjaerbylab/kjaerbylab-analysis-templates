function [methods, metrics, fitInfo] = fpqc_apply_methods(raw, cfg)
%FPQC_APPLY_METHODS Apply correction/scaling methods to FP data.

t = raw.t(:);
x405 = double(raw.signal_405(:));
x465 = double(raw.signal_465(:));
fs = raw.fs;

valid = isfinite(t) & isfinite(x405) & isfinite(x465);

fitIdx = valid;
if isfield(cfg, 'fit_interval_sec') && ~isempty(cfg.fit_interval_sec)
    fitIdx = fitIdx & t >= cfg.fit_interval_sec(1) & t <= cfg.fit_interval_sec(2);
end
if nnz(fitIdx) < 100
    warning('Fit interval too short; using all valid samples.');
    fitIdx = valid;
end

baseIdx = valid;
if isfield(cfg, 'baseline_interval_sec') && ~isempty(cfg.baseline_interval_sec)
    baseIdx = baseIdx & t >= cfg.baseline_interval_sec(1) & t <= cfg.baseline_interval_sec(2);
end
if nnz(baseIdx) < 100
    warning('Baseline interval too short; using first 10 minutes or all data.');
    baseIdx = valid & t <= min(max(t), 600);
end

smoothN = max(3, round(cfg.smoothWinSec * fs));

methods = struct();
fitInfo = struct();

% 1. Linear fit
[pLin, fitLin] = local_polyfit(x405, x465, fitIdx, 1);
fitLin = movmean(fitLin, smoothN, 'omitnan');
linear_dff = 100 * (x465 - fitLin) ./ fitLin;
methods.linear_dff = pack(linear_dff, '% dF/F', 'linear 405-to-465 fit');
fitInfo.linear_dff.fit = fitLin;
fitInfo.linear_dff.coef = pLin;

% 2. Robust linear fit
[pRob, fitRob, usedRobust] = local_robustfit(x405, x465, fitIdx);
fitRob = movmean(fitRob, smoothN, 'omitnan');
robust_dff = 100 * (x465 - fitRob) ./ fitRob;
methods.robust_linear_dff = pack(robust_dff, '% dF/F', sprintf('robust linear fit; robustfit=%d', usedRobust));
fitInfo.robust_linear_dff.fit = fitRob;
fitInfo.robust_linear_dff.coef = pRob;

% 3. Polynomial fit
[p2, fit2] = local_polyfit(x405, x465, fitIdx, 2);
fit2 = movmean(fit2, smoothN, 'omitnan');
poly2_dff = 100 * (x465 - fit2) ./ fit2;
methods.poly2_dff = pack(poly2_dff, '% dF/F', 'second-degree 405-to-465 fit');
fitInfo.poly2_dff.fit = fit2;
fitInfo.poly2_dff.coef = p2;

% 4. Slow trend sensitivity
slowN = max(3, round(cfg.slowTrendWinSec * fs));
slowTrend = movmedian(linear_dff, slowN, 'omitnan');
detrended = linear_dff - slowTrend + median(linear_dff(baseIdx), 'omitnan');
methods.linear_dff_slow_detrend = pack(detrended, '% dF/F', 'linear dF/F with slow residual trend removed');
fitInfo.linear_dff_slow_detrend.fit = fitLin;
fitInfo.linear_dff_slow_detrend.slowTrend = slowTrend;

% 5. Baseline-subtracted
baseMean = mean(linear_dff(baseIdx), 'omitnan');
baseStd = std(linear_dff(baseIdx), 'omitnan');
methods.baseline_subtracted_linear_dff = pack(linear_dff - baseMean, 'percentage points dF/F', 'linear dF/F minus baseline mean');
fitInfo.baseline_subtracted_linear_dff.baseline_mean = baseMean;

% 6. Z-score
if baseStd > eps
    z = (linear_dff - baseMean) ./ baseStd;
else
    z = nan(size(linear_dff));
end
methods.zscore_after_linear_dff = pack(z, 'z-score', 'linear dF/F z-scored to baseline');
fitInfo.zscore_after_linear_dff.baseline_mean = baseMean;
fitInfo.zscore_after_linear_dff.baseline_sd = baseStd;

% 7. Anchored center
if isfield(cfg, 'anchor_value') && ~isempty(cfg.anchor_value) && isfinite(cfg.anchor_value)
    anchor = cfg.anchor_value;
else
    anchor = baseMean;
end
methods.anchored_center_linear_dff = pack(linear_dff - anchor, 'percentage points dF/F', 'linear dF/F minus shared/common anchor');
fitInfo.anchored_center_linear_dff.anchor_value = anchor;

% Metrics
metrics = struct();
names = fieldnames(methods);
for i = 1:numel(names)
    mn = names{i};
    if isfield(fitInfo.(mn), 'fit')
        fitY = fitInfo.(mn).fit;
    else
        fitY = fitLin;
    end
    metrics.(mn) = local_metrics(t, x405, x465, double(methods.(mn).y), fitY, fitIdx);
end
end

function s = pack(y, unit, description)
s = struct();
s.y = single(y);
s.unit = unit;
s.description = description;
end

function [p, fitY] = local_polyfit(x, y, idx, degree)
p = polyfit(x(idx), y(idx), degree);
fitY = polyval(p, x);
end

function [p, fitY, usedRobust] = local_robustfit(x, y, idx)
usedRobust = false;
try
    if exist('robustfit', 'file') == 2
        b = robustfit(x(idx), y(idx));
        fitY = b(1) + b(2).*x;
        p = [b(2), b(1)];
        usedRobust = true;
    else
        [p, fitY] = local_polyfit(x, y, idx, 1);
    end
catch
    [p, fitY] = local_polyfit(x, y, idx, 1);
end
end

function m = local_metrics(t, x405, x465, y, fitY, fitIdx)
m = struct();

okFit = fitIdx & isfinite(x465) & isfinite(fitY);
if nnz(okFit) > 10
    resid = x465(okFit) - fitY(okFit);
    ssRes = sum(resid.^2, 'omitnan');
    ssTot = sum((x465(okFit) - mean(x465(okFit), 'omitnan')).^2, 'omitnan');
    m.fit_r2 = 1 - ssRes/ssTot;
    m.fit_rmse = sqrt(mean(resid.^2, 'omitnan'));
else
    m.fit_r2 = NaN;
    m.fit_rmse = NaN;
end

ok = isfinite(y) & isfinite(x405);
if nnz(ok) > 10
    C = corrcoef(y(ok), x405(ok));
    m.resid_corr_405 = C(1,2);
else
    m.resid_corr_405 = NaN;
end

ok = isfinite(y) & isfinite(t);
if nnz(ok) > 10
    drift = polyfit(t(ok)/3600, y(ok), 1);
    m.drift_per_hour = drift(1);
    m.signal_sd = std(y(ok), 'omitnan');
    m.p95_minus_p5 = prctile(y(ok), 95) - prctile(y(ok), 5);
else
    m.drift_per_hour = NaN;
    m.signal_sd = NaN;
    m.p95_minus_p5 = NaN;
end

m.nan_fraction = mean(~isfinite(y));
end
