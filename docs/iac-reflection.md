# Infrastructure-as-Code Reflection
**Name:** Althea Barbato

## Benefits of automation

The biggest difference between this lab and Lab 1 is what happens when I run the setup a second time. In Lab 1, the bash script just executed every command top to bottom — if I ran it again it would try to create the same user again, rewrite files that were already correct, and restart services that didn't need restarting. With Ansible, running the exact same playbook against a server that's already configured reports zero changes, because every task checks the current state first. That's the real value of automation here: it's not just "doing the same thing faster," it's doing it in a way where the result is predictable no matter how many times you run it or who runs it.

It also means the setup isn't locked in my head or in a one-time terminal session anymore. Anyone with the repo and the right credentials could deploy an identical server from scratch by running `deploy.sh`. That's a different kind of administration than manually SSHing in and remembering what you did last time.

## Operational scalability

Right now this is all aimed at one server, but nothing about the structure assumes that. The roles don't hardcode the IP or hostname anywhere — those live in `vars/main.yml`, and the inventory file is the only place that actually points at `163.192.117.50`. If I had ten servers instead of one, I'd add nine more lines to the inventory and the same playbook would configure all of them the same way. Doing that by hand with bash scripts would mean either running the script ten separate times (and hoping I didn't typo anything differently each time) or writing increasingly complicated loops into the bash script itself. Ansible's whole inventory/role model is built around that problem already.

## Security implications

Automating security configuration means it actually happens consistently, which is the main upside. The SSH hardening, the firewall rules, and the Fail2Ban setup all get applied identically every time, instead of being something I might forget a step of if I were doing it manually under time pressure. The baseline role also runs first, before anything else, on every single run — there's never a window where a fresh server is reachable without the firewall and SSH hardening already in place, the same principle from my Lab 1 reflection but now enforced by the structure of the playbook instead of by me remembering to do things in order.

The downside is that automation also means a mistake gets applied consistently too. If I get a firewall rule wrong, it's wrong on every server I run this against, instantly, instead of being a one-off typo on one machine. That's part of why I added a `--check` dry-run option to `deploy.sh` — being able to see what would change before it actually changes matters more once a single script can affect many machines at once, not just one.

## Risks of configuration drift

Configuration drift is what happens when a server's actual state slowly stops matching what's in the code, usually because someone made a manual fix during an emergency and never went back to update the source of truth. I actually hit a real example of this while building the automation in my other Lab 2 project: I had manually added iptables rules on this exact server back in Lab 1 to get ports 80 and 443 working, and that fix lived only on the server, not anywhere in code. When I came back later and opened a new port through Ansible, the server's actual firewall behavior didn't match what UFW or the playbook thought was true, because of that undocumented manual change. The fix wasn't to patch around it manually again — it was to bring that iptables rule into the baseline role itself, so it's no longer drift, it's part of the defined state.

That's the core risk with drift: it's invisible until something breaks, and by the time it breaks, nobody necessarily remembers why the server is configured the way it is.

## Immutable infrastructure concepts

True immutable infrastructure usually means you never patch a running server at all — if something needs to change, you build a brand new server from the same code and replace the old one, rather than editing it in place. I'm not doing that literally here, since I'm reusing the same Oracle Cloud instance across labs, but the playbooks are written with that mindset: every piece of configuration is defined in code, and `rebuild-demo.sh` proves that if I deleted the NGINX config and the monitoring container entirely, rerunning the playbook puts everything back exactly as it was, without me manually intervening or remembering any specific steps. That's the practical core of immutability even without literally destroying and recreating the VM: the server's state is fully described by the code, not by its history of whatever commands happened to be run on it.

The honest gap is that the server's underlying OS and initial cloud setup still came from manual steps back in Lab 1. A fully immutable setup would also automate the VM provisioning itself, not just what happens after it boots — that would be the next real step if I were taking this further.
