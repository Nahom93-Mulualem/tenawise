import os
import sys
import json
import re
import requests  # Required for Ollama HTTP calls (_check_ollama_available, _query_ollama)
from typing import List, Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Initialize verified clinical RAG retriever
try:
    from rag_engine.retriever import ClinicalRetriever
    clinical_retriever = ClinicalRetriever()
except Exception as e:
    print(f"[*] Warning: Could not initialize ClinicalRetriever: {e}")
    clinical_retriever = None

app = FastAPI(
    title="TenaWise SRH AI Chatbot API",
    description="Dedicated AI companion for Sexual and Reproductive Health (SRH) education in Ethiopia.",
    version="2.0.0"
)

# Enable CORS for Flutter Web, Mobile, and Desktop clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Standardized Referral Directory for Ethiopia
ETHIOPIAN_LOCAL_PARTNERS = {
    "public_centers": "Nearest Government Woreda Health Center or General Hospital (100% Free PEP medication within 72h, emergency contraception, and syndromic STI treatment)",
    "marie_stopes": "Marie Stopes Ethiopia (MSE) Clinics (Quality confidential contraception, pregnancy counseling, cervical screening across Addis Ababa & regional cities)",
    "fgae": "Family Guidance Association of Ethiopia (FGAE) Youth-Friendly Centers (Confidential, youth-tailored SRH counseling and clinical services)",
    "youth_hotline": "National Youth Reproductive Health & HIV Helpline: 8335 (Toll-Free from any phone in Ethiopia)",
    "gbv_hotline": "National Gender-Based Violence (GBV) Survivor Support Line: 6788 (Toll-Free)"
}

ETHIOPIAN_LOCAL_PARTNERS_AM = {
    "public_centers": "በአቅራቢያዎ የሚገኝ የመንግስት ጤና ጣቢያ ወይም ሆስፒታል (በ72 ሰዓታት ውስጥ ነፃ የPEP መድኃኒት፣ ድንገተኛ መከላከያ እና የአባለዘር ህክምና)",
    "marie_stopes": "ማሪ ስቶፕስ ኢትዮጵያ (Marie Stopes Clinics) - በአዲስ አበባ እና በክልል ከተሞች ሚስጥራዊ የወሊድ መከላከያ እና የማማከር አገልግሎት",
    "fgae": "የኢትዮጵያ ቤተሰብ መምሪያ ማህበር (FGAE) የወጣቶች ምቹ ማዕከላት",
    "youth_hotline": "የወጣቶች የስነ-ተዋልዶ ጤና እና ኤች.አይ.ቪ ነፃ የስልክ መስመር: 8335 (ያለ ክፍያ)",
    "gbv_hotline": "የሴቶች እና የህፃናት ጥቃት ድንገተኛ ነፃ የስልክ መስመር: 6788"
}

# System Prompt embodying peer-reviewed SRH medical knowledge with Ethiopian context
SRH_SYSTEM_PROMPT = """You are TenaWise AI, an empathetic, non-judgmental, and medically accurate educational assistant specializing in Sexual and Reproductive Health (SRH) for young people in Ethiopia.

Core Principles:
1. Contextual Clinical Triage (NOT Naive Keyword Matching):
   - You must distinguish between theoretical/educational questions vs. real-life urgent emergencies.
   - Example A (Educational): "What is PEP?", "How does post-exposure prophylaxis work?", "What does unprotected sex mean?" -> This is an educational inquiry. Provide clear facts. Do NOT mark as an urgent emergency.
   - Example B (Active Clinical Emergency): "I had sex without a condom last night, what do I do?", "The condom broke an hour ago", "I was forced/assaulted", "I am bleeding heavily and dizzy" -> This is an active emergency requiring immediate triage within the critical 72-hour window.
2. Local Ethiopian Partner Referrals:
   - When an urgent situation is detected (or when clinical follow-up is appropriate), explicitly refer the user to:
     * Nearest Local Government Health Center / Hospital (for 100% free PEP within 72h, emergency contraception, and syndromic STI management)
     * Marie Stopes Ethiopia (MSE) Clinics
     * Family Guidance Association of Ethiopia (FGAE) Youth-Friendly Centers
     * National Youth Toll-Free Helpline: 8335
     * National GBV Hotline: 6788
3. Comprehensive Conceptual SRH Depth:
   - Explain physiological mechanisms, biological conception, all contraception methods, menstrual cycle endocrinology, and bodily autonomy clearly and respectfully.
4. Empathy & Confidentiality:
   - Respond without judgment, guilt, or preachiness. Affirm the user's feelings and provide calm, clear steps.
5. Language & Tone:
   - If the user writes in Amharic, respond fluently in natural, respectful Amharic.
   - If the user writes in English, respond in clear, easy-to-read English with structured bullet points.
"""

