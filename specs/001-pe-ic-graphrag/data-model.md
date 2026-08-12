# Data Model: PE IC GraphRAG Showcase

## RetrievalMode

- `local`: Uses precise local context and source chunks.
- `global`: Uses community-level summaries and broad themes.
- `drift`: Uses local search expanded with community context.

## GraphRAGArtifact

- `fileName`: Expected parquet name.
- `schema`: One of entity, relationship, document, text unit, community, community report, covariate.
- `optionalFields`: Fields that may be absent or null in current GraphRAG outputs.

## CorpusSource

- `id`: Stable source identifier.
- `title`: Human-readable source title.
- `category`: Sponsor, target company, regulatory, market context, or methodology.
- `url`: Public source URL.
- `localFileName`: Suggested local output name.
- `demoUse`: Why the source is useful for the IC showcase.

## ICQuestion

- `section`: Memo section.
- `objective`: What the section must establish.
- `globalPrompt`: Broad synthesis query.
- `localPrompt`: Evidence-seeking query.
- `driftPrompt`: Drafting query with local plus community context.
- `evidenceExpectations`: Facts, entities, or relationships required before making claims.
- `gapChecks`: Missing information that should remain explicit.

## ICMemoSection

- `title`: Section title.
- `draft`: Evidence-backed draft text.
- `evidence`: References to retrieved source/context items.
- `assumptions`: Claims that require validation.
- `openDiligenceGaps`: Questions that remain unresolved.
