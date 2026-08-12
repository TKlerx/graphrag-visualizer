# Feature Specification: PE IC GraphRAG Showcase

**Feature Branch**: `001-pe-ic-graphrag`

**Created**: 2026-06-28

**Status**: Draft

**Input**: User description: "Initialize GitHub Spec Kit, update GraphRAG Visualizer to current upstream, add DRIFT search, support Microsoft GraphRAG v2 parquet artifacts, prepare a public Forterro-style private equity corpus, and generate a Markdown investment committee memo from a reusable question catalogue."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Explore GraphRAG Retrieval Modes (Priority: P1)

A demo presenter can load Microsoft GraphRAG artifacts, inspect the graph, and run Local, Global, and DRIFT retrieval through the API search drawer.

**Why this priority**: This is the core live demo path and proves the visualizer works with current GraphRAG outputs and the retrieval API.

**Independent Test**: With GraphRAG artifacts loaded and the API server running, the presenter can open the graph, see entity limiting controls, and run all three search modes.

**Acceptance Scenarios**:

1. **Given** GraphRAG v2 parquet artifacts are available, **When** the app loads them, **Then** the graph and data tables are populated without crashing.
2. **Given** the API server is reachable and communities are loaded, **When** the presenter submits a query through Drift Search, **Then** the app calls the DRIFT retrieval endpoint and displays the response and context tables.
3. **Given** a large entity graph is loaded, **When** the presenter adjusts the Max Entities control, **Then** the graph reduces visible entities without creating broken relationship links.

---

### User Story 2 - Prepare a Public PE Demo Corpus (Priority: P2)

A demo builder can assemble a legally usable public proxy corpus that resembles Partners Group internal knowledge plus current market data for Forterro-style IC preparation.

**Why this priority**: The showcase needs realistic source material without relying on confidential investment documents.

**Independent Test**: Running the corpus preparation instructions produces local source files from public URLs while keeping downloaded third-party documents out of git.

**Acceptance Scenarios**:

1. **Given** the repo is freshly cloned, **When** the demo builder reads the corpus manifest, **Then** they can see each source, its role in the demo, and whether it should be downloaded locally.
2. **Given** the preparation script is run, **When** public URLs are reachable, **Then** raw files are saved under ignored local demo corpus folders.

---

### User Story 3 - Generate an Evidence-Guided IC Memo Draft (Priority: P3)

A demo builder can use a reusable question catalogue to query the GraphRAG index section-by-section and assemble a Markdown IC memo draft with explicit evidence references and diligence gaps.

**Why this priority**: This turns graph retrieval into the business-facing outcome Partners Group cares about: faster IC document preparation.

**Independent Test**: The question catalogue and sample memo can be reviewed without running the app, and each memo paragraph traces back to standard diligence questions and expected evidence.

**Acceptance Scenarios**:

1. **Given** the IC question catalogue, **When** a memo section is drafted, **Then** the section has standard questions, recommended retrieval mode, evidence expectations, and gap checks.
2. **Given** retrieved evidence is available, **When** the Markdown memo template is filled, **Then** evidence-backed claims, assumptions, and open diligence gaps are separated.

### Edge Cases

- API server is offline or does not expose DRIFT search.
- GraphRAG artifacts are partial, missing optional tables, or contain null optional fields.
- Entity limiting removes nodes referenced by text-unit, community, or covariate relationships.
- Public corpus URLs are unavailable or block download.
- A memo section has insufficient retrieved evidence and must show a gap instead of inventing a claim.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST support Local, Global, and DRIFT retrieval actions from the API search drawer.
- **FR-002**: The app MUST call `/search/drift` when DRIFT retrieval is selected.
- **FR-003**: The app MUST enable DRIFT retrieval only when community context is available.
- **FR-004**: The app MUST keep existing Local and Global search behavior intact.
- **FR-005**: The app MUST support both current unprefixed GraphRAG parquet file names and legacy `create_final_` prefixed file names.
- **FR-006**: The app MUST tolerate missing or null optional parquet fields without throwing runtime conversion errors.
- **FR-007**: The graph builder MUST avoid creating links whose source or target node is absent.
- **FR-008**: The repo MUST document expected placement of GraphRAG parquet artifacts under `public/artifacts/`.
- **FR-009**: The repo MUST include a public Forterro-style corpus manifest with source URLs and demo purpose for each source.
- **FR-010**: The repo MUST include a local corpus preparation script that stores downloaded sources in git-ignored folders.
- **FR-011**: The repo MUST include an IC question catalogue organized by memo section.
- **FR-012**: The repo MUST include a sample Markdown IC memo showing evidence-backed claims, assumptions, and open diligence gaps.
- **FR-013**: Downloaded third-party source documents MUST NOT be committed.

### Key Entities

- **Retrieval Mode**: Local, Global, or DRIFT search selected by the presenter.
- **GraphRAG Artifact**: A parquet table produced by Microsoft GraphRAG and loaded into the visualizer.
- **Public Corpus Source**: A URL and metadata entry used to prepare the demo corpus.
- **IC Question**: A reusable diligence question tied to a memo section, retrieval mode, and evidence expectation.
- **IC Memo Section**: A structured portion of the generated Markdown memo.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A presenter can run Local, Global, and DRIFT searches from the same drawer in under 2 minutes once artifacts and API are available.
- **SC-002**: Loading partial GraphRAG v2 artifacts does not produce a visible application crash.
- **SC-003**: The public corpus manifest contains at least 8 source entries across company, sponsor, regulatory, and market-context categories.
- **SC-004**: The IC question catalogue covers at least 10 memo sections and includes at least one Global, Local, and DRIFT prompt per section.
- **SC-005**: The sample IC memo clearly labels evidence, assumptions, and diligence gaps in every substantive section.

## Assumptions

- Microsoft GraphRAG and `graphrag-api` are the first-pass backend stack.
- Neo4j GraphRAG remains out of scope for this implementation.
- The first generated IC artifact is Markdown, not Word or PowerPoint.
- Public proxy documents are acceptable for the showcase.
- Downloaded source files remain local and ignored by git.
- Basic Search is out of scope.
