# TenaWise (ጤና ዋይዝ)

TenaWise is a Flutter application for sexual and reproductive health (SRH) education, designed for young people in Ethiopia. It combines a bilingual English/Amharic mobile experience with an offline-first SRH knowledge engine and an optional local Python AI service. The app includes a conversational assistant, a menstrual-cycle feature, and an educational library.

> **Health information notice:** TenaWise provides educational information, not a diagnosis or substitute for a qualified health professional. For urgent, personal, or uncertain medical concerns, contact a health professional or local emergency/support service. Review all clinical content and referral information with qualified local experts before distributing the app.

## What the app includes

- **SRH assistant:** Answers common questions about contraception, menstrual health, HIV/STIs, consent, reproductive rights, and related topics. The Flutter client has a built-in English/Amharic rule-based knowledge engine for offline responses.
- **Optional local AI backend:** A FastAPI service can retrieve relevant local guideline excerpts and send context to a locally running Ollama model. If the backend or model is unavailable, the service uses its built-in response engine; if the Flutter app cannot reach the backend, it falls back to the Dart knowledge engine.
- **Guideline retrieval:** The Python backend can index PDF and text files in `python_chatbot/knowledge_docs/`. It supports persistent ChromaDB vector search and a JSON-based local search fallback.
- **Cycle feature and learning library:** Flutter screens are organized under `lib/screens/cycle/` and `lib/screens/library/`.
- **Language and appearance preferences:** Shared app-level localization and light/dark theme components live under `lib/core/`.
- **Safety-oriented responses:** The assistant includes crisis and urgency handling and Ethiopian service referrals. Verify current hotline numbers, clinical recommendations, translations, and partner availability before release.

## Design and architecture

### Product and interaction design

Design for a private, approachable, low-bandwidth experience suitable for sensitive health questions:

1. Keep navigation between the home, assistant, cycle, and learning-library experiences clear and predictable.
2. Use calm, readable layouts and clear visual hierarchy; make urgent guidance and referral information easy to distinguish from general education.
3. Offer English and Amharic consistently, and ensure text expansion, Ethiopic typography, and right-to-left/localized content needs are tested where relevant.
4. Provide understandable loading, offline, error, and fallback states. Do not imply that an AI-generated answer is a clinician's advice.
5. Protect privacy: avoid collecting identifying details that are unnecessary, do not log sensitive chat content in production, and explain any data handling to users.
6. Make accessibility part of each screen: adequate contrast, scalable text, semantic labels, and controls usable with assistive technology.

### Technical design

```text
Flutter client (Dart)
  ├─ Home, assistant, cycle, and library screens
  ├─ Shared theme and language preferences
  ├─ Assistant API client (HTTP)
  └─ Local SRH knowledge engine (offline fallback)
             │ optional HTTP
             ▼
Python FastAPI service
  ├─ /api/chat and health endpoint
  ├─ ClinicalRetriever: ChromaDB vector search when initialized
  │     └─ JSON knowledge-index keyword-search fallback
  ├─ Optional local Ollama model for response generation
  └─ Built-in clinical rule-based fallback
```

The Python service is optional for the Flutter app's local rule-based assistant. When enabled, the API retrieves up to three relevant passages before constructing the Ollama prompt. Do not describe the service as cloud-hosted or fully independent of local setup: Ollama must be installed and running to use the local language model, and the backend itself must be reachable for API-backed chat.

### RAG and ChromaDB data flow

The following flow describes the implemented Python retrieval-augmented generation (RAG) path. Use current, approved SRH reference material as the source; the application does not automatically verify that a document is authoritative or up to date.

```text
INDEXING (run by a developer)
Approved SRH PDF/TXT documents
        │
        ▼
Text extraction (PDF) / text loading (TXT)
        │
        ▼
Text chunking (overlapping chunks)
        │
        ▼
Sentence-transformer embeddings (all-MiniLM-L6-v2)
        │
        ▼
Persistent ChromaDB collection
python_chatbot/chroma_db/ — tenawise_srh_guidelines
        │
        │
QUERY (when a user sends a question to the Python API)
        ▼
User question ──► ChromaDB embeds the query and runs similarity search
        │
        ▼
Up to 3 matching passages + source/page metadata
        │
        ▼
Prompt context + question + recent conversation history
        │
        ▼
Local Ollama model (configured default: qwen2.5:3b)
        │
        ▼
Context-aware answer, with urgency/referral handling by the API
```

Important implementation details and fallbacks:

