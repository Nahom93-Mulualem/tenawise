"""
Semantic Clinical Retriever for TenaWise
Searches local ChromaDB or TenaWise Native Knowledge Index for verified passages
matching the user's inquiry (supporting both English and Amharic).
"""
import os
import json
import re
from pathlib import Path
from typing import List, Dict, Any, Optional

BASE_DIR = Path(__file__).resolve().parent.parent
CHROMA_DIR = BASE_DIR / "chroma_db"
INDEX_FILE = BASE_DIR / "knowledge_index.json"

def _tokenize(text: str) -> List[str]:
    """Tokenize English words and Ethiopic/Amharic words."""
    return [t.lower() for t in re.findall(r'[\w\u1200-\u137F]+', text) if len(t) > 1]

class ClinicalRetriever:
    def __init__(self):
        self.collection = None
        self.local_index: List[Dict[str, Any]] = []
        self._init_db()

    def _init_db(self):
        """Initializes connection to persistent Chroma vector database or local index."""
        # 1. Try ChromaDB if installed and directory exists
        try:
            if CHROMA_DIR.exists():
                import chromadb
                from chromadb.utils import embedding_functions

                client = chromadb.PersistentClient(path=str(CHROMA_DIR))
                embedding_fn = embedding_functions.SentenceTransformerEmbeddingFunction(
                    model_name="all-MiniLM-L6-v2"
                )
                collections = client.list_collections()
                if any(c.name == "tenawise_srh_guidelines" for c in collections):
                    self.collection = client.get_collection(
                        name="tenawise_srh_guidelines",
                        embedding_function=embedding_fn
                    )
                    return
        except Exception:
            self.collection = None

        # 2. Fallback to TenaWise Native Knowledge Index (Zero dependencies, 100% compatible)
        if INDEX_FILE.exists():
            try:
                with open(INDEX_FILE, "r", encoding="utf-8") as f:
                    self.local_index = json.load(f)
            except Exception as e:
                print(f"[!] Warning: Could not load {INDEX_FILE.name}: {e}")
                self.local_index = []

    def search(self, query: str, top_k: int = 3) -> List[Dict[str, Any]]:
        """Searches for relevant clinical passages matching the query."""
        if not query or not query.strip():
            return []

        # 1. If ChromaDB is active, use vector search
        if self.collection:
            try:
                results = self.collection.query(
                    query_texts=[query],
                    n_results=top_k
                )
                passages = []
                if results and "documents" in results and results["documents"]:
                    docs = results["documents"][0]
                    metas = results["metadatas"][0] if "metadatas" in results else [{}] * len(docs)
                    dists = results["distances"][0] if "distances" in results else [0.0] * len(docs)

                    for doc, meta, dist in zip(docs, metas, dists):
                        passages.append({
                            "content": doc,
                            "source": meta.get("source", "Ethiopian MoH Guideline"),
                            "page": meta.get("page", 1),
                            "relevance_distance": dist
                        })
                return passages
            except Exception as e:
                print(f"[!] Error querying ChromaDB: {e}")

        # 2. Use Native BM25-style keyword search over local index
        if not self.local_index and INDEX_FILE.exists():
            self._init_db()

        if not self.local_index:
            return []

        query_tokens = set(_tokenize(query))
        if not query_tokens:
            return []

        scored_passages = []
        clean_query = query.lower().strip()

        for chunk in self.local_index:
            content_lower = chunk["content"].lower()
            score = 0.0

            # Exact phrase match gets high priority
            if len(clean_query) > 3 and clean_query in content_lower:
                score += 15.0

            # Token overlap score
            chunk_tokens = set(chunk.get("tokens", []))
            overlap = query_tokens.intersection(chunk_tokens)
            if overlap:
                # Add score proportional to matched words
                score += len(overlap) * 3.0

            # Substring match for Amharic roots and English medical terms
            for qt in query_tokens:
                if len(qt) >= 3 and qt in content_lower:
                    score += 1.5

            if score > 0.0:
                scored_passages.append((score, chunk))

        # Sort by score descending
        scored_passages.sort(key=lambda x: x[0], reverse=True)

        results = []
        for score, chunk in scored_passages[:top_k]:
            results.append({
                "content": chunk["content"],
                "source": chunk.get("source", "Ethiopian MoH / WHO Guideline"),
                "page": chunk.get("page", 1),
                "score": score
            })

        return results

    def format_context_for_prompt(self, passages: List[Dict[str, Any]]) -> str:
        """Formats retrieved passages into a clean prompt section."""
        if not passages:
            return "No specific passages retrieved from local documents."

        formatted = ["### Verified Passages from Ethiopian MoH & WHO Guidelines:"]
        for idx, p in enumerate(passages, 1):
            formatted.append(f"[{idx}] Source: {p['source']} (Page {p['page']})\nExcerpt: \"{p['content']}\"")
        return "\n\n".join(formatted)

