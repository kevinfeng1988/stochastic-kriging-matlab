% Use stochastic kriging to fit the response surface of the stochastic
% process follow the Branin function
%   k: number of design points.
%   K^2: number of prediction points. Note that the prediction points should
%       be generated using a mesh-grid pattern in order to draw graph
%   X: [k * 2] design points matrix
%   XK: [K^2 * 2] prediction points matrix

clc; clear all; close all;

% Define the exp domain and sample it using LHS

maxX = [10 15] ; minX = [-5 0];
k = 25;
Co = lhsdesign(k, 2);   % coeff generated by LHS to be used for params generation

min = repmat(minX, [k 1]);
max = repmat(maxX, [k 1]);
X = min + (max - min).*Co;
n = repmat(10, [k,1]);
[Y Vhat] = procBranin(X, n, 'norm');

% Use mesh-grid function to generate the prediction points
K = 50; % K^2 is the number of prediction points, which will be generated by meshgrid function
[Xp Yp] = meshgrid(minX(1):((maxX(1) - minX(1))/(K-1)):maxX(1),...
    minX(2):((maxX(2) - minX(2))/(K-1)):maxX(2));
XK = [reshape(Xp, [K^2 1]) reshape(Yp, [K^2 1])];

B = repmat(1, [k 1]);   % basis function matrix at design points
% q = 0;  % degree of polynomial to fit in regression part(default)
% B = repmat(X,[1 q+1]).^repmat(0:q,[k 1]) 
BK = repmat(1, [K^2 1]);

% produce the SK prediction surface
% skriging_model = SKfit(X,Y,B,Vhat,2);
%fname = modelFitting(X,Y,Vhat,1);
fname = SKfiting(X,Y,Vhat,'SKsetting');
[SK_gau MSE] = predictCal(XK, fname);
 
% calculate the analytical values
n = repmat(2, [K^2,1]);
[trueK dummmy] = procBranin(XK, n, 'none');

% reshape the results into graph-compatible form
trueKp = reshape(trueK, [K K]);
SKp = reshape(SK_gau, [K K]);
msep = reshape(MSE, [K K]);

% draw all graphs
subplot(2, 2, 1);
mesh(Xp, Yp, trueKp, (trueKp - trueKp));
title('Analytical surface','FontWeight', 'bold');

subplot(2, 2, 2);
mesh(Xp, Yp, SKp, (SKp - SKp));
hold on;
scatter3(X(1:k,1), X(1:k,2), Y, 'filled');
title('SK prediction surface','FontWeight', 'bold');

subplot(2, 2, 3);
surface(Xp, Yp, SKp, abs(SKp-trueKp));
title('SK surface with regard to analytical values','FontWeight', 'bold');
colorbar;

subplot(2, 2, 4);
surface(Xp, Yp, SKp, msep);
title('SK surface with regard to predicted MSE','FontWeight', 'bold');
colorbar;

threshold = -10;
X = mseMin(fname,maxX, minX, threshold, 'SASetting')

% init = minX + (maxX-minX)./2;
% % test = mseCal(init, fname);
% % 
% loss = @(x) mseCal(x, fname);
% % options.Generator = @(x) neighbor(x, maxX, minX);
% % [min fval] = anneal(loss, init, options)
% % 
% controls.ub = maxX;
% controls.lb = minX;
% controls.nt = 90;
% controls.functol = 0.1;
% controls.paramtol = 0.01;
% controls.maxEval = 20000;
% controls.neps = 20;
% [min fval] = samin(loss, init, controls)
% 
% algor = 'trust-region-reflective';
% myopt = optimset('Display','iter','MaxFunEvals',1000000,'MaxIter',1000,...
%     'Algorithm', algor);
% [min fval] = fmincon(loss,init,[],[],[],[],minX,maxX,[],myopt)
