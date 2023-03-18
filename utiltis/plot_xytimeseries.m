function p=plot_xytimeseries(x, y)
x = reshape(x.Data, numel(x.Data), 1);
y = reshape(y.Data, numel(y.Data), 1);
p = plot(x, y);
end