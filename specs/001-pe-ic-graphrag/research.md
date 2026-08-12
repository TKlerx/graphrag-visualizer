# Research: PE IC GraphRAG Showcase

## Decision: Use Microsoft GraphRAG artifacts as the primary demo substrate

**Rationale**: The existing app is purpose-built for Microsoft GraphRAG parquet artifacts. This gives the fastest path to a credible retrieval and explainability demo.

**Alternatives considered**: Neo4j GraphRAG would be useful for a production graph backend, but it would add a second data model and delay the visualizer demo.

## Decision: Add DRIFT as a third API retrieval mode

**Rationale**: DRIFT is a strong fit for IC drafting because it combines local factual grounding with broader community context.

**Alternatives considered**: Adding only Basic Search would be simpler, but it would not demonstrate the richer local-plus-community retrieval story.

## Decision: Store corpus documents locally but keep them out of git

**Rationale**: Public reports and pages can be used for a demo, but many are third-party copyrighted documents. The repo should keep only source manifests, scripts, and generated templates.

**Alternatives considered**: Committing copied PDFs would make setup easier but creates avoidable licensing and repository bloat risk.

## Decision: Generate Markdown IC memo first

**Rationale**: Markdown is easy to inspect, diff, cite, and evolve into Word or slides later.

**Alternatives considered**: Word output is closer to committee workflow, but it would add layout/template complexity before the retrieval workflow is proven.
