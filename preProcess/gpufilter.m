function datr = gpufilter(buff, ops, chanMap)
% filter this batch of data after common average referencing with the
% median
% buff is timepoints by channels
% chanMap are indices of the channels to be kep
% ops.fs and ops.fshigh are sampling and high-pass frequencies respectively
% if ops.fslow is present, it is used as low-pass frequency (discouraged)

% JIC -- parameters for the filter now set in preprocessDataSub, stored as
% ops.filterParam; whether to filter at all in ops.doFilter

dataRAW = gpuArray(buff); % move int16 data to GPU
dataRAW = dataRAW';
dataRAW = single(dataRAW); % convert to float32 so GPU operations are fast
dataRAW = dataRAW(:, chanMap); % subsample only good channels

if ops.doFilter == 0
    % assume all preprocessing handled before KS2
    datr = dataRAW;
    return
end

% fprintf('running filter\n')
% subtract the mean from each channel; unnecessary if data has been filtered
dataRAW = dataRAW - mean(dataRAW, 1); % subtract mean of each channel

% CAR, common average referencing by median
if getOr(ops, 'CAR', 1)
    dataRAW = dataRAW - median(dataRAW, 2); % subtract median across channels
end

% next four lines should be equivalent to filtfilt (which cannot be used because it requires float64)
datr = filter(ops.filtb1, ops.filta1, dataRAW); % causal forward filter
datr = flipud(datr); % reverse time
datr = filter(ops.filtb1, ops.filta1, datr); % causal forward filter again
datr = flipud(datr); % reverse time back
