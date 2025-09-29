clc
clear all
close all

% Define the Fuzzy Inference System (FIS)
fis = mamfis('Name', 'DCMotorFLC');

% Define Speed Error input
% Range: [-3, 3] based on ref speed [-1, 1] and actual speed [-2, 2]
fis = addInput(fis, [-3 3], 'Name', 'SpeedError');
fis = addMF(fis, 'SpeedError', 'trimf', [-3 -3 -2], 'Name', 'NL'); % Negative Large
fis = addMF(fis, 'SpeedError', 'trimf', [-3 -2 -1], 'Name', 'NM'); % Negative Medium
fis = addMF(fis, 'SpeedError', 'trimf', [-2 -1 0], 'Name', 'NS'); % Negative Small
fis = addMF(fis, 'SpeedError', 'trimf', [-1 0 1], 'Name', 'ZE'); % Zero
fis = addMF(fis, 'SpeedError', 'trimf', [0 1 2], 'Name', 'PS'); % Positive Small
fis = addMF(fis, 'SpeedError', 'trimf', [1 2 3], 'Name', 'PM'); % Positive Medium
fis = addMF(fis, 'SpeedError', 'trimf', [2 3 3], 'Name', 'PL'); % Positive Large

% Define Change in Speed Error input
% Range: [-3, 3] for robustness
fis = addInput(fis, [-3 3], 'Name', 'DeltaSpeedError');
fis = addMF(fis, 'DeltaSpeedError', 'trimf', [-3 -3 -2], 'Name', 'NL'); % Negative Large
fis = addMF(fis, 'DeltaSpeedError', 'trimf', [-3 -2 -1], 'Name', 'NM'); % Negative Medium
fis = addMF(fis, 'DeltaSpeedError', 'trimf', [-2 -1 0], 'Name', 'NS'); % Negative Small
fis = addMF(fis, 'DeltaSpeedError', 'trimf', [-1 0 1], 'Name', 'ZE'); % Zero
fis = addMF(fis, 'DeltaSpeedError', 'trimf', [0 1 2], 'Name', 'PS'); % Positive Small
fis = addMF(fis, 'DeltaSpeedError', 'trimf', [1 2 3], 'Name', 'PM'); % Positive Medium
fis = addMF(fis, 'DeltaSpeedError', 'trimf', [2 3 3], 'Name', 'PL'); % Positive Large

% Define Torque output
% Range: [-2, 2] N-m, as specified
fis = addOutput(fis, [-2 2], 'Name', 'Torque');
fis = addMF(fis, 'Torque', 'trimf', [-2 -2 -1.33], 'Name', 'NL'); % Negative Large
fis = addMF(fis, 'Torque', 'trimf', [-2 -1.33 -0.67], 'Name', 'NM'); % Negative Medium
fis = addMF(fis, 'Torque', 'trimf', [-1.33 -0.67 0], 'Name', 'NS'); % Negative Small
fis = addMF(fis, 'Torque', 'trimf', [-0.67 0 0.67], 'Name', 'ZE'); % Zero
fis = addMF(fis, 'Torque', 'trimf', [0 0.67 1.33], 'Name', 'PS'); % Positive Small
fis = addMF(fis, 'Torque', 'trimf', [0.67 1.33 2], 'Name', 'PM'); % Positive Medium
fis = addMF(fis, 'Torque', 'trimf', [1.33 2 2], 'Name', 'PL'); % Positive Large

