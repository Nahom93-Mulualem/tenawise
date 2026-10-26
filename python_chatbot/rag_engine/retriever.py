"""
Semantic Clinical Retriever for TenaWise
Searches local ChromaDB for verified passages matching the user's inquiry.
"""
import os
from pathlib import Path
from typing import List, Dict, Any, Optional

BASE_DIR = Path(__file__).resolve().parent.parent
CHROMA_DIR = BASE_DIR / "chroma_db"

class ClinicalRetriever:
    def __init__(self):
        self.collection = None
        self._init_db()

    def _init_db(self):
        """Initializes connection to persistent Chroma vector database."""
        try:
            import chromadb
            from chromadb.utils import embedding_functions

            if not CHROMA_DIR.exists():
                return

            client = chromadb.PersistentClient(path=str(CHROMA_DIR))
            embedding_fn = embedding_functions.SentenceTransformerEmbeddingFunction(
                model_name="all-MiniLM-L6-v2"
            )
            # Retrieve collection if exists
            collections = client.list_collections()
            collection_names = [c.name for c in collections]
            if "tenawise_srh_guidelines" in collection_names:
                self.collection = client.get_collection(
                    name="tenawise_srh_guidelines",
                    embedding_function=embedding_fn
                )
        except Exception as e:
            print(f"[!] Warning: Could not connect to local ChromaDB: {e}")
            self.collection = None

    def search(self, query: str, top_k: int = 3) -> List[Dict[str, Any]]:
        """Searches for relevant clinical passages matching the query."""
        if not self.collection:
            return []

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
            return []

    def format_context_for_prompt(self, passages: List[Dict[str, Any]]) -> str:
        """Formats retrieved passages into a clean prompt section."""
        if not passages:
            return "No specific passages retrieved from local documents."

        formatted = ["### Verified Passages from Ethiopian MoH & WHO Guidelines:"]
        for idx, p in enumerate(passages, 1):
            formatted.append(f"[{idx}] Source: {p['source']} (Page {p['page']})\nExcerpt: \"{p['content']}\"")
        return "\n\n".join(formatted)