class ChatMessage(BaseModel):
    role: str  # 'user' or 'assistant'
    content: str

class ChatRequest(BaseModel):
    message: str
    language: Optional[str] = "en"  # 'en' or 'am'
    history: Optional[List[ChatMessage]] = []

class ChatResponse(BaseModel):
    reply: str
    category: str
    is_urgent: bool = False
    referral_partner: Optional[str] = None
    follow_up_questions: List[str] = []
    source: str = "TenaWise AI"

def _is_assault_crisis(text: str) -> bool:
    lowered = text.lower()
    assault_terms = [
        "raped", "rape", "assaulted", "sexual assault", "forced me", "against my will", "violated",
        "ተደፈርኩ", "ተገደድኩ", "አስገደደኝ", "የፆታ ጥቃት"
    ]
    return any(t in lowered for t in assault_terms)

def _is_pregnancy_inquiry(text: str) -> bool:
    lowered = text.lower()
    preg_terms = [
        "pregnant", "pregnancy", "get pregnant", "conception", "ovulation", "fertilization",
        "እርጉዝ", "እርግዝና", "ማርገዝ", "እንቁላል መውጣት"
    ]
    return any(t in lowered for t in preg_terms)

def _contextual_urgency_assessment(text: str) -> bool:
    """Smart contextual assessment for offline fallback mode.
    Prioritizes acute emergencies and crisis situations above educational filters.
    """
    lowered = text.lower()

    # 1. Assault and acute trauma are ALWAYS urgent regardless of wording
    if _is_assault_crisis(text):
        return True

    # 2. Acute temporal emergency indicators (recent event within critical 72h window)
    emergency_patterns = [
        "hours ago", "hour ago", "yesterday", "last night", "today", "just happened",
        "broke during", "condom broke", "bleeding heavily", "severe pain", "terrified", "need pep now",
        "ሰዓት በፊት", "ትናንት", "ዛሬ", "አሁን", "ኮንዶም ተቀደደብን", "ደሜ አልቆመም"
    ]
    if any(p in lowered for p in emergency_patterns):
        return True

    # 3. If the user is explicitly asking for a definition or educational explanation, do NOT flag as urgent
    educational_patterns = [
        "what is", "what are", "define", "definition", "explain", "meaning of", "how does it work",
        "difference between", "tell me about", "history of", "can you explain",
        "ምንድን ነው", "ምን ማለት ነው", "አብራራልኝ", "ትርጉም", "ስለ", "ልዩነቱ"
    ]
    if any(p in lowered for p in educational_patterns):
        return False

    return False

def _build_referral_text(is_amharic: bool) -> str:
    if is_amharic:
        p = ETHIOPIAN_LOCAL_PARTNERS_AM
        return (
            "\n\n🏥 **የአካባቢዎ የጤና አጋሮች እና ነፃ የስልክ መስመሮች:**\n"
            f"1. **{p['public_centers']}**\n"
            f"2. **{p['marie_stopes']}**\n"
            f"3. **{p['fgae']}**\n"
            f"4. 📞 **{p['youth_hotline']}**\n"
            f"5. 📞 **{p['gbv_hotline']}**"
        )
    else:
        p = ETHIOPIAN_LOCAL_PARTNERS
        return (
            "\n\n🏥 **Recommended Local Partners & Confidential Helplines in Ethiopia:**\n"
            f"1. **{p['public_centers']}**\n"
            f"2. **{p['marie_stopes']}**\n"
            f"3. **{p['fgae']}**\n"
            f"4. 📞 **{p['youth_hotline']}**\n"
            f"5. 📞 **{p['gbv_hotline']}**"
        )

