function rez = remove_bad_PCproj(rez)

% remove spikes with NaN or inf values
bad_spk = [find(isnan(rez.cProjPC));find(isinf(rez.cProjPC))];    
nBad = numel(bad_spk);

fprintf('Removing %d spikes with nan or inf PCproj values\n', nBad);

for ib = 1:nBad
    [curr_index, ~, ~] = ind2sub(size(rez.cProjPC),bad_spk(ib));
    rez.st3(curr_index,2) = 0;
end

rez = remove_spikes(rez,rez.st3(:,2)==0,'bad cProjPC values');

end






