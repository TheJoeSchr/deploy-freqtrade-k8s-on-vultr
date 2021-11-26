---
servers:
%{ for name, ip in instances ~}
  -
    name        : "${replace(name, "-","_")}"
    username    : "${username}"
    password    : "${password}"
    ip          : ${ip}
    port        : ${port}
%{ endfor ~}