- `python_chatbot/rag_engine/ingest.py` reads PDF and UTF-8 TXT files, extracts or loads their text, splits text into overlapping chunks, then attempts to upsert the chunks and source metadata into the persistent ChromaDB collection `tenawise_srh_guidelines`.
- ChromaDB's `SentenceTransformerEmbeddingFunction` uses `all-MiniLM-L6-v2`. The collection embedding function embeds the documents during ingestion and the user's query during vector search; the code does not separately build or store query embeddings itself.
- The API asks the retriever for `top_k=3`. When ChromaDB returns results, these excerpts are formatted into context for the Ollama prompt.
- The ingestion script also writes `python_chatbot/knowledge_index.json`. If ChromaDB is missing, uninitialized, or a Chroma query fails, `ClinicalRetriever` can use this JSON index's local keyword-based search instead. That fallback is not vector similarity search and should not be described as embedding-based retrieval.
- Ollama is optional. `.env.example` configures `OLLAMA_MODEL=qwen2.5:3b` by default, but a developer may configure a different model. If Ollama is unavailable or fails, the Python service returns its built-in rule-based response; that fallback does not generate an LLM answer from the retrieved context. If the Flutter client cannot reach the Python backend, it uses the Dart-side SRH knowledge engine.
- ChromaDB usage is implemented, but a ChromaDB database is not required to be committed to Git. The local persistent database is created/populated by ingestion; the JSON index is the checked-in fallback.

This pipeline can ground a generated response in retrieved documents, but it does **not** guarantee medical accuracy or eliminate hallucinations. Keep source attribution, clinical review, safety testing, and clear educational-not-medical-advice messaging in place.

### ChromaDB status

**ChromaDB integration is implemented in this repository.** `chromadb` is listed in `python_chatbot/requirements.txt`. The ingestion script uses a persistent ChromaDB client at `python_chatbot/chroma_db/`, creates/updates the `tenawise_srh_guidelines` collection, and embeds document chunks with `all-MiniLM-L6-v2`. The retriever queries this collection when it is available. If ChromaDB is absent, its database is not initialized, or a query fails, retrieval falls back to `python_chatbot/knowledge_index.json`.

This means ChromaDB is supported, but it is only actively populated and used after you install the Python dependencies and ingest source documents. The committed JSON index is the fallback; a checked-in ChromaDB database is not required.

## Development setup

### Requirements

- Flutter SDK compatible with the Dart constraint in `pubspec.yaml` (currently `^3.13.5`)
- Python 3.10 or later recommended for the backend and its dependencies
- Optional: [Ollama](https://ollama.com/) and a compatible local model, such as `qwen2.5:3b`
- Optional: official, reviewed guideline PDFs or text documents for building the retrieval index

### Run the Flutter app

From the repository root:

```bash
flutter pub get
flutter run
```

To run tests and static analysis:

```bash
flutter test
flutter analyze
```

### Run the Python API

In a separate terminal:

```bash
cd python_chatbot
python -m venv .venv
```

Activate the virtual environment, then install dependencies:

```bash
# macOS / Linux
source .venv/bin/activate
pip install -r requirements.txt

# Windows PowerShell (use this instead of the source command)
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Copy `.env.example` to `.env` if you want to configure the local Ollama URL/model. Start Ollama separately and pull the configured model if you want model-generated responses. Then start the API:

```bash
python app.py
```

The service defaults to `http://127.0.0.1:8000`; interactive API documentation is available at `http://127.0.0.1:8000/docs` while it is running. The API has a health endpoint at `/` and a chat endpoint at `/api/chat`.

The Flutter API client currently uses `http://localhost:8000` for web, iOS simulator, and desktop, and `http://10.0.2.2:8000` for the Android emulator. A physical phone needs a reachable development machine address and appropriate network configuration; do not expose an unauthenticated development API to the public internet.

### Build or refresh the knowledge index

1. Add approved PDF or UTF-8 text guideline documents to `python_chatbot/knowledge_docs/`. The folder's README lists example document types.
2. With the Python virtual environment active and dependencies installed, run:

   ```bash
   cd python_chatbot
   python rag_engine/ingest.py
   ```

3. The ingestion process chunks the documents and attempts to upsert them into the persistent ChromaDB collection. It also writes/refreshes `knowledge_index.json` for fallback retrieval.
4. Start or restart the API and test retrieval with a non-sensitive sample question. Check the API health response and backend logs to confirm what is available.

Do not add private, identifiable, or unlicensed documents to the index. Review source provenance and clinical correctness before using documents to inform user-facing answers.

### Backend checks

From `python_chatbot/`, with dependencies installed:

```bash
python test_chat.py
python test_triage_accuracy.py
```

These scripts exercise the chatbot and triage behavior; verify their expected backend/model requirements before running. Flutter tests are in `test/`.

## Repository map

```text
lib/
  core/                  Shared themes, language, and reusable widgets
  screens/               Home, assistant, cycle, library, and app shell
python_chatbot/
  app.py                 FastAPI chatbot API and fallback responses
  rag_engine/            Document ingestion and clinical retrieval
  knowledge_docs/        Place reviewed PDF/TXT source material here
  knowledge_index.json   Local keyword-search fallback index
  requirements.txt       Python backend and ChromaDB dependencies
test/                    Flutter tests
```

## Contribution and content safety

- Keep Flutter presentation, shared app utilities, and assistant/backend concerns in their existing feature-oriented folders.
- Add or update tests when changing assistant behavior, urgency classification, localization, or fallback handling.
- Never commit API keys, `.env` files, chat transcripts containing personal information, or sensitive user data.
- Treat AI output and retrieval as fallible. Validate medical content with qualified clinicians and authoritative, current sources; retrieval does not guarantee that an answer is correct or eliminate hallucinations.
- Review privacy, security, accessibility, localization, and platform-specific behavior before a release.
