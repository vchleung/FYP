function [center, U, obj_fcn] = wfcm(data, W, cluster_n, options)
%Weighted FCM Data set clustering using fuzzy c-means clustering.
%
%
%   Modified from Built-in MATLAB fcm routine:
%   [CENTER, U, OBJ_FCN] = FCM(DATA, N_CLUSTER) finds N_CLUSTER number of
%   clusters in the data set DATA. DATA is size M-by-N, where M is the number of
%   data points and N is the number of coordinates for each data point. The
%   coordinates for each cluster center are returned in the rows of the matrix
%   CENTER. The membership function matrix U contains the grade of membership of
%   each DATA point in each cluster. The values 0 and 1 indicate no membership
%   and full membership respectively. Grades between 0 and 1 indicate that the
%   data point has partial membership in a cluster. At each iteration, an
%   objective function is minimized to find the best location for the clusters
%   and its values are returned in OBJ_FCN.
%
%   [CENTER, ...] = FCM(DATA,N_CLUSTER,OPTIONS) specifies a vector of options
%   for the clustering process:
%       OPTIONS(1): exponent for the matrix U             (default: 2.0)
%       OPTIONS(2): maximum number of iterations          (default: 100)
%       OPTIONS(3): minimum amount of improvement         (default: 1e-5)
%       OPTIONS(4): info display during iteration         (default: 1)
%   The clustering process stops when the maximum number of iterations
%   is reached, or when the objective function improvement between two
%   consecutive iterations is less than the minimum amount of improvement
%   specified. Use NaN to select the default value.
%
%   Roger Jang, 12-13-94, N. Hickey 04-16-01
%   Chi Hang Leung, Feb 2018
%   Copyright 1994-2002 The MathWorks, Inc. 

if nargin ~= 3 & nargin ~= 4,
	error('Too many or too few input arguments!');
end

data_n = size(data, 1);
in_n = size(data, 2);

% Change the following to set default options
default_options = [2;	% exponent for the partition matrix U
		100;	% max. number of iteration
		1e-5;	% min. amount of improvement
		1];	% info display during iteration 

if nargin == 3,
	options = default_options;
else
	% If "options" is not fully specified, pad it with default values.
	if length(options) < 4,
		tmp = default_options;
		tmp(1:length(options)) = options;
		options = tmp;
	end
	% If some entries of "options" are nan's, replace them with defaults.
	nan_index = find(isnan(options)==1);
	options(nan_index) = default_options(nan_index);
	if options(1) <= 1,
		error('The exponent should be greater than 1!');
	end
end

expo = options(1);		% Exponent for U
max_iter = options(2);		% Max. iteration
min_impro = options(3);		% Min. improvement
display = options(4);		% Display info or not

obj_fcn = zeros(max_iter, 1);	% Array for objective function

U = initfcm(cluster_n, data_n);			% Initial fuzzy partition
% Main loop
for i = 1:max_iter,
	[U, center, obj_fcn(i)] = stepwfcm(data, W, U, cluster_n, expo);
	if display, 
		fprintf('Iteration count = %d, obj. fcn = %f\n', i, obj_fcn(i));
	end
	% check termination condition
	if i > 1,
		if abs(obj_fcn(i) - obj_fcn(i-1)) < min_impro, break; end,
	end
end

iter_n = i;	% Actual number of iterations 
obj_fcn(iter_n+1:max_iter) = [];

end

function [U_new, center, obj_fcn] = stepwfcm(data, W, U, cluster_n, expo)
%STEPFCM One step in weighted fuzzy c-mean clustering.
%   [U_NEW, CENTER, ERR] = STEPFCM(DATA, U, CLUSTER_N, EXPO)
%   performs one iteration of fuzzy c-mean clustering, where
%
%   DATA: matrix of data to be clustered. (Each row is a data point.)
%   U: partition matrix. (U(i,j) is the MF value of data j in cluster j.)
%   CLUSTER_N: number of clusters.
%   EXPO: exponent (> 1) for the partition matrix.
%   U_NEW: new partition matrix.
%   CENTER: center of clusters. (Each row is a center.)
%   ERR: objective function for partition U.
%
%   Note that the situation of "singularity" (one of the data points is
%   exactly the same as one of the cluster centers) is not checked.
%   However, it hardly occurs in practice.
%
%       See also DISTFCM, INITFCM, IRISFCM, FCMDEMO, FCM.

%   Copyright 1994-2014 The MathWorks, Inc. 

mf = U.^expo;       % MF matrix after exponential modification
center = mf*(W.*data)./(mf*W*ones(1,size(data,2))); %new center
dist = distfcm(center, data);       % fill the distance matrix
dist = dist.^2;
obj_fcn = sum(dist.*mf*W);  % objective function
tmp = dist.^(-1/(expo-1));      % calculate new U, suppose expo != 1
U_new = tmp./(ones(cluster_n, 1)*sum(tmp));
end