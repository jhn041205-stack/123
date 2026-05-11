% compute_lqr_tail_disabled_theta0.m
% 尾巴失能且被迫固定在 theta_t = 0 时的降维 LQR 解算
%
% 建模假设:
%   1. 基于“尾巴离地”完整动力学模型。
%   2. 尾巴相对机体角固定: theta_t = 0, dtheta_t = 0, ddtheta_t = 0。
%   3. 尾巴不作为 LQR 控制输入；尾电机/锁止机构只提供被动约束力矩。
%   4. 约束力矩由尾巴转动方程 eq6 = 0 反解得到，并代回机体俯仰方程 eq2。
%   5. 锁死尾巴后，尾巴自身绕尾电机轴转动惯量 I_t 随机体俯仰一起转动，
%      额外折算为机体俯仰方程中的 I_t * ddtheta_b。
%
% 状态:
%   X = [X_b_h, dX_b_h, phi, dphi, theta_l, dtheta_l,
%        theta_r, dtheta_r, theta_b, dtheta_b]^T
%
% 输入:
%   U = [T_r_to_b, T_l_to_b, T_wr_to_r, T_wl_to_l]^T

clear; clc;
tic;

fprintf('========================================\n');
fprintf('尾巴失能 theta_t=0 降维 LQR 解算\n');
fprintf('========================================\n\n');

%% Part 1: 参数

g_val = -9.81;

R_val = 0.130;
R_w_val = 0.386 / 2;

m_b_val = 6.9;
I_b_val = 59035.925e-6;
l_b_val = 4.3e-3;
I_yaw_val = 294272.34e-6;
theta_b0_val = 0;

m_wl_val = 0.823;
m_wr_val = 0.823;
I_wl_val = 6311.798e-6;
I_wr_val = 6311.798e-6;

l_l_val = 0.17;
l_r_val = 0.17;
m_l_val = 2.2;
m_r_val = 2.2;
I_l_val = 0.034231929;
I_r_val = 0.034231929;
l_l_d_val = 0.10157;
l_r_d_val = 0.10157;
theta_l0_val = 0.582108261;
theta_r0_val = 0.582108261;

% 尾巴 v1.1 参数，和单片机 TAIL_VERSION=1 对齐
m_t_val = 0.83;
I_t_val = 29341.743e-6;
a_t_p_val = 0.07125;
b_t_p_val = 0.1105;
l_t_c_val = 0.17755;
delta_t_val = 0.06597;
theta_t_fixed_val = 0.0;
include_locked_tail_rot_inertia = true;

fprintf('尾巴固定角 theta_t_fixed = %.6f rad (%.3f deg)\n\n', ...
        theta_t_fixed_val, rad2deg(theta_t_fixed_val));

%% Part 2: 符号变量与动力学

syms X_b_h dX_b_h ddX_b_h real
syms phi dphi ddphi real
syms theta_l dtheta_l ddtheta_l real
syms theta_r dtheta_r ddtheta_r real
syms theta_b dtheta_b ddtheta_b real
syms theta_t dtheta_t ddtheta_t real

syms ddtheta_wl ddtheta_wr real

syms T_r_to_b T_l_to_b T_wr_to_r T_wl_to_l real
syms T_t_to_b real

syms m_b m_l m_r m_wl m_wr real
syms I_b I_l I_r I_wl I_wr I_yaw real
syms l_b l_l l_r l_l_d l_r_d real
syms theta_l0 theta_r0 theta_b0 real
syms R R_w g real
syms m_t I_t a_t_p b_t_p l_t_c delta_t real

load('dynamics_new_coords.mat');

%% Part 3: 轮角加速度代换

leg_term = (l_r*cos(theta_r)*ddtheta_r + l_l*cos(theta_l)*ddtheta_l)/2 ...
         - (l_r*sin(theta_r)*dtheta_r^2 + l_l*sin(theta_l)*dtheta_l^2)/2;

