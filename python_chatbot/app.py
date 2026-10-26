import os
import sys
import json
import re
from typing import List, Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

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

def _contextual_urgency_assessment(text: str) -> bool:
    """Smart contextual assessment for offline fallback mode.
    Distinguishes theoretical/educational queries from active emergencies.
    """
    lowered = text.lower()

    # If the user is explicitly asking for a definition or educational explanation, do NOT flag as urgent
    educational_patterns = [
        "what is", "what are", "define", "definition", "explain", "meaning of", "how does it work",
        "difference between", "tell me about", "history of", "can you explain",
        "ምንድን ነው", "ምን ማለት ነው", "አብራራልኝ", "ትርጉም", "ስለ", "ልዩነቱ"
    ]
    if any(p in lowered for p in educational_patterns):
        return False

    # Active temporal emergency indicators (recent event within critical 72h window, acute distress, or assault)
    emergency_patterns = [
        "hours ago", "hour ago", "yesterday", "last night", "today", "just happened",
        "forced me", "raped", "assaulted", "broke during", "condom broke",
        "bleeding heavily", "severe pain", "terrified", "need pep now",
        "ሰዓት በፊት", "ትናንት", "ዛሬ", "አሁን", "አስገደደኝ", "ተደፈርኩ", "ተገደድኩ", "ኮንዶም ተቀደደብን", "ደሜ አልቆመም"
    ]
    return any(p in lowered for p in emergency_patterns)

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
    is_urgent = _contextual_urgency_assessment(message)

    if is_urgent:
        referral = _build_referral_text(is_amharic)
        if is_amharic:
            reply = (
                "⚠️ **አስቸኳይ ክሊኒካዊ እርምጃ (በ72 ሰዓታት ውስጥ):**\n\n"
                "ጥንቃቄ የጎደለው ግንኙነት ካጋጠመዎት ወይም ኮንዶም ከተቀደደ ሰዓቱ ወሳኝ ነው:\n"
                "1. **ኤች.አይ.ቪን ለመከላከል (PEP):** ክስተቱ በተፈጠረ በ**72 ሰዓታት (3 ቀናት)** ውስጥ ወደ ጤና ተቋም በመሄድ የPEP መድኃኒት በነፃ መጀመር አለብዎት።\n"
                "2. **ያልተፈለገ እርግዝናን ለመከላከል:** የድንገተኛ የወሊድ መከላከያ እንክብል (Postinor-2 / Postpill) በ72 ሰዓታት ውስጥ በማንኛውም ፋርማሲ ያለ ማዘዣ ይገኛል።"
                + referral
            )
            return ChatResponse(
                reply=reply,
                category="አስቸኳይ ክሊኒካዊ እርምጃ",
                is_urgent=True,
                referral_partner="የመንግስት ጤና ጣቢያ / ማሪ ስቶፕስ / FGAE / 8335",
                followUpQuestions=["PEP እንዴት ይሰራል?", "Postpill የት ይገኛል?", "በነፃ የስልክ መስመር 8335 መደወል"],
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
                followUpQuestions=["How does PEP work?", "Where can I get emergency contraception?", "Call Toll-Free 8335"],
                source="TenaWise Offline Clinical Engine"
            )

    # Educational / Concept query fallback
    if is_amharic:
        return ChatResponse(
            reply="ጤና ዋይዝ ስለ ስነ-ተዋልዶ ጤና የተረጋገጠ መረጃ ይሰጣል። ስለ ወሊድ መከላከያ ዘዴዎች (Postpill፣ የ3 ወር መርፌ፣ ጃዴል፣ ሳያና ፕሬስ)፣ የአባለዘር በሽታዎች፣ ኤች.አይ.ቪ (PEP/PrEP) እና የወር አበባ ዑደት ማንኛውንም ጥያቄ መጠየቅ ይችላሉ። ለግል ክሊኒካዊ ምክር በነፃ መስመር 8335 ይደውሉ።",
            category="SRH Education",
            is_urgent=False,
            followUpQuestions=["PEP ምንድን ነው?", "የወሊድ መከላከያ ዘዴዎች በሙሉ ምን ምን ናቸው?", "የኤች.አይ.ቪ ምልክቶች ምንድን ናቸው?"],
            source="TenaWise Offline Clinical Engine"
        )
    else:
        return ChatResponse(
            reply="TenaWise provides peer-reviewed education on contraception (emergency pills, implants, injectables including DMPA-SC), STI/HIV prevention, menstrual health, and reproductive rights. In Ethiopia, you can also dial 8335 for free confidential youth counseling.",
            category="SRH Education",
            is_urgent=False,
            followUpQuestions=["What is PEP?", "Compare all birth control methods", "How does human conception work?"],
            source="TenaWise Offline Clinical Engine"
        )

@app.get("/")
def health_check():
    has_gemini = bool(os.getenv("GEMINI_API_KEY"))
    return {
        "status": "healthy",
        "app": "TenaWise SRH AI Chatbot",
        "gemini_configured": has_gemini,
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

@app.post("/api/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    api_key = os.getenv("GEMINI_API_KEY")
    is_amharic = request.language == "am" or any(ord(c) >= 0x1200 and ord(c) <= 0x137F for c in request.message)

    # If no API key configured, use intelligent clinical fallback
    if not api_key:
        return _generate_fallback_response(request.message, is_amharic)

    try:
        from google import genai
        client = genai.Client(api_key=api_key)

        # Explicit instructions for JSON structure with clinical urgency assessment
        triage_instructions = """
You MUST perform a clinical triage of the user's situation based on CONTEXT, not just keywords:
- Set "is_urgent": true ONLY if the user is describing an actual, acute personal situation that requires immediate clinical action within 72 hours (e.g. recent unprotected sex, condom broke during intercourse, assault, severe pain, heavy bleeding).
- Set "is_urgent": false if the user is asking an educational, historical, or theoretical question (e.g. "What is PEP?", "Explain contraception", "What is unprotected sex?").
- If urgent or recommending a clinical visit, ALWAYS include referrals to:
  1. Nearest Government Woreda Health Center / Hospital (for 100% free PEP & care within 72h)
  2. Marie Stopes Ethiopia (MSE) Clinics
  3. Family Guidance Association of Ethiopia (FGAE) Youth Centers
  4. Toll-Free Youth Hotline: 8335
  5. GBV Helpline: 6788

Output format: Return ONLY a valid JSON object with these keys:
{
  "reply": "string (your comprehensive, empathetic response with formatting)",
  "category": "string (e.g. 'Emergency Triage', 'Contraception', 'STI Education')",
  "is_urgent": boolean,
  "referral_partner": "string or null",
  "follow_up_questions": ["string", "string", "string"]
}
"""

        prompt_content = f"{SRH_SYSTEM_PROMPT}\n\n{triage_instructions}\n\nUser Question: {request.message}\nLanguage Preferred: {'Amharic' if is_amharic else 'English'}"

        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt_content,
        )

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
                    source="Gemini 2.5 Flash via TenaWise"
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
            source="Gemini 2.5 Flash via TenaWise"
        )
    except Exception as e:
        print(f"Error invoking Gemini API: {e}", file=sys.stderr)
        return _generate_fallback_response(request.message, is_amharic)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app:app", host="0.0.0.0", port=8000, reload=True)
