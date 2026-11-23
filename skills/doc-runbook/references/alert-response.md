# Alert-response layout

Read when the page is an **Alert response** (an alert fired, something is failing). It is not a procedure with a footnote; it changes the layout of `template.md`:

- Metadata: add the alert name and its source (monitor, dashboard link); leave out Time needed.
- Leave out section 4 (Purpose and context) and section 5 (Before you start): nobody reads prerequisites mid-incident. Put one line "Access you need" at the top of Quick checks.
- Section 6 becomes three h2 sections: **Impact and severity** (a small table: level, what it means, who to notify, when; use the team's own scale, otherwise High means users are affected now and Low means no user impact, and label an invented scale "(assumption)"), **Quick checks** (a table: check, command, what a bad result looks like, next step; it replaces section 8, Troubleshooting) and **Mitigation** (restore service before diagnosing: restart, fail over, scale or roll back; when the cause is a recent change, rolling back is the mitigation, so section 9 becomes a step here). Notify at the severity that calls for it, in parallel with the first check, not after the mitigation.
- Escalation carries a time-box: "after N minutes without improvement". Label an unsourced N "(assumption)".
- Mitigations usually change state and cannot be run safely while writing the page: source them from documentation or `--help`, tag them "(inferred, not run)", set Last tested to "not run end to end", and add to Follow-up a walk-through in staging or a game day.
