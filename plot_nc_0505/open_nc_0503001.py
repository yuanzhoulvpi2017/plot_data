import netCDF4
from netCDF4 import Dataset
import pandas as pd
import numpy as np
nc_obj = Dataset("D:\\Downloads\\air.2x2.250.mon.anom.land.nc")
nc_obj.variables.keys()
lat = nc_obj.variables['lat'][:]
lon = nc_obj.variables['lon'][:]
air = nc_obj.variables['air'][:]

my_time = netCDF4.num2date(nc_obj.variables['time'][:],
                           units=nc_obj.variables['time'].units,
                           calendar='gregorian',
                           only_use_python_datetimes=True)


LON, LAT = np.meshgrid(lon, lat)
import cartopy.crs as ccrs
import matplotlib.pyplot as plt
from matplotlib import cm
import cartopy

# init
i = air.shape[0]-1
fig= plt.figure(figsize=(10, 8))
ax = plt.axes(projection=ccrs.PlateCarree())
ax.coastlines()
ax.gridlines()
ax.add_feature(cartopy.feature.LAND)
ax.add_feature(cartopy.feature.BORDERS, linestyle=':')
ax.add_feature(cartopy.feature.RIVERS)
cs = ax.contourf(LON, LAT, air[i], cmap=cm.coolwarm)
cs.set_clim(vmin=air.min(), vmax=air.max())

# ax.set_xlim((60, 160))
# ax.set_ylim((0, 80))
ax.set_title(f"month: {str(my_time[i]).split(' ')[0]} Monthly Average Temperature Anomailes")

plt.colorbar(cs, label="temperature")



def my_ani(i):

    global ax

    ax.cla()
    ax = plt.axes(projection=ccrs.PlateCarree())
    #
    ax.coastlines()
    #
    ax.add_feature(cartopy.feature.LAND)
    ax.add_feature(cartopy.feature.BORDERS, linestyle=':')
    ax.add_feature(cartopy.feature.RIVERS)

    ax.contour(LON, LAT, air[i])
    cs = ax.contourf(LON, LAT, air[i], cmap=cm.coolwarm)
    # cs.set_clim(vmin=np.min(air), vmax=np.max(air))
    cs.set_clim(vmin=-10, vmax=10)
    # ax.set_xlim((60, 160))
    # ax.set_ylim((0, 80))
    print(f"month: {str(my_time[i]).split(' ')[0]} Monthly Average Temperature Anomailes")
    # ax.set_axis('tight')
    ax.set_title(f"month: {str(my_time[i]).split(' ')[0]} Monthly Average Temperature Anomailes")
    return ax



from matplotlib.animation import FuncAnimation
from matplotlib import animation

ani = FuncAnimation(fig, my_ani, interval=15, frames=np.arange(0, air.shape[0])) # air.shape[0]

Writer = animation.writers['ffmpeg']
writer = Writer(fps=40, metadata=dict(artist='Me'), bitrate=1800)

ani.save("D:\\data\\mean_day_temperature_tropp2.mp4", writer=writer, dpi=400)

plt.show()
