# CLAUDE.md — Project Rules

## Git Workflow

**Never push directly to `main`.** Always create a feature branch and open a PR.

1. Create a branch: `git checkout -b <branch-name>`
2. Commit changes on the branch
3. Push the branch: `git push -u origin <branch-name>`
4. Open a PR via `gh pr create`

Main is protected. Direct pushes are not allowed — always go through a PR.
