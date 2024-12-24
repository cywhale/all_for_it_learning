python -c "import _multiprocessing, os, sysconfig; print(sysconfig.get_config_var('CONFIG_ARGS'))"

# check multiprocessing with correctly '--enable-shared' been setup
'--prefix=/home/odbadmin/.pyenv/versions/3.11.5' '--enable-shared' '--libdir=/.../.pyenv/versions/3.11.5/lib' 'LDFLAGS=-L/.../.pyenv/versions/3.11.5/lib -Wl,-rpath,/.../.pyenv/versions/3.11.5/lib' 'CPPFLAGS=-I/.../.pyenv/versions/3.11.5/include'

# Use Editable Install, will allow you to reflect the changes you make in your local development code without reinstalling the package:
pip install -e .

# A conventional project structure
"
my_project/
├── my_app/
│   ├── __init__.py
│   ├── main.py
│   ├── src/
│   │   ├── __init__.py
│   │   ├── utils.py
│   │   ├── plot.py
├── tests/
│   ├── __init__.py
│   ├── test_app.py
├── setup.py
├── pytest.ini
"
# Use pipenv to solve ./requirements.txt cannot be upgraded to latest version automatically problem
pipenv install -r ./requirements.txt 
pipenv update
pipreqs --force ./ #then I can keep a minmum man-written requirements.txt, not lots of dependency
pipenv install #if you already have Pipfile and want to use it to install
# But somtimes Lockfile stuck, and need
PIP_NO_CACHE_DIR=off pipenv install

# test environment for testing package install
pyenv virtualenv 3.11.3 test-env-3.11
# list
pyenv virtualenvs
pyenv activate test-env-3.11
pyenv deactivate

# Trouble solution
# Numpy version conflict:  Installing collected packages: numpy
#  Attempting uninstall: numpy
#    Found existing installation: numpy None
# error: uninstall-no-record-fileCannot uninstall packaging None
# ╰─> The package's contents are unknown: no RECORD file was found for packaging.
# Solution: follow this: 
# https://stackoverflow.com/questions/68886239/cannot-uninstall-numpy-1-21-2-record-file-not-found
# Find your site-packages folder.

SITE_PACKAGES_FOLDER=$(python3 -c "import sysconfig; print(sysconfig.get_paths()['purelib'])")
echo $SITE_PACKAGES_FOLDER
# Check for extraneous numpy packages from your site-packages folder.

ls $SITE_PACKAGES_FOLDER/numpy*
# Trash extraneous packages.

pip install trash-cli
trash-put $SITE_PACKAGES_FOLDER/numpy*
# Reinstall numpy.
pip install --upgrade numpy
