import netCDF4
from netCDF4 import Dataset
import pandas as pd
import numpy as np
import cartopy.crs as ccrs
import matplotlib.pyplot as plt
from matplotlib import cm
import cartopy

nc_obj = Dataset("D:\\Downloads\\air.2m.gauss.2020.nc")
nc_obj.variables.keys()

lat = nc_obj.variables['lat'][:]
lon = nc_obj.variables['lon'][:]
air = nc_obj.variables['air'][:]

my_time = netCDF4.num2date(nc_obj.variables['time'][:],
                           units=nc_obj.variables['time'].units,
                           calendar='gregorian',
                           only_use_python_datetimes=True)

my_time = [str(i).split(' ')[0] for i in my_time]

LON, LAT = np.meshgrid(lon, lat)

# init plot
i = 0
fig = plt.figure(figsize=(10, 8))
ax = plt.axes(projection=ccrs.PlateCarree())
ax.coastlines()
ax.gridlines()
ax.add_feature(cartopy.feature.LAND)
ax.add_feature(cartopy.feature.BORDERS, linestyle=':')
ax.add_feature(cartopy.feature.RIVERS)
ax.contour(LON, LAT, air[i], transform=ccrs.PlateCarree())
cs = ax.contourf(LON, LAT, air[i], cmap=cm.coolwarm, transform=ccrs.PlateCarree())
cs.set_clim(vmin=air.min(), vmax=air.max())

# ax.set_xlim((60, 160))
# ax.set_ylim((0, 80))
ax.set_title(f"day: {my_time[i]}")
plt.colorbar(cs, label="temperature(K)")
# plt.show()




def my_ani(i):

    global ax

    ax.cla()
    ax = plt.axes(projection=ccrs.PlateCarree())
    ax.coastlines()
    ax.gridlines()
    ax.add_feature(cartopy.feature.LAND)
    ax.add_feature(cartopy.feature.BORDERS, linestyle=':')
    ax.add_feature(cartopy.feature.RIVERS)
    ax.contour(LON, LAT, air[i], transform=ccrs.PlateCarree())
    cs = ax.contourf(LON, LAT, air[i], cmap=cm.coolwarm, transform=ccrs.PlateCarree())
    cs.set_clim(vmin=air.min(), vmax=air.max())
    ax.set_title(f"day: {my_time[i]}")
    print(f"month: {my_time[i]}")
    return ax



from matplotlib.animation import FuncAnimation
ani = FuncAnimation(fig, my_ani, interval=100, frames=np.arange(0, air.shape[0])) # air.shape[0]
from matplotlib import animation

Writer = animation.writers['ffmpeg']
writer = Writer(fps=16, metadata=dict(artist='Me'), bitrate=1800)

ani.save("D:\\data\\05052m.mp4", writer=writer, dpi=400)

plt.show()