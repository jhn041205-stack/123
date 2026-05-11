% build_tail_disabled_closed_loop_model.m
% 基于尾巴失能 theta_t=0 LQR 的等效受控模型
%
% 输入:
%   r = [v_x_ref; w_z_ref]
%
% 输出:
%   y = [v_x; w_z]
%
% 状态:
%   x = [X_b_h, dX_b_h, phi, dphi, theta_l, dtheta_l,
%        theta_r, dtheta_r, theta_b, dtheta_b]^T
%
% LQR 误差状态:
%   x_err = x - R_ref * r
%
% 其中其余预期状态量均为 0，仅速度和角速度参考非零:
%   x_err(2) = dX_b_h - v_x_ref
%   x_err(4) = dphi   - w_z_ref
%
% 原线性系统:
%   x_dot = A*x + B*u
%
% LQR:
%   u = -K*x_err = -K*x + K*R_ref*r
%
% 等效受控模型:
%   x_dot = (A - B*K)*x + B*K*R_ref*r
%   y     = C*x

clear; clc;

fprintf('========================================\n');
fprintf('尾巴失能 LQR 受控等效模型\n');
fprintf('========================================\n\n');

% 查询腿长。若尾巴失能拟合结果存在，则使用该腿长对应的拟合模型。
l_l_query = 0.17;
l_r_query = 0.17;
use_fitted_leg_model = true;

result_path = fullfile('..', '尾巴失能', 'lqr_tail_disabled_theta0_results.mat');
if ~isfile(result_path)
    error('找不到 %s。请先运行 尾巴失能/compute_lqr_tail_disabled_theta0.m', result_path);
end

load(result_path, 'A_num', 'B_num', 'K', ...
                  'theta_l_star', 'theta_r_star', 'theta_b_star', ...
                  'theta_t_fixed_val', 'T_leg_eq_val', 'T_t_constraint_eq');

if isempty(K)
    error('尾巴失能 LQR 结果中的 K 为空。');
end

n = size(A_num, 1);
if n ~= 10 || size(B_num, 2) ~= 4 || any(size(K) ~= [4, 10])
    error('A/B/K 维度不符合 10状态、4输入的尾巴失能模型。');
end

fitting_path = fullfile('..', '尾巴失能', 'lqr_tail_disabled_theta0_fitting_results.mat');
using_fitted_model = false;

if use_fitted_leg_model && isfile(fitting_path)
    fit = load(fitting_path, ...
        'K_coef_tail_disabled', 'A_coef_tail_disabled', 'B_coef_tail_disabled', ...
        'Offset_coef_tail_disabled', 'InputEq_coef_tail_disabled', 'fit_info');

    A_num = reshape_poly22_eval(fit.A_coef_tail_disabled, l_l_query, l_r_query, 10, 10);
    B_num = reshape_poly22_eval(fit.B_coef_tail_disabled, l_l_query, l_r_query, 10, 4);
    K = reshape_poly22_eval(fit.K_coef_tail_disabled, l_l_query, l_r_query, 4, 10);

    offset_vals = poly22_eval(fit.Offset_coef_tail_disabled, l_l_query, l_r_query);
    input_vals = poly22_eval(fit.InputEq_coef_tail_disabled, l_l_query, l_r_query);

    theta_l_star = offset_vals(1);
    theta_r_star = offset_vals(2);
    theta_b_star = offset_vals(3);
    T_leg_eq_val = input_vals(1);
    T_t_constraint_eq = input_vals(2);

    using_fitted_model = true;
elseif use_fitted_leg_model
    warning('未找到腿长拟合结果，将使用单点 l_l=l_r=0.17 的模型。');
end

% 参考输入映射: r = [v_x_ref; w_z_ref]
R_ref = zeros(10, 2);
R_ref(2, 1) = 1.0;  % dX_b_h reference
R_ref(4, 2) = 1.0;  % dphi reference

% 输出: y = [actual v_x; actual w_z]
C_out = zeros(2, 10);
C_out(1, 2) = 1.0;
C_out(2, 4) = 1.0;
D_out = zeros(2, 2);

A_cl = A_num - B_num * K;
B_ref = B_num * K * R_ref;
C_cl = C_out;
D_cl = D_out;

sys_cl = ss(A_cl, B_ref, C_cl, D_cl);

fprintf('输入 r = [v_x_ref; w_z_ref]\n');
fprintf('输出 y = [v_x; w_z]\n\n');
fprintf('腿长查询点: l_l = %.4f m, l_r = %.4f m\n', l_l_query, l_r_query);
fprintf('模型来源: %s\n\n', ternary(using_fitted_model, 'poly22 腿长拟合模型', '单点模型'));

fprintf('平衡点/固定量:\n');
fprintf('  theta_l_eq = %.10f rad (%.6f deg)\n', theta_l_star, rad2deg(theta_l_star));
fprintf('  theta_r_eq = %.10f rad (%.6f deg)\n', theta_r_star, rad2deg(theta_r_star));
fprintf('  theta_b_eq = %.10f rad (%.6f deg)\n', theta_b_star, rad2deg(theta_b_star));
fprintf('  theta_t_fixed = %.10f rad (%.6f deg)\n', theta_t_fixed_val, rad2deg(theta_t_fixed_val));
fprintf('  T_leg_eq = %.10f\n', T_leg_eq_val);
fprintf('  T_t_constraint_eq = %.10f\n\n', T_t_constraint_eq);

fprintf('A_cl = A - B*K (10x10):\n');
disp(A_cl);

fprintf('B_ref = B*K*R_ref (10x2):\n');
disp(B_ref);

fprintf('C_cl (2x10):\n');
disp(C_cl);

fprintf('D_cl (2x2):\n');
disp(D_cl);

fprintf('闭环极点:\n');
disp(eig(A_cl));

dc_gain = dcgain(sys_cl);
fprintf('DC gain y/r:\n');
disp(dc_gain);

save('tail_disabled_closed_loop_model.mat', ...
     'A_cl', 'B_ref', 'C_cl', 'D_cl', 'sys_cl', 'R_ref', ...
     'A_num', 'B_num', 'K', ...
     'l_l_query', 'l_r_query', 'using_fitted_model', ...
     'theta_l_star', 'theta_r_star', 'theta_b_star', ...
     'theta_t_fixed_val', 'T_leg_eq_val', 'T_t_constraint_eq');

fprintf('结果已保存到 tail_disabled_closed_loop_model.mat\n');

function values = poly22_eval(coef, l_l, l_r)
    basis = [1, l_l, l_r, l_l^2, l_l*l_r, l_r^2];
    values = basis * coef;
end

function mat = reshape_poly22_eval(coef, l_l, l_r, rows, cols)
    values = poly22_eval(coef, l_l, l_r);
    mat = reshape(values, cols, rows).';
end

function out = ternary(cond, a, b)
    if cond
        out = a;
    else
        out = b;
    end
end
