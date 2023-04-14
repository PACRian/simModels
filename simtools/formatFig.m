function formatFig(name, fig, ax, ty)
arguments
    name = {}
    fig = gcf
    ax = gca
    ty = 0
end
set(fig, 'PaperPosition',[3.5 10.5 14 8.6]);        % Size setting
set(fig, 'InnerPosition', get(gcf, 'Position'));
set(ax, 'FontName', 'Times New Roman');            % Font style
set(ax, 'FontSize', 10);                         % Font size setting

if isempty(name)
    return
end
saveAsPng = @() exportgraphics(fig, [name, '.png'], 'Resolution', 300, 'BackgroundColor', 'none');
saveAsEmf = @() exportgraphics(fig, [name, '.emf'], 'ContentType','vector','BackgroundColor','none');
switch ty
    case 0
        saveAsPng();
        saveAsEmf();
    case 1
        saveAsPng();
    case 2
        saveAsEmf();
    otherwise
        error('`Type` must be 0, 1 or 2');
end
        



end



