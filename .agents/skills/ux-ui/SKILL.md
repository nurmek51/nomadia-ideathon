---
name: editorial-brutalism
description: Disciplined editorial-brutalist product UI for serious web apps, with strong typography, hard structure, and memorable board-centric presentation.
license: MIT
metadata:
  author: typeui.sh
---

<!-- TYPEUI_SH_MANAGED_START -->
# Editorial Brutalism Design System Skill

## Mission

Create practical, implementation-ready guidance for product interfaces that need a sharp, confident identity without falling into AI-generated dashboard cliches.

## Brand

a serious, competitive, editorial-brutalist style built for product UIs: assertive typography, visible structure, hard edges, restrained color, and a strong sense of hierarchy that feels closer to a tournament bulletin than a startup template

## Style Foundations

- Visual style: bold, disciplined, product-first
- Typography scale: expressive display with compact body copy | Fonts: primary=Darker Grotesque, display=Darker Grotesque, mono=JetBrains Mono | weights=300, 400, 500, 600, 700, 800
- Color palette: primary, secondary, neutral, success, warning, danger | Tokens: primary=#d85c41, secondary=#b88b2f, neutral=#191512, surface=#f3efe6, text=#16120f, success=#2e7d4f, warning=#b56b1f, danger=#a63d2f
- Spacing scale: 4/8/12/16/24/32/48
- Border radius: 0/4/8 only
- Borders: 1px and 2px solid only; use borders for hierarchy before shadows
- Shadows: minimal and structural; never soft, decorative, or floating

## Product Fit

This system is best for interfaces that must feel credible, competitive, and memorable:

- strategy tools
- premium dashboards
- creative productivity products
- editorial commerce
- chess, cards, and tournament-style products

It is not for playful consumer toys, doodle-heavy brands, or soft lifestyle aesthetics.

## Accessibility

WCAG 2.2 AA, keyboard-first interactions, visible focus states, strong contrast, and touch targets that remain usable on mobile

## Writing Tone

concise, direct, informed, product-specific

## Rules: Do

- prefer semantic tokens over raw values
- preserve a strict visual hierarchy with obvious headings and dense supporting copy
- use strong typography before decorative effects
- let borders, spacing, and alignment carry the design
- keep motion short, intentional, and state-driven
- make primary actions obvious without turning them into oversized pills
- keep layouts structured and legible on desktop and mobile

## Rules: Don't

- avoid low contrast text
- avoid ornamental copy or faux-premium slogans
- avoid soft gradients, glassmorphism, glow effects, and floating shells
- avoid oversized radii, pill buttons, and decorative badges
- avoid chaotic asymmetry that harms scanability
- avoid novelty that makes gameplay or product workflows harder

## Chess Product Guidance

When the product is a chess platform or similarly competitive interface:

- the board must be the visual anchor
- timers, captured pieces, evaluation summaries, and move lists must read as tournament utilities, not lifestyle widgets
- use animation to reinforce moves, captures, check states, and game-over transitions, not to decorate the layout
- premium surfaces should feel like printed match materials, lacquered wood, stone, metal, or club signage, not generic SaaS glass
- monetization UI must feel integrated into the product hierarchy, not bolted on as a marketing card

## Expected Behavior

- Start with the product context and define the interface's core tension: precision vs drama, utility vs prestige, speed vs readability.
- Build foundations first, then component rules, then page composition.
- When aesthetics and usability conflict, preserve usability and make the visual system work harder.
- Keep guidance opinionated, concise, and implementation-focused.

## Guideline Authoring Workflow

1. Restate the design intent in one sentence.
2. Define tokens, typography, spacing, borders, and motion constraints.
3. Specify layout structure before styling isolated components.
4. Define component anatomy, states, variants, and responsive behavior.
5. Include accessibility acceptance criteria and content-writing expectations.
6. Add anti-patterns and migration notes for inconsistent existing UI.
7. End with a QA checklist for implementation review.

## Required Output Structure

When generating design-system guidance, use this structure:

- Context and goals
- Design tokens and foundations
- Layout system and composition rules
- Component-level rules (anatomy, variants, states, responsive behavior)
- Accessibility requirements and testable acceptance criteria
- Content and tone standards with examples
- Anti-patterns and prohibited implementations
- QA checklist

## Layout Rules

- Use standard page sections with clear vertical rhythm; no decorative hero strips inside application shells unless the page is explicitly marketing.
- Prefer stable grids and split layouts over experimental overlap.
- Make one dominant object or region per viewport; everything else should support it.
- Keep desktop density purposeful and mobile layouts compressed but readable.
- Use max-width containers and strong alignment lines; do not center random blocks for drama.

## Component Rule Expectations

- Define required states: default, hover, focus-visible, active, disabled, loading, error.
- Describe behavior for keyboard, pointer, and touch.
- State spacing, typography, border treatment, and color-token usage explicitly.
- Include responsive behavior and edge cases such as long labels, empty states, overflow, captured content, and scoreboard compression.

## Motion Rules

- Use 120ms to 180ms transitions for most state changes.
- Use transform motion sparingly; prefer opacity, color, and position shifts that support understanding.
- Reserve larger motion moments for page entrance, piece movement, captures, and end-state transitions.
- Never use bounce, float, glow-pulse, or decorative perpetual animation.

## Quality Gates

- No rule should depend on vague adjectives alone; anchor every rule to a token, threshold, or example.
- Every accessibility statement must be testable in implementation.
- System consistency beats one-off local cleverness.
- If the interface starts to resemble a default AI dashboard, simplify and harden it.
- If brutalism starts making the product harder to use, reduce the brutality and preserve the hierarchy.

## Example Constraint Language

- Use "must" for non-negotiable rules and "should" for recommendations.
- Pair every do-rule with at least one concrete don't-example.
- If introducing a new pattern, include migration guidance for existing components.

<!-- TYPEUI_SH_MANAGED_END -->
