# Section Prompt Plan: PE IC Memo

This plan documents which GraphRAG prompt to use for each IC memo section and how the result should be used. The catalogue source of truth is `question-catalogue.json`.

## Retrieval Roles

Use the three retrieval methods for different jobs:

- **Global Search**: section-level synthesis across communities. Use for the first draft of each memo section.
- **Local Search**: source-backed facts and citations. Use to validate names, numbers, transaction facts, and company-specific claims.
- **DRIFT Search**: second-pass challenge and discovery. Use to surface adjacent risks, missing diligence, and non-obvious connected questions. Do not use DRIFT as the primary full-memo generator unless latency is acceptable.

## Output Rules

Every section should separate:

- **Evidence-backed claims**: claims directly supported by GraphRAG context references.
- **Assumptions**: plausible underwriting logic not proven by the public corpus.
- **Diligence gaps**: facts required before IC approval.

Do not convert a diligence gap into a confident claim. Do not invent financial metrics.

## Section Prompts

### 1. Executive Summary

**Objective**: State the recommendation, investment thesis, main risks, and required next diligence.

**Global Search**

```text
What are the main investment merits, risks, and open questions for a Forterro-style European industrial ERP software platform?
```

Use for the initial thesis, key positives, key negatives, and conditional recommendation framing.

**Local Search**

```text
Find source-backed facts about Forterro, its owner, customer base, product category, valuation marker, and value creation plan.
```

Use to validate named parties, transaction context, product category, customer scale, and valuation markers.

**DRIFT Search**

```text
Draft an IC executive summary for a Forterro-style investment using only retrieved evidence and clearly label unresolved diligence gaps.
```

Use as a challenger pass: compare its highlighted gaps against the Global draft.

### 2. Transaction Overview

**Objective**: Explain the transaction, parties, timing, perimeter, and strategic rationale.

**Global Search**

```text
Summarize the transaction context and strategic rationale around Partners Group and Forterro.
```

Use for the deal narrative and strategic rationale.

**Local Search**

```text
Find facts about acquisition timing, seller, buyer, enterprise value, financing, and regulatory context.
```

Use to validate buyer, seller, enterprise value, EU review, and any missing deal terms.

**DRIFT Search**

```text
Draft the transaction overview section with cited evidence and missing deal terms.
```

Use to surface missing transaction terms such as leverage, management rollover, fees, and ownership perimeter.

### 3. Business Model

**Objective**: Describe products, customers, revenue model, retention drivers, and mission criticality.

**Global Search**

```text
What business model characteristics make industrial ERP software attractive or risky?
```

Use for generic vertical software attractiveness and risk framing.

**Local Search**

```text
Find evidence on Forterro products, ERP brands, industrial mid-market customers, subscription/cloud readiness, and customer base.
```

Use for Forterro-specific product, customer, and platform facts.

**DRIFT Search**

```text
Draft the business model section and separate evidence-backed claims from assumptions.
```

Use to challenge whether recurrence, retention, and mission criticality are evidenced or only assumed.

### 4. Market

**Objective**: Assess market size, growth, structural tailwinds, cyclicality, and geographic exposure.

**Global Search**

```text
What are the key market trends for private equity and European industrial ERP software?
```

Use for broader PE cycle, digitization, Europe, and industrial SMB context.

**Local Search**

```text
Find evidence on digitization, industrial SMB ERP demand, Europe exposure, and private equity market conditions.
```

Use to ground market claims in source-backed facts.

**DRIFT Search**

```text
Draft the market section for an IC memo and flag unsupported market-sizing assumptions.
```

Use to identify missing TAM, growth rate, country mix, and cyclicality evidence.

### 5. Competitive Position

**Objective**: Evaluate differentiation, fragmentation, substitutes, and defensibility.

**Global Search**

```text
What competitive advantages and threats are visible for vertical industrial ERP platforms?
```

Use for category-level competitive dynamics.

**Local Search**

```text
Find facts about Forterro's brand portfolio, local market reach, customer base, and manufacturing subsectors.
```

Use for Forterro-specific defensibility evidence.

**DRIFT Search**

```text
Draft the competitive positioning section with strengths, threats, and diligence gaps.
```

Use to surface missing competitor list, win/loss data, churn by competitor, and product-depth checks.

### 6. Financial Profile

**Objective**: Summarize known financial indicators and identify missing metrics.

**Global Search**

```text
What financial profile should an IC memo test for a vertical software platform?
```

Use for the expected underwriting framework.

**Local Search**

```text
Find available evidence on valuation, customer count, revenue model, growth, and profitability indicators.
```

Use to validate public facts such as transaction value, revenue scale, customer count, and growth statements.

**DRIFT Search**

```text
Draft the financial profile section using available evidence and a clear missing-data checklist.
```

Use to produce the missing-data checklist. This section should be especially conservative.

### 7. Value Creation

**Objective**: Identify organic, inorganic, operational, and product-led value creation levers.

**Global Search**

```text
What value creation levers matter for private equity-owned vertical software businesses?
```

Use for general value-creation playbook context.

**Local Search**

```text
Find evidence on Forterro go-to-market initiatives, strategic acquisitions, cloud offerings, and operational efficiency.
```

Use for Forterro-specific initiatives and sponsor plan evidence.

**DRIFT Search**

```text
Draft a value creation plan section with initiatives, evidence, KPIs, and diligence questions.
```

Use to add KPI and workstream questions: owner, baseline, cost, timing, and proof of delivery.

### 8. Risks

**Objective**: Describe commercial, technology, execution, financing, and exit risks.

**Global Search**

```text
What risk themes should an IC memo cover for a software platform investment in the current PE environment?
```

Use for broad risk taxonomy and current-market framing.

**Local Search**

```text
Find evidence on market risks, execution risks, competition, valuation discipline, liquidity, and exit conditions.
```

Use to validate risk claims from the corpus.

**DRIFT Search**

```text
Draft a risk section with mitigants and open diligence items.
```

Use to identify adjacent risks and mitigants that may not appear in the first draft.

### 9. ESG and Responsible Investment

**Objective**: Identify relevant ESG considerations and data gaps.

**Global Search**

```text
What ESG considerations are relevant for a European industrial software platform and its sponsor?
```

Use for responsible-investment framing.

**Local Search**

```text
Find sponsor ESG approach, company footprint, customer sectors, and governance indicators.
```

Use for source-backed sponsor/company ESG evidence.

**DRIFT Search**

```text
Draft the ESG section with available evidence and missing checks.
```

Use to identify missing privacy, cyber, employee, emissions, governance, supplier, and regulatory checks.

### 10. Recommendation and Diligence Plan

**Objective**: Convert evidence into a conditional recommendation and next-step diligence agenda.

**Global Search**

```text
Based on the corpus, what should the committee decide and what diligence remains?
```

Use for the provisional recommendation and overall decision posture.

**Local Search**

```text
Find the strongest evidence for and against proceeding with a Forterro-style investment.
```

Use to balance positives and negatives with source-backed support.

**DRIFT Search**

```text
Draft the recommendation section with conditions to proceed, required evidence, and workplan.
```

Use to build the final diligence workplan and conditions to proceed.

## Suggested Generation Sequence

1. Run all Global prompts and assemble the initial memo.
2. Run all Local prompts and insert or correct citations and factual claims.
3. Run DRIFT prompts only for sections where the draft feels thin, too generic, or underchallenged.
4. Finish with the Recommendation and Diligence Plan section after all other sections are drafted.
