import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

# Bookings Data
n = [2000, 4000, 8000, 16000, 32000]  # X-axis data
avg_time = [74.59, 71.69, 70.69, 73.44, 69.77]  # Y-axis data

# Create figure and axis
fig, ax = plt.subplots()
ax.set_xlim(0, max(n) + 1000)
ax.set_ylim(0, max(avg_time) + 10)

# Create empty line
line, = ax.plot([], [], lw=2, marker='o', color='red')

# Initialization function: plot the background of each frame
def init():
    line.set_data([], [])
    plt.xlabel('Number of Records')
    plt.ylabel('Average Insertion Time (microseconds)')
    plt.title('Average Time vs Records')
    plt.grid(True)
    return line,

# Animation function, which updates the plot with each frame
def animate(i):
    x = n[:i+1]
    y = avg_time[:i+1]
    line.set_data(x, y)
    return line,

# Create animation
ani = FuncAnimation(fig, animate, frames=len(n), init_func=init, blit=True, interval=500)

# Save animation as GIF using pillow writer
ani.save('animation.gif', writer='pillow')

# Show plot
plt.show()