ddtheta_wr_sub = (ddX_b_h + R_w*ddphi)/R - leg_term/R;
ddtheta_wl_sub = (ddX_b_h - R_w*ddphi)/R - leg_term/R;
wheel_subs = {ddtheta_wr, ddtheta_wr_sub; ddtheta_wl, ddtheta_wl_sub};

eq1_new = simplify(subs(eq1_new, wheel_subs(:,1), wheel_subs(:,2)));
eq2_new = simplify(subs(eq2_new, wheel_subs(:,1), wheel_subs(:,2)));
eq3_new = simplify(subs(eq3_new, wheel_subs(:,1), wheel_subs(:,2)));
eq4_new = simplify(subs(eq4_new, wheel_subs(:,1), wheel_subs(:,2)));
eq5_new = simplify(subs(eq5_new, wheel_subs(:,1), wheel_subs(:,2)));
eq6_new = simplify(subs(eq6_new, wheel_subs(:,1), wheel_subs(:,2)));

%% Part 4: 固定尾巴角并消去尾巴自由度

tail_lock_subs = {
    theta_t, theta_t_fixed_val;
    dtheta_t, 0;
    ddtheta_t, 0
};

eq1_disabled = simplify(subs(eq1_new, tail_lock_subs(:,1), tail_lock_subs(:,2)));
eq2_disabled = simplify(subs(eq2_new, tail_lock_subs(:,1), tail_lock_subs(:,2)));
eq3_disabled = simplify(subs(eq3_new, tail_lock_subs(:,1), tail_lock_subs(:,2)));
eq4_disabled = simplify(subs(eq4_new, tail_lock_subs(:,1), tail_lock_subs(:,2)));
eq5_disabled = simplify(subs(eq5_new, tail_lock_subs(:,1), tail_lock_subs(:,2)));
eq6_disabled = simplify(subs(eq6_new, tail_lock_subs(:,1), tail_lock_subs(:,2)));

% 被动锁止力矩: 由尾巴转动方程决定，不作为控制输入。
T_t_constraint = simplify(solve(eq6_disabled == 0, T_t_to_b));
eq2_disabled = simplify(subs(eq2_disabled, T_t_to_b, T_t_constraint));

if include_locked_tail_rot_inertia
    eq2_disabled = simplify(eq2_disabled + I_t * ddtheta_b);
end

eqs = {eq1_disabled, eq2_disabled, eq3_disabled, eq4_disabled, eq5_disabled};
ddq = [ddX_b_h; ddphi; ddtheta_l; ddtheta_r; ddtheta_b];
u = [T_r_to_b; T_l_to_b; T_wr_to_r; T_wl_to_l];

fprintf('被动尾巴约束力矩 T_t_constraint = \n');
disp(T_t_constraint);

%% Part 5: 提取 M, B, g

M_sym = sym(zeros(5,5));
for i = 1:5
    for j = 1:5
        M_sym(i,j) = diff(eqs{i}, ddq(j));
    end
end

B_raw = sym(zeros(5,4));
for i = 1:5
    for j = 1:4
        B_raw(i,j) = diff(eqs{i}, u(j));
    end
end
B_sym = -B_raw;

g_sym = sym(zeros(5,1));
for i = 1:5
    g_sym(i) = -(eqs{i} - M_sym(i,:)*ddq - B_raw(i,:)*u);
end

%% Part 6: 代入参数

param_subs = {
    m_b, m_b_val;
    m_l, m_l_val;
    m_r, m_r_val;
    m_wl, m_wl_val;
    m_wr, m_wr_val;
    I_b, I_b_val;
    I_l, I_l_val;
    I_r, I_r_val;
    I_wl, I_wl_val;
    I_wr, I_wr_val;
    I_yaw, I_yaw_val;
    l_l, l_l_val;
    l_r, l_r_val;
    l_l_d, l_l_d_val;
    l_r_d, l_r_d_val;
    l_b, l_b_val;
    R, R_val;
    R_w, R_w_val;
    g, g_val;
    theta_l0, theta_l0_val;
    theta_r0, theta_r0_val;
    theta_b0, theta_b0_val;
    m_t, m_t_val;
    I_t, I_t_val;
    a_t_p, a_t_p_val;
    b_t_p, b_t_p_val;
    l_t_c, l_t_c_val;
    delta_t, delta_t_val;
};

