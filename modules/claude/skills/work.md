---
description: Start working on a task (plain instruction or GitHub issue)
argument-hint: <issue-number | instruction>
allowed-tools: TodoWrite, Task, Read, Glob, Grep, Edit, Write
---

# Work Command

Start working on a task with the mindset of a lead veteran senior software engineer who writes clean, elegant, and maintainable code.

## Variables

- `$ARGUMENTS`: Either a GitHub issue number (e.g., `123`, `#123`) or a plain text instruction describing the task

## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Recent commits: !`git log --oneline -5`

## Task Detection

Determine the type of task from `$ARGUMENTS`:

1. **GitHub Issue**: If `$ARGUMENTS` matches a number or `#number` pattern (e.g., `123`, `#456`), fetch the issue details using GitHub MCP
2. **Plain Instruction**: Otherwise, treat `$ARGUMENTS` as a direct task description

## Workflow

### Phase 1: Task Understanding

1. **For GitHub Issues:**
   - Use GitHub MCP `get_issue` to fetch issue details (owner: `MillionOnMars`, repo: `lumina5`)
   - Extract: title, description, labels, acceptance criteria
   - Identify priority from labels (P0-P3)
   - Note any linked PRs or related issues

2. **For Plain Instructions:**
   - Parse the instruction to understand the goal
   - Identify if it references existing code, features, or bugs
   - Clarify scope boundaries

3. **Create Task Breakdown:**
   - Use TodoWrite to create a structured task list
   - Break complex tasks into atomic, achievable steps
   - Include verification steps (typecheck, tests)

### Phase 2: Codebase Analysis

1. **Explore Relevant Code:**
   - Use the Explore agent to understand existing patterns
   - Identify files that need modification
   - Note existing conventions and styles
   - Understand data flow and dependencies

2. **Architecture Assessment:**
   - Review related components and their interactions
   - Identify potential impact areas
   - Note any technical debt to address (if in scope)

### Phase 3: Branch Setup

1. **Create Feature Branch:**
   - Branch naming: `type/short-description` (e.g., `fix/login-validation`, `feat/user-metrics`)
   - Types: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`
   - If from GitHub issue, include issue number: `fix/123-login-validation`

2. **Branch Command:**
   ```bash
   git checkout -b <branch-name>
   ```

### Phase 4: Implementation

Execute the implementation following these engineering principles:

## Engineering Principles

### Code Quality Standards

**Clean Code:**
- Self-documenting code with meaningful names
- Single Responsibility Principle for functions and components
- Keep functions short and focused (ideally < 20 lines)
- Avoid deep nesting; prefer early returns
- No magic numbers or strings; use named constants

**SOLID Principles:**
- **S**ingle Responsibility: One reason to change per module
- **O**pen/Closed: Open for extension, closed for modification
- **L**iskov Substitution: Subtypes must be substitutable
- **I**nterface Segregation: Prefer specific interfaces
- **D**ependency Inversion: Depend on abstractions

**DRY & KISS:**
- Don't Repeat Yourself (but avoid premature abstraction)
- Keep It Simple, Stupid (simplest solution that works)
- Three strikes rule: Abstract on third repetition

### Implementation Approach

**Think Before Coding:**
- Understand the problem fully before writing code
- Consider edge cases upfront
- Plan for error handling
- Think about testability

**Incremental Progress:**
- Make small, focused changes
- Commit logical units of work
- Verify each step before proceeding
- Update todos as you progress

**Defensive Programming:**
- Validate inputs at boundaries
- Handle errors gracefully
- Provide meaningful error messages
- Never swallow exceptions silently

### Code Style

**TypeScript:**
- Avoid `any` type; use proper typing
- Leverage type inference where clear
- Use discriminated unions for state
- Prefer `interface` for object shapes
- Use `type` for unions and complex types

**React:**
- Prefer function components with hooks
- Keep components focused and small
- Lift state only when necessary
- Memoize expensive computations
- Use proper dependency arrays in hooks

**Testing:**
- Write tests for critical paths
- Use data-testid for element selection
- Test behavior, not implementation
- Keep tests focused and readable

### Project-Specific Patterns

**Routing:** Tanstack Router (NOT Next.js router)
**UI Library:** MUI Joy (NOT Material UI)
**Theme Mode:** Use `useTheme().palette.mode` (NOT `useColorScheme().mode`)
**Styling:** Use `@mui/system` utilities (NOT @emotion directly)
**Dependencies:** Add to specific package, not root unless truly global

### Quality Gates

Before considering implementation complete:

1. **TypeScript:** Run `pnpm -r typecheck` - must pass
2. **Tests:** Run `pnpm -r test` - must pass
3. **Lint:** Run `npx lint-staged --no-stash --diff="HEAD~1"` - must pass
4. **Manual Verification:** User will test in their dev environment

## Communication Style

**Progress Updates:**
- Mark todos complete as you finish each step
- Explain significant decisions briefly
- Flag blockers or questions immediately
- Show what was done, not just what will be done

**When Stuck:**
- Explain what you tried
- Share relevant error messages
- Propose alternative approaches
- Ask targeted questions

**When Uncertain:**
- State assumptions clearly
- Ask for clarification
- Prefer safe defaults
- Document decisions

## Anti-Patterns to Avoid

- Over-engineering or premature optimization
- Adding features not explicitly requested
- Ignoring existing patterns in the codebase
- Making sweeping changes when surgical fixes suffice
- Committing untested code
- Leaving console.log statements
- Creating unnecessary abstractions
- Adding dependencies without justification
- Modifying unrelated code
- Skipping error handling

## Instructions

1. **Parse `$ARGUMENTS`** to determine task type
2. **Fetch context** using GitHub MCP for issues or clarify plain instructions
3. **Create branch** with appropriate naming convention
4. **Use TodoWrite** to break down the task
5. **Explore codebase** to understand existing patterns
6. **Implement incrementally** following engineering principles
7. **Verify quality** by running typecheck and tests
8. **Update todos** as you progress
9. **Report completion** with summary of changes made

## Example Usage

```
/work 123
/work #456
/work Fix the login button not responding to clicks
/work Add validation to the email input field on signup form
/work Refactor the user service to use dependency injection
```

## Notes

- NEVER commit directly to main
- ALWAYS create a feature branch
- Follow Conventional Commits format
- Refer to CLAUDE.md for project-specific guidelines
- Ask for clarification when requirements are ambiguous
- The user runs their own dev server; don't start one
