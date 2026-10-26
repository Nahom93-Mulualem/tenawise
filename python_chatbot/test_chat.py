"""Simple CLI tool to test the TenaWise Python chatbot endpoint.
Run with: python test_chat.py
"""
import requests
import json

URL = "http://localhost:8000/api/chat"

def chat():
    print("=" * 60)
    print(" TenaWise AI Chatbot CLI Test")
    print(" Type 'exit' to quit. Test queries in English or Amharic.")
    print("=" * 60)

    while True:
        try:
            msg = input("\nYou: ").strip()
            if not msg:
                continue
            if msg.lower() in ["exit", "quit"]:
                break

            response = requests.post(
                URL,
                json={"message": msg},
                timeout=15
            )
            data = response.json()
            print(f"\nTenaWise [{data.get('category', 'AI')}]:")
            print(data.get("reply", "No reply received."))
            if data.get("is_urgent"):
                print("\n⚠️ [URGENT ATTENTION RECOMMENDED]")
            if data.get("follow_up_questions"):
                print("\nSuggested follow-ups:")
                for q in data["follow_up_questions"]:
                    print(f"  • {q}")
        except Exception as e:
            print(f"\n[Error communicating with {URL}]: {e}")
            print("Make sure the backend is running with: python app.py")

if __name__ == "__main__":
    chat()