M_param = simplify(subs(M_sym, param_subs(:,1), param_subs(:,2)));
B_param = simplify(subs(B_sym, param_subs(:,1), param_subs(:,2)));
g_param = simplify(subs(g_sym, param_subs(:,1), param_subs(:,2)));

eq2_param = simplify(subs(eq2_disabled, param_subs(:,1), param_subs(:,2)));
eq3_param = simplify(subs(eq3_disabled, param_subs(:,1), param_subs(:,2)));
eq4_param = simplify(subs(eq4_disabled, param_subs(:,1), param_subs(:,2)));

T_t_constraint_param = simplify(subs(T_t_constraint, param_subs(:,1), param_subs(:,2)));

%% Part 7: 静态平衡点

theta_b_star = 0.0;
syms T_leg_eq real

static_subs = {
    theta_b, theta_b_star;
    dtheta_l, 0;
    dtheta_r, 0;
    dtheta_b, 0;
    ddtheta_l, 0;
    ddtheta_r, 0;
    ddtheta_b, 0;
    ddX_b_h, 0;
    ddphi, 0;
    phi, 0;
    dphi, 0;
    X_b_h, 0;
    dX_b_h, 0;
    T_r_to_b, T_leg_eq;
    T_l_to_b, T_leg_eq;
    T_wr_to_r, 0;
    T_wl_to_l, 0
};

eq2_static = simplify(subs(eq2_param, static_subs(:,1), static_subs(:,2)));
eq3_static = simplify(subs(eq3_param, static_subs(:,1), static_subs(:,2)));
eq4_static = simplify(subs(eq4_param, static_subs(:,1), static_subs(:,2)));

fprintf('正在求解静态平衡 [theta_l, theta_r, T_leg_eq] ...\n');
x0 = [0.2; 0.2; 0.4];
sol_static = vpasolve( ...
    [eq2_static == 0, eq3_static == 0, eq4_static == 0], ...
    [theta_l, theta_r, T_leg_eq], ...
    x0);

if isempty(sol_static)
    error('vpasolve 未找到尾巴失能平衡点。');
end

theta_l_star = double(sol_static.theta_l);
theta_r_star = double(sol_static.theta_r);
T_leg_eq_val = double(sol_static.T_leg_eq);

if ~isscalar(theta_l_star) || ~isscalar(theta_r_star) || ~isscalar(T_leg_eq_val)
    error('平衡点结果不是标量。');
end

T_t_constraint_eq = double(subs(T_t_constraint_param, theta_b, theta_b_star));

eq_static_check = double(subs( ...
    [eq2_static; eq3_static; eq4_static], ...
    [theta_l, theta_r, T_leg_eq], ...
    [theta_l_star, theta_r_star, T_leg_eq_val]));

fprintf('静态方程残差 ||eq_static||: %.2e\n', norm(eq_static_check));
fprintf('theta_l* = %.10f rad (%.6f deg)\n', theta_l_star, rad2deg(theta_l_star));
fprintf('theta_r* = %.10f rad (%.6f deg)\n', theta_r_star, rad2deg(theta_r_star));
fprintf('theta_b* = %.10f rad (%.6f deg)\n', theta_b_star, rad2deg(theta_b_star));
fprintf('theta_t_fixed = %.10f rad (%.6f deg)\n', theta_t_fixed_val, rad2deg(theta_t_fixed_val));
fprintf('T_leg_eq = %.10f\n', T_leg_eq_val);
fprintf('T_t_constraint_eq = %.10f\n\n', T_t_constraint_eq);

%% Part 8: 线性化