% Define fuzzy rules (49 rules for 7x7 combinations)
rules = [
    "If SpeedError is NL and DeltaSpeedError is NL then Torque is NL"
    "If SpeedError is NL and DeltaSpeedError is NM then Torque is NL"
    "If SpeedError is NL and DeltaSpeedError is NS then Torque is NM"
    "If SpeedError is NL and DeltaSpeedError is ZE then Torque is NM"
    "If SpeedError is NL and DeltaSpeedError is PS then Torque is NS"
    "If SpeedError is NL and DeltaSpeedError is PM then Torque is NS"
    "If SpeedError is NL and DeltaSpeedError is PL then Torque is ZE"
    "If SpeedError is NM and DeltaSpeedError is NL then Torque is NL"
    "If SpeedError is NM and DeltaSpeedError is NM then Torque is NM"
    "If SpeedError is NM and DeltaSpeedError is NS then Torque is NM"
    "If SpeedError is NM and DeltaSpeedError is ZE then Torque is NS"
    "If SpeedError is NM and DeltaSpeedError is PS then Torque is NS"
    "If SpeedError is NM and DeltaSpeedError is PM then Torque is ZE"
    "If SpeedError is NM and DeltaSpeedError is PL then Torque is ZE"
    "If SpeedError is NS and DeltaSpeedError is NL then Torque is NM"
    "If SpeedError is NS and DeltaSpeedError is NM then Torque is NM"
    "If SpeedError is NS and DeltaSpeedError is NS then Torque is NS"
    "If SpeedError is NS and DeltaSpeedError is ZE then Torque is NS"
    "If SpeedError is NS and DeltaSpeedError is PS then Torque is ZE"
    "If SpeedError is NS and DeltaSpeedError is PM then Torque is ZE"
    "If SpeedError is NS and DeltaSpeedError is PL then Torque is PS"
    "If SpeedError is ZE and DeltaSpeedError is NL then Torque is NM"
    "If SpeedError is ZE and DeltaSpeedError is NM then Torque is NS"
    "If SpeedError is ZE and DeltaSpeedError is NS then Torque is NS"
    "If SpeedError is ZE and DeltaSpeedError is ZE then Torque is ZE"
    "If SpeedError is ZE and DeltaSpeedError is PS then Torque is PS"
    "If SpeedError is ZE and DeltaSpeedError is PM then Torque is PS"
    "If SpeedError is ZE and DeltaSpeedError is PL then Torque is PM"
    "If SpeedError is PS and DeltaSpeedError is NL then Torque is NS"
    "If SpeedError is PS and DeltaSpeedError is NM then Torque is ZE"
    "If SpeedError is PS and DeltaSpeedError is NS then Torque is ZE"
    "If SpeedError is PS and DeltaSpeedError is ZE then Torque is PS"
    "If SpeedError is PS and DeltaSpeedError is PS then Torque is PS"
    "If SpeedError is PS and DeltaSpeedError is PM then Torque is PM"
    "If SpeedError is PS and DeltaSpeedError is PL then Torque is PM"
    "If SpeedError is PM and DeltaSpeedError is NL then Torque is ZE"
    "If SpeedError is PM and DeltaSpeedError is NM then Torque is ZE"
    "If SpeedError is PM and DeltaSpeedError is NS then Torque is PS"
    "If SpeedError is PM and DeltaSpeedError is ZE then Torque is PS"
    "If SpeedError is PM and DeltaSpeedError is PS then Torque is PM"
    "If SpeedError is PM and DeltaSpeedError is PM then Torque is PM"
    "If SpeedError is PM and DeltaSpeedError is PL then Torque is PL"
    "If SpeedError is PL and DeltaSpeedError is NL then Torque is ZE"
    "If SpeedError is PL and DeltaSpeedError is NM then Torque is PS"
    "If SpeedError is PL and DeltaSpeedError is NS then Torque is PS"
    "If SpeedError is PL and DeltaSpeedError is ZE then Torque is PM"
    "If SpeedError is PL and DeltaSpeedError is PS then Torque is PM"
    "If SpeedError is PL and DeltaSpeedError is PM then Torque is PL"
    "If SpeedError is PL and DeltaSpeedError is PL then Torque is PL"
];

% Apply the rules to the FIS
fis = addRule(fis, rules);

% Save the FIS file
writeFIS(fis, 'DCMotorFLC.fis');

% Optional: Visualize the FIS
figure;
plotfis(fis);

% Optional: Visualize membership functions
figure;
subplot(3,1,1);
plotmf(fis, 'input', 1);
title('SpeedError Membership Functions');
subplot(3,1,2);
plotmf(fis, 'input', 2);
title('DeltaSpeedError Membership Functions');
subplot(3,1,3);
plotmf(fis, 'output', 1);
title('Torque Membership Functions');

% Optional: Visualize control surface
figure;
gensurf(fis, [1 2], 1);
title('Control Surface: Torque vs. SpeedError, DeltaSpeedError');
xlabel('SpeedError');
ylabel('DeltaSpeedError');
zlabel('Torque');