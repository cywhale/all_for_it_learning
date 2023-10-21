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
#Use pipenv to solve ./requirements.txt cannot be upgraded to latest version automatically problem
pipenv install -r ./requirements.txt 
pipenv update
pipreqs --force ./ #then I can keep a minmum man-written requirements.txt, not lots of dependency