eq_subs_full = {
    theta_l, theta_l_star;
    theta_r, theta_r_star;
    theta_b, theta_b_star;
    dtheta_l, 0;
    dtheta_r, 0;
    dtheta_b, 0;
    phi, 0;
    dphi, 0;
    X_b_h, 0;
    dX_b_h, 0;
    T_r_to_b, T_leg_eq_val;
    T_l_to_b, T_leg_eq_val;
    T_wr_to_r, 0;
    T_wl_to_l, 0
};

M_eq = double(subs(M_param, eq_subs_full(:,1), eq_subs_full(:,2)));
B_eq = double(subs(B_param, eq_subs_full(:,1), eq_subs_full(:,2)));
g_eq = double(subs(g_param, eq_subs_full(:,1), eq_subs_full(:,2)));

fprintf('平衡点 g 向量范数: %.2e\n', norm(g_eq));

dg_dtheta_l = double(subs(diff(g_param, theta_l), eq_subs_full(:,1), eq_subs_full(:,2)));
dg_dtheta_r = double(subs(diff(g_param, theta_r), eq_subs_full(:,1), eq_subs_full(:,2)));
dg_dtheta_b = double(subs(diff(g_param, theta_b), eq_subs_full(:,1), eq_subs_full(:,2)));

n = 10;
m_ctrl = 4;
A_num = zeros(n, n);
B_num = zeros(n, m_ctrl);

A_num(1,2) = 1;
A_num(3,4) = 1;
A_num(5,6) = 1;
A_num(7,8) = 1;
A_num(9,10) = 1;

M_inv = inv(M_eq);
A_dyn_theta_l = M_inv * dg_dtheta_l;
A_dyn_theta_r = M_inv * dg_dtheta_r;
A_dyn_theta_b = M_inv * dg_dtheta_b;

A_num(2,5)  = A_dyn_theta_l(1); A_num(2,7)  = A_dyn_theta_r(1); A_num(2,9)  = A_dyn_theta_b(1);
A_num(4,5)  = A_dyn_theta_l(2); A_num(4,7)  = A_dyn_theta_r(2); A_num(4,9)  = A_dyn_theta_b(2);
A_num(6,5)  = A_dyn_theta_l(3); A_num(6,7)  = A_dyn_theta_r(3); A_num(6,9)  = A_dyn_theta_b(3);
A_num(8,5)  = A_dyn_theta_l(4); A_num(8,7)  = A_dyn_theta_r(4); A_num(8,9)  = A_dyn_theta_b(4);
A_num(10,5) = A_dyn_theta_l(5); A_num(10,7) = A_dyn_theta_r(5); A_num(10,9) = A_dyn_theta_b(5);

B_dyn = M_inv * B_eq;
B_num(2,:) = B_dyn(1,:);
B_num(4,:) = B_dyn(2,:);
B_num(6,:) = B_dyn(3,:);
B_num(8,:) = B_dyn(4,:);
B_num(10,:) = B_dyn(5,:);

fprintf('A_num (10x10):\n');
disp(A_num);
fprintf('B_num (10x4):\n');
disp(B_num);

%% Part 9: LQR

rank_Co = rank(ctrb(A_num, B_num));
fprintf('可控性矩阵秩: %d / %d\n', rank_Co, n);

lqr_Q = diag([120, 10, ...
              4000, 1, ...
              1000, 10, ...
              1000, 10, ...
              8000, 1]);
lqr_R = diag([1, 1, 10, 10]);

try
    [K, S, e] = lqr(A_num, B_num, lqr_Q, lqr_R);
    fprintf('LQR K (4x10):\n');
    disp(K);
    fprintf('闭环特征值:\n');
    disp(e);
catch ME
    fprintf('LQR 计算失败: %s\n', ME.message);
    K = [];
    S = [];
    e = [];
end

