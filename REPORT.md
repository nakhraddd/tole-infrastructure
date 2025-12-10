**Full Name:** YOUR_FULL_NAME
**Group:** YOUR_GROUP
**Educational Program:** YOUR_PROGRAM

**Name:** Journalling and Audit Setup
**Topic:** Systemd Journald, auditd integration and tooling
**Target:** Configure system to persist and watch system journal and audit critical events
**Tasks:** Set up journalling, create helper scripts, add audit rules to watch sudoers

---

1. Task fulfillment (step-by-step)

- **Step 1 — Playbook preparation**: The Ansible playbook `journal_setup.yml` installs `auditd` and `audispd-plugins`, configures `journald` for persistent storage and deploys an audit rule file to `/etc/audit/rules.d/99-sudoers.rules`.

- **Step 2 — Audit rules**: The file `files/99-sudoers.rules` contains watches for `/etc/sudoers` and `/etc/sudoers.d` with key `sudoers_change` so any write/attribute change generates an audit record.

- **Step 3 — Audisp syslog plugin**: The playbook activates the audisp syslog plugin so audit events are forwarded to syslog/journal.

- **Step 4 — Helper scripts**: Three scripts were added into `tole_project/scripts/` and the playbook copies them to `/usr/local/bin/`:
  - `journal_search.sh` — quick pattern search in the journal
  - `journal_filter_services.sh` — filter logs by systemd unit(s)
  - `journal_watch_alert.sh` — continuous watcher that writes alerts via `logger`

- **Step 5 — Restart services**: The playbook restarts `systemd-journald` and `auditd` handlers when config files are changed.

2. How to run (Google Cloud VM)

On your Google Cloud VM (Debian/Ubuntu/RHEL), copy this repo, then run:

```powershell
# From your VM (Linux shell commands shown here):
ansible-playbook -i 'localhost,' -c local journal_setup.yml --become
```

Notes:
- Ensure Python and Ansible are installed on the control host/VM.
- If running from a different machine, adjust `-i` inventory accordingly.

3. Verification steps and screenshots

- After running the playbook, verify journald storage:

```bash
grep -E '^Storage=' /etc/systemd/journald.conf || journalctl --disk-usage
journalctl --verify
```

- Verify audit rules:

```bash
sudo auditctl -l | grep sudoers
sudo ausearch -k sudoers_change
```

- Example screenshot steps (do on the VM and include images in final report): take screenshots of `journalctl -xe`, `sudo ausearch -k sudoers_change` and `ls -l /usr/local/bin | grep journal`.

4. Short conclusions

Summarize what you learned (example): journald persistent storage ensures logs survive reboots; auditd provides kernel-level auditing for sensitive files; forwarding audit events to syslog/journal centralizes event monitoring; small scripts help quickly inspect and monitor logs for incidents.

---

Repository link:

- Add the repository URL here after pushing: `https://github.com/YOUR_ACCOUNT/tole-infrastructure`

Conversion to required format:

- To produce a final document in 14pt Times New Roman with bold headers, open this `REPORT.md` in LibreOffice or Word, set font and spacing, then export to PDF/DOCX for submission.
