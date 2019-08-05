function Title(name,num)
    global FIGNUM

    if ~exist('num','var')
        sgtitle(['Figura ',num2str(FIGNUM,'%d'),': ', name],'Color',[1 0.5 0],'FontSize',14);
        FIGNUM=FIGNUM+1;
    else
        sgtitle(['Figura ',num2str(num,'%d'),': ', name],'Color',[1 0.5 0],'FontSize',14);
    end

end