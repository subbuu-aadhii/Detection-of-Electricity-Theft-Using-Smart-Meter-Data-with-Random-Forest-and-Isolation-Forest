clc; clear; close all;

model = 'ml_project';  

sim_time = 50;        
step_size = 0.02;     
num_runs = 40;       

fprintf('Target samples ≈ %.0f\n', (sim_time/step_size)*num_runs);

all_data_cell = cell(num_runs,1);


for i = 1:num_runs
    
    fprintf('Run %d/%d\n', i, num_runs);
    
    % --- FORCE DIVERSITY ---
    hour_val = randi([0 23]);
    day_val = randi([1 30]);
    season_val = randi([1 3]);
    
    % Send values to Simulink
    assignin('base','Hour_in_val',hour_val);
    assignin('base','Day_in_val',day_val);
    assignin('base','Season_in_val',season_val);
    
    % Run simulation
    out = sim(model, 'StopTime', num2str(sim_time));
    
    % Extract data safely
    try
        data = out.simout;   
    catch
        data = out.simout.signals.values;
    end
    
    all_data_cell{i} = data;
end

all_data = vertcat(all_data_cell{:});

fprintf('Total samples generated: %d\n', size(all_data,1));

headers = ["Hour","Day","Season","Mismatch_Ratio","Actual_load","Connected_load","Voltage", ...
           "Current","Power","Energy", ...
           "Theft_Label","Tamper_Label","Tamper_Detected"];

T = array2table(all_data, 'VariableNames', headers);


disp('Unique Hours:'); disp(unique(T.Hour)');
disp('Unique Seasons:'); disp(unique(T.Season)');


figure;
subplot(3,1,1)
plot(T.Power)
title('Power')

subplot(3,1,2)
plot(T.Current)
title('Current')

subplot(3,1,3)
plot(T.Mismatch_Ratio)
title('Mismatch Ratio')

sgtitle('System Behavior Overview')

figure;
plot(T.Voltage)
title('Voltage Variation')

figure;
plot(T.Energy)
title('Energy')

figure;
plot(T.Theft_Label)
title('Theft Events')

figure;
histogram(T.Season)
title('Season Distribution')


writetable(T, 'smart_meter_fin.csv'); 
writetable(T, 'smart_meter_fin.xlsx');  

save('smart_meter_data.mat','T');

fprintf('Dataset exported successfully!\n');