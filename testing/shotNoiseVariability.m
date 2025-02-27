%% this script is to express variability between spots as a function of expected shot noise variation

% takes data in the form of data(rows,columns,timestep)
% make sure to update the following constants to match your
% signal_intensity, spot_size, number_of_frames, number_of_spots,
% slope_LUT, and mirror_intensity.

%% Gather user input to define constants:
prompt = {'Signal Intensity of a spot','size of spot in pixels', 'number of frames averaged', 'number of spots measured at a time', 'slope of the LUT', 'mirror intensity'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'36000','600', '50', '1', '96', '60300'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);


%% Define expected shot noise
% this will depend on approximate spot intensity, spot size, number of frames, and number
% of spots measured


signal_intensity = str2num(answer{1});
spot_size = str2num(answer{2});
number_of_frames = str2num(answer{3});
number_of_spots = str2num(answer{4});


shot_noise = sqrt(signal_intensity/(spot_size * number_of_frames * number_of_spots));

%% Express shot noise in nm
% first normalize by the mirror intensity and then mutiply by the slope of
% the LUT to obtain nm from the normalized shot noise.


slope_LUT = str2num(answer{5}); %nm/normalized reflectivity
mirror_intensity = str2num(answer{6});

norm_shot_noise = shot_noise/mirror_intensity;
shot_noise_nm = norm_shot_noise * slope_LUT;

%% Calculate the standard deviation between the images of each spot
%for a data in a 3D array rowxcolumnximage

data_size = size(data);

for i = 1 : data_size(1)
    for j = 1: data_size(2)
        temp = [];
        for k = 1: data_size(3)
            temp(k) = data(i,j,k);
                       
        end
        variability.measured(i,j) = std(temp);
    end
end

%% express the variability as a function of shot noise variability

 variability.aafo_shot_noise = variability.measured/shot_noise_nm;
 variability.params = answer;
 
 
 %% Plot the variability
 
 figure(1)
 subplot(1,2,1)
 histogram(variability.measured, 7)
  xlabel('Measured Variability in nm');
 ylabel('number of spots')
    ax = gca;
    ax.LineWidth = 2;
    ax.FontSize = 16;
    ax.FontWeight = 'bold';
    ax.Box = 'off';
 
 subplot(1,2,2)
 histogram(variability.aafo_shot_noise)
 xlabel(['Variability as a function of shot noise (' num2str(round(shot_noise_nm,4)) 'nm)']);
 ylabel('number of spots')
    ax = gca;
    ax.LineWidth = 2;
    ax.FontSize = 16;
    ax.FontWeight = 'bold';
    ax.Box = 'off';

