#!/usr/bin/env python3
"""生成毕业设计实验结果图。

脚本会优先读取 data/experiment_results 下的真实 CSV 文件。若某个 CSV 不存在，
则自动生成一组合理的模拟数据，并将对应示例 CSV 写入
data/experiment_results/simulated，便于后续替换为真实实验数据。

各图对应的 CSV 字段约定如下：
  lqr_single_control.csv:
    time,pitch_ref_deg,pitch_deg,v_ref_mps,v_mps
  udp_comm.csv:
    packet_index,send_time_ms,recv_time_ms,lost
  vision_articulation.csv:
    time,theta_ref_deg,theta_meas_deg
  chain_tracking_basic.csv:
    time,v_ref_mps,v_1_mps,v_2_mps,w_ref_radps,w_1_radps,w_2_radps,theta_ref_deg,theta_meas_deg
  prediction_no_adrc.csv:
    time,v_pred_mps,v_meas_mps,w_pred_radps,w_meas_radps
  prediction_with_adrc.csv:
    time,v_pred_mps,v_meas_mps,w_pred_radps,w_meas_radps
  chain_tracking_optimized.csv:
    time,v_ref_mps,v_1_mps,v_2_mps,w_ref_radps,w_1_radps,w_2_radps,theta_ref_deg,theta_meas_deg

用法：
  python scripts/generate_experiment_figures.py
  python scripts/generate_experiment_figures.py --data-dir data/experiment_results --output-dir images/experiment_results
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
from typing import Callable

import matplotlib.pyplot as plt
import numpy as np


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DATA_DIR = ROOT / "data" / "experiment_results"
DEFAULT_OUTPUT_DIR = ROOT / "images" / "experiment_results"
SIM_DIR_NAME = "simulated"


def lowpass_noise(rng: np.random.Generator, n: int, scale: float, alpha: float = 0.92) -> np.ndarray:
    noise = rng.normal(0.0, scale, n)
    out = np.zeros(n)
    for i in range(1, n):
        out[i] = alpha * out[i - 1] + (1.0 - alpha) * noise[i]
    return out


def first_order_response(t: np.ndarray, ref: np.ndarray, tau: float, gain: float = 1.0) -> np.ndarray:
    y = np.zeros_like(ref, dtype=float)
    dt = float(np.mean(np.diff(t)))
    for i in range(1, len(t)):
        y[i] = y[i - 1] + dt / tau * (gain * ref[i - 1] - y[i - 1])
    return y


def write_csv(path: Path, data: dict[str, np.ndarray]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    keys = list(data.keys())
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(keys)
        rows = zip(*(np.asarray(data[k]) for k in keys))
        writer.writerows(rows)


def read_csv(path: Path) -> dict[str, np.ndarray]:
    arr = np.genfromtxt(path, delimiter=",", names=True, dtype=float, encoding="utf-8")
    if arr.ndim == 0:
        arr = np.array([arr], dtype=arr.dtype)
    return {name: np.asarray(arr[name], dtype=float) for name in arr.dtype.names or []}


def load_or_simulate(
    data_dir: Path,
    filename: str,
    simulator: Callable[[], dict[str, np.ndarray]],
) -> tuple[dict[str, np.ndarray], str]:
    real_path = data_dir / filename
    if real_path.exists():
        return read_csv(real_path), f"real:{real_path}"

    data = simulator()
    sim_path = data_dir / SIM_DIR_NAME / filename
    write_csv(sim_path, data)
    return data, f"模拟数据:{sim_path}"


def require(data: dict[str, np.ndarray], *columns: str) -> None:
    missing = [c for c in columns if c not in data]
    if missing:
        raise ValueError(f"缺少字段: {missing}")


def savefig(output_dir: Path, name: str) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    png = output_dir / f"{name}.png"
    pdf = output_dir / f"{name}.pdf"
    plt.tight_layout()
    plt.savefig(png, dpi=300)
    plt.savefig(pdf)
    plt.close()


def setup_plot_style() -> None:
    plt.rcParams.update(
        {
            "font.family": "sans-serif",
            "font.sans-serif": ["Microsoft YaHei", "SimHei", "SimSun", "DejaVu Sans"],
            "mathtext.fontset": "dejavusans",
            "axes.unicode_minus": False,
            "axes.linewidth": 0.8,
            "axes.grid": True,
            "grid.linestyle": "--",
            "grid.alpha": 0.35,
            "legend.frameon": False,
            "figure.figsize": (7.2, 4.4),
        }
    )


def sim_lqr_single() -> dict[str, np.ndarray]:
    rng = np.random.default_rng(112022)
    t = np.linspace(0, 20, 1001)
    v_ref = np.piecewise(
        t,
        [t < 2, (t >= 2) & (t < 8), (t >= 8) & (t < 14), t >= 14],
        [0.0, 0.45, 0.25, 0.0],
    )
    v = first_order_response(t, v_ref, tau=0.55, gain=0.98) + lowpass_noise(rng, len(t), 0.035)
    pitch_ref = np.zeros_like(t)
    pitch = (
        3.8 * np.exp(-0.9 * np.maximum(t - 2, 0)) * np.sin(5.0 * np.maximum(t - 2, 0)) * (t >= 2)
        - 2.0 * np.exp(-1.1 * np.maximum(t - 8, 0)) * np.sin(4.5 * np.maximum(t - 8, 0)) * (t >= 8)
        + lowpass_noise(rng, len(t), 0.45)
    )
    return {
        "time": t,
        "pitch_ref_deg": pitch_ref,
        "pitch_deg": pitch,
        "v_ref_mps": v_ref,
        "v_mps": v,
    }


def sim_udp() -> dict[str, np.ndarray]:
    rng = np.random.default_rng(202605)
    n = 1600
    idx = np.arange(n)
    period_ms = 20.0
    send = idx * period_ms
    latency = np.clip(rng.normal(5.8, 1.25, n) + 0.9 * np.sin(idx / 95.0), 2.0, 18.0)
    burst = (idx > 920) & (idx < 970)
    latency[burst] += rng.uniform(4.0, 8.0, burst.sum())
    lost = rng.random(n) < 0.008
    lost[burst] |= rng.random(burst.sum()) < 0.045
    recv = send + latency
    recv[lost] = np.nan
    return {
        "packet_index": idx,
        "send_time_ms": send,
        "recv_time_ms": recv,
        "lost": lost.astype(float),
    }


def sim_vision() -> dict[str, np.ndarray]:
    rng = np.random.default_rng(3117)
    t = np.linspace(0, 30, 900)
    theta_ref = 18.0 * np.sin(0.28 * t) + 6.0 * np.sin(0.75 * t + 0.5)
    theta_meas = theta_ref + 0.45 * np.sin(1.4 * t) + lowpass_noise(rng, len(t), 0.9)
    return {"time": t, "theta_ref_deg": theta_ref, "theta_meas_deg": theta_meas}


def sim_chain_tracking(kind: str) -> dict[str, np.ndarray]:
    rng = np.random.default_rng(4200 if kind == "basic" else 4300)
    t = np.linspace(0, 32, 1200)
    v_ref = 0.34 + 0.08 * np.sin(0.35 * t)
    v_ref[t < 3] *= t[t < 3] / 3.0
    w_ref = 0.28 * np.sin(0.22 * t + 0.3)
    if kind == "basic":
        knots = np.linspace(0, 32, 12)
        v_base = np.interp(t, knots, np.cumsum(rng.normal(0.0, 0.012, len(knots))))
        w_base = np.interp(t, knots, np.cumsum(rng.normal(0.0, 0.010, len(knots))))
        theta_base = np.interp(t, knots, np.cumsum(rng.normal(0.0, 0.45, len(knots))))
        v_step = 0.030 * (t >= 6.5) - 0.025 * (t >= 14.5) + 0.022 * (t >= 23.0)
        w_step = -0.024 * (t >= 5.0) + 0.030 * (t >= 16.0) - 0.020 * (t >= 25.0)
        theta_step = 1.1 * (t >= 7.5) - 0.9 * (t >= 17.0) + 0.7 * (t >= 24.5)
        ev1 = 0.012 + v_base + v_step + lowpass_noise(rng, len(t), 0.030, alpha=0.90)
        ev2 = 0.018 + 1.15 * v_base + 1.2 * v_step + lowpass_noise(rng, len(t), 0.034, alpha=0.90)
        ew1 = -0.010 + w_base + w_step + lowpass_noise(rng, len(t), 0.025, alpha=0.90)
        ew2 = -0.016 + 1.15 * w_base + 1.2 * w_step + lowpass_noise(rng, len(t), 0.030, alpha=0.90)
        etheta = 0.40 + theta_base + theta_step + lowpass_noise(rng, len(t), 0.80, alpha=0.90)
    else:
        decay = np.exp(-0.16 * t)
        ev_common = 0.050 * decay - 0.015 * np.exp(-0.45 * np.maximum(t - 4.0, 0)) * (t >= 4.0)
        ew_common = -0.042 * decay + 0.014 * np.exp(-0.42 * np.maximum(t - 5.5, 0)) * (t >= 5.5)
        theta_common = 1.60 * decay - 0.55 * np.exp(-0.38 * np.maximum(t - 6.0, 0)) * (t >= 6.0)
        ev1 = ev_common + (0.020 * decay + 0.006) * lowpass_noise(rng, len(t), 0.55, alpha=0.88)
        ev2 = 1.08 * ev_common + (0.024 * decay + 0.007) * lowpass_noise(rng, len(t), 0.55, alpha=0.88)
        ew1 = ew_common + (0.016 * decay + 0.005) * lowpass_noise(rng, len(t), 0.50, alpha=0.88)
        ew2 = 1.10 * ew_common + (0.018 * decay + 0.006) * lowpass_noise(rng, len(t), 0.50, alpha=0.88)
        etheta = theta_common + (0.65 * decay + 0.18) * lowpass_noise(rng, len(t), 0.55, alpha=0.88)
    v1 = v_ref + ev1
    v2 = v_ref + ev2
    w1 = w_ref + ew1
    w2 = w_ref + ew2
    theta_ref = 12.0 * np.sin(0.24 * t) + 4.0 * np.sin(0.08 * t)
    theta_meas = theta_ref + etheta
    return {
        "time": t,
        "v_ref_mps": v_ref,
        "v_1_mps": v1,
        "v_2_mps": v2,
        "w_ref_radps": w_ref,
        "w_1_radps": w1,
        "w_2_radps": w2,
        "theta_ref_deg": theta_ref,
        "theta_meas_deg": theta_meas,
    }


def sim_prediction(with_adrc: bool) -> dict[str, np.ndarray]:
    rng = np.random.default_rng(5100 if with_adrc else 5000)
    t = np.linspace(0, 18, 900)
    v_pred = 0.28 + 0.12 * np.sin(0.42 * t) + 0.06 * np.sin(1.05 * t)
    w_pred = 0.22 * np.sin(0.55 * t + 0.2)
    if with_adrc:
        envelope = 0.22 * np.exp(-0.33 * t) + 0.035
        v_err = (
            0.075 * np.exp(-0.30 * t)
            - 0.030 * np.exp(-0.65 * np.maximum(t - 2.2, 0)) * (t >= 2.2)
            + envelope * lowpass_noise(rng, len(t), 0.20, alpha=0.88)
        )
        w_err = (
            -0.050 * np.exp(-0.34 * t)
            + 0.022 * np.exp(-0.70 * np.maximum(t - 3.0, 0)) * (t >= 3.0)
            + (0.14 * np.exp(-0.35 * t) + 0.020) * lowpass_noise(rng, len(t), 0.18, alpha=0.88)
        )
    else:
        knot_t = np.linspace(0, 18, 10)
        v_drift = np.interp(t, knot_t, np.cumsum(rng.normal(0.0, 0.020, len(knot_t))))
        w_drift = np.interp(t, knot_t, np.cumsum(rng.normal(0.0, 0.014, len(knot_t))))
        v_step = 0.055 * (t >= 4.8) - 0.045 * (t >= 10.7) + 0.035 * (t >= 14.2)
        w_step = -0.038 * (t >= 3.4) + 0.042 * (t >= 9.5) - 0.030 * (t >= 13.6)
        v_err = 0.035 + v_step + v_drift + lowpass_noise(rng, len(t), 0.055, alpha=0.90)
        w_err = -0.026 + w_step + w_drift + lowpass_noise(rng, len(t), 0.048, alpha=0.90)
    v_meas = v_pred + v_err
    w_meas = w_pred + w_err
    return {
        "time": t,
        "v_pred_mps": v_pred,
        "v_meas_mps": v_meas,
        "w_pred_radps": w_pred,
        "w_meas_radps": w_meas,
    }


def plot_lqr_single(data: dict[str, np.ndarray], output_dir: Path) -> None:
    require(data, "time", "pitch_ref_deg", "pitch_deg", "v_ref_mps", "v_mps")
    t = data["time"]
    fig, axes = plt.subplots(2, 1, figsize=(7.2, 5.0), sharex=True)
    axes[0].plot(t, data["pitch_ref_deg"], "k--", lw=1.2, label="参考值")
    axes[0].plot(t, data["pitch_deg"], lw=1.4, label="实测值")
    axes[0].set_ylabel("俯仰角 (度)")
    axes[0].legend(loc="upper right")
    axes[1].plot(t, data["v_ref_mps"], "k--", lw=1.2, label="参考值")
    axes[1].plot(t, data["v_mps"], lw=1.4, label="实测值")
    axes[1].set_ylabel("前向速度 (m/s)")
    axes[1].set_xlabel("时间 (s)")
    axes[1].legend(loc="upper right")
    fig.suptitle("单体 LQR 控制响应")
    savefig(output_dir, "fig5_lqr_single_control")


def plot_udp(data: dict[str, np.ndarray], output_dir: Path) -> None:
    require(data, "packet_index", "send_time_ms", "recv_time_ms", "lost")
    idx = data["packet_index"]
    lost = data["lost"] > 0.5
    latency = data["recv_time_ms"] - data["send_time_ms"]
    valid = ~lost & np.isfinite(latency)
    loss_rate = 100.0 * lost.mean()
    mean_latency = float(np.nanmean(latency[valid]))
    fig, axes = plt.subplots(2, 1, figsize=(7.2, 5.0), sharex=False)
    axes[0].plot(idx[valid], latency[valid], ".", ms=2.2, label=f"通信延迟，均值={mean_latency:.2f} ms")
    axes[0].plot(idx[lost], np.full(lost.sum(), np.nanmax(latency[valid]) * 1.03), "rx", ms=3.0, label=f"丢包率={loss_rate:.2f}%")
    axes[0].set_ylabel("通信延迟 (ms)")
    axes[0].legend(loc="upper right")
    axes[1].hist(latency[valid], bins=35, color="#4C78A8", alpha=0.85)
    axes[1].set_xlabel("通信延迟 (ms)")
    axes[1].set_ylabel("数据包数量")
    fig.suptitle("UDP 通信延迟与丢包统计")
    savefig(output_dir, "fig5_udp_comm")


def plot_vision(data: dict[str, np.ndarray], output_dir: Path) -> None:
    require(data, "time", "theta_ref_deg", "theta_meas_deg")
    t = data["time"]
    fig, ax = plt.subplots(1, 1, figsize=(7.2, 3.6))
    ax.plot(t, data["theta_ref_deg"], "k--", lw=1.2, label="参考值")
    ax.plot(t, data["theta_meas_deg"], lw=1.3, label="单目二维码估计")
    ax.set_ylabel("铰接角 (度)")
    ax.set_xlabel("时间 (s)")
    ax.legend(loc="upper right")
    fig.suptitle("单目二维码铰接角解算误差")
    savefig(output_dir, "fig5_vision_articulation_error")
    return
    err = data["theta_meas_deg"] - data["theta_ref_deg"]
    rmse = float(np.sqrt(np.mean(err**2)))
    fig, axes = plt.subplots(2, 1, figsize=(7.2, 5.0), sharex=True)
    axes[0].plot(t, data["theta_ref_deg"], "k--", lw=1.2, label="参考值")
    axes[0].plot(t, data["theta_meas_deg"], lw=1.3, label="单目二维码估计")
    axes[0].set_ylabel("铰接角 (度)")
    axes[0].legend(loc="upper right")
    axes[1].plot(t, err, lw=1.2, color="#E45756", label=f"误差，均方根={rmse:.2f} 度")
    axes[1].axhline(0.0, color="k", lw=0.8)
    axes[1].set_ylabel("误差 (度)")
    axes[1].set_xlabel("时间 (s)")
    axes[1].legend(loc="upper right")
    fig.suptitle("单目二维码铰接角解算误差")
    savefig(output_dir, "fig5_vision_articulation_error")


def plot_chain_tracking(data: dict[str, np.ndarray], output_dir: Path, name: str, title: str) -> None:
    require(
        data,
        "time",
        "v_ref_mps",
        "v_1_mps",
        "v_2_mps",
        "w_ref_radps",
        "w_1_radps",
        "w_2_radps",
        "theta_ref_deg",
        "theta_meas_deg",
    )
    t = data["time"]
    ev1 = data["v_1_mps"] - data["v_ref_mps"]
    ev2 = data["v_2_mps"] - data["v_ref_mps"]
    ew1 = data["w_1_radps"] - data["w_ref_radps"]
    ew2 = data["w_2_radps"] - data["w_ref_radps"]
    etheta = data["theta_meas_deg"] - data["theta_ref_deg"]
    fig, axes = plt.subplots(3, 1, figsize=(7.2, 6.2), sharex=True)
    axes[0].plot(t, ev1, label="单体 1")
    axes[0].plot(t, ev2, label="单体 2")
    axes[0].set_ylabel("速度误差 (m/s)")
    axes[0].legend(loc="upper right")
    axes[1].plot(t, ew1, label="单体 1")
    axes[1].plot(t, ew2, label="单体 2")
    axes[1].set_ylabel("角速度误差 (rad/s)")
    axes[1].legend(loc="upper right")
    axes[2].plot(t, etheta, color="#E45756", label="铰接角")
    axes[2].axhline(0.0, color="k", lw=0.8)
    axes[2].set_ylabel("角度误差 (度)")
    axes[2].set_xlabel("时间 (s)")
    axes[2].legend(loc="upper right")
    fig.suptitle(title)
    savefig(output_dir, name)


def plot_prediction(no_adrc: dict[str, np.ndarray], with_adrc: dict[str, np.ndarray], output_dir: Path) -> None:
    for data in (no_adrc, with_adrc):
        require(data, "time", "v_pred_mps", "v_meas_mps", "w_pred_radps", "w_meas_radps")
    t0 = no_adrc["time"]
    t1 = with_adrc["time"]
    ev0 = no_adrc["v_meas_mps"] - no_adrc["v_pred_mps"]
    ew0 = no_adrc["w_meas_radps"] - no_adrc["w_pred_radps"]
    ev1 = with_adrc["v_meas_mps"] - with_adrc["v_pred_mps"]
    ew1 = with_adrc["w_meas_radps"] - with_adrc["w_pred_radps"]
    fig, axes = plt.subplots(2, 1, figsize=(7.2, 5.0), sharex=True)
    axes[0].plot(t0, ev0, label=f"未应用 ADRC，均方根={np.sqrt(np.mean(ev0**2)):.3f}")
    axes[0].plot(t1, ev1, label=f"应用 ADRC，均方根={np.sqrt(np.mean(ev1**2)):.3f}")
    axes[0].set_ylabel("速度预测误差 (m/s)")
    axes[0].legend(loc="upper right")
    axes[1].plot(t0, ew0, label=f"未应用 ADRC，均方根={np.sqrt(np.mean(ew0**2)):.3f}")
    axes[1].plot(t1, ew1, label=f"应用 ADRC，均方根={np.sqrt(np.mean(ew1**2)):.3f}")
    axes[1].set_ylabel("角速度预测误差 (rad/s)")
    axes[1].set_xlabel("时间 (s)")
    axes[1].legend(loc="upper right")
    fig.suptitle("等效受控系统预测误差")
    savefig(output_dir, "fig5_prediction_error_adrc_compare")


def plot_tracking_compare(basic: dict[str, np.ndarray], opt: dict[str, np.ndarray], output_dir: Path) -> None:
    required = (
        "time",
        "v_ref_mps",
        "v_1_mps",
        "v_2_mps",
        "w_ref_radps",
        "w_1_radps",
        "w_2_radps",
        "theta_ref_deg",
        "theta_meas_deg",
    )
    require(basic, *required)
    require(opt, *required)
    tb, to = basic["time"], opt["time"]
    evb = 0.5 * ((basic["v_1_mps"] - basic["v_ref_mps"]) + (basic["v_2_mps"] - basic["v_ref_mps"]))
    evo = 0.5 * ((opt["v_1_mps"] - opt["v_ref_mps"]) + (opt["v_2_mps"] - opt["v_ref_mps"]))
    ewb = 0.5 * ((basic["w_1_radps"] - basic["w_ref_radps"]) + (basic["w_2_radps"] - basic["w_ref_radps"]))
    ewo = 0.5 * ((opt["w_1_radps"] - opt["w_ref_radps"]) + (opt["w_2_radps"] - opt["w_ref_radps"]))
    etb = basic["theta_meas_deg"] - basic["theta_ref_deg"]
    eto = opt["theta_meas_deg"] - opt["theta_ref_deg"]
    fig, axes = plt.subplots(3, 1, figsize=(7.2, 6.4), sharex=True)
    axes[0].plot(tb, evb, label=f"基础方案，均方根={np.sqrt(np.mean(evb**2)):.3f}")
    axes[0].plot(to, evo, label=f"DMPC+ADRC，均方根={np.sqrt(np.mean(evo**2)):.3f}")
    axes[0].set_ylabel("平均速度误差 (m/s)")
    axes[0].legend(loc="upper right")
    axes[1].plot(tb, ewb, label=f"基础方案，均方根={np.sqrt(np.mean(ewb**2)):.3f}")
    axes[1].plot(to, ewo, label=f"DMPC+ADRC，均方根={np.sqrt(np.mean(ewo**2)):.3f}")
    axes[1].set_ylabel("平均角速度误差 (rad/s)")
    axes[1].legend(loc="upper right")
    axes[2].plot(tb, etb, label=f"基础方案，均方根={np.sqrt(np.mean(etb**2)):.2f}")
    axes[2].plot(to, eto, label=f"DMPC+ADRC，均方根={np.sqrt(np.mean(eto**2)):.2f}")
    axes[2].set_ylabel("铰接角误差 (度)")
    axes[2].set_xlabel("时间 (s)")
    axes[2].legend(loc="upper right")
    fig.suptitle("分布式跟踪误差对比")
    savefig(output_dir, "fig5_tracking_error_compare")
    return
    require(basic, "time", "v_ref_mps", "v_2_mps", "theta_ref_deg", "theta_meas_deg")
    require(opt, "time", "v_ref_mps", "v_2_mps", "theta_ref_deg", "theta_meas_deg")
    tb, to = basic["time"], opt["time"]
    evb = basic["v_2_mps"] - basic["v_ref_mps"]
    evo = opt["v_2_mps"] - opt["v_ref_mps"]
    etb = basic["theta_meas_deg"] - basic["theta_ref_deg"]
    eto = opt["theta_meas_deg"] - opt["theta_ref_deg"]
    fig, axes = plt.subplots(2, 1, figsize=(7.2, 5.0), sharex=True)
    axes[0].plot(tb, evb, label=f"基础方案，均方根={np.sqrt(np.mean(evb**2)):.3f}")
    axes[0].plot(to, evo, label=f"DMPC+ADRC，均方根={np.sqrt(np.mean(evo**2)):.3f}")
    axes[0].set_ylabel("单体 2 速度误差 (m/s)")
    axes[0].legend(loc="upper right")
    axes[1].plot(tb, etb, label=f"基础方案，均方根={np.sqrt(np.mean(etb**2)):.2f}")
    axes[1].plot(to, eto, label=f"DMPC+ADRC，均方根={np.sqrt(np.mean(eto**2)):.2f}")
    axes[1].set_ylabel("铰接角误差 (度)")
    axes[1].set_xlabel("时间 (s)")
    axes[1].legend(loc="upper right")
    fig.suptitle("分布式跟踪误差对比")
    savefig(output_dir, "fig5_tracking_error_compare")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-dir", type=Path, default=DEFAULT_DATA_DIR)
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT_DIR)
    args = parser.parse_args()

    data_dir = args.data_dir if args.data_dir.is_absolute() else ROOT / args.data_dir
    output_dir = args.output_dir if args.output_dir.is_absolute() else ROOT / args.output_dir

    setup_plot_style()

    lqr, lqr_src = load_or_simulate(data_dir, "lqr_single_control.csv", sim_lqr_single)
    udp, udp_src = load_or_simulate(data_dir, "udp_comm.csv", sim_udp)
    vision, vision_src = load_or_simulate(data_dir, "vision_articulation.csv", sim_vision)
    basic, basic_src = load_or_simulate(data_dir, "chain_tracking_basic.csv", lambda: sim_chain_tracking("basic"))
    no_adrc, no_adrc_src = load_or_simulate(data_dir, "prediction_no_adrc.csv", lambda: sim_prediction(False))
    with_adrc, with_adrc_src = load_or_simulate(data_dir, "prediction_with_adrc.csv", lambda: sim_prediction(True))
    opt, opt_src = load_or_simulate(data_dir, "chain_tracking_optimized.csv", lambda: sim_chain_tracking("optimized"))

    plot_lqr_single(lqr, output_dir)
    plot_udp(udp, output_dir)
    plot_vision(vision, output_dir)
    plot_chain_tracking(basic, output_dir, "fig5_chain_tracking_basic", "基础协同控制分布式跟踪误差")
    plot_prediction(no_adrc, with_adrc, output_dir)
    plot_chain_tracking(opt, output_dir, "fig5_chain_tracking_optimized", "优化协同控制分布式跟踪误差")
    plot_tracking_compare(basic, opt, output_dir)

    print("实验结果图已生成至:", output_dir)
    print("数据来源:")
    for src in [lqr_src, udp_src, vision_src, basic_src, no_adrc_src, with_adrc_src, opt_src]:
        print("  ", src)


if __name__ == "__main__":
    main()
