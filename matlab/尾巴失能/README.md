# 尾巴失能 theta_t=0 模型

本目录基于 `尾巴离地` 模型建立尾巴失能、但被迫固定抬起的降维模型。

## 假设

- 尾巴固定在 `theta_t = 0`。
- `dtheta_t = 0`，`ddtheta_t = 0`。
- 尾巴不作为 LQR 输入，控制输入为：

```text
U = [T_r_to_b, T_l_to_b, T_wr_to_r, T_wl_to_l]^T
```

- 尾巴锁止/外部约束力矩由尾巴转动方程 `eq6 = 0` 反解，并代回机体俯仰方程。
- 锁死尾巴的自身转动惯量 `I_t` 折算到机体俯仰方程，加入 `I_t * ddtheta_b`。

## 状态

```text
X = [X_b_h, dX_b_h, phi, dphi, theta_l, dtheta_l,
     theta_r, dtheta_r, theta_b, dtheta_b]^T
```

## 使用

在 MATLAB 中进入本目录后运行：

```matlab
compute_lqr_tail_disabled_theta0
```

输出文件：

```text
lqr_tail_disabled_theta0_results.mat
lqr_tail_disabled_theta0_fitting_results.mat
```

其中 `lqr_tail_disabled_theta0_results.mat` 包含默认腿长 `l_l=l_r=0.17` 下的 `A_num`、`B_num`、`K`、平衡点角度和尾巴约束力矩。

`lqr_tail_disabled_theta0_fitting_results.mat` 包含不同腿长 `0.15:0.01:0.30` 下重新求平衡点、线性化、计算 LQR 后得到的 poly22 拟合系数：

```text
K_coef_tail_disabled
A_coef_tail_disabled
B_coef_tail_disabled
Acl_coef_tail_disabled
Bref_coef_tail_disabled
Offset_coef_tail_disabled
InputEq_coef_tail_disabled
```
