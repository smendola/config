#!/bin/sh

cat <<EOF > /tmp/py-libs.txt
Mako==0.9.0
PyVirtualDisplay==0.1.2
Pygments==1.6
pyodbc==3.0.6
python-dateutil==1.5
requests==0.13.9
robotframework==2.8.1
robotframework-databaselibrary==0.6
robotframework-httplibrary==0.4.0
robotframework-requests==0.2.4
robotframework-ride==1.1
robotframework-selenium2library==1.3.0
selenium==2.28.0
EOF


# Attempting to install the whole batch at once rolls back everything
# if any part of it fails; so do it one by one instead
for f in $(cat /tmp/py-libs.txt)
do
  echo Installing $f...
  pip install "$f" -U -q || echo -e "\e[31m*** FAILED TO INSTALL $f ***\e[0m"
done
