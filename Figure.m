function Figure(n)
    if ~exist('n','var')
        n=3;
    end
    figure('Units', 'Normalized', 'OuterPosition', [0, 0, 1, 0.25*n]);
end