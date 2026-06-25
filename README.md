# Lab 2 – Automation, Scripting & Immutable Infrastructure
**Name:** Althea Barbato

This builds on the same server from Lab 1 (`webserver01`, Oracle Cloud, Ubuntu 20.04 LTS, `163.192.117.50`). It automates the setup two ways: plain Bash scripts that do the work directly, and Ansible playbooks that do the same thing in a repeatable, idempotent way.

## Layout

```
lab2-iac/
├── scripts/                  standalone bash automation, no Ansible needed
│   ├── update-system.sh
│   ├── install-packages.sh
│   ├── create-user.sh
│   ├── configure-firewall.sh
│   ├── configure-service.sh
│   ├── generate-logs.sh
│   └── run-all.sh             runs all of the above in order
├── ansible/
│   ├── inventory.ini
│   ├── site.yml               master playbook, runs the 3 below in order
│   ├── vars/main.yml
│   ├── playbooks/
│   │   ├── 01-baseline.yml    security baseline, users, firewall, cron, backups
│   │   ├── 02-webserver.yml   NGINX deployment
│   │   └── 03-monitoring.yml  Docker + containerized node_exporter
│   └── roles/
│       ├── baseline/
│       ├── webserver/
│       ├── docker/
│       └── monitoring/
├── deploy.sh                  runs the full Ansible deployment
├── verify.sh                  checks everything actually deployed correctly
├── rebuild-demo.sh            deletes stuff on purpose, then rebuilds it from code
└── docs/
    └── iac-reflection.md
```

## Running the bash scripts (manual path)

```bash
bash scripts/run-all.sh
```
Runs system update, package install, user creation, firewall config, service config, and logging setup, one script at a time, directly over SSH on the server.

## Running the Ansible automation (the actual deliverable)

```bash
bash deploy.sh --check    # dry run, shows what would change
bash deploy.sh            # actually deploys
bash verify.sh            # confirms it worked
```

`site.yml` runs three separate playbooks in order:
1. **01-baseline.yml** — packages, SSH hardening, UFW + the OS-level iptables fix, Fail2Ban, a `deployer` user, a weekly cron job for updates, a nightly cron job that backs up configs into `/var/backups/webserver01`
2. **02-webserver.yml** — installs and configures NGINX
3. **03-monitoring.yml** — installs Docker, then runs node_exporter as a container instead of a raw binary (this is the "container deployment" piece)

## Demonstrating rebuild capability

```bash
bash rebuild-demo.sh
```
This intentionally deletes the NGINX config and removes the node_exporter container, confirms they're actually gone, then reruns the playbook and shows everything comes back exactly the same — that's the immutable infrastructure idea: don't fix what's broken by hand, just rebuild it from the code.

## Notes from extending Lab 1 / the other Lab 2 project

This server already has Python 3.8 by default (Ubuntu 20.04), and current Ansible needs 3.9+. `site.yml` installs Python 3.9 automatically using the `raw` module before anything else runs, so that's handled without a manual step. There's also a hidden iptables layer on this Oracle Cloud image that sits in front of UFW — the baseline role opens every port at both layers so nothing gets silently blocked.
