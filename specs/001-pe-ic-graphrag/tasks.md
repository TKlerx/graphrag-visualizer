# Tasks: PE IC GraphRAG Showcase

**Input**: Design documents from `specs/001-pe-ic-graphrag/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: Build and smoke checks are required; no new automated test framework is introduced.

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Initialize Spec Kit in the existing repository with Codex integration
- [x] T002 Run `specify check` and confirm CLI readiness
- [x] T003 Create feature specification artifacts under `specs/001-pe-ic-graphrag/`
- [x] T004 Fast-forward local main to upstream GraphRAG Visualizer main

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T005 Add `.specify/feature.json` pointer for current feature directory
- [x] T006 Update `.gitignore` to exclude local demo corpus downloads
- [x] T007 [P] Add Forterro corpus manifest in `demo/corpus/manifest.json`
- [x] T008 [P] Add IC question catalogue in `demo/ic-memo/question-catalogue.json`

---

## Phase 3: User Story 1 - Explore GraphRAG Retrieval Modes (Priority: P1)

**Goal**: Load GraphRAG artifacts and run Local, Global, and DRIFT retrieval.

**Independent Test**: Build the app and verify the API drawer exposes all three retrieval modes.

- [x] T009 [US1] Add DRIFT API client method in `src/app/api/agent.ts`
- [x] T010 [US1] Extend API search drawer search type, loading state, button, and warnings in `src/app/components/APISearchDrawer.tsx`
- [x] T011 [US1] Route DRIFT search from graph viewer and keep max-entities behavior in `src/app/components/GraphViewer.tsx`
- [x] T012 [US1] Harden parquet optional-field parsing in `src/app/utils/parquet-utils.ts`
- [x] T013 [US1] Prevent missing-node graph links in `src/app/hooks/useGraphData.ts`

---

## Phase 4: User Story 2 - Prepare a Public PE Demo Corpus (Priority: P2)

**Goal**: Provide a repeatable public-source corpus setup path.

**Independent Test**: Run the preparation script and confirm ignored local files are created.

- [x] T014 [US2] Add public corpus README in `demo/corpus/README.md`
- [x] T015 [US2] Add corpus preparation script in `demo/scripts/prepare-forterro-corpus.ps1`

---

## Phase 5: User Story 3 - Generate an Evidence-Guided IC Memo Draft (Priority: P3)

**Goal**: Provide a reusable question catalogue and a Markdown IC memo draft.

**Independent Test**: Review the sample memo and confirm each section separates evidence, assumptions, and gaps.

- [x] T016 [US3] Add IC memo workflow README in `demo/ic-memo/README.md`
- [x] T017 [US3] Add sample Markdown IC memo in `demo/ic-memo/sample-forterro-ic-memo.md`

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T018 Update root README with Spec Kit, DRIFT search, artifact loading, and demo workflow notes
- [x] T019 Run `specify check`
- [x] T020 Run `pnpm build`
- [x] T021 Smoke-test `pnpm start` briefly without leaving a running server
- [x] T022 Add Azure AI Foundry graph build documentation in `docs/azure-ai-foundry-graphrag.md`
- [x] T023 Add OpenTofu Azure scaffold in `infra/opentofu/`
- [x] T024 Add PDF-to-Markdown corpus conversion script in `demo/scripts/convert-corpus-pdfs-to-markdown.ps1`
- [x] T025 Add source URL download checklist in `demo/corpus/download-urls.md`
- [x] T026 Add Azure Document Intelligence PDF conversion script in `demo/scripts/convert-corpus-pdfs-with-document-intelligence.ps1`
- [x] T027 Add Document Intelligence resource and outputs to `infra/opentofu/`
- [x] T028 Add Azure AI Foundry GraphRAG config template in `demo/graphrag/settings.azure-foundry.yml`
- [x] T029 Add PE/IC GraphRAG prompt pack in `demo/graphrag/prompts/`
- [x] T030 Add IC question catalogue runner in `demo/scripts/run-ic-question-catalogue.ps1`

## Dependencies & Execution Order

- Setup precedes all other work.
- Foundational tasks precede user stories.
- User Story 1 is the MVP and should complete before corpus and memo polish.
- User Stories 2 and 3 can be implemented independently after foundational tasks.

## Implementation Strategy

Deliver the app retrieval changes first, then add corpus and memo assets, then update documentation and run checks.
