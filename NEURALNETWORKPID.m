% Step 1: Load your raw data from Simulink exports
error_data = error_data2;         % Error (e)
delta_error = delta_error2;       % Change in error (Δe)
ref_data = ref_data2;             % Reference speed (r)
control_data = control_data2;     % Control signal (output to plant)

% Step 2: Combine raw inputs (no normalization)
input_data = [error_data(:), delta_error(:), ref_data(:)]';  % Each column = one time sample
target_data = control_data(:)';                              % Target control signal

% Step 3: Create the neural network with fewer neurons
hiddenLayerSize = [3];               % Simpler network
net = feedforwardnet(hiddenLayerSize, 'trainscg');  % Use stable optimizer (scaled conjugate gradient)

% Step 4: Training settings — no early stopping, no validation
net.divideParam.trainRatio = 1.0;             % Use 100% of data for training
net.divideParam.valRatio = 0.0;               % Disable validation
net.divideParam.testRatio = 0.0;              % Disable testing

% Regularization and training settings
net.trainParam.epochs = 4000;                 % Train for 5000 epochs for better convergence
net.trainParam.min_grad = 1e-12;              % Lower gradient for smoother learning
net.performParam.regularization = 0.1;       % Increased regularization to prevent overfitting
net.layers{1}.transferFcn = 'tansig';         % Use tanh activation function for smoother output
net.trainParam.lr = 0.005;                    % Lower the learning rate for smoother adjustments

% Step 5: Train the network
[net, tr] = train(net, input_data, target_data);

% Step 6: Predict and check results
predicted_control_output = net(input_data);

% Step 7: Apply low-pass filter (simple smoothing) to the output
T = 10;  % Time constant for low-pass filter
smoothed_output = filter([1, -1], [1, T], predicted_control_output);  % Simple low-pass filter

% Step 8: Clip the output to avoid excessive values (if needed)
smoothed_output = max(min(smoothed_output, 1), -1);  % Clip between -1 and 1


% Step 9: Export the trained network to Simulink
gensim(net, 0.01);  % Generate NN block with 0.01s sample time


