# LQR 受控等效模型

本目录将 `尾巴失能/theta_t=0` 的开环线性模型和 LQR 增益合成为闭环受控模型。

脚本会优先读取：

```text
../尾巴失能/lqr_tail_disabled_theta0_fitting_results.mat
```

若存在该文件，则按 `l_l_query`、`l_r_query` 使用 poly22 拟合系数重建对应腿长下的 `A`、`B`、`K`，再构造闭环模型；否则退回单点 `l_l=l_r=0.17` 模型。

## 输入

```text
r = [v_x_ref, w_z_ref]^T
```

其余预期状态量均设为 0。

## 输出

```text
y = [v_x, w_z]^T
```

## 建模关系

开环线性模型：

```text
x_dot = A*x + B*u
```

LQR 控制律：

```text
u = -K*x_err
x_err = x - R_ref*r
```

其中：

```text
x_err(2) = dX_b_h - v_x_ref
x_err(4) = dphi - w_z_ref
```

所以闭环等效模型为：

```text
x_dot = (A - B*K)*x + B*K*R_ref*r
y     = C*x
```

## 使用

先运行：

```matlab
../尾巴失能/compute_lqr_tail_disabled_theta0.m
```

再进入本目录运行：

```matlab
build_tail_disabled_closed_loop_model
```

可在脚本开头修改查询腿长：

```matlab
l_l_query = 0.17;
l_r_query = 0.17;
```

输出文件：

```text
tail_disabled_closed_loop_model.mat
```
