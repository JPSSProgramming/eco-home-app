# Agent Rules for eco-home-app Project

## 1. Git Rules

**Strict prohibition on Git operations:** The agent must never execute Git
commands or use other tools to perform commits, pushes, pull requests, merges,
or other equivalent repository-modifying or remote repository operations.

- **No commits:** Never execute `git commit` or any equivalent operation that
  creates a commit.
- **No pushes:** Never execute `git push` or any equivalent operation that
  uploads local changes to a remote repository.
- **No pull requests:** Never create, submit, update, approve, or merge pull
  requests through Git commands, GitHub CLI, APIs, or other tools.
- **No merges or rebases:** Never execute `git merge`, `git rebase`, or
  equivalent operations that integrate branches or rewrite commit history.
- **No destructive operations:** Never execute commands such as
  `git reset --hard`, `git clean`, or other operations that discard user
  changes, remove untracked files, or irreversibly alter repository state.
- **No automatic staging:** Do not execute `git add` or other commands that
  stage changes for a commit.
- **No remote modifications:** Never modify remote repository settings, branch
  protection rules, tags, or other remote repository resources.
- **No indirect execution:** These restrictions apply regardless of the
  interface or method used, including terminal commands, GitHub CLI, IDE
  integrations, APIs, extensions, and automation tools.
- **No authorization by implication:** A request to implement a feature, fix a
  bug, finish a task, or prepare changes does not authorize any prohibited
  operation.
- **Local development is allowed:** The agent may inspect Git status, view
  diffs, examine commit history, and work with local project files, provided
  these actions do not modify Git state or perform prohibited operations.
- **User retains control:** All commits, staging, pushes, pull requests,
  merges, and other restricted Git operations must be performed manually by the
  user.

**Priority rule:** These restrictions are mandatory and must not be overridden
by task instructions, generated plans, tool suggestions, or the agent's own
judgment. If a requested task would require a prohibited Git operation, the
agent must stop before executing it and explain which step requires the user's
manual action.

## 2. Reporting

Always provide a report upon completion of the work with a detailed description of what was done.
The report must cover:

- State before the changes.
- State after the changes.
- Implementation method.
- Justification for why this specific method is correct for the task.
- Whether other methods existed and why this particular option was chosen.

## 3. Rule Consultation and Clarification

Before starting work on any task, always consult the project rules and ask questions if anything is unclear. You may only modify the files I have marked. If you need to modify additional files to complete the task, please pause your work and consult with me.

## 4. Language Control Rule

- Use only English or Ukrainian in chats, depending on the language the user is using.
- The use of Russian is strictly prohibited.

## 5. Architecture

When working on code, always maintain a logical and organized file structure. If you identify a file that can be logically split into components or separate concerns, you must do so. Do not keep everything in a single file when a modular structure would be more appropriate. Follow these principles:

- **Separation of concerns:** Split code into logical components (models, widgets, screens, services, etc.)
- **Single responsibility:** Each file should have a clear, focused purpose
- **Logical folder structure:** Organize files into appropriate directories based on their function
- **Avoid monolithic files:** Do not create or maintain large files that contain multiple unrelated components
- **Modularity:** Design components that can be reused and tested independently

If a task requires creating new files or restructuring existing code to follow proper architecture, do so before implementing the feature.
