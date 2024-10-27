import numpy as np
import matplotlib.pyplot as plt

efs_a = np.loadtxt('efs_a.txt')
efs_b = np.loadtxt('efs_b.txt')
num_mo1 = np.array([4,5,6,7,8,9,10])
num_mo2 = np.array([4,5,6,7,8,9])
# General size
base_size = 50
# Create marker sizes for efs_a
marker_size_a = np.full_like(efs_a, base_size, dtype=float)
marker_size_a[efs_a == np.min(efs_a)] = base_size * 2  # Make the minimum value marker larger

# Create marker sizes for efs_b
marker_size_b = np.full_like(efs_b, base_size, dtype=float)
marker_size_b[efs_b == np.min(efs_b)] = base_size * 2  # Make the minimum value marker larger

plt.style.use('dark_background')
plt.title('Energía de formación de superficie $MoSeTe$')

# Use the calculated sizes as the marker size
plt.scatter(num_mo2, efs_a, c='blue', marker='^', s=marker_size_a, label='Modelo $\\alpha$')
plt.scatter(num_mo1, efs_b, c='red', marker='v', s=marker_size_b, label='Modelo $\\beta$')

plt.xlabel('Num. de átomos de $Mo$ por eje')
plt.ylabel('$EFS$ ($eV/atom$)')
plt.legend()
plt.tight_layout()
plt.savefig('efs_mosete.png', dpi=600)
plt.show()
