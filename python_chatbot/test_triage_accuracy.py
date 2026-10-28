"""
Verification test suite for TenaWise Chatbot Backend Triage & Medical Accuracy.
Runs directly with pure Python, no external testing frameworks required.
"""
import sys
import os

# Add python_chatbot to sys.path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "python_chatbot"))

from app import _contextual_urgency_assessment, _generate_fallback_response

def test_urgency_assessment():
    print("[*] Testing _contextual_urgency_assessment...")

    # 1. Educational queries must NEVER be urgent
    assert not _contextual_urgency_assessment("What does HPV mean in Amharic?"), "HPV query should not be urgent"
    assert not _contextual_urgency_assessment("What is PEP?"), "PEP educational query should not be urgent"
    assert not _contextual_urgency_assessment("how does emergency contraception work?"), "Contraception query should not be urgent"
    assert not _contextual_urgency_assessment("what does dmpa_sc means"), "DMPA query should not be urgent"
    assert not _contextual_urgency_assessment("HPV ምንድን ነው?"), "Amharic HPV query should not be urgent"

    # 2. Genuine acute emergencies MUST be urgent
    assert _contextual_urgency_assessment("the condom broke last night"), "Broken condom last night must be urgent"
    assert _contextual_urgency_assessment("I was assaulted hours ago"), "Assault must be urgent"
    assert _contextual_urgency_assessment("አስገደደኝ"), "Amharic crisis must be urgent"

    print("   [+] _contextual_urgency_assessment PASSED.")

def test_fallback_accuracy():
    print("[*] Testing _generate_fallback_response...")

    # Educational query fallback
    res = _generate_fallback_response("What does HPV mean in Amharic?", False)
    assert not res.is_urgent, "Educational fallback must not be urgent"
    assert "Emergency" not in res.category, f"Category should not have Emergency, got {res.category}"

    # Crisis fallback
    crisis = _generate_fallback_response("I was assaulted last night", False)
    assert crisis.is_urgent, "Crisis fallback must be urgent"
    assert "8335" in crisis.reply, "Crisis fallback must reference 8335 hotline"

    print("   [+] _generate_fallback_response PASSED.")

if __name__ == "__main__":
    test_urgency_assessment()
    test_fallback_accuracy()
    print("\n[SUCCESS] All Python triage and accuracy tests PASSED!")

