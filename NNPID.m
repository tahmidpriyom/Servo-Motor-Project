% Step 1: Load your raw data from Simulink exports
error_data = error_data2;         % Error (e)
delta_error = delta_error2;       % Change in error (Δe)
ref_data = ref_data2;             % Reference speed (r)
control_data = control_data2;     % Control signal (output to plant)

% Step 2: Combine raw inputs (no normalization)
input_data = [error_data(:), delta_error(:), ref_data(:)]';  % Each column = one time sample
target_data = control_data(:)';                              % Target control signal

% Step 3: Create the neural network with moderate complexity
hiddenLayerSize = [20, 15];               % Two hidden layers for better modeling
net = feedforwardnet(hiddenLayerSize, 'trainscg');

% Step 4: Training settings — no validation/testing split
net.divideParam.trainRatio = 1.0;             
net.divideParam.valRatio = 0.0;               
net.divideParam.testRatio = 0.0;              

% Regularization and training parameters
net.trainParam.epochs = 4000;                 % Train for sufficient epochs
net.trainParam.min_grad = 1e-10;              % Gradient threshold
net.performParam.regularization = 0.07;      % Reduced regularization to balance fit and smoothness
net.trainParam.lr = 0.02;                      % Moderate learning rate

% Set transfer functions to tansig for smooth nonlinearity
net.layers{1}.transferFcn = 'tansig';
net.layers{2}.transferFcn = 'tansig';

% Step 5: Train the network
[net, tr] = train(net, input_data, target_data);

% Step 6: Predict control signal
predicted_control_output = net(input_data);

% Step 7: Apply moving average smoothing filter to predicted output
windowSize = 5;                               % Window size for moving average
b = (1/windowSize)*ones(1, windowSize);
a = 1;
smoothed_output = filter(b, a, predicted_control_output);

% Step 8: Clip output values to avoid excessive values
smoothed_output = max(min(smoothed_output, 1), -1);  % Clip between -1 and 1

% Step 9: Plot training performance
figure;
plotperform(tr);

% Step 10: Plot predicted vs actual control signals
figure;
plot(control_data, 'r'); hold on;
plot(smoothed_output, 'b');
legend('Actual Control', 'Predicted Control (Smoothed)');
title('Control Signal: Neural Network vs Actual');
xlabel('Time'); ylabel('Control Signal');

% Step 11: Export the trained network to Simulink
gensim(net, 0.01);  % Generate NN block with 0.01s sample time