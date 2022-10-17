---
servers:
%{ for name, ip in instances ~}
  -
    name        : "${replace(name, "-","_")}"
    username    : "${usernames[name]}"
    password    : "${passwords[name]}"
    ip          : ${ip}
    port        : ${port}
%{ endfor ~}
