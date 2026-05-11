# 实验结果图数据接口

绘图脚本：

```powershell
python scripts\generate_experiment_figures.py
```

脚本默认读取本目录下的真实 CSV 文件。若对应 CSV 不存在，则自动使用模拟数据，并将示例 CSV 写入 `simulated/` 目录。

输出图片位于：

```text
../images/experiment_results
```

每张图同时输出 `.png` 和 `.pdf`。

## CSV 文件约定

### lqr_single_control.csv

用于生成单体 LQR 控制效果图。

```text
time,pitch_ref_deg,pitch_deg,v_ref_mps,v_mps
```

### udp_comm.csv

用于生成 UDP 通信丢包率和通信延迟图。

```text
packet_index,send_time_ms,recv_time_ms,lost
```

其中 `lost` 为 0 或 1。若丢包，`recv_time_ms` 可为空或 `nan`。

### vision_articulation.csv

用于生成单目二维码铰接角解算误差图。

```text
time,theta_ref_deg,theta_meas_deg
```

### chain_tracking_basic.csv

用于生成基础协同控制方案的链式系统分布式跟踪误差图。

```text
time,v_ref_mps,v_1_mps,v_2_mps,w_ref_radps,w_1_radps,w_2_radps,theta_ref_deg,theta_meas_deg
```

### prediction_no_adrc.csv

用于生成未应用 ADRC 时等效受控系统预测误差。

```text
time,v_pred_mps,v_meas_mps,w_pred_radps,w_meas_radps
```

### prediction_with_adrc.csv

用于生成应用 ADRC 后等效受控系统预测误差。

```text
time,v_pred_mps,v_meas_mps,w_pred_radps,w_meas_radps
```

### chain_tracking_optimized.csv

用于生成应用 DMPC 和 ADRC 后的链式系统分布式跟踪误差图。

```text
time,v_ref_mps,v_1_mps,v_2_mps,w_ref_radps,w_1_radps,w_2_radps,theta_ref_deg,theta_meas_deg
```

## 使用真实数据

将真实实验 CSV 放在本目录下，并保持上述文件名和字段名，再运行脚本即可。脚本会优先使用真实 CSV，而不是 `simulated/` 中的示例数据。
