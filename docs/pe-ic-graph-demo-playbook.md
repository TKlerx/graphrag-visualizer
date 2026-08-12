# PE IC GraphRAG Demo Playbook

## Demo Goal

Show how a GraphRAG-backed knowledge layer can help an investment team move from source documents to a structured IC view: target profile, comparable context, value creation, risks, and diligence gaps.

The story is not "the graph has all answers." The story is:

> GraphRAG gives the investment team a structured memory that produces evidence-backed first drafts and makes missing evidence visible.

## Setup

Start the API if it is not already running:

```powershell
.\demo\scripts\start-graphrag-api.ps1
```

Check it:

```powershell
Invoke-RestMethod http://localhost:8000/status
```

Start the UI:

```powershell
pnpm start
```

Open:

```text
http://localhost:3000/graphrag-visualizer/
```

Use the graph:

```text
Forterro + proALPHA
```

Use Local Search for the live demo unless DRIFT has been tested immediately before the meeting. Local is the safest live mode.

## Opening Talk Track

"This is a public-source proxy for how Partners Group could combine internal investment knowledge, prior diligence, portfolio-company context, and current market data into a retrieval layer for IC preparation. Forterro represents existing sponsor/portfolio knowledge. proALPHA represents a new potential investment target in a related ERP software theme."

"The graph is not the final memo. It is the extracted map: companies, sponsors, products, markets, customer segments, risks, value creation levers, and relationships. The retrieval layer then turns that map into IC-relevant answers."

## Act 1: Show The Knowledge Base

1. On the upload/data screen, select `Forterro + proALPHA`.
2. Open the graph view.
3. Zoom out briefly to show density.
4. Explain that the graph contains public proxy material, not confidential Partners Group documents.

Talk track:

"In a real deployment, these public documents would be joined with internal IC papers, management notes, sector theses, operating partner playbooks, prior investment reviews, and current market data."

## Act 2: Click The Anchor Nodes

Use graph search if a node is hard to find visually. Click nodes in this order.

### 1. `PARTNERS GROUP`

Why click it:

- Establishes the sponsor context.
- Shows the graph is not only about the target company.
- Links the workflow to Partners Group's private markets platform and prior ownership context.

Talk track:

"Partners Group is the sponsor context. In a real setup, this would connect to the firm's historical investment knowledge, sector theses, and portfolio operating experience."

### 2. `FORTERRO`

Why click it:

- Represents existing PG-relevant portfolio knowledge.
- Shows the comparable industrial ERP asset.
- Useful for explaining why Forterro is not the target, but a knowledge anchor.

Talk track:

"Forterro is the existing knowledge anchor: a pan-European industrial ERP platform acquired by Partners Group. We use it to frame what the team already knows about this software category."

### 3. `PROALPHA GROUP`

Why click it:

- Introduces the hypothetical target.
- The node has strong degree and links to ERP, customers, acquisitions, and sponsors.

Talk track:

"proALPHA is the target-style asset we are evaluating. The graph connects it to ERP software, DACH mid-market customers, sponsor history, acquisitions, and product-roadmap themes."

### 4. `ENTERPRISE RESOURCE PLANNING SOFTWARE`

Why click it:

- Shows the common category connecting Forterro and proALPHA.
- Moves the discussion from company facts to the investment theme.

Talk track:

"ERP is the thematic bridge. It is mission-critical software for industrial companies, so the investment question becomes: where is the stickiness, where is the growth, and what must be proven?"

### 5. `OPERATIONAL VALUE CREATION`

Why click it:

- Connects the company graph to the PE market backdrop.
- Shows the system can combine target-specific context with current PE themes.

Talk track:

"The market backdrop matters. In today's PE environment, the memo cannot rely on multiple expansion. It needs an operational value creation case."

### 6. Optional proALPHA Detail Nodes

Click one or two only if time allows:

- `BREGAL UNTERNEHMERKAPITAL`
- `INTERMEDIATE CAPITAL GROUP (ICG)`
- `PROALPHA ERP RELEASE 9.5`
- `GEDYS INTRAWARE GMBH`
- `PERSIS GMBH`
- `DACH ERP MARKET`
- `MEDIUM-SIZED MANUFACTURING AND TRADING COMPANIES`

Talk track:

"These nodes show why the system is useful for diligence navigation: it separates ownership history, product roadmap, add-on M&A, market, and customer segment instead of flattening everything into one paragraph."

## Act 3: Show Graph Switching

Switch from:

```text
Forterro + proALPHA
```

to:

```text
Forterro Only
```

Then switch back.

Talk track:

"This is useful when new diligence material arrives. We can compare the knowledge base before and after adding the target. The visual graph changes, and the search API now queries the selected graph as well."

Do not spend too long here. The point is versioning and before/after knowledge, not graph aesthetics.

