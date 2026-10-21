<!--
  Infrastructure as Code (Ansible) deployment for Foxnet
  Description:      Overview and usage instructions for the FoxNet Ansible deployment
  Author:           Glen Charlton
  Source:           https://github.com/bhradsky/foxnet
  License:          See LICENCE.md in repository root
  Use of AI:        Claude Opus 5.5 was used to assist the development of this code
-->

# FoxNet server provisioning (Ansible)

Provisions an **Ubuntu 24.04** host to run FoxNet headless via R/`nlrx`, with RStudio Server for browser access.

|               |                                                                          |
|---------------|--------------------------------------------------------------------------|
| **Project**   | Infrastructure as Code (Ansible) deployment for FoxNet                   |
| **Author**    | Glen Charlton                                                            |
| **Source**    | [github.com/bhradsky/foxnet](https://github.com/bhradsky/foxnet)         |
| **License**   | See [LICENCE.md](../LICENCE.md) in the repository root                   |
| **Use of AI** | Claude Opus 5.5 was used to assist the development of this code          |

| Role             | What it does |
|------------------|--------------|
| `common`         | Base packages, timezone, unattended-upgrades, `foxnet` group + researcher accounts |
| `security`       | UFW (SSH + optional RStudio CIDRs), fail2ban, sshd drop-in |
| `netlogo`        | OpenJDK 17 JRE, NetLogo 6.4.0 in `/opt/netlogo/netlogo-6.4.0` (`/opt/netlogo/current`) |
| `r`              | R from the CRAN apt repo, Posit Package Manager binaries, FoxNet R packages |
| `rstudio_server` | Posit RStudio Server on port 8787, restricted to the `foxnet` group |
| `foxnet`         | Clones this repo to `/opt/foxnet`, group-writable; sets `FOXNET_HOME`, `NETLOGO_HOME`, `JAVA_HOME` for R |

## Configuration

The inventory and variables are site-specific, so the repo ships `.example` templates. Copy each one and fill in the `[placeholders]`. Run all commands from the `ansible/` folder.

| Example file | Copy to | What to set |
|--------------|---------|-------------|
| `inventories/production/hosts.yml.example` | `hosts.yml` | Server address (`ansible_host`) and an existing sudo user to connect as (`ansible_user`) |
| `inventories/production/group_vars/foxnet/vars.yml.example` | `vars.yml` | Researcher accounts, RStudio network access, SSH password policy |
| `inventories/production/group_vars/foxnet/vault.yml.example` | `vault.yml` | One password per researcher account (encrypted with ansible-vault) |

### 1. Install Ansible collections

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
```

### 2. Hosts (`hosts.yml`)

```bash
cp inventories/production/hosts.yml.example inventories/production/hosts.yml
```

Set `ansible_host` to the server's IP or domain name, and set `ansible_user` to an account that can SSH in and use `sudo`. Check the connection:

```bash
ansible foxnet -m ping
```

### 3. Variables (`vars.yml`)

```bash
cp inventories/production/group_vars/foxnet/vars.yml.example \
   inventories/production/group_vars/foxnet/vars.yml
```

- `foxnet_users`: one entry per researcher. Each `name` must have a matching key in `vault.yml`. `ssh_keys` holds the user's public key(s), e.g. the contents of `~/.ssh/id_ed25519.pub`.
- `rstudio_allowed_cidrs`: networks allowed to reach RStudio on port 8787. Leave it as `[]` to allow access only through an SSH tunnel (see [Accessing RStudio](#accessing-rstudio)).
- `security_ssh_disable_password_auth`: leave as `false` until key-based login works for every admin, then set it to `true`.

Any other role default (`roles/<role>/defaults/main.yml`) can be overridden here too.

### 4. Secrets (`vault.yml`)

User passwords are stored as plain text in `vault.yml`, which is then encrypted with ansible-vault. The playbook hashes them, and they are used for SSH/sudo and the RStudio login.

```bash
cp inventories/production/group_vars/foxnet/vault.yml.example \
   inventories/production/group_vars/foxnet/vault.yml
# replace user1/user2 with the names from vars.yml and set real passwords
ansible-vault encrypt inventories/production/group_vars/foxnet/vault.yml
ansible-vault edit    inventories/production/group_vars/foxnet/vault.yml   # later changes
```

Never commit an unencrypted `vault.yml` or a `.vault_pass*` file.

> `vars.yml` and `vault.yml` are ignored by git (see the repository `.gitignore`), so each deployment keeps its own copies.

## Usage

```bash
ansible-playbook deploy.yml --ask-vault-pass --check --diff     # dry run
ansible-playbook deploy.yml --ask-vault-pass                    # apply
ansible-playbook deploy.yml --ask-vault-pass --tags r           # single role
ansible-playbook deploy.yml --ask-vault-pass --tags verify      # smoke test only
```

You can use `--vault-password-file .vault_password` instead of `--ask-vault-pass`. That file is ignored by git.

## Accessing RStudio

If `rstudio_allowed_cidrs` is empty, port 8787 is closed; use an SSH tunnel:

```bash
ssh -L 8787:localhost:8787 user@server   # then browse http://localhost:8787
```

## Using nlrx on the server

R sessions get these environment variables, so scripts don't need Windows paths:

```r
library(nlrx)
nl <- nl(nlversion = Sys.getenv("NETLOGO_VERSION"),
         nlpath    = Sys.getenv("NETLOGO_HOME"),
         modelpath = file.path(Sys.getenv("FOXNET_HOME"), "foxnet_model/foxnet.nlogo"),
         jvmmem    = 4096)
```
