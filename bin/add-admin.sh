#!/bin/sh
host=${1:-10.0.0.1}
cat > .$$.sql << EOF
DELETE from [dbo].[UserAccount]
WHERE username = 'admin'
GO

INSERT [dbo].[UserAccount] (
    creationDate, 
    username, email, 
    firstName, lastName,
    passwordHash, passwordHashSalt,
    status, lockOutStatus,
    failCount
) 
VALUES (
    CURRENT_TIMESTAMP,
    'admin', 'noreply@phtcorp.com',
    'System', 'Administrator',
    '36205fc92c4ac292e831058968a08aa63455b9d9', 'c0a45e7effa52161d88f03f3c8d5ffdc',
    'ACTIVE', 'NOT_LOCKED',
    0
)
	
GO

EOF

sqlcmd -S$host -Usa -Ppassword -dAccessControl -i.$$.sql
rm .$$.sql