## Act 4: Run Live Queries

Use `Local Search` first.

### Query 1: Target Profile

```text
What is proALPHA and why could it be relevant for a private equity investment committee?
```

What to point out:

- ERP/ERP+ platform
- industrial SME and mid-market focus
- scale indicators
- sponsor history
- buy-and-build angle
- evidence references

Talk track:

"This is a target profile paragraph. It is already closer to IC language than a generic web search answer because the prompt and graph are tuned for PE diligence."

### Query 2: Comparable Context

```text
Compare Forterro and proALPHA as ERP software assets from a private equity perspective.
```

What to point out:

- proALPHA as focused DACH ERP+ compounder
- Forterro as broader pan-European consolidation platform
- shared ERP strengths
- different underwriting profiles

Talk track:

"This is where the graph helps: it connects a new target to existing platform knowledge and turns the comparison into an underwriting frame."

### Query 3: Value Creation

```text
What are the main value creation levers for proALPHA from a private equity perspective?
```

What to point out:

- cross-sell into installed base
- ERP+ suite expansion
- add-on M&A
- AI/cloud/product innovation
- geographic expansion
- operational EBITDA growth, subject to validation

Talk track:

"This becomes the value creation page of the memo. The important caveat is that margin expansion remains a hypothesis until financial diligence validates it."

### Query 4: Risks

```text
What risks or diligence gaps should an investment committee consider for proALPHA?
```

What to point out:

- acquisition integration risk
- ERP+ coherence versus complexity
- retention/churn
- earnings quality
- roadmap execution
- cyber and operational resilience
- governance and sponsor alignment

Talk track:

"Good IC support should not only produce a thesis. It should challenge the thesis."

### Query 5: Diligence Gaps In The Comparison

```text
What diligence gaps remain before an investment committee could rely on this Forterro versus proALPHA comparison?
```

What to point out:

- asymmetric source depth
- Forterro source inconsistency around customer/employee counts
- regulatory evidence versus underwriting evidence
- missing harmonized financials
- missing retention/cloud/SaaS metrics
- missing valuation and downside-case framework

Talk track:

"This is the most important answer. The system does not just generate a confident comparison. It tells us where the evidence is not yet decision-grade."

## Act 5: Show The Memo Artifact

Open the generated proALPHA memo:

```text
demo/ic-memo/generated/proalpha-public-proxy-ic-memo.md
```

Optional PDF:

```text
output/pdf/proalpha-public-proxy-ic-memo.pdf
```

Talk track:

"The live queries are not the whole workflow. We can run a reusable IC question catalogue section by section and assemble a Markdown memo with evidence-backed claims, assumptions, and open diligence gaps separated."

Show these sections:

- Executive Summary
- Business Model
- Value Creation
- Risks
- Diligence Workplan

## Act 6: Show The Question Catalogue

Open:

```text
demo/ic-memo/question-catalogue.json
```

Talk track:

"The point is repeatability. For every target, the team can ask a standard catalogue of IC questions: business model, market, competition, financial profile, value creation, ESG, risks, and recommendation."

"That catalogue can be adapted to Partners Group's actual IC template and diligence standards."

## Closing Talk Track

"The demo is intentionally based on public proxy data. The current graph can produce a useful first pass, but it is not decision-grade because it lacks private financials, customer cohorts, retention, product-level revenue, cloud metrics, management input, and valuation materials."

"The production value comes from adding Partners Group's internal memory: prior IC papers, sector theses, operating partner notes, portfolio-company learnings, market reports, and current target diligence. Then the system becomes a reusable IC preparation assistant, not a one-off chatbot."

## Backup Plan If Live Search Is Slow

If Local Search is slow or the API is unavailable, do not troubleshoot live. Use the prepared answers and memo.

Open:

```text
demo/ic-memo/generated/proalpha-retrieval/
demo/ic-memo/generated/v2-retrieval/
demo/ic-memo/generated/proalpha-public-proxy-query-log.md
demo/ic-memo/generated/forterro-public-proxy-v2-query-log.md
```

Say:

"For demo reliability, I have the same retrieval outputs pre-generated. These are the exact prompts used against the graph."

## What Not To Overclaim

- Do not say this replaces investment judgment.
- Do not say the current public corpus is decision-grade.
- Do not claim Forterro and proALPHA financials are comparable without private diligence.
- Do not rely on DRIFT live unless tested shortly before the session.
- Do not hide evidence gaps. Make them the point.

## Best One-Minute Summary

"We start with documents, extract a graph of companies, markets, products, sponsors, risks, and value creation levers, then query that graph with IC-specific prompts. For proALPHA, the system creates a target profile, compares it with Forterro, drafts a value creation thesis, and identifies diligence gaps. The key benefit is not automatic decision-making; it is faster, more consistent IC preparation with evidence and gaps visible from the start."
