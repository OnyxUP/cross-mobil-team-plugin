---
name: aso-keyword-research
description: This skill should be used when researching iOS App Store keywords, analyzing competitor listings, or drafting title/subtitle/keyword-field copy within Apple's character limits.
version: 0.1.0
---

# iOS App Store Optimization (ASO)

## Apple's Field Constraints

- **Title**: 30 characters max — highest keyword weight, should include the single most important term.
- **Subtitle**: 30 characters max — second-highest weight, complements the title with different keywords.
- **Keyword field**: 100 characters max, comma-separated, no spaces after commas needed, **do not repeat words already used in title or subtitle** (wastes the limited budget).
- Keywords are case-insensitive and singular/plural forms are typically treated as related — don't burn characters on both forms of the same word.

## Research Method

1. Identify the app's core value proposition and 3-5 primary category terms.
2. Expand into a candidate list: category terms, feature terms, problem/solution phrasing users search for, and branded competitor terms (where legally/policy safe).
3. Search for each candidate's competitive landscape (how many apps target it, what ranks) via web search — prioritize terms with a good relevance-to-competition ratio over pure high-volume terms that are impossible to rank for as a new/small app.
4. Cross-check top 5-10 competitor listings: what's in their title/subtitle, what they seem to target in the keyword field (visible via their positioning even if the field itself is private).

## Prioritization

Favor:
- Terms directly describing what the app does over vague brand-y language.
- Long-tail, specific phrases when the category is crowded.
- Terms not already covered by title/subtitle, to maximize the keyword field's unique coverage.

Avoid:
- Keyword stuffing that reads as spam if it ever surfaces in review context.
- Trademarked competitor names unless there's explicit legal clearance.

## Output

Always show exact character counts for proposed title/subtitle so they're verifiably within Apple's limits, and present the keyword field as the actual comma-separated string a person would paste into App Store Connect.
