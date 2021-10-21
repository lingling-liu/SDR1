import os
from geemap.conversion import *

# Create a temporary working directory
work_dir = os.path.join(os.path.expanduser('~'), 'geemap')

# Change js_dir to your own folder containing your Earth Engine JavaScripts, 
js_dir = 'C:\SDR\code\js'

# Convert all Earth Engine JavaScripts in a folder recursively to Python scripts.
js_to_python_dir(in_dir=js_dir, out_dir=js_dir, use_qgis=True)
print("Python scripts saved at: {}".format(js_dir))
