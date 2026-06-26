# Infrastructure-as-Code Reflection
**Name:** Althea Barbato

## Benefits of automation

Main thing I noticed vs Lab 1: running the bash script twice would just redo everything, recreate users that exist, restart stuff that didn't need it. Ansible checks state first, so running it again on an already-set-up server shows zero changes. That's the actual point — not just faster, but predictable no matter how many times you run it.

Also means the setup isn't just stuck in my head from one terminal session. Anyone with the repo could rebuild this exact server from scratch.

## Operational scalability

Everything's pointed at one server right now but nothing's hardcoded to assume that. IP/hostname live in vars, inventory is the only file that actually says 163.192.117.50. Add more servers to the inventory and the same playbook just runs against all of them. Doing that with bash alone means running the script N times by hand or writing messier loops.

## Security implications

Automating it means the SSH hardening, firewall, Fail2Ban stuff actually happens the same way every time instead of me possibly skipping a step under pressure. Baseline role runs first, always, so there's never a window where the server's up without security already in place.

Downside: automate a mistake and it's wrong everywhere, instantly. That's why deploy.sh has a `--check` option — see what would change before it actually changes.

## Risks of configuration drift

Hit this for real while building this stuff — I had manually added iptables rules back in Lab 1 to get ports working, and that fix only lived on the server, not in any code. Later when I opened a new port through Ansible, UFW thought one thing and the actual firewall behavior was something else because of that old manual fix nobody wrote down. Fixed it by folding that rule into the baseline role instead of patching it again by hand. That's the risk with drift — invisible until it breaks something, and then nobody remembers why.

## Immutable infrastructure concepts

Real immutable infra means you never touch a running server, you just rebuild a new one from code and swap it in. Not doing that literally since I'm reusing the same instance across labs, but the playbooks are written that way — `rebuild-demo.sh` proves it by deleting the nginx config and the monitoring container, then rerunning the playbook and getting everything back exactly the same, no manual fixing.

Honest gap: the VM itself and the original cloud setup still came from manual steps in Lab 1. Truly immutable would mean automating that part too.