def _generate_fallback_response(message: str, is_amharic: bool) -> ChatResponse:
    """Intelligent clinical fallback when Gemini API is offline."""
    referral = _build_referral_text(is_amharic)

    # 1. Specialized Sexual Assault / Trauma Triage
    if _is_assault_crisis(message):
        if is_amharic:
            reply = (
                "⚠️ **አስቸኳይ የጤና፣ የአካል እና የስነ-ልቦና ድጋፍ (Crisis Intervention):**\n\n"
                "በመጀመሪያ ይህ የእርስዎ ጥፋት እንዳልሆነ ይወቁ። እርስዎ ደህና ነዎት፣ ብቻዎን አይደሉም።\n\n"
                "### 1. አካላዊ እና የህክምና እርምጃዎች (በ72 ሰዓታት ውስጥ):\n"
                "• **አስቸኳይ ደህንነት:** ወደ አስተማማኝ እና ደህንነቱ የተጠበቀ ቦታ ይሂዱ፤ ከሚያምኑት ሰው ጋር ይሁኑ።\n"
                "• **የኤች.አይ.ቪ መከላከያ (PEP):** ጥቃቱ በተፈጠረ በ**72 ሰዓታት (3 ቀናት)** ውስጥ ወደ ጤና ተቋም በመሄድ የPEP መድኃኒት በነፃ ይጀምሩ።\n"
                "• **ድንገተኛ የወሊድ መከላከያ:** ያልተፈለገ እርግዝናን ለመከላከል የድንገተኛ የወሊድ መከላከያ እንክብል (Postinor-2 / Postpill) በ72 ሰዓታት ውስጥ ይውሰዱ።\n"
                "• **ማስረጃ መጠበቅ እና ምርመራ:** ጥቃቱን ሪፖርት የማድረግ ፍላጎት ካለዎት ወደ ጤና ተቋም ከመሄድዎ በፊት ገላዎን አለመታጠብ፣ ልብስ አለመቀየር እና አለመፀዳዳት ማስረጃዎችን ለመጠበቅ ይረዳል። ልብስ ከተቀየረ በወረቀት ፌስታል ውስጥ ያስቀምጡት።\n"
                "• **የአባለዘር በሽታ መከላከያ:** የጤና ባለሙያዎች የአባለዘር በሽታዎችን (STI) ለመከላከል እና ቁስሎችን ለማከም አስፈላጊውን እንክብካቤ ያደርጋሉ።\n\n"
                "### 2. ስነ-ልቦናዊ ድጋፍ እና ማረጋጊያ:\n"
                "• **ስሜታዊ ማረጋጊያ (Grounding):** አተነፋፈስዎን ያረጋጉ (ለ4 ሰከንድ አየር ወደ ውስጥ መሳብ፣ ለ4 ሰከንድ ማቆየት፣ ለ6 ሰከንድ ማስወጣት)። ይህ ድንጋጤ እና ድንጋጭ ስሜት ጊዜያዊ እንደሆነ ያስታውሱ።\n"
                "• **ብቻዎን አይሁኑ:** ለሚያምኑት የቤተሰብ አባል፣ ጓደኛ ወይም የሳይኮሎጂ ባለሙያ ያካፍሉ።\n"
                "• **ነፃ የስነ-ልቦና ምክር:** በነፃ የስልክ መስመሮች በመደወል የባለሙያ ድጋፍ ያግኙ።"
                + referral
            )
            return ChatResponse(
                reply=reply,
                category="አስቸኳይ የጥቃት እርዳታ",
                is_urgent=True,
                referral_partner="የመንግስት ጤና ጣቢያ / 8335 / 6788 (GBV Helpline)",
                follow_up_questions=["በነፃ የስልክ መስመር 8335 መደወል", "PEP መድሃኒት የት ይገኛል?", "ስነ-ልቦናዊ ማረጋጊያ ምክር"],
                source="TenaWise Offline Clinical Engine"
            )
        else:
            reply = (
                "⚠️ **URGENT CRISIS & MEDICAL TRIAGE:**\n\n"
                "First and most importantly: **You are safe right now, and what happened is NOT your fault.** You do not have to carry this alone.\n\n"
                "### 1. Physical & Medical Steps (Within the Critical 72-Hour Window):\n"
                "• **Immediate Physical Safety:** Move immediately to a safe, secure location with someone you trust.\n"
                "• **HIV Post-Exposure Prophylaxis (PEP):** You must begin PEP within **72 hours (3 days)**. It is **100% free** at all public health centers and hospitals in Ethiopia and prevents HIV infection.\n"
                "• **Emergency Contraception:** Take Postinor-2 / Postpill or Ella within 72–120 hours to prevent unwanted pregnancy.\n"
                "• **Forensic Evidence & Medical Exam:** If you plan or may wish to seek legal justice, avoid showering, bathing, douching, brushing teeth, or changing clothes before a clinical exam. If clothes must be changed, keep each item in clean paper bags (not plastic).\n"
                "• **STI Prevention & Injury Care:** Clinicians provide prophylactic antibiotics for gonorrhea, chlamydia, syphilis, and tetanus, and treat any physical trauma.\n\n"
                "### 2. Psychological & Emotional Steps:\n"
                "• **Emotional Grounding:** Shock, numbness, and shivering are natural physiological responses. Try slow diaphragmatic breathing (inhale for 4s, hold for 4s, exhale for 6s) or focus on physical objects around you.\n"
                "• **Reach Out to Support:** Confide in a trusted friend, family member, or counselor right away. Isolation magnifies trauma.\n"
                "• **Professional Trauma First Aid:** Trained counselors are available 24/7 to listen, support, and guide you without judgment.\n\n"
                "Call confidential emergency lines right away:"
                + referral
            )
            return ChatResponse(
                reply=reply,
                category="Crisis Intervention",
                is_urgent=True,
                referral_partner="Woreda Health Center / Toll-Free 8335 / GBV Helpline 6788",
                follow_up_questions=["Call Toll-Free Helpline 8335", "Call GBV Helpline 6788", "Where to get free PEP medication?"],
                source="TenaWise Offline Clinical Engine"
            )

    # 2. General Emergency (e.g. broken condom / unprotected exposure)
    if _contextual_urgency_assessment(message):
        if is_amharic:
            reply = (
                "⚠️ **አስቸኳይ ክሊኒካዊ እርምጃ (በ72 ሰዓታት ውስጥ):**\n\n"
                "ጥንቃቄ የጎደለው ግንኙነት ካጋጠመዎት ሰዓቱ ወሳኝ ነው:\n"
                "1. **ኤች.አይ.ቪን ለመከላከል (PEP):** በ**72 ሰዓታት (3 ቀናት)** ውስጥ ወደ ጤና ተቋም በመሄድ የPEP መድኃኒት በነፃ መጀመር አለብዎት።\n"
                "2. **ያልተፈለገ እርግዝናን ለመከላከል:** የድንገተኛ የወሊድ መከላከያ እንክብል (Postinor-2 / Postpill) በ72 ሰዓታት ውስጥ በማንኛውም ፋርማሲ ያለ ማዘዣ ይገኛል።"
                + referral
            )
            return ChatResponse(
                reply=reply,
                category="አስቸኳይ ክሊኒካዊ እርምጃ",
                is_urgent=True,
                referral_partner="የመንግስት ጤና ጣቢያ / ማሪ ስቶፕስ / FGAE / 8335",
                follow_up_questions=["PEP እንዴት ይሰራል?", "Postpill የት ይገኛል?", "በነፃ የስልክ መስመር 8335 መደወል"],
                source="TenaWise Offline Clinical Engine"
            )
        else:
            reply = (
                "⚠️ **URGENT CLINICAL TIMELINE (Within 72 Hours):**\n\n"
                "If you experienced potential exposure or a broken condom, timing is critical:\n"
                "1. **HIV Prevention (PEP):** You must begin Post-Exposure Prophylaxis (PEP) within **72 hours (3 days)**. It is 100% free at public health centers.\n"
                "2. **Emergency Contraception:** Take Postinor-2 / Postpill as soon as possible to delay ovulation."
                + referral
            )
            return ChatResponse(
                reply=reply,
                category="Emergency Clinical Triage",
                is_urgent=True,
                referral_partner="Public Health Center / Marie Stopes / FGAE / Helpline 8335",
                follow_up_questions=["How does PEP work?", "Where can I get emergency contraception?", "Call Toll-Free 8335"],
                source="TenaWise Offline Clinical Engine"
            )

    # 3. Pregnancy / Conception Inquiries
    if _is_pregnancy_inquiry(message):
        if is_amharic:
            reply = (
                "🤰 **እርግዝና እንዴት ይታወቃል? እና የመፀነስ ጊዜ:**\n\n"
                "1. **የመፀነስ ጊዜ (የእንቁላል መውጣት):** በ28 ቀናት የወር አበባ ዑደት ውስጥ ሴት ልጅ ልታረግዝ የምትችለው በሚቀጥለው የወር አበባ ከመምጣቱ 14 ቀናት ቀደም ብሎ (በእንቁላል መውጫ ዙሪያ ባሉት 5 ቀናት ውስጥ) ነው።\n"
                "2. **የመጀመሪያ ምልክቶች:** የወር አበባ መቅረት (መዘግየት)፣ የጡት ህመም ወይም ማበጥ፣ ቶሎ ቶሎ ማቅለሽለሽ፣ የድካም ስሜት።\n"
                "3. **የእርግዝና ምርመራ (hCG Strip):** የወር አበባ ከቀረበት የመጀመሪያ ቀን ጀምሮ በማንኛውም ፋርማሲ በሚገኝ ቀላል የሽንት ምርመራ ማረጋገጥ ይቻላል።"
                + referral
            )
            return ChatResponse(
                reply=reply,
                category="እርግዝና እና የመፀነስ ጤና",
                is_urgent=False,
                referral_partner="የአካባቢ ጤና ጣቢያ / FGAE",
                follow_up_questions=["የወር አበባ ዑደትን እንዴት መቁጠር ይቻላል?", "የእርግዝና ምርመራ መቼ መደረግ አለበት?", "ቅድመ ወሊድ ክትትል (ANC)"],
                source="TenaWise Offline Clinical Engine"
            )
        else:
            reply = (
                "🤰 **How Conception Works & Early Signs of Pregnancy:**\n\n"
                "1. **The Fertile Window (Ovulation):** Conception occurs when sperm fertilizes an egg. In a typical 28-day cycle, ovulation happens around Day 14 (about 12–16 days before the next period). The fertile window is the 5 days before ovulation plus ovulation day itself.\n"
                "2. **Early Signs:** The earliest reliable sign is a **missed menstrual period**, along with breast tenderness, fatigue, frequent urination, and mild nausea.\n"
                "3. **Confirmation (Pregnancy Test):** A urine home pregnancy test (detecting hCG hormone) is accurate starting from the first day of a missed period (approx. 14 days after conception). Testing too early may yield a false negative.\n"
                "4. **Clinical Ultrasound & Care:** A healthcare provider at a Woreda Health Center can confirm via blood test or ultrasound and start Antenatal Care (ANC)."
                + referral
            )
            return ChatResponse(
                reply=reply,
                category="Pregnancy & Conception",
                is_urgent=False,
                referral_partner="Woreda Health Center / Marie Stopes / FGAE",
                follow_up_questions=["How to calculate the fertile window?", "When to take a pregnancy test?", "Antenatal care (ANC) services in Ethiopia"],
                source="TenaWise Offline Clinical Engine"
            )

    # 4. Educational / Concept query fallback
    if is_amharic:
        return ChatResponse(
            reply="ጤና ዋይዝ ስለ ስነ-ተዋልዶ ጤና የተረጋገጠ መረጃ ይሰጣል። ስለ ወሊድ መከላከያ ዘዴዎች (Postpill፣ የ3 ወር መርፌ፣ ጃዴል፣ ሳያና ፕሬስ)፣ የአባለዘር በሽታዎች፣ ኤች.አይ.ቪ (PEP/PrEP) እና የወር አበባ ዑደት ማንኛውንም ጥያቄ መጠየቅ ይችላሉ። ለግል ክሊኒካዊ ምክር በነፃ መስመር 8335 ይደውሉ።",
            category="SRH Education",
            is_urgent=False,
            follow_up_questions=["PEP ምንድን ነው?", "የወሊድ መከላከያ ዘዴዎች በሙሉ ምን ምን ናቸው?", "የኤች.አይ.ቪ ምልክቶች ምንድን ናቸው?"],
            source="TenaWise Offline Clinical Engine"
        )
    else:
        return ChatResponse(
            reply="TenaWise provides peer-reviewed education on contraception (emergency pills, implants, injectables including DMPA-SC), STI/HIV prevention, menstrual health, and reproductive rights. In Ethiopia, you can also dial 8335 for free confidential youth counseling.",
            category="SRH Education",
            is_urgent=False,
            follow_up_questions=["What is PEP?", "Compare all birth control methods", "How does human conception work?"],
            source="TenaWise Offline Clinical Engine"
        )

