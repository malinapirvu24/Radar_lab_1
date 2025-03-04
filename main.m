%% Import data
%load('HH_20170206135256_2.mat');

%% Import noise
load('NoiseFile');

%% Plot raw data
PRF = 1000; % expressed in Hz
img_file = plot_raw_data(Data_out, range);
filtered_output = mti_filter(Data_out', PRF);

%% Plot noise statistics
plot_noise_statistics(Data_out', 'abs')

%% Doppler processing
N_Doppler = 512;
hfig = doppler_processing(1, N_Doppler, PRF, filtered_output', range);

%% Create video
N_doppler = 512;
create_video(N_Doppler, PRF, Data_out, range)















%% Define functions

function [img_file] = plot_raw_data(data_out, range)
% Create output file
img_file = "radar_output.png";
title_str = "Range-Slow time representation";

time_ind = 0:1:(size(data_out, 1)-1);
hfig=figure;
imagesc(time_ind,range,db(abs(data_out')))
colorbar
set(gca,'ydir','norm')
xlabel('Slow time, ms')
ylabel('Range, m')
title(['{',title_str,'}'], 'FontSize', 16)
print(hfig,'-dpng',img_file);
end

function hfig = doppler_processing(j, N_Doppler, PRF, Data_out, range)

PRI = 1000/(PRF); %expressed in ms
title_str = 'Doppler processing ';
start_time = 1+ N_Doppler*(j-1);
x = Data_out(start_time :PRI: start_time + PRI*N_Doppler-1,:);
RD = fftshift(fft(x, N_Doppler),1);
frequency = -PRF/2:PRF/(N_Doppler+1):PRF/2; % how this has to be changed for diff PRF?
c = 3*10^8;
fc = 3.315*10^9;
ratio = c/(2*fc);
velocity = frequency*ratio*3.6;
hfig = figure;
imagesc(velocity,range,db(abs(RD')));
colorbar;
set(gca,'ydir','norm');
set(gca,'clim',[20,140]) % If you do not see the range-Doppler plane similar to slide 10,
% comment (or edit) the codeline set(gca,'clim',[10,70])
xlabel('Velocity, km/h');
ylabel('Range, m');
title(['{',title_str, num2str(PRI),' ms, burst ',num2str(j),'}'], 'FontSize', 16);

end

function create_video(N_doppler,PRF, Data_out, range)

video_file=['video.avi'];
writerObj = VideoWriter(video_file);
open(writerObj);
for j=1:59
    frame = getframe(doppler_processing(j, N_doppler, PRF, Data_out, range));
    writeVideo(writerObj,frame);
    close all
    disp(j);
end
close(writerObj);
end

function plot_noise_statistics(data_out,type)

    if strcmp(type,'amplitude') 
        noise = real(data_out(:));  
    end

    if strcmp(type,'phase') 
        noise = imag(data_out(:));  
    end
    if strcmp(type,'abs')
        noise = abs(data_out(:));
    end
    mean_val = mean(noise);
    var_val = var(noise);
    std_val = std(noise);

    figure;
    grid on
    
    % Plot histogram
    histogram(noise, 100, 'Normalization', 'pdf');
    hold on;

    % PDF
    [f, x] = ksdensity(noise);
    plot(x, f, 'r', 'LineWidth', 2);

    title('Probability Density Function of Noise', 'FontSize', 16);
    xlabel('Amplitude (Absolute Value)');
    ylabel('Probability Density Function');
    legend('Histogram', 'Smoothed PDF');

    % Display mean and std on plot
    text(0.7*max(x), max(f)*0.9, ['Mean = ', num2str(mean_val, '%.2f')]);
    text(0.7*max(x), max(f)*0.8, ['Std = ', num2str(std_val, '%.2f')]);

    hold off;
end

function mti_output = mti_filter(data_out, PRF)
    PRI = 1000/PRF;
    delay_samples = round(PRI);
    % Compute the differnce
    mti_output = data_out(:, (delay_samples+1):end) - data_out(:, 1:end-delay_samples);
    % Match the size
    mti_output = mti_output(:, 1:end-delay_samples); 
    figure;
    imagesc(db(abs(mti_output))); 
    colorbar;
    xlabel('Slow time (ms)');
    ylabel('Range (m)');
    title('MTI Filtered Range-Slow Time Representation');
    set(gca, 'ydir', 'norm'); 
end



