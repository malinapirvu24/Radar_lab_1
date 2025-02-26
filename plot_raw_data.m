function [img_file] = plot_raw_data(data_out, range)
    % Create output file
    img_file = "radar_output.png";

    time_ind = linspace(0, size(data_out, 1));
    hfig=figure;
    imagesc(time_ind,range,db(abs(data_out')))
    colorbar
    set(gca,'ydir','norm')
    xlabel('Slow time, ms')
    ylabel('Range, m')
    title(['{',title_str,'}'])
    print(hfig,'-dpng',img_file);
    close(hfig);
end