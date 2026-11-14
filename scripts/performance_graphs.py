
import os
import csv
import matplotlib.pyplot as plt

os.makedirs("results", exist_ok=True)

workloads = ["Independent", "Dependency-heavy", "Mixed"]

single_cycles = [8, 8, 8]
dual_cycles = [4, 8, 4]
instructions = 8

single_ipc = [instructions / c for c in single_cycles]
dual_ipc = [instructions / c for c in dual_cycles]

single_cpi = [c / instructions for c in single_cycles]
dual_cpi = [c / instructions for c in dual_cycles]

speedup = [s / d for s, d in zip(single_cycles, dual_cycles)]

# Export measurements
with open("results/performance.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow([
        "Workload", "Single Cycles", "Dual Cycles",
        "Single IPC", "Dual IPC",
        "Single CPI", "Dual CPI", "Speedup"
    ])
    for i, name in enumerate(workloads):
        writer.writerow([
            name, single_cycles[i], dual_cycles[i],
            single_ipc[i], dual_ipc[i],
            single_cpi[i], dual_cpi[i], speedup[i]
        ])

def comparison_plot(single, dual, ylabel, title, filename):
    x = list(range(len(workloads)))
    width = 0.35

    fig, ax = plt.subplots(figsize=(9, 5))
    ax.bar([v - width/2 for v in x], single,
           width, label="Single-issue")
    ax.bar([v + width/2 for v in x], dual,
           width, label="Dual-issue")

    ax.set_xticks(x)
    ax.set_xticklabels(workloads)
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.legend()
    ax.grid(axis="y", alpha=0.25)
    fig.tight_layout()
    fig.savefig("results/" + filename, dpi=300)
    plt.close(fig)

comparison_plot(
    single_cycles, dual_cycles, "Issue cycles",
    "Single vs Dual Issue Cycles", "cycles.png"
)

comparison_plot(
    single_ipc, dual_ipc, "Issue IPC",
    "Instructions Issued per Cycle", "ipc.png"
)

comparison_plot(
    single_cpi, dual_cpi, "Issue CPI",
    "Issue Cycles per Instruction", "cpi.png"
)

fig, ax = plt.subplots(figsize=(9, 5))
ax.bar(workloads, speedup)
ax.axhline(1, linestyle="--", label="No speedup")
ax.set_ylabel("Speedup (x)")
ax.set_title("Dual-Issue Speedup")
ax.set_ylim(0, 2.5)
ax.legend()
ax.grid(axis="y", alpha=0.25)
fig.tight_layout()
fig.savefig("results/speedup.png", dpi=300)
plt.close(fig)

print("PERFORMANCE GRAPHS GENERATED")
print("CSV: results/performance.csv")
print("Graphs: cycles.png, ipc.png, cpi.png, speedup.png")