if ~isempty(K)
    fprintf('\n// Tail-disabled theta_t=0 LQR K[4][10]\n');
    fprintf('// u = -K * X, U = [T_r_to_b, T_l_to_b, T_wr_to_r, T_wl_to_l]\n');
    fprintf('float theta_l_eq = %.10ff;\n', theta_l_star);
    fprintf('float theta_r_eq = %.10ff;\n', theta_r_star);
    fprintf('float theta_b_eq = %.10ff;\n', theta_b_star);
    fprintf('float theta_t_fixed = %.10ff;\n', theta_t_fixed_val);
    fprintf('float T_leg_eq = %.10ff;\n', T_leg_eq_val);
    fprintf('float T_t_constraint_eq = %.10ff;\n\n', T_t_constraint_eq);
    fprintf('float K_tail_disabled[4][10] = {\n');
    for i = 1:4
        fprintf('    {');
        for j = 1:10
            if j < 10
                fprintf('%11.6ff, ', K(i,j));
            else
                fprintf('%11.6ff', K(i,j));
            end
        end
        if i < 4
            fprintf('},\n');
        else
            fprintf('}\n');
        end
    end
    fprintf('};\n');
end

save('lqr_tail_disabled_theta0_results.mat', ...
     'A_num', 'B_num', 'K', 'S', 'e', 'lqr_Q', 'lqr_R', ...
     'theta_l_star', 'theta_r_star', 'theta_b_star', 'theta_t_fixed_val', ...
     'T_leg_eq_val', 'T_t_constraint_eq', ...
     'M_eq', 'B_eq', 'g_eq', 'T_t_constraint');

fprintf('\n结果已保存到 lqr_tail_disabled_theta0_results.mat\n');

%% Part 10: 不同腿长下的 LQR 与闭环模型拟合

enable_fitting = true;

