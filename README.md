# Lab 2 Automation, Scripting & Immutable Infrastructure
**Name:** Althea Barbato

Same server as Lab 1 (`webserver01`, `163.192.117.50`). Set up two ways here plain bash scripts, and Ansible playbooks that do the same stuff but idempotent.

## Layout

```
lab2-iac/
├── scripts/          bash only, no ansible
├── ansible/
│   ├── inventory.ini
│   ├── site.yml      runs everything
│   ├── vars/main.yml
│   ├── playbooks/     3 separate playbooks
│   └── roles/         baseline, webserver, docker, monitoring
├── deploy.sh
├── verify.sh
├── rebuild-demo.sh   breaks stuff on purpose then rebuilds it
└── docs/iac-reflection.md
```

## Running it

```bash
bash scripts/run-all.sh     # the manual bash version
```

```bash
bash deploy.sh --check      # dry run
bash deploy.sh              # actually deploys
bash verify.sh              # checks it worked
```

`site.yml` runs 3 playbooks: baseline (security, user, firewall, cron, backups), webserver (NGINX), monitoring (Docker + node_exporter container).

## Rebuild demo

```bash
bash rebuild-demo.sh
```
deletes the nginx config + the container, then reruns the playbook to bring it all back. that's the immutable infra part don't fix it by hand, just rebuild from the code.

## Random notes

server's python is too old for newer ansible so site.yml installs python3.9 itself first. also this oracle image has a second firewall layer hiding behind ufw, baseline role handles both of em.