# LLM Provider Configuration: 'auto' (checks Ollama first, then Gemini), 'ollama', or 'gemini'
LLM_PROVIDER = os.getenv("LLM_PROVIDER", "auto").lower()
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "qwen2.5:3b")

def _check_ollama_available() -> bool:
    """Checks if local Ollama server is running and accessible."""
    try:
        r = requests.get(f"{OLLAMA_URL}/api/tags", timeout=3.0)
        return r.status_code == 200
    except Exception:
        return False

def _build_history_text(history: List[ChatMessage]) -> str:
    """Formats the last 6 messages (3 turns) of conversation history into a readable prompt block.
    This gives Ollama memory of the recent conversation so it can reply in context.
    """
    if not history:
        return ""
    recent = history[-6:]  # keep last 3 user+assistant pairs to stay within token limits
    lines = []
    for msg in recent:
        role_label = "User" if msg.role == "user" else "TenaWise Assistant"
        lines.append(f"{role_label}: {msg.content}")
    return "### Conversation History (Most Recent First):\n" + "\n".join(lines) + "\n"


def _query_ollama(prompt: str, is_amharic: bool) -> Optional[ChatResponse]:
    """Queries local Ollama instance (e.g. qwen2.5:3b) with MoH RAG context."""
    try:
        payload = {
            "model": OLLAMA_MODEL,
            "prompt": prompt,
            "stream": False,
            "options": {
                "temperature": 0.3,
                "num_predict": 450,
            }
        }
        res = requests.post(f"{OLLAMA_URL}/api/generate", json=payload, timeout=45)
        if res.status_code == 200:
            text = res.json().get("response", "").strip()
            if text:
                is_urgent = _contextual_urgency_assessment(prompt)
                referral = _build_referral_text(is_amharic) if is_urgent else None
                reply = text + (f"\n\n{referral}" if is_urgent and referral and "8335" not in text else "")
                
                return ChatResponse(
                    reply=reply,
                    category="Emergency Clinical Triage" if is_urgent else "TenaWise Local AI",
                    is_urgent=is_urgent,
                    referral_partner="Woreda Health Center / Marie Stopes / FGAE / 8335" if is_urgent else None,
                    follow_up_questions=[
                        "ስለ ድንገተኛ መከላከያ ተጨማሪ ማወቅ እፈልጋለሁ" if is_amharic else "How does emergency contraception work?",
                        "በአቅራቢያዬ ያለ ነፃ ጤና ጣቢያ የት ይገኛል?" if is_amharic else "Where can I access free youth-friendly health services?",
                        "የአደጋ ጊዜ ስልክ 8335" if is_amharic else "Toll-free youth helpline 8335"
                    ],
                    source=f"Local Ollama ({OLLAMA_MODEL}) via TenaWise"
                )
    except Exception as e:
        print(f"[*] Ollama query failed: {e}", file=sys.stderr)
    return None

