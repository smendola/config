#!/bin/sh
host=${1:-10.0.0.1}
cat > .$$.sql << EOF
drop database AccessControl
GO
drop database Logging
GO
drop database Template
GO
drop database FileStorage
GO
EOF

sqlcmd -S$host -Usa -Ppassword -i.$$.sql
rm .$$.sql