if enable_fitting
    fprintf('\n========================================\n');
    fprintf('Part 10: 不同腿长 LQR/闭环模型拟合\n');
    fprintf('========================================\n\n');

    theta0_fun = @(x) 277.69*x.^4 - 304.33*x.^3 + 130.52*x.^2 - 27.562*x + 2.7591;
    ld_fun     = @(x) 1.4205*x.^4 - 2.0644*x.^3 + 1.2526*x.^2 - 0.059*x + 0.0844;
    Ileg_fun   = @(x) -0.3588*x.^4 + 0.3595*x.^3 + 0.0659*x.^2 + 0.0318*x + 0.0255;
    Iyaw_fun   = @(x) -6.4624*x.^4 + 6.7339*x.^3 - 3.0029*x.^2 + 0.5202*x + 0.2758;

    l_range = 0.15:0.01:0.30;
    sample_size = numel(l_range)^2;

    K_sample = zeros(sample_size, 42);       % [l_l, l_r, K(:)']
    A_sample = zeros(sample_size, 102);      % [l_l, l_r, A(:)']
    B_sample = zeros(sample_size, 42);       % [l_l, l_r, B(:)']
    Acl_sample = zeros(sample_size, 102);    % [l_l, l_r, A_cl(:)']
    Bref_sample = zeros(sample_size, 22);    % [l_l, l_r, B_ref(:)']
    offset_sample = zeros(sample_size, 5);   % [l_l, l_r, theta_l, theta_r, theta_b]
    input_eq_sample = zeros(sample_size, 4); % [l_l, l_r, T_leg_eq, T_t_constraint_eq]

    R_ref_fit = zeros(10, 2);
    R_ref_fit(2, 1) = 1.0;
    R_ref_fit(4, 2) = 1.0;

    idx = 0;
    failed_cases = [];
    printed_first_fit_error = false;
    tic_fit = tic;

    for i = 1:numel(l_range)
        for j = 1:numel(l_range)
            idx = idx + 1;
            l_l_fit = l_range(i);
            l_r_fit = l_range(j);

            theta_l0_fit = theta0_fun(l_l_fit);
            theta_r0_fit = theta0_fun(l_r_fit);
            l_l_d_fit = ld_fun(l_l_fit);
            l_r_d_fit = ld_fun(l_r_fit);
            I_l_fit = Ileg_fun(l_l_fit);
            I_r_fit = Ileg_fun(l_r_fit);
            I_yaw_fit = Iyaw_fun((l_l_fit + l_r_fit) / 2);

            param_subs_fit = {
                m_b, m_b_val;
                m_l, m_l_val;
                m_r, m_r_val;
                m_wl, m_wl_val;
                m_wr, m_wr_val;
                I_b, I_b_val;
                I_l, I_l_fit;
                I_r, I_r_fit;
                I_wl, I_wl_val;
                I_wr, I_wr_val;
                I_yaw, I_yaw_fit;
                l_l, l_l_fit;
                l_r, l_r_fit;
                l_l_d, l_l_d_fit;
                l_r_d, l_r_d_fit;
                l_b, l_b_val;
                R, R_val;
                R_w, R_w_val;
                g, g_val;
                theta_l0, theta_l0_fit;
                theta_r0, theta_r0_fit;
                theta_b0, theta_b0_val;
                m_t, m_t_val;
                I_t, I_t_val;
                a_t_p, a_t_p_val;
                b_t_p, b_t_p_val;
                l_t_c, l_t_c_val;
                delta_t, delta_t_val;
            };

            try
                M_fit = subs(M_sym, param_subs_fit(:,1), param_subs_fit(:,2));
                B_fit = subs(B_sym, param_subs_fit(:,1), param_subs_fit(:,2));
                g_fit = subs(g_sym, param_subs_fit(:,1), param_subs_fit(:,2));

                eq2_fit = subs(eq2_disabled, param_subs_fit(:,1), param_subs_fit(:,2));
                eq3_fit = subs(eq3_disabled, param_subs_fit(:,1), param_subs_fit(:,2));
                eq4_fit = subs(eq4_disabled, param_subs_fit(:,1), param_subs_fit(:,2));
                T_t_constraint_fit = subs(T_t_constraint, param_subs_fit(:,1), param_subs_fit(:,2));

                syms T_leg_eq_fit real
                static_subs_fit = {
                    theta_b, theta_b_star;
                    dtheta_l, 0;
                    dtheta_r, 0;
                    dtheta_b, 0;
                    ddtheta_l, 0;
                    ddtheta_r, 0;
                    ddtheta_b, 0;
                    ddX_b_h, 0;
                    ddphi, 0;
                    phi, 0;
                    dphi, 0;
                    X_b_h, 0;
                    dX_b_h, 0;
                    T_r_to_b, T_leg_eq_fit;
                    T_l_to_b, T_leg_eq_fit;
                    T_wr_to_r, 0;
                    T_wl_to_l, 0
                };

                eq2_static_fit = subs(eq2_fit, static_subs_fit(:,1), static_subs_fit(:,2));
                eq3_static_fit = subs(eq3_fit, static_subs_fit(:,1), static_subs_fit(:,2));
                eq4_static_fit = subs(eq4_fit, static_subs_fit(:,1), static_subs_fit(:,2));

                sol_fit = vpasolve( ...
                    [eq2_static_fit == 0, eq3_static_fit == 0, eq4_static_fit == 0], ...
                    [theta_l, theta_r, T_leg_eq_fit], ...
                    [0.2; 0.2; 0.4]);

                if isempty(sol_fit)
                    error('vpasolve 未找到解');
                end

                theta_l_fit_val = double(sol_fit.theta_l);
                theta_r_fit_val = double(sol_fit.theta_r);
                T_leg_fit_val = double(sol_fit.T_leg_eq_fit);

                if ~isscalar(theta_l_fit_val) || ~isscalar(theta_r_fit_val) || ~isscalar(T_leg_fit_val)
                    error('平衡点非标量');
                end

                T_t_constraint_fit_val = double(subs(T_t_constraint_fit, theta_b, theta_b_star));

                eq_subs_fit = {
                    theta_l, theta_l_fit_val;
                    theta_r, theta_r_fit_val;
                    theta_b, theta_b_star;
                    dtheta_l, 0;
                    dtheta_r, 0;
                    dtheta_b, 0;
                    phi, 0;
                    dphi, 0;
                    X_b_h, 0;
                    dX_b_h, 0;
                    T_r_to_b, T_leg_fit_val;
                    T_l_to_b, T_leg_fit_val;
                    T_wr_to_r, 0;
                    T_wl_to_l, 0
                };

                M_fit_eq = double(subs(M_fit, eq_subs_fit(:,1), eq_subs_fit(:,2)));
                B_fit_eq = double(subs(B_fit, eq_subs_fit(:,1), eq_subs_fit(:,2)));

                zero_accel_subs_fit = {
                    ddX_b_h, 0;
                    ddphi, 0;
                    ddtheta_l, 0;
                    ddtheta_r, 0;
                    ddtheta_b, 0
                };
                dg_dtheta_l_fit = double(subs(diff(g_fit, theta_l), ...
                    [eq_subs_fit(:,1); zero_accel_subs_fit(:,1)], ...
                    [eq_subs_fit(:,2); zero_accel_subs_fit(:,2)]));
                dg_dtheta_r_fit = double(subs(diff(g_fit, theta_r), ...
                    [eq_subs_fit(:,1); zero_accel_subs_fit(:,1)], ...
                    [eq_subs_fit(:,2); zero_accel_subs_fit(:,2)]));
                dg_dtheta_b_fit = double(subs(diff(g_fit, theta_b), ...
                    [eq_subs_fit(:,1); zero_accel_subs_fit(:,1)], ...
                    [eq_subs_fit(:,2); zero_accel_subs_fit(:,2)]));

                M_inv_fit = inv(M_fit_eq);
                A_dyn_l_fit = M_inv_fit * dg_dtheta_l_fit;
                A_dyn_r_fit = M_inv_fit * dg_dtheta_r_fit;
                A_dyn_b_fit = M_inv_fit * dg_dtheta_b_fit;
                B_dyn_fit = M_inv_fit * B_fit_eq;

                A_fit_num = zeros(10, 10);
                B_fit_num = zeros(10, 4);
                A_fit_num(1,2) = 1;
                A_fit_num(3,4) = 1;
                A_fit_num(5,6) = 1;
                A_fit_num(7,8) = 1;
                A_fit_num(9,10) = 1;

                A_fit_num(2,5) = A_dyn_l_fit(1);  A_fit_num(2,7) = A_dyn_r_fit(1);  A_fit_num(2,9) = A_dyn_b_fit(1);
                A_fit_num(4,5) = A_dyn_l_fit(2);  A_fit_num(4,7) = A_dyn_r_fit(2);  A_fit_num(4,9) = A_dyn_b_fit(2);
                A_fit_num(6,5) = A_dyn_l_fit(3);  A_fit_num(6,7) = A_dyn_r_fit(3);  A_fit_num(6,9) = A_dyn_b_fit(3);
                A_fit_num(8,5) = A_dyn_l_fit(4);  A_fit_num(8,7) = A_dyn_r_fit(4);  A_fit_num(8,9) = A_dyn_b_fit(4);
                A_fit_num(10,5) = A_dyn_l_fit(5); A_fit_num(10,7) = A_dyn_r_fit(5); A_fit_num(10,9) = A_dyn_b_fit(5);

                B_fit_num(2,:) = B_dyn_fit(1,:);
                B_fit_num(4,:) = B_dyn_fit(2,:);
                B_fit_num(6,:) = B_dyn_fit(3,:);
                B_fit_num(8,:) = B_dyn_fit(4,:);
                B_fit_num(10,:) = B_dyn_fit(5,:);

                K_fit = lqr(A_fit_num, B_fit_num, lqr_Q, lqr_R);
                Acl_fit = A_fit_num - B_fit_num * K_fit;
                Bref_fit = B_fit_num * K_fit * R_ref_fit;

                K_sample(idx,:) = [l_l_fit, l_r_fit, reshape(K_fit.', 1, [])];
                A_sample(idx,:) = [l_l_fit, l_r_fit, reshape(A_fit_num.', 1, [])];
                B_sample(idx,:) = [l_l_fit, l_r_fit, reshape(B_fit_num.', 1, [])];
                Acl_sample(idx,:) = [l_l_fit, l_r_fit, reshape(Acl_fit.', 1, [])];
                Bref_sample(idx,:) = [l_l_fit, l_r_fit, reshape(Bref_fit.', 1, [])];
                offset_sample(idx,:) = [l_l_fit, l_r_fit, theta_l_fit_val, theta_r_fit_val, theta_b_star];
                input_eq_sample(idx,:) = [l_l_fit, l_r_fit, T_leg_fit_val, T_t_constraint_fit_val];

            catch ME
                if ~printed_first_fit_error
                    fprintf('首个拟合样本错误堆栈:\n');
                    for stack_i = 1:numel(ME.stack)
                        fprintf('  %s:%d\n', ME.stack(stack_i).name, ME.stack(stack_i).line);
                    end
                    printed_first_fit_error = true;
                end
                failed_cases = [failed_cases; l_l_fit, l_r_fit]; %#ok<AGROW>
                warning('腿长拟合样本失败 l_l=%.3f, l_r=%.3f: %s', l_l_fit, l_r_fit, ME.message);
            end
        end
    end

    valid_mask = any(K_sample(:,3:end) ~= 0, 2);
    valid_count = nnz(valid_mask);

    if valid_count < 6
        error('有效拟合样本不足，无法进行 poly22 拟合。');
    end

    Phi = build_poly22_design(K_sample(valid_mask,1), K_sample(valid_mask,2));

    K_coef_tail_disabled = Phi \ K_sample(valid_mask,3:end);
    A_coef_tail_disabled = Phi \ A_sample(valid_mask,3:end);
    B_coef_tail_disabled = Phi \ B_sample(valid_mask,3:end);
    Acl_coef_tail_disabled = Phi \ Acl_sample(valid_mask,3:end);
    Bref_coef_tail_disabled = Phi \ Bref_sample(valid_mask,3:end);
    Offset_coef_tail_disabled = Phi \ offset_sample(valid_mask,3:end);
    InputEq_coef_tail_disabled = Phi \ input_eq_sample(valid_mask,3:end);

    fit_info = struct();
    fit_info.l_range = l_range;
    fit_info.valid_count = valid_count;
    fit_info.sample_size = sample_size;
    fit_info.failed_cases = failed_cases;
    fit_info.poly22_order = {'p00','p10','p01','p20','p11','p02'};
    fit_info.elapsed = toc(tic_fit);

    save('lqr_tail_disabled_theta0_fitting_results.mat', ...
         'K_coef_tail_disabled', 'A_coef_tail_disabled', 'B_coef_tail_disabled', ...
         'Acl_coef_tail_disabled', 'Bref_coef_tail_disabled', ...
         'Offset_coef_tail_disabled', 'InputEq_coef_tail_disabled', ...
         'K_sample', 'A_sample', 'B_sample', 'Acl_sample', 'Bref_sample', ...
         'offset_sample', 'input_eq_sample', 'fit_info', ...
         'lqr_Q', 'lqr_R', 'theta_t_fixed_val');

    fprintf('有效样本: %d / %d\n', valid_count, sample_size);
    fprintf('拟合耗时: %.2f s\n', fit_info.elapsed);
    fprintf('结果已保存到 lqr_tail_disabled_theta0_fitting_results.mat\n');
end

fprintf('总耗时: %.2f s\n', toc);

function Phi = build_poly22_design(l_l_vec, l_r_vec)
    Phi = [ones(size(l_l_vec)), ...
           l_l_vec, ...
           l_r_vec, ...
           l_l_vec.^2, ...
           l_l_vec .* l_r_vec, ...
           l_r_vec.^2];
end
