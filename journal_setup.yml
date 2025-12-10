- name: Set up Journalling and Auditing
  hosts: localhost
  gather_facts: yes
  become: yes  # Required for editing /etc files

  tasks:
    - name: Display a message
      debug:
        msg: "Starting journaling and auditing setup."

    - name: Ensure required packages are installed
      package:
        name:
          - auditd
          - audispd-plugins
        state: present

    # FIX 1: This must point to journald.conf, not the audit config
    - name: Ensure journald is configured for persistent storage
      lineinfile:
        path: /etc/systemd/journald.conf
        regexp: '^#?Storage='
        line: 'Storage=persistent'
        state: present
      notify: restart systemd-journald

    # FIX 2: This must also point to journald.conf
    - name: Tune journald max use (optional)
      lineinfile:
        path: /etc/systemd/journald.conf
        regexp: '^#?SystemMaxUse='
        line: 'SystemMaxUse=500M'
        state: present
      notify: restart systemd-journald

    - name: Deploy audit rules for sudoers changes
      copy:
        src: files/99-sudoers.rules
        dest: /etc/audit/rules.d/99-sudoers.rules
        owner: root
        group: root
        mode: '0644'
      notify: restart auditd

    # FIX 3: Updated path for Debian 11+ (audit/ instead of audisp/)
    - name: Ensure audisp syslog plugin is active
      lineinfile:
        path: /etc/audit/plugins.d/syslog.conf
        regexp: '^active = '
        line: 'active = yes'
        state: present
      notify: restart auditd

    - name: Deploy journal helper scripts
      copy:
        src: "tole_project/scripts/{{ item }}"
        dest: "/usr/local/bin/{{ item }}"
        owner: root
        group: root
        mode: '0755'
      loop:
        - journal_search.sh
        - journal_filter_services.sh
        - journal_watch_alert.sh

  handlers:
    - name: restart systemd-journald
      service:
        name: systemd-journald
        state: restarted

    - name: restart auditd
      service: # Use the service module to restart auditd
        name: auditd
        state: restarted