@app.get("/")
def health_check():
    has_gemini = bool(os.getenv("GEMINI_API_KEY"))
    ollama_ok = _check_ollama_available()
    chunks_count = len(clinical_retriever.local_index) if (clinical_retriever and clinical_retriever.local_index) else 0
    return {
        "status": "healthy",
        "app": "TenaWise SRH AI Chatbot",
        "llm_provider": LLM_PROVIDER,
        "local_ollama": {
            "available": ollama_ok,
            "model": OLLAMA_MODEL if ollama_ok else None
        },
        "gemini_configured": has_gemini,
        "knowledge_guidelines_indexed": chunks_count,
        "language_support": ["Amharic", "English"],
        "hotlines": {
            "youth_srh_hotline": "8335 (Toll-Free in Ethiopia)",
            "gbv_hotline": "6788 (Toll-Free)"
        },
        "clinical_partners": [
            "Government Woreda Health Centers & Hospitals",
            "Marie Stopes Ethiopia",
            "Family Guidance Association of Ethiopia (FGAE)"
        ]
    }

# Active model candidates in priority order (gemini-3.1-flash-lite is active and fast)
GEMINI_MODELS = [
    "gemini-3.1-flash-lite",
    "gemini-3-flash-preview",
    "gemini-flash-latest",
    "gemini-3.8-flash",
]

