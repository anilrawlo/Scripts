 #!/bin/bash

# Email configuration
recipient="your_email@example.com"
subject_success="Service is reachable"
subject_failure="Service is unreachable"
mail_body_success="The service on $remote_server:$port is reachable."
mail_body_failure="The service on $remote_server:$port is unreachable."

# Define the remote server and port
remote_server="example.com"
port="80"

# Attempt to connect using Telnet
if telnet "$remote_server" "$port" >/dev/null 2>&1; then
    echo "$mail_body_success" | mail -s "$subject_success" "$recipient"
else
    echo "$mail_body_failure" | mail -s "$subject_failure" "$recipient"
fi
