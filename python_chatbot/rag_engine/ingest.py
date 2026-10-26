"""
PDF Ingestion & Vector Indexing Pipeline for TenaWise
Reads verified Ethiopian MoH and WHO guidelines from knowledge_docs/
chunks them, and indexes them into the local Chroma vector database.
"""
import os
import glob
from pathlib import Path

# Base paths
BASE_DIR = Path(__file__).resolve().parent.parent
DOCS_DIR = BASE_DIR / "knowledge_docs"
CHROMA_DIR = BASE_DIR / "chroma_db"

def extract_text_from_pdf(pdf_path: Path):
    """Extracts text from a PDF file page by page."""
    try:
        from pypdf import PdfReader
        reader = PdfReader(str(pdf_path))
        pages_content = []
        for idx, page in enumerate(reader.pages):
            text = page.extract_text()
            if text and text.strip():
                pages_content.append({"page": idx + 1, "text": text.strip()})
        return pages_content
    except ImportError:
        print("[-] pypdf not installed. Please run: pip install pypdf")
        return []
    except Exception as e:
        print(f"[-] Error reading {pdf_path.name}: {e}")
        return []

def chunk_text(text: str, chunk_size: int = 600, overlap: int = 100):
    """Splits long text into overlapping chunks."""
    chunks = []
    start = 0
    text_len = len(text)

    while start < text_len:
        end = start + chunk_size
        chunk = text[start:end].strip()
        if chunk:
            chunks.append(chunk)
        start += chunk_size - overlap
    return chunks

def ingest_documents():
    """Scans knowledge_docs/ and indexes all documents into ChromaDB."""
    try:
        import chromadb
        from chromadb.utils import embedding_functions
    except ImportError:
        print("[-] chromadb not installed. Please run: pip install chromadb sentence-transformers")
        return

    print(f"[*] Initializing local ChromaDB at: {CHROMA_DIR}")
    client = chromadb.PersistentClient(path=str(CHROMA_DIR))

    # Using local sentence-transformers embedding
    embedding_fn = embedding_functions.SentenceTransformerEmbeddingFunction(
        model_name="all-MiniLM-L6-v2"
    )

    collection = client.get_or_create_collection(
        name="tenawise_srh_guidelines",
        embedding_function=embedding_fn,
        metadata={"description": "Ethiopian Ministry of Health and WHO SRH Guidelines"}
    )

    pdf_files = list(DOCS_DIR.glob("*.pdf"))
    txt_files = list(DOCS_DIR.glob("*.txt"))
    all_files = pdf_files + txt_files

    if not all_files:
        print(f"[!] No PDFs or TXT documents found in {DOCS_DIR}")
        print("    Please drop your guideline files into python_chatbot/knowledge_docs/")
        return

    print(f"[*] Found {len(all_files)} document(s) to process.")

    documents = []
    metadatas = []
    ids = []
    chunk_counter = 0

    for file_path in all_files:
        print(f"[*] Processing: {file_path.name}")
        if file_path.suffix.lower() == ".pdf":
            pages = extract_text_from_pdf(file_path)
            for p in pages:
                page_chunks = chunk_text(p["text"])
                for i, c in enumerate(page_chunks):
                    chunk_id = f"{file_path.stem}_p{p['page']}_c{i}"
                    documents.append(c)
                    metadatas.append({
                        "source": file_path.name,
                        "page": p["page"],
                        "type": "Ethiopian MoH / WHO Guideline"
                    })
                    ids.append(chunk_id)
                    chunk_counter += 1
        elif file_path.suffix.lower() == ".txt":
            content = file_path.read_text(encoding="utf-8")
            txt_chunks = chunk_text(content)
            for i, c in enumerate(txt_chunks):
                chunk_id = f"{file_path.stem}_c{i}"
                documents.append(c)
                metadatas.append({
                    "source": file_path.name,
                    "page": 1,
                    "type": "Manual / Protocol"
                })
                ids.append(chunk_id)
                chunk_counter += 1

    if documents:
        # Batch insert into ChromaDB
        batch_size = 50
        for i in range(0, len(documents), batch_size):
            collection.upsert(
                documents=documents[i:i + batch_size],
                metadatas=metadatas[i:i + batch_size],
                ids=ids[i:i + batch_size]
            )
        print(f"[+] Successfully indexed {chunk_counter} guideline chunks into ChromaDB!")
    else:
        print("[!] No text content could be extracted from documents.")

if __name__ == "__main__":
    ingest_documents()