@app.post("/api/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    api_key = os.getenv("GEMINI_API_KEY")
    is_amharic = request.language == "am" or any(ord(c) >= 0x1200 and ord(c) <= 0x137F for c in request.message)

    # 1. Retrieve verified passages from Ethiopian MoH / WHO documents
    retrieved_passages = []
    rag_context = ""
    if clinical_retriever:
        retrieved_passages = clinical_retriever.search(request.message, top_k=3)
        if retrieved_passages:
            rag_context = clinical_retriever.format_context_for_prompt(retrieved_passages)

    # 2. Check Local Ollama (Privacy-first, 100% offline) if enabled
    if LLM_PROVIDER in ["auto", "ollama"] and _check_ollama_available():
        # Build conversation history block so Ollama remembers previous turns
        history_text = _build_history_text(request.history or [])
        ollama_prompt = (
            f"{SRH_SYSTEM_PROMPT}\n\n"
            f"{rag_context}\n\n"
            f"{history_text}\n"
            f"User Question: {request.message}\n"
            f"Language Preferred: {'Amharic' if is_amharic else 'English'}\n\n"
            f"Provide a clear, culturally sensitive, non-judgmental, and medically accurate response "
            f"based on the Ethiopian MoH and WHO guidelines above."
        )
        ollama_res = _query_ollama(ollama_prompt, is_amharic)
        if ollama_res:
            return ollama_res
        if LLM_PROVIDER == "ollama":
            # If user explicitly set provider to ollama, don't fall back to cloud
            return _generate_fallback_response(request.message, is_amharic)

    # 3. Fallback to Gemini if Ollama is not active and API key exists
    if not api_key:
        return _generate_fallback_response(request.message, is_amharic)

    try:
        from google import genai
        client = genai.Client(api_key=api_key)

        # Explicit instructions for JSON structure with clinical urgency assessment
        triage_instructions = """
You MUST perform a clinical triage of the user's situation based on CONTEXT, not just keywords:
- CRITICAL CRISIS / ASSAULT PROTOCOL:
  If the user mentions or asks about sexual assault, rape, coercion, or crisis:
  1. ALWAYS begin with immediate trauma-informed reassurance: "First and most importantly: You are safe, and what happened is NOT your fault."
  2. Directly address ALL specific information and questions asked by the user (e.g. if they asked about physical steps, explain the 72h PEP timeline, emergency contraception, and evidence preservation; if they asked about psychological steps, explain emotional grounding, confiding in trusted support, and trauma counseling).
  3. Emphasize that Post-Exposure Prophylaxis (PEP) must begin within 72 hours and is 100% free in public health centers.
  4. Always include referrals to Ethiopian helplines: Toll-Free Youth Helpline 8335 and National GBV Helpline 6788.

- Set "is_urgent": true ONLY if the user is describing an actual, acute personal situation that requires immediate clinical action within 72 hours (e.g. recent unprotected sex, condom broke during intercourse, assault, severe pain, heavy bleeding).
- Set "is_urgent": false if the user is asking an educational, historical, or theoretical question (e.g. "What is PEP?", "Explain contraception", "What is unprotected sex?").
- If urgent or recommending a clinical visit, ALWAYS include referrals to:
  1. Nearest Government Woreda Health Center / Hospital (for 100% free PEP & care within 72h)
  2. Marie Stopes Ethiopia (MSE) Clinics
  3. Family Guidance Association of Ethiopia (FGAE) Youth Centers
  4. Toll-Free Youth Helpline: 8335
  5. National GBV Helpline: 6788

Output format: Return ONLY a valid JSON object with these keys:
{
  "reply": "string (your comprehensive, empathetic response with formatting)",
  "category": "string (e.g. 'Crisis Intervention', 'Emergency Triage', 'Contraception', 'STI Education')",
  "is_urgent": boolean,
  "referral_partner": "string or null",
  "follow_up_questions": ["string", "string", "string"]
}
"""

        prompt_content = f"{SRH_SYSTEM_PROMPT}\n\n{rag_context}\n\n{triage_instructions}\n\nUser Question: {request.message}\nLanguage Preferred: {'Amharic' if is_amharic else 'English'}"

        response = None
        chosen_model = None
        last_error = None

        # Resilient model cascade: try fast & active models
        for model_name in GEMINI_MODELS:
            try:
                response = client.models.generate_content(
                    model=model_name,
                    contents=prompt_content,
                )
                if response and response.text:
                    chosen_model = model_name
                    break
            except Exception as err:
                last_error = err
                print(f"Model {model_name} failed: {err}. Trying next candidate...", file=sys.stderr)
                continue

        if not response or not chosen_model:
            raise last_error or RuntimeError("All Gemini candidate models failed to respond.")

        response_text = response.text or "{}"
        
        # Parse JSON from Gemini response (handles code blocks ```json ... ``` gracefully)
        json_match = re.search(r'\{.*\}', response_text, re.DOTALL)
        if json_match:
            try:
                data = json.loads(json_match.group(0))
                reply = data.get("reply", response_text)
                category = data.get("category", "TenaWise SRH AI")
                is_urgent = bool(data.get("is_urgent", False))
                referral = data.get("referral_partner")
                follow_ups = data.get("follow_up_questions", [])

                return ChatResponse(
                    reply=reply,
                    category=category,
                    is_urgent=is_urgent,
                    referral_partner=referral,
                    follow_up_questions=follow_ups if isinstance(follow_ups, list) else [],
                    source=f"Gemini AI ({chosen_model}) via TenaWise"
                )
            except Exception:
                pass

        # Fallback parsing if JSON wasn't structured
        is_urgent = _contextual_urgency_assessment(request.message)
        return ChatResponse(
            reply=response_text,
            category="TenaWise SRH AI",
            is_urgent=is_urgent,
            referral_partner="Woreda Health Center / Marie Stopes / FGAE / 8335" if is_urgent else None,
            follow_up_questions=[
                "የወሊድ መከላከያ ዘዴዎች ምን ምን ናቸው?" if is_amharic else "What are common contraception options?",
                "በአቅራቢያዬ ያለ ነፃ ጤና ጣቢያ የት ይገኛል?" if is_amharic else "Where can I find free youth clinics?",
                "የአደጋ ጊዜ ስልክ 8335" if is_amharic else "Toll-free youth helpline 8335"
            ],
            source=f"Gemini AI ({chosen_model}) via TenaWise"
        )
    except Exception as e:
        print(f"Error invoking Gemini API: {e}", file=sys.stderr)
        return _generate_fallback_response(request.message, is_amharic)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app:app", host="127.0.0.1", port=8000, reload=True)
