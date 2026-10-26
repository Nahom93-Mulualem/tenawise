# TenaWise AI Chatbot (Sexual & Reproductive Health)

Dedicated, confidential, and culturally tailored Sexual and Reproductive Health (SRH) AI backend for Ethiopian youth.

---

## 🚀 Quick Setup (Easiest Way to Run)

### 1. Install Dependencies
```bash
cd python_chatbot
pip install -r requirements.txt
```

### 2. Configure Environment (Optional but Recommended)
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```
Add your free Google Gemini API Key from [Google AI Studio](https://aistudio.google.com/):
```env
GEMINI_API_KEY=AIzaSy...
```
*(Note: If no API key is provided, the server automatically uses the built-in intelligent clinical rule engine so it never fails).*

### 3. Run the Backend Server
```bash
python app.py
```
The server will start on `http://localhost:8000`. You can visit `http://localhost:8000/docs` for the interactive Swagger documentation.

### 4. Test Queries via Terminal
In another terminal, run:
```bash
python test_chat.py
```

---

## 💡 Recommended Architecture & Training Ideas

### 1. Hybrid Architecture (What We Built)
- **Primary**: Cloud LLM (Gemini 2.5 Flash via FastAPI) for natural multi-turn conversations and empathetic nuance in Amharic & English.
- **Secondary (Zero Failure)**: Client-side offline SRH Knowledge Engine (`SrhKnowledgeEngine` in Flutter) so users with spotty 2G/3G connections or zero data in regional areas never get blocked.

### 2. Retrieval-Augmented Generation (RAG) for Custom Medical Guidelines
Instead of fine-tuning, RAG is faster, cheaper, and 100% auditable:
- Index the **Ethiopian Ministry of Health (MOH) Adolescent & Youth Health Strategy** and **Marie Stopes Clinical Protocols** using `ChromaDB` or `FAISS`.
- When a user asks a question, retrieve top 3 clinical paragraphs and feed them into the LLM context.
- Guarantees 0% hallucinations on drug dosages (e.g., Postinor-2 timing, PEP within 72 hours).

### 3. Privacy & Youth Safety First
- **Zero PII**: Never store user names, phone numbers, or exact locations.
- **Anonymous Sessions**: Assign ephemeral UUIDs for conversation history that expire after 24 hours.
- **Emergency Triage**: Always detect rape/assault or recent exposure to display the toll-free **8335** and **6788** hotlines immediately.
