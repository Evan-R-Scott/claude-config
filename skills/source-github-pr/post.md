# Post a review on a pull request

Read only by the caller (never the review agent), after the report has been shown. `<host>`, `<owner>/<repo>` and `<n>` come from the URL as in `SKILL.md`; add `--hostname <host>` to every `gh api` call for a host other than github.com.

## Build it, show it, ask

The report has already been shown to the user in full. Then, in this order:

1. **Pin the commit.** Re-read `headRefOid`. If it differs from the reviewed SHA, tell the user and do not continue.
2. **Check for a pending review** of the current user (`gh api --paginate repos/<owner>/<repo>/pulls/<n>/reviews`, state PENDING) and tell the user instead of creating another; stop until the user decides.
3. **Decide each finding's place.** Take the hunks of `gh pr diff` (if it fails with HTTP 406 on a large PR, use the `patch` field of `gh api --paginate repos/<owner>/<repo>/pulls/<n>/files`; if no diff is available at all, put every finding in the body) and note, per file, the new-file line numbers inside a hunk (added and context lines) and the old-file line numbers (removed and context lines). A finding whose `path:line` is in that set becomes an inline comment (`side: "RIGHT"`; a multi-line finding adds `start_line` and `start_side`, both ends inside one hunk); use `LEFT` with the old-file line only for a finding about a removed line, and only if that old-file line is in a hunk. Every other finding stays in the body. Use the new path for renamed files.
4. **Re-review:** do not post a Still-open finding again as a new inline comment. If this account's earlier comment is still there, add a reply to it (a separate `POST .../pulls/<n>/comments/<id>/replies`, top-level comments only) or list it in the body. Say Resolved in the body. A finding another reviewer already raised: say "agrees with `<login>`" (in backticks) or drop it.
5. **Write the payload** to a JSON file in the scratchpad with the Write tool (never a heredoc or `-f`: it may hold quoted PR text): `commit_id` (the reviewed SHA), `event`, `body` and `comments` (`path`, `line`, `side`, and `start_line`/`start_side` when needed, `body`). Write each reply body to its own JSON file.
6. **Show it all and ask.** Show the user exactly what will be posted: the event (`COMMENT` unless the user asks for `APPROVE` or `REQUEST_CHANGES`; a report with the verdict INCOMPLETE is never posted as an approval), the full body, every inline comment (`path`, `line`, `side`, full text) and every reply. Do not post until the user explicitly approves that content. If they want changes, change the review text only (never the code), rebuild the payload and show it again.
7. **Post, after re-checking `headRefOid` once more:**

```bash
gh api --method POST repos/<owner>/<repo>/pulls/<n>/reviews --input <payload.json>
gh api --method POST repos/<owner>/<repo>/pulls/<n>/comments/<id>/replies --input <reply.json>
```

Post one review per round, never two. If the author is the current `gh` user, GitHub refuses `APPROVE` and `REQUEST_CHANGES`: use `COMMENT`. If GitHub answers 422, show the raw error to the user and stop; do not guess which comment failed and retry blindly.

**Body:** the Summary, the Verdict, the findings that are not inline, Not verified, and the CI result. Leave out the checklist, local paths, the run directory and the `Report file:` line. A secret is shown as a short prefix and `path:line` only. Every posted text (body, inline comments, replies) follows two rules: write any `@name` (a user, a team, or code such as `@property`) in backticks so nobody is notified, and never include a secret's value. Put the evidence inside a code fence. A body over about 60000 characters (the cap is 65536) keeps the Summary, the Verdict and every finding of MEDIUM or above, and says what was left out.

**Re-review body:** open with a "Previously raised findings" section: one entry per prior finding, `**[title]** - Resolved / Still open / Not re-verified` plus one line on what was run. Then new findings.

**Finding format (body and inline, first review and re-review):**
~~~
**[SEVERITY] Short title** (`path/to/file:line`; leave the location out for an inline comment)

What is wrong and why it matters, in 1-2 sentences.

<details><summary>Evidence</summary>

```
the command and the observed result
```

</details>

Hint (optional): one line naming a direction, never code or an exact change. The author decides the fix.
~~~

No `suggestion` blocks: the review states problems, the author writes the fix.

No-issues body: `Looks good - no issues found.` followed by the CI result you collected (Pass, Fail, Pending or N/A) and the Not verified list. Never say CI is green unless it is.

