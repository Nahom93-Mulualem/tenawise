"""
TenaWise RAG Engine
Local, verified clinical retrieval-augmented generation engine
grounded in Ethiopian Ministry of Health and WHO guidelines.
"""
from .retriever import ClinicalRetriever

__all__ = ["ClinicalRetriever"]
