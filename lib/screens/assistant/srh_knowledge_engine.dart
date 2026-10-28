/// Response model returned by the SRH Knowledge Engine
class SrhResponse {
  final String text;
  final String category;
  final List<String> followUpQuestions;
  final bool isUrgent;

  const SrhResponse({
    required this.text,
    required this.category,
    required this.followUpQuestions,
    this.isUrgent = false,
  });
}

/// An offline-first, culturally sensitive, peer-reviewed Sexual and Reproductive Health (SRH)
/// expert intelligence engine tailored specifically for youth in Ethiopia.
/// Supports both broad conceptual mastery (physiology, reproductive biology, contraception comparison,
/// sexual rights, endocrine cycle) and granular clinical answers.
class SrhKnowledgeEngine {
  /// Analyzes the query and returns a medically accurate, empathetic response.
  static SrhResponse getResponse(String rawQuery, bool isAmharic) {
    final query = rawQuery.trim().toLowerCase();

    // 0. CRISIS & ASSAULT INTERVENTION (Immediate trauma-informed compassion, physical & psychological steps)
    if (_matchesAny(query, [
      'raped', 'rape', 'assault', 'assaulted', 'sexual assault', 'forced me', 'against my will', 'violated',
      'ተደፈር', 'ተገደድ', 'አስገደደኝ', 'የፆታ ጥቃት'
    ])) {
      return _getAssaultCrisisResponse(isAmharic);
    }

    // Distinguish between educational inquiries vs active clinical emergencies
    final isEducational = _matchesAny(query, [
      'what is', 'what are', 'what does', 'define', 'definition', 'explain', 'meaning of', 'means', 'how does it work',
      'how does pep work', 'difference between', 'tell me about', 'history of', 'can you explain',
      'ምንድን ነው', 'ምን ማለት ነው', 'አብራራልኝ', 'ትርጉም', 'ስለ', 'ልዩነቱ'
    ]);

    // Educational Question about PEP (Not an emergency!)
    if (isEducational && _matchesAny(query, ['pep', 'post exposure', 'ፖስት ኤክስፖዠር'])) {
      return _getPepEducationalResponse(isAmharic);
    }

    // 1. ACTIVE CLINICAL EMERGENCY TRIAGE (Personal incident within 72h, broken condom, hemorrhage)
    final hasActiveEmergency = _matchesAny(query, [
      'condom broke', 'broke during', 'yesterday', 'hours ago', 'last night',
      'just happened', 'bleeding heavily', 'emergency', 'help me',
      'ኮንዶም ተቀደደ', 'ትናንት', 'ሰዓት በፊት', 'ደሜ አልቆመም', 'አስቸኳይ'
    ]) || (!isEducational && _matchesAny(query, ['pep', '72 hour', '72 ሰዓት']));

    if (hasActiveEmergency) {
      return _getUrgentResponse(isAmharic);
    }

    // 2. BROAD CONCEPT: What is Sexual & Reproductive Health (SRH)?
    if (_matchesAny(query, [
      'what is srh', 'sexual and reproductive health', 'reproductive health', 'srh meaning',
      'what is sexual health', 'overview of srh', 'srh concept', 'pillars of srh',
      'ስነ ተዋልዶ', 'ስነ-ተዋልዶ', 'የስነ-ተዋልዶ ጤና', 'የስነ ተዋልዶ ጤና ማለት ምን ማለት ነው', 'ፅንሰ ሀሳብ'
    ])) {
      return _getBroadSrhConceptResponse(isAmharic);
    }

    // 3. BROAD CONCEPT: How Human Reproduction & Conception Works (Biology of Pregnancy)
    if (_matchesAny(query, [
      'how does pregnancy happen', 'how does conception work', 'fertilization', 'how do people get pregnant',
      'biology of reproduction', 'human reproduction', 'implantation', 'sperm meets egg',
      'pregnant', 'pregnancy', 'wife would be pregnant', 'know if pregnant', 'am i pregnant', 'is she pregnant',
      'signs of pregnancy', 'early pregnancy', 'fertile window',
      'እርግዝና እንዴት ይፈጠራል', 'ፅንስ እንዴት', 'መራባት', 'የሰው ዘር መራባት', 'እንቁላል ማዳቀል', 'እርግዝና', 'እርጉዝ'
    ])) {
      return _getReproductionBiologyResponse(isAmharic);
    }

    // 4. BROAD CONCEPT: Comprehensive Contraception Master Guide & Comparison
    if (_matchesAny(query, [
      'all contraception', 'birth control methods', 'types of contraception', 'compare contraception',
      'contraceptive options', 'family planning methods', 'which birth control is best',
      'የወሊድ መከላከያ ዘዴዎች በሙሉ', 'የወሊድ መከላከያ ዓይነቶች', 'የመከላከያ ዘዴዎች', 'የቤተሰብ ምጣኔ', 'የትኛው መከላከያ ይሻላል'
    ])) {
      return _getComprehensiveContraceptionGuide(isAmharic);
    }

    // 5. BROAD CONCEPT: Menstrual Cycle Endocrine Physiology & Hormones
    if (_matchesAny(query, [
      'menstrual cycle phases', 'explain menstrual cycle', 'how does menstruation work', 'estrogen and progesterone',
      'ovulation biology', 'follicular phase', 'luteal phase', 'hormones in cycle',
      'የወር አበባ ዑደት ደረጃዎች', 'የሆርሞን ለውጥ', 'ዑደት እንዴት ይሰራል', 'የእንቁላል ዑደት'
    ])) {
      return _getMenstrualCycleBiologyGuide(isAmharic);
    }

    // 6. BROAD CONCEPT: STI Pathophysiology, Transmission & Complications
    if (_matchesAny(query, [
      'types of stis', 'all stis', 'sexually transmitted infections overview', 'sti complications',
      'bacterial vs viral sti', 'how do stis spread', 'pelvic inflammatory disease',
      'የአባለዘር በሽታዎች ዓይነቶች', 'ስለ አባለዘር በሽታ አጠቃላይ', 'የአባለዘር በሽታዎች ጉዳት'
    ])) {
      return _getStiComprehensiveGuide(isAmharic);
    }

    // 7. BROAD CONCEPT: Sexual Rights, Bodily Autonomy & Consent
    if (_matchesAny(query, [
      'reproductive rights', 'bodily autonomy', 'sexual rights', 'what is consent', 'consent in relationships',
      'fries consent', 'sexual coercion', 'coercion', 'healthy relationship',
      'የስነ ተዋልዶ መብት', 'የሰውነት ነፃነት', 'ስምምነት ማለት', 'መብቴ', 'ጤናማ ግንኙነት'
    ])) {
      return _getReproductiveRightsAndConsentGuide(isAmharic);
    }

    // 8. BROAD CONCEPT: Ethiopian Myths vs Scientific Medical Facts
    if (_matchesAny(query, [
      'myths', 'misconceptions', 'taboos', 'common myths in ethiopia', 'myths about sex', 'false beliefs',
      'የተሳሳቱ አመለካከቶች', 'የተሳሳተ ወሬ', 'እውነታዎች', 'አጉል እምነት', 'ሀሰት'
    ])) {
      return _getEthiopianMythsAndFactsGuide(isAmharic);
    }

    // 9. Specific: Emergency Contraception (Postpill / Postinor)
    if (_matchesAny(query, [
      'postpill', 'postinor', 'emergency pill', 'morning after', 'ecp', 'prevent pregnancy after',
      'ድንገተኛ', 'ፖስትፒል', 'ፖስቲኖር', 'እርግዝና መከላከያ እንክብል', 'ግንኙነት በኋላ'
    ])) {
      return _getEmergencyContraceptionResponse(isAmharic);
    }

    // 10. Specific: Implants (Jadelle / Implanon)
    if (_matchesAny(query, [
      'implant', 'jadelle', 'implanon', 'norplant', 'arm implant', 'rod',
      'ኢምፕላንት', 'ጃዴል', 'ክንድ', 'የክንድ መከላከያ', 'የ3 አመት', 'የ5 አመት'
    ])) {
      return _getImplantsResponse(isAmharic);
    }

    // 11. Specific: DMPA-SC / Sayana Press (Self-injectable modern 3-month contraception)
    if (_matchesAny(query, [
      'dmpasc', 'dmpa-sc', 'dmpa_sc', 'dmpa sc', 'dmpa', 'sayana press', 'sayana', 'subcutaneous', 'self injection', 'self-inject',
      'ሳያና ፕሬስ', 'ሳያና', 'በራስ የሚወጋ መርፌ', 'ዲኤምፒኤ'
    ])) {
      return _getDmpaScResponse(isAmharic);
    }

    // 12. Specific: Injectables (Depo-Provera / DMPA-IM 3-month shot)
    if (_matchesAny(query, [
      'depo', 'provera', 'injection', 'injectable', 'shot', 'spotting', 'irregular bleeding',
      'መርፌ', 'የ3 ወር መርፌ', 'ደፈረሰ', 'ደም መፍሰስ', 'የወር አበባ መዛባት'
    ])) {
      return _getInjectablesResponse(isAmharic);
    }

    // 12. Specific: IUD (Copper-T / Loop / Hormonal Coil)
    if (_matchesAny(query, [
      'iud', 'iucd', 'copper', 'loop', 'coil', 'mirena',
      'ሉፕ', 'አይዩዲ', 'የማህፀን ሉፕ', 'ኮፐር'
    ])) {
      return _getIudResponse(isAmharic);
    }

    // 13. Specific: Condoms & Barrier Methods
    if (_matchesAny(query, [
      'condom', 'sensation', 'dkt', 'latex', 'dual protection', 'free condom',
      'ኮንዶም', 'ነፃ ኮንዶም', 'ሴንሴሽን', 'አጠቃቀም'
    ])) {
      return _getCondomsResponse(isAmharic);
    }

    // 14. Specific: Oral Contraceptive Pills (Daily Pills)
    if (_matchesAny(query, [
      'daily pill', 'oral contraceptive', 'birth control pill', 'missed a pill', 'combined pill',
      'የየዕለት እንክብል', 'እንክብል ረሳሁ', 'የወሊድ እንክብል'
    ])) {
      return _getOralPillsResponse(isAmharic);
    }

    // 15. Specific: HIV, Testing & Window Period
    if (_matchesAny(query, [
      'hiv', 'aids', 'virus', 'window period', 'rapid test', 'positive', 'cd4', 'art',
      'ኤችአይቪ', 'ኤድስ', 'የደም ምርመራ', 'ቫይረስ', 'ምርመራ'
    ])) {
      return _getHivResponse(isAmharic);
    }

    // 16. Specific: PrEP (Pre-Exposure Prophylaxis)
    if (_matchesAny(query, [
      'prep', 'pre exposure', 'prevent hiv before',
      'ፕሪፕ', 'ከመገናኘት በፊት'
    ])) {
      return _getPrepResponse(isAmharic);
    }

    // 17. Specific: HPV (Human Papillomavirus / የማህፀን በር ካንሰር አምጪ ቫይረስ)
    if (_matchesAny(query, [
      'hpv', 'human papilloma', 'papillomavirus', 'cervical cancer', 'genital warts',
      'ኤችፒቪ', 'የሰው ፓፒሎማ ቫይረስ', 'የማህፀን በር ጫፍ ካንሰር'
    ])) {
      return _getHpvResponse(isAmharic);
    }

    // 18. Specific: STIs & Genital Symptoms (Syphilis, Gonorrhea, Chlamydia, Discharge)
    if (_matchesAny(query, [
      'sti', 'std', 'syphilis', 'gonorrhea', 'chlamydia', 'discharge', 'smell', 'odor', 'burning', 'itching', 'ulcer', 'sores', 'bumps',
      'አባለዘር', 'ፈሳሽ', 'ማሳከክ', 'ቁስል', 'ማቃጠል', 'ጨብጥ', 'ቂጥኝ'
    ])) {
      return _getStiResponse(isAmharic);
    }

    // 18. Specific: Menstrual Cycle, Ovulation & Safe Period
    if (_matchesAny(query, [
      'cycle', 'ovulation', 'fertile window', 'safe period', 'calendar method', 'get pregnant', 'calendar',
      'ዑደት', 'እንቁላል', 'እርግዝና የሚፈጠርበት', 'አስተማማኝ ቀናት', 'የወር አበባ ቀን'
    ])) {
      return _getCycleAndOvulationResponse(isAmharic);
    }

    // 19. Specific: Period Cramps & Dysmenorrhea
    if (_matchesAny(query, [
      'cramp', 'period pain', 'dysmenorrhea', 'menstrual pain', 'stomach hurt',
      'ቁርጠት', 'የወር አበባ ህመም', 'ማህፀን ህመም', 'ህመም'
    ])) {
      return _getCrampsResponse(isAmharic);
    }

    // 20. Specific: Puberty, Wet Dreams & Body Changes
    if (_matchesAny(query, [
      'puberty', 'wet dream', 'nocturnal emission', 'breast', 'voice breaking', 'hair growth',
      'የጉርምስና', 'የእንቅልፍ ፈሳሽ', 'ጡት', 'የሰውነት ለውጥ'
    ])) {
      return _getPubertyResponse(isAmharic);
    }

    // 21. Specific: Masturbation Myths & Sexual Health
    if (_matchesAny(query, [
      'masturbat', 'self pleasure', 'myth', 'blindness', 'infertility', 'guilt',
      'ራስን ማርካት', 'ማስተርቤሽን', 'ጉዳት'
    ])) {
      return _getMasturbationResponse(isAmharic);
    }

    // 22. Clinics & Hotlines in Ethiopia
    if (_matchesAny(query, [
      'clinic', 'hospital', 'marie stopes', 'fgae', 'hotline', 'phone', 'helpline', 'addis ababa', 'ethiopia', 'where to go',
      'ክሊኒክ', 'ማሪ ስቶፕስ', 'ኤፍጂኤኢ', 'ስልክ', '8335', 'ነፃ የስልክ መስመር'
    ])) {
      return _getClinicsResponse(isAmharic);
    }

    // Default Fallback
    return _getDefaultResponse(isAmharic);
  }

  static bool _matchesAny(String query, List<String> keywords) {
    for (final kw in keywords) {
      if (query.contains(kw)) return true;
    }
    return false;
  }

  // ==========================================
  // COMPREHENSIVE CONCEPTUAL MASTER MODULES
  // ==========================================

  static SrhResponse _getBroadSrhConceptResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የስነ-ተዋልዶ ጤና (SRH) ፅንሰ-ሀሳብ',
        text: '🌿 **የስነ-ተዋልዶ ጤና (SRH) አጠቃላይ ፅንሰ-ሀሳብ እና ማዕከሎች:**\n\n'
            'የዓለም ጤና ድርጅት (WHO) እና የኢትዮጵያ ጤና ጥበቃ ሚኒስቴር እንደሚያስቀምጡት፣ **የስነ-ተዋልዶ ጤና** ማለት በሽታ ወይም የአካል ጉዳት አለመኖር ብቻ ሳይሆን፤ ከስነ-ተዋልዶ ስርዓት፣ ተግባር እና ሂደት ጋር በተያያዘ ሙሉ **አካላዊ፣ አእምሯዊ እና ማህበራዊ ደህንነት** መኖር ነው።\n\n'
            '📌 **የስነ-ተዋልዶ ጤና 5ቱ ዋና ዋና ምሰሶዎች:**\n\n'
            '1. **የቤተሰብ ምጣኔ እና የወሊድ መከላከያ (Family Planning):**\n'
            '   እያንዳንዱ ግለሰብ መቼ፣ በምን ያህል ልዩነት እና ስንት ልጆች መውለድ እንዳለበት በነፃነት እና በኃላፊነት የመወሰን መብት።\n\n'
            '2. **የእናቶች እና የጨቅላ ህፃናት ጤና (Maternal & Newborn Health):**\n'
            '   ደህንነቱ የተጠበቀ የእርግዝና ክትትል፣ በሰለጠኑ የጤና ባለሙያዎች የሚከናወን ወሊድ እና የድህረ-ወሊድ ክብካቤ።\n\n'
            '3. **የአባለዘር በሽታዎች እና ኤች.አይ.ቪ መከላከል (STIs & HIV):**\n'
            '   ኮንዶም መጠቀም፣ መደበኛ ምርመራ ማድረግ፣ PEP እና PrEP ህክምናዎችን ማግኘት።\n\n'
            '4. **የወጣቶች እና የጉርምስና ጤና (Adolescent & Youth SRH):**\n'
            '   ስለ ሰውነት እድገት፣ የወር አበባ ንፅህና፣ ስሜታዊ ለውጦች እና ስለ ፆታዊ ግንኙነት ያልተዛባ ሳይንሳዊ እውቀት ማግኘት።\n\n'
            '5. **የስነ-ተዋልዶ መብቶች እና ከጥቃት ነፃ መሆን (Rights & Bodily Autonomy):**\n'
            '   ማንኛውም ሰው በራሱ አካል ላይ የመወሰን ሙሉ መብት አለው፤ ከግዳጅ፣ ከጾታዊ ትንኮሳ እና ከጥቃት ነፃ የሆነ ህይወት መኖር።',
        followUpQuestions: [
          'የወሊድ መከላከያ ዘዴዎች በሙሉ ምን ምን ናቸው?',
          'እርግዝና እንዴት ይፈጠራል?',
          'የስነ-ተዋልዶ መብቶች ምንድን ናቸው?',
          'የወር አበባ ዑደት ደረጃዎች እንዴት ይሰራሉ?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Comprehensive SRH Concept',
        text: '🌿 **Comprehensive Sexual & Reproductive Health (SRH) Master Guide:**\n\n'
            'According to the World Health Organization (WHO) and the Ethiopian Ministry of Health (MOH), **Sexual and Reproductive Health (SRH)** is a state of complete **physical, mental, and social well-being** in all matters relating to the reproductive system, not merely the absence of disease or infirmity.\n\n'
            '📌 **The 5 Core Pillars of SRH:**\n\n'
            '1. **Voluntary Family Planning & Contraception:**\n'
            '   The fundamental right of individuals and couples to freely decide the number, timing, and spacing of their children through modern scientific methods.\n\n'
            '2. **Maternal, Perinatal & Newborn Health:**\n'
            '   Ensuring that pregnancy, childbirth, and postnatal phases are safe, respectful, and supported by skilled clinical attendants.\n\n'
            '3. **Prevention & Management of STIs and HIV:**\n'
            '   Dual protection strategies, confidential screening, syndromic STI management, and access to PEP/PrEP and antiretroviral therapy.\n\n'
            '4. **Adolescent & Youth Sexual Health:**\n'
            '   Age-appropriate, evidence-based education regarding puberty, menstrual hygiene, fertility awareness, and emotional well-being without social stigma.\n\n'
            '5. **Reproductive Rights & Gender-Based Violence (GBV) Prevention:**\n'
            '   Upholding bodily autonomy, enthusiastic consent, gender equality, and safe legal/medical support for survivors.',
        followUpQuestions: [
          'Compare all birth control methods',
          'How does human conception work biologically?',
          'Explain the phases of the menstrual cycle',
          'What are common SRH myths in Ethiopia?',
        ],
      );
    }
  }

  static SrhResponse _getReproductionBiologyResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የመራባት እና እርግዝና ስነ-ህይወት',
        text: '🔬 **እርግዝና በስነ-ህይወት (Biology) እንዴት ይፈጠራል? ደረጃ በደረጃ ማብራሪያ:**\n\n'
            'እርግዝና በአንድ ጀምበር የሚከሰት ክስተት ሳይሆን በርካታ ተከታታይ የተፈጥሮ ሂደቶች ውጤት ነው:\n\n'
            '1. **እንቁላል መውጣት (Ovulation):**\n'
            '   በየወሩ አንዲት የደረሰች እንቁላል ከእንቁላል ከረጢት (Ovary) ወጥታ ወደ ማህፀን ቱቦ (Fallopian Tube) ትጓዛለች። እንቁላሏ በህይወት የምትቆየው ለ**12 እስከ 24 ሰዓታት** ብቻ ነው።\n\n'
            '2. **የወንድ ዘር ጉዞ (Insemination & Sperm Capacitation):**\n'
            '   በግንኙነት ወቅት በሚሊዮን የሚቆጠሩ የወንድ የዘር ፍሬዎች ይለቀቃሉ። ጠንካሮቹ በሴቷ ማህፀን በር ፈሳሽ በኩል ወደ ማህፀን ቱቦ ይዋኛሉ። የወንድ ዘር በሴቷ አካል ውስጥ እስከ **5 ቀናት** በህይወት መቆየት ይችላል።\n\n'
            '3. **መዳቀል (Fertilization):**\n'
            '   አንዲት የወንድ ዘር ሴል ከእንቁላሏ ጋር በማህፀን ቱቦ ውስጥ ስትገናኝ እና ሽፋኗን አልፋ ስትገባ መዳቀል ይፈጠራል። ይህ የተዳቀለ ህዋስ **ዛይጎት (Zygote)** ይባላል።\n\n'
            '4. **ጉዞ እና ክፍፍል (Cell Division & Cleavage):**\n'
            '   ዛይጎቱ በፍጥነት በህዋሳት እየተከፋፈለ ወደ ማህፀን አቅጣጫ ከ3 እስከ 4 ቀናት ይጓዛል።\n\n'
            '5. **በማህፀን ግድግዳ ላይ መጣበቅ (Implantation):**\n'
            '   ግንኙነት ከተደረገ ከ**6 እስከ 10 ቀናት** በኋላ የተከፋፈለው ፅንስ (Blastocyst) በማህፀን ውስጥ ባለው ለስላሳ ደም የተሞላ ግድግዳ (Endometrium) ላይ ይጣበቃል። በህክምና ሳይንስ **እርግዝና በይፋ ተፈጠረ** የሚባለው ይህ መጣበቅ ሲሳካ ነው!\n\n'
            '💡 **አስፈላጊ ግንዛቤ:** የድንገተኛ መከላከያ እንክብል (Postpill) እንቁላል እንዳይወጣ በማድረግ መዳቀልን አስቀድሞ ይከላከላል እንጂ የተጣበቀን ፅንስ አያስወርድም።',
        followUpQuestions: [
          'የእርግዝና ምልክቶች መቼ ይጀምራሉ?',
          'የወር አበባ ዑደት እርግዝናን እንዴት ይወስናል?',
          'Postpill እንዴት መወሰድ አለበት?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Biology of Human Reproduction',
        text: '🔬 **Biological Stages of Human Conception & Fertilization:**\n\n'
            'Conception is a sophisticated, multi-step physiological sequence spanning several days:\n\n'
            '1. **Ovulation (Oocyte Release):**\n'
            '   A mature ovum is released from an ovarian follicle and swept into the fallopian tube. The unfertilized egg remains viable for only **12 to 24 hours**.\n\n'
            '2. **Insemination & Sperm Transit:**\n'
            '   During ejaculation, 100–300 million spermatozoa are deposited. Aided by fertile cervical mucus, thousands swim upward through the uterus. Sperm can survive viable inside the female reproductive tract for up to **5 full days**.\n\n'
            '3. **Fertilization (Syngamy):**\n'
            '   Occurs in the ampulla of the fallopian tube when a single sperm penetrates the zona pellucida of the ovum, fusing genetic material to form a single diploid cell called a **Zygote**.\n\n'
            '4. **Cell Division & Blastocyst Development:**\n'
            '   The zygote undergoes rapid cleavage divisions into a morula, progressing into a blastocyst as it glides toward the uterine cavity over 3–5 days.\n\n'
            '5. **Endometrial Implantation:**\n'
            '   Occurs approximately **6 to 10 days post-fertilization**. The blastocyst embeds securely into the vascularized endometrial lining. Medically, pregnancy is officially established only upon successful implantation.\n\n'
            '💡 **Clinical Clarification:** Emergency contraceptive pills (like Postinor-2) work by delaying ovulation to prevent fertilization. They cannot disrupt an established, implanted pregnancy.',
        followUpQuestions: [
          'What is the fertile window?',
          'How does Postinor-2 work biologically?',
          'What are the earliest signs of pregnancy?',
        ],
      );
    }
  }

  static SrhResponse _getComprehensiveContraceptionGuide(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የወሊድ መከላከያ ዘዴዎች ሙሉ ንፅፅር',
        text: '📊 **የወሊድ መከላከያ ዘዴዎች የተሟላ ንፅፅር እና ማብራሪያ:**\n\n'
            'ዘመናዊ የወሊድ መከላከያ ዘዴዎች በ6 ዋና ዋና ክፍሎች ይመደባሉ:\n\n'
            '1. **የክንድ ውስጥ መከላከያ (Implants - Jadelle & Implanon):**\n'
            '   • **ቆይታ:** ጃዴል (5 ዓመት)፣ ኢምፕላኖን (3 ዓመት)\n'
            '   • **ውጤታማነት:** ከ99.9% በላይ (በጣም አስተማማኝ)\n'
            '   • **ጥቅም:** በየቀኑ የሚታወስ ነገር የለም፤ ሲወጣ የመውለድ ችሎታ ወዲያው ይመለሳል።\n\n'
            '2. **የማህፀን ሉፕ (IUD - Copper-T & Hormonal):**\n'
            '   • **ቆይታ:** ኮፐር ሉፕ (እስከ 10-12 ዓመት፣ ሆርሞን አልባ)፣ የሆርሞን ሉፕ (እስከ 5 ዓመት)\n'
            '   • **ውጤታማነት:** ከ99% በላይ\n'
            '   • **ጥቅም:** ሆርሞን መጠቀም ለማይፈልጉ ሴቶች የኮፐር ሉፕ እጅግ ተመራጭ ነው።\n\n'
            '3. **የ3 ወር መርፌ (Depo-Provera):**\n'
            '   • **አጠቃቀም:** በየ12 ሳምንት (3 ወር) የሚሰጥ\n'
            '   • **ውጤታማነት:** 96% - 99%\n'
            '   • **ማስታወሻ:** በመጀመሪያዎቹ ወራት አልፎ አልፎ ደም መፍሰስ (ደፈረሰ) የተለመደ ነው።\n\n'
            '4. **የየዕለት እንክብል (Daily Oral Pills):**\n'
            '   • **አጠቃቀም:** በየቀኑ በአንድ ቋሚ ሰዓት መዋጥ አለበት\n'
            '   • **ውጤታማነት:** 93% (በስርዓቱ ሲወሰድ 99%)\n\n'
            '5. **ኮንዶም (የወንድ እና የሴት ኮንዶም):**\n'
            '   • **ውጤታማነት:** 88% - 98%\n'
            '   • **ልዩ ጥቅም:** ሁለቱንም—ያልተፈለገ እርግዝናን እና የአባለዘር በሽታዎችን (ኤች.አይ.ቪን ጨምሮ) በአንድ ላይ የሚከላከል **ብቸኛው ዘዴ** ነው!\n\n'
            '6. **የድንገተኛ መከላከያ እንክብል (Emergency Postpill):**\n'
            '   • **አጠቃቀም:** ጥንቃቄ የጎደለው ግንኙነት በተፈጠረ በ**72 ሰዓታት** ውስጥ የሚወሰድ። ለድንገተኛ ጊዜ ብቻ!',
        followUpQuestions: [
          'የትኛው ዘዴ ለእኔ ተስማሚ ነው?',
          'ኮንዶም በነፃ የት ይገኛል?',
          'የማሪ ስቶፕስ ክሊኒኮች አገልግሎት',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Comprehensive Contraception Matrix',
        text: '📊 **Master Contraception Comparison & Classification Guide:**\n\n'
            'Modern contraceptive options are categorized across 6 scientific classes:\n\n'
            '1. **Long-Acting Reversible Subdermal Implants (Jadelle & Implanon):**\n'
            '   • **Duration:** 3 years (Implanon) or 5 years (Jadelle)\n'
            '   • **Efficacy:** >99.9% (Highest tier of efficacy)\n'
            '   • **Mechanism:** Continuous low-dose progestin suppresses ovulation and thickens cervical mucus. Fully reversible upon removal.\n\n'
            '2. **Intrauterine Devices (IUDs / Copper-T & Hormonal):**\n'
            '   • **Duration:** 10–12 years (Copper-T) or 3–5 years (Mirena/Levosert)\n'
            '   • **Efficacy:** >99.2%\n'
            '   • **Advantage:** Copper IUD is 100% hormone-free and can also serve as emergency contraception if placed within 5 days.\n\n'
            '3. **Injectable Progestins (Depo-Provera):**\n'
            '   • **Schedule:** One intramuscular injection every 12 weeks\n'
            '   • **Efficacy:** 96% typical / 99% perfect use\n'
            '   • **Side Profile:** Temporary spotting/irregular bleeding during the first 6 months is benign and common.\n\n'
            '4. **Combined Oral Contraceptive Pills (COCs):**\n'
            '   • **Schedule:** Taken daily at the exact same hour\n'
            '   • **Efficacy:** 93% typical / >99% perfect use\n\n'
            '5. **Barrier Methods (Male & Female Condoms):**\n'
            '   • **Efficacy:** 88% typical / 98% perfect use\n'
            '   • **Crucial Advantage:** The **only method** providing dual protection against both unintended pregnancy AND Sexually Transmitted Infections (including HIV).\n\n'
            '6. **Emergency Contraception (Postinor-2 / Ulipristal):**\n'
            '   • **Window:** Within 72–120 hours of unprotected sex. Designed solely as an emergency safety net.',
        followUpQuestions: [
          'Which method has the fewest side effects?',
          'Does Depo-Provera affect future fertility?',
          'How do implants compare to IUDs?',
        ],
      );
    }
  }

  static SrhResponse _getMenstrualCycleBiologyGuide(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የወር አበባ ዑደት ስነ-ህይወት',
        text: '🩸 **የወር አበባ ዑደት 4ቱ ደረጃዎች እና የሆርሞኖች ሚና:**\n\n'
            'የወር አበባ ዑደት ከአንጎል (Hypothalamus/Pituitary) እና ከእንቁላል ከረጢት በሚመነጩ 4 ዋና ሆርሞኖች (FSH, LH, Estrogen, Progesterone) ይመራል:\n\n'
            '1. **ደረጃ 1: የወር አበባ መፍሰስ (Menstrual Phase - ቀናት 1 እስከ 5):**\n'
            '   እርግዝና ካልተፈጠረ የኢስትሮጅን እና ፕሮጄስትሮን መጠን ይቀንሳል፤ ማህፀን ያዘጋጀውን ውስጠኛ ግድግዳ (Endometrium) ከደም ጋር አድርጎ ያስወጣል።\n\n'
            '2. **ደረጃ 2: የዝግጅት ወቅት (Follicular Phase - ቀናት 1 እስከ 13):**\n'
            '   የFSH ሆርሞን በአዲሶቹ እንቁላሎች እድገት ላይ ይሰራል፤ ኢስትሮጅን በማህፀን ውስጥ አዲስ የደም ግድግዳ በፍጥነት እንዲገነባ ያደርጋል።\n\n'
            '3. **ደረጃ 3: እንቁላል መውጣት (Ovulation - ቀን 14 አካባቢ):**\n'
            '   የLH ሆርሞን በከፍተኛ ሁኔታ ይረጫል (LH Surge)፤ የደረሰችው እንቁላል ፈንድታ ወደ ማህፀን ቱቦ ትገባለች። እርግዝና ሊፈጠር የሚችለው በዚህ ወቅት ነው!\n\n'
            '4. **ደረጃ 4: የፅንስ መጠበቂያ ወቅት (Luteal Phase - ቀናት 15 እስከ 28):**\n'
            '   እንቁላል የወጣችበት ባዶ ከረጢት (Corpus Luteum) ፕሮጄስትሮን ያመነጫል፤ ማህፀን ፅንስን ለመቀበል ሞቅ ያለ እና ምቹ ይሆናል። ፅንስ ካልተጣበቀ ዑደቱ ዳግም ይጀምራል።',
        followUpQuestions: [
          'የወር አበባ ህመምን እንዴት ማስታገስ ይቻላል?',
          'የእኔ አስተማማኝ ቀናት የትኞቹ ናቸው?',
          'ያልተለመደ ፈሳሽ ምልክቶች ምንድን ናቸው?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Menstrual Cycle Endocrinology',
        text: '🩸 **The 4 Phases of the Menstrual Cycle & Hormonal Axis:**\n\n'
            'The menstrual cycle is orchestrated by the Hypothalamic-Pituitary-Ovarian (HPO) axis using 4 synchronized hormones: FSH, LH, Estrogen, and Progesterone.\n\n'
            '1. **Menstrual Phase (Days 1–5):**\n'
            '   Withdrawal of progesterone and estrogen causes the spiral arteries in the uterine lining to constrict, resulting in the shedding of the functional endometrial layer.\n\n'
            '2. **Follicular / Proliferative Phase (Days 1–13):**\n'
            '   Pituitary-derived Follicle-Stimulating Hormone (FSH) stimulates ovarian follicle maturation. Developing follicles secrete rising Estrogen, stimulating endometrial proliferation and fertile cervical fluid.\n\n'
            '3. **Ovulatory Phase (Around Day 14):**\n'
            '   Sustained peak estrogen triggers a rapid surge in Luteinizing Hormone (LH). Within 24–36 hours of the LH surge, the dominant follicle ruptures, releasing the ovum.\n\n'
            '4. **Luteal / Secretory Phase (Days 15–28):**\n'
            '   The collapsed follicle transforms into the **Corpus Luteum**, producing high Progesterone levels to mature the endometrium for implantation. If fertilization does not occur, the corpus luteum atrophies, progesterone drops, and menses resumes.',
        followUpQuestions: [
          'What causes painful menstrual cramps?',
          'How does stress delay ovulation?',
          'Can hormonal birth control stop periods?',
        ],
      );
    }
  }

  static SrhResponse _getStiComprehensiveGuide(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የአባለዘር በሽታዎች አጠቃላይ መመሪያ',
        text: '🩺 **የአባለዘር በሽታዎች (STIs) ዓይነቶች፣ ምልክቶች እና ውስብስብ ችግሮች:**\n\n'
            'የአባለዘር በሽታዎች በዋናነት በ3 ረቂቅ ተህዋሲያን ይከሰታሉ:\n\n'
            '1. **በባክቴሪያ የሚመጡ (በፀረ-ተህዋስያን ሙሉ በሙሉ የሚድኑ):**\n'
            '   • **ጨብጥ (Gonorrhea) እና ክላሚዲያ (Chlamydia):** ቢጫ/አረንጓዴ ፈሳሽ፣ በሽንት ጊዜ ማቃጠል ያስከትላሉ። በሴቶች ላይ ብዙውን ጊዜ ምንም ምልክት ላያሳዩ ይችላሉ።\n'
            '   • **ቂጥኝ (Syphilis):** ህመም የሌለው ቁስል (chancre) በብልት ላይ ይጀምራል፤ ካልታከመ በጊዜ ሂደት ልብንና አእምሮን ይጎዳል።\n\n'
            '2. **በቫይረስ የሚመጡ (በመድኃኒት የሚቆጣጠሩ):**\n'
            '   • **ኤች.አይ.ቪ (HIV):** በART ህክምና ሙሉ በሙሉ ቁጥጥር ይደረጋል (U=U)።\n'
            '   • **HPV (የማህፀን በር ካንሰር አምጪ ቫይረስ):** በኢትዮጵያ ለልጃገረዶች የHPV ክትባት በነፃ ይሰጣል።\n'
            '   • **የብልት ሄርፒስ (Herpes / HSV):** አልፎ አልፎ የሚፈነዱ የሚያቃጥሉ አረፋዎች/ቁስሎች።\n\n'
            '3. **ባልታከሙ የአባለዘር በሽታዎች የሚመጡ ከባድ ጉዳቶች:**\n'
            '   • የማህፀን ኢንፌክሽን (Pelvic Inflammatory Disease - PID)\n'
            '   • ዘላቂ የመካንነት (Infertility) አደጋ በሁለቱም ፆታዎች\n'
            '   • ከማህፀን ውጭ የሚፈጠር እርግዝና (Ectopic Pregnancy)\n\n'
            '💡 **መፍትሄ:** በሁሉም የመንግስት ጤና ጣቢያዎች ያለ ምንም ክፍያ በሚስጥር ይመረመሩ፤ ሁለቱም አጋሮች በአንድ ላይ መታከም አለባቸው።',
        followUpQuestions: [
          'የኤች.አይ.ቪ ምርመራ በነፃ የት ይገኛል?',
          'ኮንዶም ከአባለዘር በሽታዎች ሙሉ በሙሉ ይከላከላል?',
          'የጤና ጣቢያ ነፃ ህክምና',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Comprehensive STI Pathophysiology',
        text: '🩺 **Comprehensive STI Classification, Pathogens & Complications:**\n\n'
            'Sexually Transmitted Infections fall into 3 major microbiological classes:\n\n'
            '1. **Bacterial STIs (100% Curable with targeted Antibiotics):**\n'
            '   • **Chlamydia & Gonorrhea:** Infect columnar epithelial cells of the urethra and endocervix. >70% of female infections are completely asymptomatic, silently advancing upward.\n'
            '   • **Syphilis (Treponema pallidum):** Manifests in Primary stage (painless chancre), Secondary stage (skin rashes), and Latent/Tertiary stages (cardiovascular and neurological damage).\n\n'
            '2. **Viral STIs (Manageable & Preventable):**\n'
            '   • **HIV:** Controlled with daily ART. Undetectable = Untransmittable (U=U).\n'
            '   • **Human Papillomavirus (HPV):** High-risk strains (16, 18) drive cervical cancer. Screened via VIA and preventable via the national adolescent HPV vaccine.\n'
            '   • **Herpes Simplex Virus (HSV-2):** Causes recurrent genital vesicles managed with antivirals (Acyclovir).\n\n'
            '3. **Long-Term Complications of Untreated STIs:**\n'
            '   • **Pelvic Inflammatory Disease (PID):** Chronic infection causing tubal scarring and chronic pelvic pain.\n'
            '   • **Ectopic Pregnancy & Infertility:** Blocked fallopian tubes prevent blastocyst transit.\n'
            '   • **Epididymitis & Male Subfertility**.\n\n'
            '💡 **Standard Practice in Ethiopia:** Health centers apply syndromic management guidelines to treat symptoms immediately without waiting days for lab cultures.',
        followUpQuestions: [
          'What are the symptoms of Gonorrhea and Chlamydia?',
          'Where is confidential STI testing available?',
          'How does PEP work within 72 hours?',
        ],
      );
    }
  }

  static SrhResponse _getReproductiveRightsAndConsentGuide(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የስነ-ተዋልዶ መብቶች እና ስምምነት',
        text: '🤝 **የስነ-ተዋልዶ መብቶች፣ የሰውነት ነፃነት እና ስምምነት (Consent):**\n\n'
            'የስነ-ተዋልዶ መብቶች በዓለም አቀፍ የሰብዓዊ መብቶች ድንጋጌዎች እውቅና የተሰጣቸው መሠረታዊ መብቶች ናቸው:\n\n'
            '1. **የሰውነት ነፃነት (Bodily Autonomy):**\n'
            '   ማንም ሰው በሰውነትዎ ላይ ምን መደረግ እንዳለበት ወይም እንደሌለበት የመወሰን ብቸኛ መብት የእርስዎ ብቻ ነው።\n\n'
            '2. **ትክክለኛ ስምምነት 5ቱ መርሆዎች (The FRIES Model):**\n'
            '   • **Freely Given (በነፃ ፍላጎት):** ያለ ማስገደድ፣ ያለ ማስፈራራት ወይም ያለ ጥፋተኝነት ስሜት የሚሰጥ።\n'
            '   • **Reversible (ሊቀለበስ የሚችል):** በማንኛውም ሰከንድ ሃሳብዎን መቀየር እና "አቁም" ማለት መብትዎ ነው።\n'
            '   • **Informed (የተብራራ):** ጥንቃቄው ምን እንደሆነ፣ ኮንዶም ስለመኖሩ በግልፅ አውቆ የሚሰጥ።\n'
            '   • **Enthusiastic (በሙሉ ፍላጎት):** በግዴታ ሳይሆን በደስታ የሚደረግ።\n'
            '   • **Specific (ለተወሰነ ድርጊት):** ለአንድ ነገር መስማማት ለሌላ ነገር መስማማት አይደለም።\n\n'
            '3. **ማስገደድ እና ጥቃት ሲያጋጥም:**\n'
            '   ማንኛውም ያልተፈለገ ንክኪ፣ ጥቃት ወይም ጫና ካጋጠመዎት ጥፋቱ የእርስዎ አይደለም። በነፃ የስልክ መስመሮች **8335** ወይም **6788** አሁኑኑ ሚስጥራዊ ድጋፍ ማግኘት ይችላሉ።',
        followUpQuestions: [
          'በግንኙነት ውስጥ ድንበር እንዴት ይጠበቃል?',
          'የአስቸኳይ ጊዜ ስልክ 8335',
          'PEP እና ድንገተኛ መከላከያ በ72 ሰዓት ውስጥ',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Reproductive Rights & Enthusiastic Consent',
        text: '🤝 **Reproductive Rights, Bodily Autonomy & Enthusiastic Consent:**\n\n'
            'Sexual and Reproductive Rights encompass fundamental human rights affirmed by the UN and international covenants:\n\n'
            '1. **Bodily Autonomy:**\n'
            '   The inviolable right to make decisions over your own body, sexual life, and healthcare choices without external violence, stigma, or coercion.\n\n'
            '2. **The FRIES Model of Enthusiastic Consent:**\n'
            '   • **Freely Given:** Offered without intoxication, guilt-tripping, emotional blackmail, or power imbalance.\n'
            '   • **Reversible:** Anyone can withdraw consent at any point, even in the middle of sexual activity. "Stop" means stop immediately.\n'
            '   • **Informed:** Mutual transparency about barrier protection, contraceptive methods, and STI status.\n'
            '   • **Enthusiastic:** Based on active, mutual desire rather than reluctant submission.\n'
            '   • **Specific:** Consent to kissing is never blanket consent to intercourse.\n\n'
            '3. **Support & Protection in Ethiopia:**\n'
            '   If you face coercion, assault, or GBV, confidential medical and psychosocial help is available immediately via toll-free **8335** or the GBV helpline **6788**.',
        followUpQuestions: [
          'How to communicate sexual boundaries clearly?',
          'What is reproductive coercion?',
          'Where to access emergency post-assault PEP care?',
        ],
      );
    }
  }

  static SrhResponse _getEthiopianMythsAndFactsGuide(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የተሳሳቱ አመለካከቶች እና ሳይንሳዊ እውነታዎች',
        text: '💡 **በኢትዮጵያ ውስጥ ያሉ የተሳሳቱ አመለካከቶች እና የህክምና እውነታዎች:**\n\n'
            '❌ **የተሳሳተ ወሬ 1:** "የመጀመሪያ ቀን ግንኙነት እርግዝና አያመጣም።"\n'
            '✅ **ሳይንሳዊ እውነታ:** የሴቷ እንቁላል ከወጣች በመጀመሪያም ሆነ በመቶኛ ቀን ግንኙነት እርግዝና የመፈጠር እድሉ እኩል ነው!\n\n'
            '❌ **የተሳሳተ ወሬ 2:** "የድንገተኛ መከላከያ እንክብል (Postpill) መካን ያደርጋል።"\n'
            '✅ **ሳይንሳዊ እውነታ:** እንክብሉ በሰውነት ውስጥ ለጥቂት ቀናት ብቻ ቆይቶ ይወጣል። የመውለድ ችሎታ ላይ ምንም ዓይነት ዘላቂ ተጽዕኖ የለውም።\n\n'
            '❌ **የተሳሳተ ወሬ 3:** "ግንኙነት ከተደረገ በኋላ መታጠብ፣ ሽንት መሽናት ወይም ኮካ መጠጣት እርግዝናን ይከላከላል።"\n'
            '✅ **ሳይንሳዊ እውነታ:** የወንድ ዘር በ90 ሰከንድ ውስጥ ወደ ማህፀን በር ይገባል፤ መታጠብም ሆነ ለስላሳ መጠጦች መጠጣት ምንም አይነት መከላከያ አይሰጡም።\n\n'
            '❌ **የተሳሳተ ወሬ 4:** "ራስን ማርካት (Masturbation) ያሳውራል ወይም ጉልበት ያደክማል።"\n'
            '✅ **ሳይንሳዊ እውነታ:** ይህ ፍፁም የተሳሳተ አጉል እምነት ነው። በአካል ላይ ምንም ዓይነት የጤና ወይም የአይን ጉዳት አያመጣም።\n\n'
            '❌ **የተሳሳተ ወሬ 5:** "ኤች.አይ.ቪ በአንድ እቃ አብሮ በመብላት ወይም በመጨባበጥ ይተላለፋል።"\n'
            '✅ **ሳይንሳዊ እውነታ:** ኤች.አይ.ቪ በደም፣ በጥንቃቄ በጎደለው ግንኙነት እና ከእናት ወደ ልጅ ብቻ ነው የሚተላለፈው።',
        followUpQuestions: [
          'Postpill በወር ውስጥ ስንት ጊዜ ይፈቀዳል?',
          'የወሊድ መከላከያ ዘዴዎች ሙሉ ንፅፅር',
          'ኮንዶም እንዴት በትክክል ጥቅም ላይ ይውላል?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Debunking SRH Myths & Taboos',
        text: '💡 **Top Sexual Health Myths vs Scientific Facts in Ethiopia:**\n\n'
            '❌ **Myth 1:** "A girl cannot get pregnant during her first sexual encounter."\n'
            '✅ **Scientific Fact:** Conception depends strictly on ovulation, not sexual history. If intercourse coincides with the fertile window, pregnancy can occur on the very first try.\n\n'
            '❌ **Myth 2:** "Emergency pills (Postinor-2) cause permanent infertility."\n'
            '✅ **Scientific Fact:** Emergency progestins clear from the body within days. Natural fertility returns immediately in the subsequent menstrual cycle.\n\n'
            '❌ **Myth 3:** "Douching, urinating, or drinking herbal drinks/soda after sex prevents pregnancy."\n'
            '✅ **Scientific Fact:** Sperm penetrates the cervical canal within 90 seconds. Vaginal washing does not reach the uterus and disrupts protective vaginal flora.\n\n'
            '❌ **Myth 4:** "Masturbation causes spinal weakness, acne, or blindness."\n'
            '✅ **Scientific Fact:** Medically groundless. It has zero negative physical effects on vision, musculoskeletal strength, or future reproductive ability.\n\n'
            '❌ **Myth 5:** "HIV can spread through sharing meals, toilets, or mosquito bites."\n'
            '✅ **Scientific Fact:** HIV requires direct fluid transmission (blood, sexual fluids, mother-to-child) and dies rapidly outside the human host.',
        followUpQuestions: [
          'How do condoms prevent both STIs and pregnancy?',
          'What are the safe days in a cycle?',
          'Where are Marie Stopes clinics located?',
        ],
      );
    }
  }

  // ==========================================
  // GRANULAR CLINICAL TOPIC RESPONSES
  // ==========================================

  static SrhResponse _getPepEducationalResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        isUrgent: false,
        category: 'ስለ PEP ሳይንሳዊ እውቀት',
        text: '💊 **PEP (Post-Exposure Prophylaxis / የድህረ-ንክኪ መከላከያ) ምንድን ነው?**\n\n'
            '• **ትርጉሙ:** አንድ ሰው ለኤች.አይ.ቪ ቫይረስ ሊያጋልጥ የሚችል ሁኔታ ካጋጠመው በኋላ ቫይረሱ በሰውነት ውስጥ እንዳይሰራጭ የሚወሰድ የድንገተኛ የART መድኃኒት ነው።\n'
            '• **ወሳኝ ሰዓት:** ክስተቱ ከተፈጠረበት ቅጽበት ጀምሮ በ**72 ሰዓታት (3 ቀናት)** ውስጥ መጀመር አለበት። ቶሎ በተጀመረ ቁጥር ውጤታማነቱ እጅግ የላቀ ነው።\n'
            '• **አወሳሰድ:** መድኃኒቱ ለ**28 ተከታታይ ቀናት** በየቀኑ በሰዓቱ ይወሰዳል።\n'
            '• **ውጤታማነት:** በስርዓቱ ሲወሰድ ኤች.አይ.ቪ እንዳይፈጠር ከ90% በላይ አስተማማኝ ጥበቃ ይሰጣል።\n'
            '• **በኢትዮጵያ:** በሁሉም የመንግስት ጤና ጣቢያዎች እና ሆስፒታሎች 100% **በነፃ እና በሚስጥር** ይሰጣል።\n\n'
            '💡 **ልዩነት:** PEP ድንገተኛ አደጋ ከደረሰ *በኋላ* የሚወሰድ ሲሆን፤ PrEP ደግሞ አስቀድሞ በየቀኑ የሚወሰድ መከላከያ ነው።',
        followUpQuestions: [
          'PEP የጎንዮሽ ጉዳት አለው?',
          'PrEP እና PEP ልዩነታቸው ምንድን ነው?',
          'የአደጋ ጊዜ ስልክ 8335',
        ],
      );
    } else {
      return const SrhResponse(
        isUrgent: false,
        category: 'PEP Educational Overview',
        text: '💊 **What is PEP (Post-Exposure Prophylaxis)? Comprehensive Facts:**\n\n'
            '• **Definition:** PEP is a short-course emergency regimen of antiretroviral medications (ARVs) taken after potential exposure to HIV to stop the virus from becoming permanent.\n'
            '• **The Strict 72-Hour Window:** PEP must be initiated as soon as possible, and strictly **within 72 hours (3 days)** after potential exposure. Every hour counts—the earlier it is started, the higher the viral clearance.\n'
            '• **Duration:** The regimen lasts for **28 consecutive days**, taken faithfully at the exact same time every day.\n'
            '• **Efficacy:** When completed adherence is maintained, PEP reduces the risk of HIV acquisition by over 90%.\n'
            '• **Availability in Ethiopia:** Standard PEP starter packs and comprehensive counseling are **100% free and confidential** at all government health facilities.\n\n'
            '💡 **PEP vs PrEP:** PEP is taken *after* an emergency exposure for 28 days; PrEP is taken daily *before* exposure as a continuous prevention lifestyle.',
        followUpQuestions: [
          'What are the common side effects of PEP?',
          'How does PrEP differ from PEP?',
          'Where is the nearest youth-friendly clinic in Ethiopia?',
        ],
      );
    }
  }

  static SrhResponse _getAssaultCrisisResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        isUrgent: true,
        category: 'አስቸኳይ የጥቃት እርዳታ',
        text: '⚠️ **አስቸኳይ የጤና፣ የአካል እና የስነ-ልቦና ድጋፍ (Crisis Intervention):**\n\n'
            'በመጀመሪያ ይህ የእርስዎ ጥፋት እንዳልሆነ ይወቁ። እርስዎ ደህና ነዎት፣ ብቻዎን አይደሉም።\n\n'
            '### 1. አካላዊ እና የህክምና እርምጃዎች (በ72 ሰዓታት ውስጥ):\n'
            '• **ደህንነት:** ወደ አስተማማኝ እና ደህንነቱ የተጠበቀ ቦታ ይሂዱ፤ ከሚያምኑት ሰው ጋር ይሁኑ።\n'
            '• **የኤች.አይ.ቪ መከላከያ (PEP):** ጥቃቱ በተፈጠረ በ**72 ሰዓታት (3 ቀናት)** ውስጥ ወደ ጤና ተቋም በመሄድ የPEP መድኃኒት በነፃ ይጀምሩ።\n'
            '• **ድንገተኛ የወሊድ መከላከያ:** ያልተፈለገ እርግዝናን ለመከላከል የድንገተኛ የወሊድ መከላከያ እንክብል (Postinor-2 / Postpill) በ72 ሰዓታት ውስጥ ይውሰዱ።\n'
            '• **ማስረጃ መጠበቅ እና ምርመራ:** ጥቃቱን ሪፖርት የማድረግ ሀሳብ ካለዎት ወደ ጤና ተቋም ከመሄድዎ በፊት ገላዎን አለመታጠብ፣ ልብስ አለመቀየር እና አለመፀዳዳት ማስረጃዎችን ለመጠበቅ ይረዳል። ልብስ ከተቀየረ በወረቀት ፌስታል ውስጥ ያስቀምጡት።\n\n'
            '### 2. ስነ-ልቦናዊ ድጋፍ እና ማረጋጊያ:\n'
            '• **ስሜታዊ ማረጋጊያ (Grounding):** አተነፋፈስዎን ያረጋጉ (ለ4 ሰከንድ አየር ወደ ውስጥ መሳብ፣ ለ4 ሰከንድ ማቆየት፣ ለ6 ሰከንድ ማስወጣት)። ይህ ድንጋጤ ጊዜያዊ እንደሆነ ያስታውሱ።\n'
            '• **የብቻ ሸክም አይሁን:** ለሚያምኑት የቤተሰብ አባል፣ ጓደኛ ወይም የሳይኮሎጂ ባለሙያ ያካፍሉ።\n\n'
            '🏥 **ነፃ እና ሚስጥራዊ የስልክ መስመሮች እና የጤና አጋሮች:**\n'
            '• 📞 **8335** - የወጣቶች የስነ-ተዋልዶ ጤና ነፃ መስመር (ምክር እና ክሊኒካዊ መመሪያ)\n'
            '• 📞 **6788** - የፆታ ጥቃት (GBV) ተጎጂዎች ነፃ የአደጋ ጊዜ ስልክ መስመር\n'
            '• **የመንግስት ወረዳ ጤና ጣቢያዎች ወይም ሆስፒታሎች:** ነፃ የPEP ህክምና እና ክሊኒካዊ ድጋፍ\n'
            '• **ማሪ ስቶፕስ እና FGAE:** ሚስጥራዊ የስነ-ተዋልዶ ጤና ማዕከላት',
        followUpQuestions: [
          'በነፃ የስልክ መስመር 8335 መደወል',
          'የPEP መድኃኒት እንዴት ይሰራል?',
          'በነፃ የስልክ መስመር 6788 መደወል',
        ],
      );
    } else {
      return const SrhResponse(
        isUrgent: true,
        category: 'Crisis Intervention',
        text: '⚠️ **URGENT CRISIS & MEDICAL TRIAGE:**\n\n'
            'First and most importantly: **You are safe right now, and what happened is NOT your fault.** You do not have to go through this alone.\n\n'
            '### 1. Physical & Medical Steps (Within the Critical 72-Hour Window):\n'
            '• **Immediate Safety:** Get to a secure, safe environment with someone you trust.\n'
            '• **HIV Post-Exposure Prophylaxis (PEP):** You must begin PEP within **72 hours (3 days)** of the incident. It stops HIV from taking hold in your body and is **100% free** at all public health centers and hospitals in Ethiopia.\n'
            '• **Emergency Contraception:** Take Postinor-2 / Postpill or Ella within 72–120 hours to prevent unintended pregnancy.\n'
            '• **Forensic Evidence & Medical Exam:** If you may report or seek justice, try to avoid showering, bathing, douching, brushing teeth, or changing clothes before a clinical exam. If you must change clothes, place each garment in clean paper bags (not plastic).\n'
            '• **STI Screening & Wound Care:** Clinicians will provide syndromic antibiotics to prevent gonorrhea, chlamydia, and syphilis, and care for any physical injuries.\n\n'
            '### 2. Psychological & Emotional Steps:\n'
            '• **Emotional Grounding:** Acute shock and trembling are natural bodily reactions. Use slow diaphragmatic breathing (inhale for 4 seconds, hold 4, exhale 6) or the 5-4-3-2-1 sensory grounding technique.\n'
            '• **Reach Out:** Confide in a trusted friend, family member, or healthcare professional. Do not isolate yourself.\n'
            '• **Trauma Counseling:** Access free, trauma-informed psychological first aid right away.\n\n'
            '🏥 **Immediate Ethiopian Support Lines & Partners:**\n'
            '• 📞 **8335** - National Youth Reproductive Health Helpline (Toll-Free from any phone in Ethiopia)\n'
            '• 📞 **6788** - National GBV Survivor Support Hotline (Toll-Free, 24/7 confidential crisis line)\n'
            '• **Nearest Government Woreda Health Center or Hospital:** 100% free PEP & emergency trauma care\n'
            '• **Marie Stopes Ethiopia & FGAE Youth Centers:** Confidential, non-judgmental youth reproductive care',
        followUpQuestions: [
          'Call Toll-Free Helpline 8335',
          'Call GBV Helpline 6788',
          'How does PEP medication work?',
        ],
      );
    }
  }

  static SrhResponse _getUrgentResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        isUrgent: true,
        category: 'ድንገተኛ ክሊኒካዊ እርምጃ',
        text: '⚠️ **አስቸኳይ ክሊኒካዊ የጊዜ ሰሌዳ (በ72 ሰዓታት ውስጥ):**\n\n'
            'ጥንቃቄ የጎደለው ግንኙነት፣ የኮንዶም መቀደድ ወይም ጥቃት ካጋጠመዎት ጊዜው ወሳኝ ነው:\n\n'
            '1. **ኤች.አይ.ቪን በነፃ ለመከላከል (PEP):** ክስተቱ በተፈጠረ በ**72 ሰዓታት (3 ቀናት)** ውስጥ በአቅራቢያዎ ወደሚገኝ ጤና ጣቢያ በመሄድ የPEP መድኃኒት መጀመር አለብዎት።\n'
            '2. **ድንገተኛ እርግዝናን ለመከላከል:** ፖስቲኖር (Postpill) በ72 ሰዓታት ውስጥ በማንኛውም ፋርማሲ ያለ ሀኪም ማዘዣ ይገኛል።\n\n'
            '🏥 **የሚረዱዎት የአካባቢዎ የጤና አጋሮች እና ነፃ መስመሮች:**\n'
            '• **የመንግስት ጤና ጣቢያዎች እና ሆስፒታሎች:** ነፃ የPEP መድኃኒት፣ ነፃ ፈጣን የኤች.አይ.ቪ ምርመራ እና የSTI ህክምና ይሰጣሉ።\n'
            '• **ማሪ ስቶፕስ ኢትዮጵያ (Marie Stopes):** በአዲስ አበባ እና በሁሉም ክልል ከተሞች ሚስጥራዊ የወሊድ መከላከያ እና የማማከር አገልግሎት።\n'
            '• **የኢትዮጵያ ቤተሰብ መምሪያ ማህበር (FGAE):** የወጣቶች ምቹ ማዕከላት።\n'
            '• 📞 **8335** - የወጣቶች የስነ-ተዋልዶ ጤና ነፃ የስልክ መስመር (ያለ ክፍያ ይደውሉ)\n'
            '• 📞 **6788** - የሴቶች እና የህፃናት ጥቃት ድንገተኛ ነፃ የስልክ መስመር',
        followUpQuestions: [
          'PEP ምንድን ነው?',
          'በነፃ 8335 ይደውሉ',
          'Postpill እንዴት ይሰራል?',
        ],
      );
    } else {
      return const SrhResponse(
        isUrgent: true,
        category: 'Emergency Clinical Triage',
        text: '⚠️ **URGENT CLINICAL TIMELINE (Within 72 Hours):**\n\n'
            'If you experienced condom breakage, potential exposure, or assault, immediate action is required:\n\n'
            '1. **HIV Prevention (PEP):** You must begin Post-Exposure Prophylaxis (PEP) within **72 hours (3 days)**. It stops HIV from taking hold in your body. It is 100% free at public clinics.\n'
            '2. **Emergency Contraception:** Take Postinor-2 / Postpill as soon as possible to prevent pregnancy.\n\n'
            '🏥 **Recommended Local Healthcare Partners in Ethiopia:**\n'
            '• **Nearest Government Woreda Health Center or Hospital:** Provides 100% free PEP medication, emergency counseling, and syndromic STI treatment.\n'
            '• **Marie Stopes Ethiopia (MSE) Clinics:** Full confidential reproductive services across Addis Ababa and regional cities.\n'
            '• **Family Guidance Association of Ethiopia (FGAE):** Youth-friendly confidential drop-in clinics.\n'
            '• 📞 **8335** - National Youth Reproductive Health Helpline (Toll-Free from any network)\n'
            '• 📞 **6788** - National GBV Survivor Crisis Helpline (Toll-Free)',
        followUpQuestions: [
          'What are the side effects of PEP?',
          'Call Toll-Free 8335 immediately',
          'How does emergency contraception work?',
        ],
      );
    }
  }

  static SrhResponse _getEmergencyContraceptionResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'ድንገተኛ የወሊድ መከላከያ',
        text: '💊 **ስለ ድንገተኛ የእርግዝና መከላከያ እንክብል (Postpill / Postinor-2):**\n\n'
            '• **መቼ ይወሰዳል?** ጥንቃቄ የጎደለው ግንኙነት በተፈጠረ በ**72 ሰዓታት (3 ቀናት)** ውስጥ መወሰድ አለበት። ቶሎ በተወሰደ ቁጥር ውጤታማነቱ ከፍ ይላል (በመጀመሪያዎቹ 24 ሰዓት እስከ 95% ይከላከላል)።\n'
            '• **እንዴት ይሰራል?** እንቁላል ከእንቁላል ከረጢት እንዳይወጣ በማዘግየት እርግዝና እንዳይፈጠር ያደርጋል። የተፈጠረን እርግዝና አያቋርጥም (ፅንስ አያስወርድም)።\n'
            '• **የጎንዮሽ ጉዳት:** ጊዜያዊ የማቅለሽለሽ ስሜት፣ የድካም ስሜት ወይም የወር አበባ ቀን ጥቂት ቀናት ቀደም ወይም ዘግይቶ መምጣት ሊያጋጥም ይችላል።\n'
            '• **አስፈላጊ ማስታወሻ:** ይህ ለድንገተኛ አደጋ እንጂ እንደ ቋሚ የወሊድ መከላከያ አይመከርም። ከአባለዘር በሽታዎች አይከላከልም።',
        followUpQuestions: [
          'Postpill በወር ውስጥ ስንት ጊዜ መወሰድ ይችላል?',
          'የ3 ወር መርፌ ወይስ ጃዴል ይሻላል?',
          'ኮንዶም ከአባለዘር በሽታዎች ሙሉ በሙሉ ይከላከላል?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Emergency Contraception',
        text: '💊 **Emergency Contraceptive Pills (Postpill / Postinor-2):**\n\n'
            '• **Timing is Critical:** Must be taken within **72 hours (3 days)** of unprotected intercourse. The sooner you take it, the higher the efficacy (up to 95% in the first 24 hours).\n'
            '• **Mechanism:** It prevents pregnancy primarily by delaying or inhibiting ovulation. It does **not** induce abortion and cannot terminate an established pregnancy.\n'
            '• **Side Effects:** Mild nausea, fatigue, or temporary changes to your next period (it may arrive a few days early or late).\n'
            '• **Important Note:** Emergency pills are designed for emergencies only, not routine contraception. They do **not** protect against HIV or STIs.',
        followUpQuestions: [
          'Can I take Postpill multiple times in one month?',
          'What are long-acting contraception options?',
          'How do I calculate my safe days?',
        ],
      );
    }
  }

  static SrhResponse _getImplantsResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የክንድ መከላከያ (ኢምፕላንት)',
        text: '🔬 **የክንድ ውስጥ የወሊድ መከላከያ (Jadelle / Implanon):**\n\n'
            '• **ቆይታ:** ኢምፕላኖን (Implanon) ለ3 ዓመታት፣ ጃዴል (Jadelle) ደግሞ ለ5 ዓመታት አስተማማኝ ጥበቃ ይሰጣሉ።\n'
            '• **ውጤታማነት:** ከ99% በላይ አስተማማኝ ሲሆን በየቀኑ ምንም የሚያስታውሱት ነገር የለም።\n'
            '• **የሰውነት ለውጥ:** በመጀመሪያዎቹ ወራት የወር አበባ መዛባት፣ አልፎ አልፎ ደም መፍሰስ ወይም የወር አበባ ሙሉ በሙሉ መቆም ሊከሰት ይችላል። ይህ በጤና ላይ ምንም አይነት ጉዳት የለውም።\n'
            '• **ማውጣት:** መውለድ ሲፈልጉ በማንኛውም ጊዜ በጤና ባለሙያ በቀላሉ ሊወጣ ይችላል፤ የመውለድ ችሎታም ወዲያውኑ ይመለሳል።',
        followUpQuestions: [
          'የ3 ወር መርፌ እንዴት ይሰራል?',
          'ኢምፕላንት የክብደት ለውጥ ያመጣል?',
          'በነፃ የት ይገኛል?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Contraceptive Implants',
        text: '🔬 **Subdermal Contraceptive Implants (Jadelle & Implanon):**\n\n'
            '• **Duration:** Implanon (single rod) protects for 3 years; Jadelle (two flexible rods) protects for up to 5 years.\n'
            '• **Effectiveness:** Over 99.9% effective, making it one of the most reliable reversible methods in existence.\n'
            '• **How it feels:** Inserted just beneath the skin of the inner upper arm in a simple 5-minute minor clinical procedure with local anesthetic.\n'
            '• **Bleeding Changes:** Spotting or paused periods are common and medically safe. Fertility returns immediately upon removal.',
        followUpQuestions: [
          'Does the implant hurt to put in?',
          'What is the difference between Depo-Provera and Jadelle?',
          'Can implants protect against STIs?',
        ],
      );
    }
  }

  static SrhResponse _getDmpaScResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'ሳያና ፕሬስ (DMPA-SC)',
        text: '💉 **ስለ ሳያና ፕሬስ (DMPA-SC / Sayana Press) ዘመናዊ መርፌ:**\n\n'
            '• **ምንድን ነው?** DMPA-SC (Depot Medroxyprogesterone Acetate - Subcutaneous) ዘመናዊና ዝቅተኛ መጠን ያለው የሆርሞን መርፌ ሲሆን፤ በትንሽ መርፌ ከቆዳ ስር በሆድ ወይም በጭን ላይ የሚሰጥ ነው።\n'
            '• **ዋነኛ ጥቅሙ (Self-Injection):** ሴቶች አጭር ስልጠና ከወሰዱ በኋላ **በራሳቸው ቤት ውስጥ መውጋት የሚችሉት** ብቸኛው የ3 ወር መርፌ ነው! ክሊኒክ የመሄድ ጊዜን እና ወጪን በእጅጉ ይቀንሳል፤ ከፍተኛ ሚስጥራዊነትን ይሰጣል።\n'
            '• **ቆይታ እና ውጤታማነት:** እንደ መደበኛው ዲፖ-ፕሮቬራ ሁሉ ለ**3 ወራት (13 ሳምንታት)** ከ99% በላይ አስተማማኝ ጥበቃ ይሰጣል።\n'
            '• **የአቀራረብ ቴክኖሎጂ (Uniject):** መድኃኒቱ እና መርፌው በአንድ ላይ የተዘጋጀ (All-in-one prefilled) በመሆኑ በቀላሉ ተጨምቆ ይወጋል።\n'
            '• **የሰውነት ለውጥ:** በመጀመሪያዎቹ ወራት አልፎ አልፎ ደም መፍሰስ (spotting) ሊኖር ይችላል። በኢትዮጵያ በጤና ኤክስቴንሽን ሰራተኞች እና በማሪ ስቶፕስ በኩል ይሰጣል።',
        followUpQuestions: [
          'DMPA-SC እና መደበኛው ዲፖ-ፕሮቬራ ልዩነታቸው ምንድን ነው?',
          'በቤት ውስጥ እንዴት መውጋት ይቻላል?',
          'በአቅራቢያዬ የት ይገኛል?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'DMPA-SC (Sayana Press)',
        text: '💉 **What is DMPA-SC (Sayana Press)? Modern Subcutaneous Contraception:**\n\n'
            '• **Definition:** DMPA-SC stands for **Depot Medroxyprogesterone Acetate - Subcutaneous** (widely known under the brand name **Sayana Press**).\n'
            '• **How it Works:** Contains a lower progestin dose (104 mg vs 150 mg in traditional IM Depo) injected just beneath the skin (subcutaneously) into the abdomen or anterior thigh.\n'
            '• **Game-Changing Breakthrough — Self-Injection:** Unlike traditional intramuscular injections that require deep gluteal injection by a health professional, DMPA-SC comes in a pre-filled, single-use **Uniject** device. After a simple demonstration, users can safely **self-inject at home**, granting immense privacy, independence, and eliminating frequent clinic visits.\n'
            '• **Duration & Efficacy:** Highly effective (>99%) for **3 months (13 weeks)** per injection.\n'
            '• **Availability in Ethiopia:** Scaled up through the Ethiopian Ministry of Health via Health Extension Workers (HEWs), youth centers, and Marie Stopes Ethiopia.',
        followUpQuestions: [
          'What is the difference between DMPA-SC and DMPA-IM?',
          'How do you safely self-inject Sayana Press?',
          'What are common side effects of DMPA-SC?',
        ],
      );
    }
  }

  static SrhResponse _getInjectablesResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የ3 ወር መርፌ (Depo-Provera)',
        text: '💉 **የ3 ወር መርፌ (Depo-Provera):**\n\n'
            '• **አጠቃቀም:** በየ3 ወሩ (12 ሳምንት) አንድ ጊዜ በክንድ ወይም በዳሌ ጡንቻ ላይ ይሰጣል።\n'
            '• **ደፈረሰ/ደም መፍሰስ:** በመጀመሪያዎቹ 3 እስከ 6 ወራት ውስጥ አልፎ አልፎ ደም መፍሰስ (spotting) በጣም የተለመደ ነው። ከጥቂት ጊዜ በኋላ የወር አበባ ሊቆም ይችላል፤ ይህ ጎጂ አይደለም።\n'
            '• **የመውለድ ችሎታ መመለስ:** መርፌውን ካቆሙ በኋላ እርግዝና ለመያዝ ከ6 እስከ 10 ወራት ሊወስድ ይችላል።\n'
            '• **ምክር:** መርፌውን በትክክለኛው ቀን መውሰድ ውጤታማነቱን ያረጋግጣል።',
        followUpQuestions: [
          'የመርፌው ቀን ካለፈብኝ ምን ላድርግ?',
          'መርፌው መሀን ያደርጋል?',
          'የወሊድ እንክብል ወይስ መርፌ ይሻላል?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Injectable Contraception',
        text: '💉 **Depo-Provera (3-Month Injectable):**\n\n'
            '• **Administration:** One intramuscular injection every 12 weeks (3 months).\n'
            '• **Spotting & Irregular Bleeding:** Very common in the first 3–6 months as the endometrium adjusts to progestin. Eventually, many users experience no bleeding at all (amenorrhea), which is medically safe.\n'
            '• **Fertility Return:** Unlike pills or condoms, fertility may take 6 to 10 months to return after discontinuing Depo.\n'
            '• **Routine:** Setting calendar reminders for your return appointment ensures continuous 99% efficacy.',
        followUpQuestions: [
          'What if I am a few days late for my injection?',
          'Does Depo-Provera cause weight gain?',
          'Where can I get Depo in Addis Ababa?',
        ],
      );
    }
  }

  static SrhResponse _getIudResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የማህፀን ሉፕ (IUD)',
        text: '🛡️ **የማህፀን ሉፕ (IUD / Copper T):**\n\n'
            '• **ዓይነቶች:** የኮፐር ሉፕ (እስከ 10-12 ዓመት የሚቆይ፣ ሆርሞን አልባ) እና የሆርሞን ሉፕ (እስከ 5 ዓመት የሚቆይ)።\n'
            '• **ጥቅሞች:** ምንም ዓይነት ሆርሞን ሳይጠቀሙ ለረጅም ጊዜ መከላከል ለሚፈልጉ የኮፐር ሉፕ ተመራጭ ነው።\n'
            '• **ማስገባት:** በሰለጠነ የጤና ባለሙያ በማህፀን በር በኩል በጥቂት ደቂቃዎች ውስጥ ይገባል።\n'
            '• **ልብ ይበሉ:** የኮፐር ሉፕ በመጀመሪያዎቹ ወራት የወር አበባ ህመምን ወይም ደምን ሊያበዛ ይችላል።',
        followUpQuestions: [
          'ሉፕ ገብቶ ግንኙነት ማድረግ ይቻላል?',
          'ሉፕ ማህፀን ውስጥ ይጠፋል የሚባለው እውነት ነው?',
          'ማሪ ስቶፕስ ክሊኒኮች የት ይገኛሉ?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Intrauterine Device (IUD)',
        text: '🛡️ **Intrauterine Device (IUD / Copper-T & Hormonal):**\n\n'
            '• **Longevity:** Copper-T provides up to 10–12 years of hormone-free protection. Hormonal IUDs provide 3–5 years.\n'
            '• **Mechanism:** Copper prevents sperm from reaching and fertilizing an egg. Can also serve as an emergency contraceptive if placed within 5 days of unprotected sex.\n'
            '• **Myths vs Facts:** An IUD cannot travel into other body organs. A healthcare provider can check the strings, and you can remove it anytime you decide to conceive.',
        followUpQuestions: [
          'Can women who haven’t given birth get an IUD?',
          'Does an IUD hurt during placement?',
          'How does the Copper IUD compare to Jadelle?',
        ],
      );
    }
  }

  static SrhResponse _getCondomsResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'ኮንዶም እና ድርብ ጥበቃ',
        text: '🛡️ **ኮንዶም (Dual Protection):**\n\n'
            '• **ድርብ ጥበቃ:** ኮንዶም ሁለቱንም—ያልተፈለገ እርግዝናን እና የአባለዘር በሽታዎችን (ኤች.አይ.ቪን ጨምሮ) በአንድ ጊዜ የሚከላከል ብቸኛው ዘዴ ነው!\n'
            '• **ትክክለኛ አጠቃቀም:**\n'
            '  1. የማለቂያ ቀኑን (Expiry Date) እና የፓኬቱን ንፅህና ያረጋግጡ።\n'
            '  2. ፓኬቱን በጥርስ ሳይሆን በእጅ በጥንቃቄ ይክፈቱ።\n'
            '  3. ከጫፉ ላይ አየር እንዳይይዝ ቆንጥጠው በመያዝ በቆመ ብልት ላይ እስከ ስሩ ድረስ ይግለጡት።\n'
            '  4. ከግንኙነት በኋላ ሳይለሰልስ ወዲያውኑ አውልቀው በሽንት ቤት ወረቀት ጠቅልለው ይጣሉ።\n'
            '• **የት ይገኛል?** በሁሉም የመንግስት ጤና ጣቢያዎች እና ወጣቶች ማዕከላት በነፃ ይገኛል።',
        followUpQuestions: [
          'ኮንዶም ከተቀደደ ምን ማድረግ አለብኝ?',
          'ኮንዶም ላይ ቫዝሊን መጠቀም ይቻላል?',
          'የሴቶች ኮንዶም በኢትዮጵያ ይገኛል?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Barrier Protection & Condoms',
        text: '🛡️ **Condoms (Dual Protection):**\n\n'
            '• **Dual Safety:** The only contraceptive method that simultaneously prevents unintended pregnancy AND protects against STIs (including HIV).\n'
            '• **Golden Rules for Safety:**\n'
            '  1. Always check the expiration date and air cushion on the pack before opening.\n'
            '  2. Never use teeth or scissors to open the package.\n'
            '  3. Pinch the tip to expel trapped air, and roll it down the fully erect penis.\n'
            '  4. Use water- or silicone-based lubricants only (never use Vaseline, baby oil, or lotions, which degrade latex within 60 seconds).\n'
            '• **Availability in Ethiopia:** Distributed 100% free at public health centers, or affordably via DKT (Sensation brand) at all pharmacies and shops.',
        followUpQuestions: [
          'What should I do if a condom breaks?',
          'What are the symptoms of common STIs?',
          'Where can I get free HIV testing?',
        ],
      );
    }
  }

  static SrhResponse _getOralPillsResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የየዕለት የወሊድ እንክብል',
        text: '💊 **የየዕለት የወሊድ መከላከያ እንክብል (Daily Pills):**\n\n'
            '• **አወሳሰድ:** በየቀኑ በአንድ ሰዓት ላይ መወሰድ አለበት። በሰዓቱ ሲወሰድ ከ99% በላይ አስተማማኝ ነው።\n'
            '• **እንክብል ቢረሳ:** ልክ እንዳስታወሱ የረሱትን ወዲያውኑ ይውሰዱ፤ የዕለቱንም በሰዓቱ ይውሰዱ። 2 እንክብል በተከታታይ ከረሱ ለሚቀጥሉት 7 ቀናት ተጨማሪ ጥበቃ (ኮንዶም) ይጠቀሙ።\n'
            '• **ጥቅም:** የወር አበባ ህመምን ይቀንሳል፣ የወር አበባን ዑደት ያዘወትራል።',
        followUpQuestions: [
          'የወሊድ እንክብል እርግዝና ይከላከላል?',
          'እንክብል መውሰድ ሲቆም ወዲያው እርጉዝ መሆን ይቻላል?',
          'የድንገተኛ እንክብል እና የየዕለት እንክብል ልዩነት ምንድን ነው?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Oral Contraceptive Pills',
        text: '💊 **Daily Combined Oral Contraceptive Pills (COCs):**\n\n'
            '• **Routine:** Must be taken every single day at the exact same time to maintain protective hormone levels.\n'
            '• **What if you miss a pill?** Take the missed pill as soon as you remember, even if it means taking two pills in one day. If you miss two or more consecutive days, use backup barrier protection (condoms) for the next 7 days.\n'
            '• **Additional Benefits:** Often helps regulate menstrual cycles, reduces heavy bleeding, and minimizes acne.',
        followUpQuestions: [
          'What is the difference between daily pills and Postpill?',
          'Are there pills safe for breastfeeding mothers?',
          'What are the warning signs to watch for?',
        ],
      );
    }
  }

  static SrhResponse _getHpvResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የስነ-ተዋልዶ ጤና ትምህርት',
        text: '🔬 **HPV (Human Papillomavirus) ምንድን ነው?**\n\n'
            '• **ትክክለኛ ፍቺ:** HPV ማለት **የሰው ፓፒሎማ ቫይረስ (Human Papillomavirus)** ማለት ነው። ይህ ቫይረስ በግብረ-ስጋ ግንኙነት እና በቆዳ ንክኪ የሚተላለፍ በጣም የተለመደ ቫይረስ ነው።\n'
            '• **የሚያስከትለው የጤና ችግር:** አብዛኛዎቹ የHPV አይነቶች ምንም ጉዳት ሳያደርሱ በራሳቸው ይጠፋሉ። ነገር ግን የተወሰኑት አይነቶች (በተለይ አይነት 16 እና 18) **የማህፀን በር ጫፍ ካንሰር (Cervical Cancer)** ሊያስከትሉ ይችላሉ፤ ሌሎች አይነቶች ደግሞ የብልት ኪንታሮት (Genital Warts) ያመጣሉ።\n'
            '• **መከላከያ (የHPV ክትባት):** በኢትዮጵያ ጤና ጥበቃ ሚኒስቴር ለታዳጊ ሴቶች **ነፃ የHPV ክትባት** በትምህርት ቤቶች እና በጤና ጣቢያዎች ይሰጣል።\n'
            '• **ምርመራ:** እድሜያቸው ከ30 ዓመት በላይ ለሆኑ ሴቶች በጤና ጣቢያዎች ቀላል የማህፀን በር ቅድመ-ካንሰር ምርመራ (VIA screening) በነፃ ይሰጣል።',
        followUpQuestions: [
          'የHPV ክትባት የት ይገኛል?',
          'የማህፀን በር ጫፍ ካንሰር ምርመራ (VIA) ምንድን ነው?',
          'የአባለዘር በሽታዎች መከላከያ መንገዶች',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'SRH Education',
        text: '🔬 **What does HPV mean? (Human Papillomavirus):**\n\n'
            '• **Medical Definition:** HPV stands for **Human Papillomavirus**. It is a common sexually transmitted viral infection transmitted through skin-to-skin intimate contact.\n'
            '• **Health Risks:** While most infections clear naturally by the immune system, persistent high-risk strains (specifically types 16 and 18) are the primary cause of **cervical cancer**. Low-risk strains can cause benign genital warts.\n'
            '• **Prevention (HPV Vaccine):** In Ethiopia, the national HPV vaccination campaign provides free, highly protective vaccines to adolescent girls through schools and public health centers before sexual debut.\n'
            '• **Clinical Screening:** Routine visual inspection with acetic acid (VIA screening) is available free at public health centers and Marie Stopes clinics for early detection and outpatient cryotherapy.',
        followUpQuestions: [
          'Where is the free HPV vaccine available in Ethiopia?',
          'What is Cervical Cancer VIA Screening?',
          'How effective are condoms against HPV transmission?',
        ],
      );
    }
  }

  static SrhResponse _getHivResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'ኤች.አይ.ቪ እና ምርመራ',
        text: '🩸 **ስለ ኤች.አይ.ቪ (HIV) እና ምርመራ:**\n\n'
            '• **ምልክቶች:** በመጀመሪያዎቹ ሳምንታት ጉንፋን መሰል ምልክቶች ሊታዩ ይችላሉ፤ ወይም ለብዙ ዓመታት ምንም ዓይነት ምልክት ሳይታይ በሰውነት ውስጥ ሊቆይ ይችላል። ሁኔታዎን ለማወቅ ብቸኛው መንገድ ምርመራ ማድረግ ነው።\n'
            '• **የመስኮት ወቅት (Window Period):** ቫይረሱ ከገባበት ቀን ጀምሮ በፈጣን ምርመራ እስከሚታወቅበት ድረስ ከ2 እስከ 12 ሳምንታት ሊወስድ ይችላል።\n'
            '• **ህክምና (ART):** ዛሬ ኤች.አይ.ቪ ያለባቸው ሰዎች በቀን አንዲት የART እንክብል በመውሰድ ረጅም፣ ጤናማ እና ውጤታማ ህይወት ይኖራሉ። ቫይረሱ በደማቸው ውስጥ እንዳይታይ (Undetectable) ሲሆን ለሌላ ሰው አያስተላልፉም (U=U)።\n'
            '• **በኢትዮጵያ:** ምርመራ እና የART ህክምና በሁሉም የመንግስት ጤና ተቋማት 100% ነፃ እና ሚስጥራዊ ነው።',
        followUpQuestions: [
          'PEP እና PrEP ምንድን ናቸው?',
          'ኤች.አይ.ቪ በምን አይተላለፍም?',
          'በአቅራቢያዬ ነፃ ምርመራ የት አገኛለሁ?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'HIV Facts & Confidential Testing',
        text: '🩸 **HIV Facts, Testing & Modern Treatment:**\n\n'
            '• **Early Symptoms:** Many people have zero symptoms for years, while some experience mild flu-like symptoms 2–4 weeks after exposure. You cannot diagnose HIV by symptoms alone.\n'
            '• **Window Period:** Rapid antibody blood tests detect HIV accurately around 4–12 weeks after potential exposure.\n'
            '• **Modern Antiretroviral Therapy (ART):** Today, taking one pill daily lowers the viral count to undetectable levels. **Undetectable = Untransmittable (U=U)**: people with an undetectable viral load cannot transmit HIV sexually.\n'
            '• **Services in Ethiopia:** Confidential rapid testing, counseling, and ART medication are 100% free at every government health center.',
        followUpQuestions: [
          'What is the difference between PEP and PrEP?',
          'Can HIV be transmitted through saliva or kissing?',
          'Where is the nearest testing site?',
        ],
      );
    }
  }

  static SrhResponse _getPrepResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የቅድመ ንክኪ መከላከያ (PrEP)',
        text: '🛡️ **PrEP (የቅድመ ንክኪ መከላከያ እንክብል):**\n\n'
            '• **ምን ማለት ነው?** ኤች.አይ.ቪ የሌለባቸው ሰዎች ለቫይረሱ ተጋላጭ ከሆኑበት ሁኔታ በፊት በየቀኑ የሚወስዱት የመከላከያ እንክብል ነው።\n'
            '• **ውጤታማነት:** በየቀኑ በስርዓት ሲወሰድ የኤች.አይ.ቪ የመያዝ እድልን ከ99% በላይ ይቀንሳል።\n'
            '• **ልዩነት:** PrEP ከግንኙነት *በፊት* በየቀኑ የሚወሰድ ሲሆን፤ PEP ደግሞ ድንገተኛ ንክኪ ካጋጠመ *በኋላ* በ72 ሰዓታት ውስጥ የሚጀመር ነው።',
        followUpQuestions: [
          'PrEP በኢትዮጵያ የት ይገኛል?',
          'PrEP ከአባለዘር በሽታዎች ይከላከላል?',
          'PEP እንዴት ይወሰዳል?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'PrEP (Pre-Exposure Prophylaxis)',
        text: '🛡️ **PrEP (Pre-Exposure Prophylaxis):**\n\n'
            '• **What is it?** A daily oral medication taken by HIV-negative individuals who are at ongoing substantial risk of HIV exposure.\n'
            '• **Efficacy:** Reduces the risk of getting HIV from sex by more than 99% when taken consistently.\n'
            '• **PrEP vs PEP:** PrEP is taken *before* exposure as a daily prevention habit; PEP is an emergency 28-day regimen started *after* exposure within 72 hours.',
        followUpQuestions: [
          'Where is PrEP available in Ethiopia?',
          'Does PrEP protect against pregnancy or syphilis?',
          'How frequently are checkups needed on PrEP?',
        ],
      );
    }
  }

  static SrhResponse _getStiResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የአባለዘር በሽታዎች እና ምልክቶች',
        text: '🩺 **የአባለዘር በሽታዎች (STIs) ምልክቶች እና ህክምና:**\n\n'
            '• **የተለመዱ ምልክቶች:**\n'
            '  - ያልተለመደ የብልት ፈሳሽ (ቢጫ፣ አረንጓዴ፣ የወፈረ ወይም መጥፎ ጠረን ያለው)\n'
            '  - በሽንት ጊዜ ማቃጠል ወይም ህመም\n'
            '  - በብልት አካባቢ ማሳከክ፣ ቁስል (sores) ወይም እብጠት\n'
            '  - የታችኛው ሆድ ህመም\n'
            '• **ህክምና:** አብዛኛዎቹ የአባለዘር በሽታዎች (እንደ ጨብጥ፣ ቂጥኝ እና ክላሚዲያ) በፀረ-ተህዋስያን (Antibiotics) ሙሉ በሙሉ ይድናሉ። ሁለቱም አጋሮች በአንድ ላይ መታከም አለባቸው።\n'
            '• **አስፈላጊ:** ያለ ሀኪም ትዕዛዝ ፋርማሲ ገብተው መድኃኒት አይውሰዱ፤ በአቅራቢያዎ ወደሚገኝ ጤና ጣቢያ ጎራ ይበሉ።',
        followUpQuestions: [
          'የጤናማ ፈሳሽ እና የኢንፌክሽን ፈሳሽ ልዩነት ምንድን ነው?',
          'ኮንዶም ሙሉ በሙሉ ከቂጥኝ ይከላከላል?',
          'የነፃ ህክምና የት ማግኘት እችላለሁ?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'STIs & Clinical Symptoms',
        text: '🩺 **Sexually Transmitted Infections (STIs):**\n\n'
            '• **Key Warning Signs:**\n'
            '  - Abnormal vaginal or penile discharge (yellowish, greenish, thick white, or foul-smelling)\n'
            '  - Burning or painful sensation during urination\n'
            '  - Sores, blisters, ulcers, or warts around genital or anal areas\n'
            '  - Deep lower abdominal or pelvic pain\n'
            '• **Curability:** Bacterial STIs like Syphilis, Gonorrhea, and Chlamydia are completely curable with proper antibiotics. Both sexual partners must be treated simultaneously to prevent reinfection.\n'
            '• **Ethiopian Syndromic Management:** Public health centers provide free or low-cost syndromic STI treatment immediately upon examination.',
        followUpQuestions: [
          'How do I tell normal discharge from an infection?',
          'What happens if an STI is left untreated?',
          'Where are Marie Stopes clinics located?',
        ],
      );
    }
  }

  static SrhResponse _getCycleAndOvulationResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የወር አበባ ዑደት እና እርግዝና ቀናት',
        text: '📅 **የወር አበባ ዑደት እና እርግዝና ሊፈጠር የሚችልባቸው ቀናት:**\n\n'
            '• **ዑደት ምንድን ነው?** ከአንድ የወር አበባ መጀመሪያ ቀን ጀምሮ እስከሚቀጥለው የወር አበባ መጀመሪያ ቀን ያለው ጊዜ ነው። መደበኛው ርዝመት ከ21 እስከ 35 ቀናት (በአማካይ 28 ቀናት) ነው።\n'
            '• **እንቁላል የሚወጣበት ቀን (Ovulation):** የወር አበባ ከሚመጣበት ቀን 14 ቀናት ቀደም ብሎ ይከሰታል። ለምሳሌ የ28 ቀን ዑደት ላላት ሴት በ14ኛው ቀን አካባቢ ነው።\n'
            '• **እርግዝና የሚፈጠርበት ወቅት (Fertile Window):** እንቁላል ከመውጣቷ 5 ቀናት በፊት እና ከወጣች ከ1-2 ቀናት በኋላ ያለው ጊዜ ከፍተኛ እርግዝና የሚፈጠርበት ነው። የወንድ የዘር ፍሬ በማህፀን ውስጥ እስከ 5 ቀናት በህይወት መቆየት ይችላል።\n'
            '• **ማስጠንቀቂያ:** የወር አበባ ዑደት በጭንቀት ወይም በሆርሞን ለውጥ ስለሚቀያየር የቀን ቆጠራ ብቻውን አስተማማኝ መከላከያ አይደለም።',
        followUpQuestions: [
          'የወር አበባዬ ለምን ይዛባል?',
          'በወር አበባ ወቅት እርግዝና ሊፈጠር ይችላል?',
          'የወር አበባ ዑደት 4ቱ ደረጃዎች ምን ምን ናቸው?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Menstrual Cycle & Fertile Window',
        text: '📅 **Menstrual Cycle & Ovulation Science:**\n\n'
            '• **Cycle Duration:** Counted from Day 1 of bleeding until the day before your next period begins. Normal cycles span between 21 and 35 days (average 28).\n'
            '• **Ovulation Timing:** Ovulation typically occurs approximately 14 days before the next period starts (around Day 14 for a 28-day cycle).\n'
            '• **The Fertile Window:** Encompasses the 5 days before ovulation plus ovulation day itself, because sperm can survive up to 5 days inside fertile cervical mucus.\n'
            '• **Important Caution:** Calendar-only tracking has a high failure rate in young people because cycles naturally fluctuate due to stress, nutrition, or exams.',
        followUpQuestions: [
          'Can you get pregnant during your period?',
          'What causes irregular periods?',
          'Explain the 4 phases of the menstrual cycle',
        ],
      );
    }
  }

  static SrhResponse _getCrampsResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የወር አበባ ቁርጠት (Cramps)',
        text: '🌸 **የወር አበባ ቁርጠት (Dysmenorrhea) ማስታገሻ ዘዴዎች:**\n\n'
            '• **ለምን ያመኛል?** ማህፀን ያረጀውን ደም ለማስወጣት በሚኮማተርበት ወቅት በፕሮስታግላንዲን (Prostaglandins) ሆርሞን ምክንያት የሚፈጠር ተፈጥሯዊ ሂደት ነው።\n'
            '• **ህመምን ለማስታገስ:**\n'
            '  1. **ሙቀት:** በታችኛው ሆድ ወይም ወገብ ላይ የሞቀ ውሃ ከረጢት ወይም የሞቀ ጨርቅ ማድረግ።\n'
            '  2. **ፈሳሽ:** ሞቅ ያለ ሻይ (ዝንጅብል ወይም ካሞሚል) እና ብዙ ውሃ መጠጣት።\n'
            '  3. **እንቅስቃሴ:** ቀላል የእግር ጉዞ፣ ዮጋ ወይም ቀላል የአካል እንቅስቃሴ ማህፀንን ያፍታታል።\n'
            '  4. **መድኃኒት:** እንደ Ibuprofen ወይም Paracetamol ያሉ ቀላል ማስታገሻዎች በሀኪም ወይም ፋርማሲስት ምክር መውሰድ።\n'
            '• **ሀኪም ማየት መቼ ያስፈልጋል?** ህመሙ ከአቅም በላይ ከሆነ፣ ከትምህርት ወይም ስራ የሚያስተጓጉል ከሆነ ወይም ከባድ ደም መፍሰስ ካለ የጤና ባለሙያ ያማክሩ።',
        followUpQuestions: [
          'የወር አበባ ህመም ከእድሜ ጋር ይቀንሳል?',
          'የወሊድ መከላከያ የወር አበባ ህመምን ይቀንሳል?',
          'ያልተለመደ ፈሳሽ ምልክቶች ምንድን ናቸው?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Menstrual Cramp Relief (Dysmenorrhea)',
        text: '🌸 **Menstrual Cramp Relief (Dysmenorrhea):**\n\n'
            '• **The Biological Cause:** Cramps are triggered by prostaglandins—natural hormone-like chemicals that cause the uterine muscle to contract and shed its lining.\n'
            '• **Proven Evidence-Based Remedies:**\n'
            '  1. **Heat Therapy:** Applying a heating pad or hot water bottle to the lower abdomen relaxes the myometrium as effectively as mild pain relievers.\n'
            '  2. **Hydration & Warm Teas:** Staying well hydrated reduces pelvic bloating. Warm ginger or peppermint tea helps soothe smooth muscle contractions.\n'
            '  3. **Gentle Movement:** Walking, stretching, or light aerobic activity releases endorphins—your body’s natural painkillers.\n'
            '  4. **NSAIDs:** Ibuprofen taken at the very onset of cramps suppresses prostaglandin production effectively.\n'
            '• **When to Consult a Clinician:** If pain is severe, incapacitating, or accompanied by heavy clotting, visit a youth clinic to screen for conditions like endometriosis.',
        followUpQuestions: [
          'Do hormonal contraceptives reduce period cramps?',
          'What foods help ease period pain?',
          'What are normal vs abnormal flow amounts?',
        ],
      );
    }
  }

  static SrhResponse _getPubertyResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'የጉርምስና ወቅት እና ተፈጥሯዊ ለውጦች',
        text: '🌱 **በጉርምስና ወቅት የሚታዩ ተፈጥሯዊ ለውጦች:**\n\n'
            '• **የእንቅልፍ ፈሳሽ (Wet Dreams / Nocturnal Emissions):** በወንዶች ላይ በእንቅልፍ ወቅት የሚከሰት ተፈጥሯዊ የወንድ ዘር መፍሰስ ነው። ይህ ምንም ዓይነት ህመም ወይም በሽታ ሳይሆን ሰውነት የደረሰበትን የሆርሞን እድገት የሚያሳይ ተፈጥሯዊ ሂደት ነው።\n'
            '• **በልጃገረዶች ላይ:** የጡት ማደግ፣ የዳሌ መስፋት፣ በብልት እና በብብት አካባቢ ፀጉር ማብቀል እና የወር አበባ መጀመር (Menarche)።\n'
            '• **በወንዶች ላይ:** የድምፅ መጎርነን፣ የጡንቻ ማደግ፣ የብልት መጠን መጨመር እና የፊት ፀጉር ማብቀል።\n'
            '• **የስሜት መለዋወጥ:** በሆርሞን ለውጥ ምክንያት የስሜት መለዋወጥ የተለመደ ነው። ማንኛውንም ለውጥ በፍርሃት ሳይሆን በተፈጥሮ ሂደትነት ይመልከቱት።',
        followUpQuestions: [
          'የወር አበባ በስንት አመት ይጀምራል?',
          'የፊት ብጉር በጉርምስና ወቅት ለምን ይበዛል?',
          'ራስን ማርካት ጉዳት አለው?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Puberty & Body Changes',
        text: '🌱 **Puberty Science & Normal Biological Changes:**\n\n'
            '• **Wet Dreams (Nocturnal Emissions):** Involuntary ejaculation during sleep is completely normal and healthy. It does not indicate illness, weakness, or moral failing—it is simply how the body manages seminal fluid.\n'
            '• **Changes in Girls:** Breast development (thelarche), wider hips, pubic/underarm hair growth, and onset of menstruation (menarche, usually ages 10–15).\n'
            '• **Changes in Boys:** Deepening vocal pitch, enlargement of testicles and penis, facial and body hair growth, and height growth spurts.\n'
            '• **Emotional Growth:** Hormonal surges naturally affect mood, self-image, and attraction. These transitions are universal milestones.',
        followUpQuestions: [
          'What is the normal age for menstruation to begin?',
          'Is breast asymmetry normal?',
          'How does puberty affect skin and acne?',
        ],
      );
    }
  }

  static SrhResponse _getMasturbationResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'ስለ ራስን ማርካት የተሳሳቱ አመለካከቶች',
        text: '🔍 **ስለ ራስን ማርካት (Masturbation) የህክምና እውነታዎች:**\n\n'
            '• **የህክምና እውነታ:** ራስን ማርካት በተፈጥሮ ብዙ ሰዎች የሚያደርጉት የተለመደ ተግባር ነው።\n'
            '• **የተሳሳቱ አመለካከቶች እና እውነታዎች:**\n'
            '  ❌ አያሳውርም (Does not cause blindness)\n'
            '  ❌ መካን አያደርግም (Does not cause infertility)\n'
            '  ❌ ጉልበት ወይም አእምሮን አያደክምም\n'
            '  ❌ የፊት ብጉር አያመጣም\n'
            '• **መቼ ችግር ይሆናል?** ከዕለት ተዕለት ኑሮ፣ ትምህርት ወይም ማህበራዊ ግንኙነት የሚያስተጓጉል ከሆነ ወይም ከፍተኛ የጥፋተኝነት ስሜት የሚፈጥር ከሆነ የባህሪ ድጋፍ ማግኘት ይመከራል።',
        followUpQuestions: [
          'ስለ ወሲባዊ ጤና ሌሎች ጥያቄዎች አሉዎት?',
          'የአባለዘር በሽታዎች እንዴት ይተላለፋሉ?',
          'ለማማከር በነፃ የስልክ መስመር 8335 ይደውሉ',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Sexual Health Myths & Facts',
        text: '🔍 **Masturbation: Scientific Facts vs Myths:**\n\n'
            '• **Medical Consensus:** Masturbation is a common, normal human behavior across genders with zero adverse physical health effects.\n'
            '• **Debunking Common Myths:**\n'
            '  ❌ It does NOT cause blindness, hair loss, or back weakness.\n'
            '  ❌ It does NOT cause infertility or deplete sperm counts.\n'
            '  ❌ It does NOT cause acne or stunt physical growth.\n'
            '• **When to Seek Support:** Only if compulsive habits interfere with daily obligations, sleep, or mental well-being is counseling recommended.',
        followUpQuestions: [
          'What are the emotional aspects of sexual health?',
          'How do condoms protect against STIs?',
          'What clinics offer confidential counseling?',
        ],
      );
    }
  }

  static SrhResponse _getClinicsResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'በኢትዮጵያ ውስጥ ያሉ የጤና ማዕከላት',
        text: '🏥 **በኢትዮጵያ ውስጥ ያሉ ሚስጥራዊ የጤና እና የምክር አገልግሎቶች:**\n\n'
            '1. **ነፃ የስልክ መስመሮች (Toll-Free Hotlines):**\n'
            '   • **8335** - የወጣቶች የስነ-ተዋልዶ ጤና እና የኤች.አይ.ቪ ነፃ የስልክ መስመር\n'
            '   • **6788** - የሴቶች እና የህጻናት ጥቃት ድንገተኛ መስመር\n'
            '   • **952** - የኢትዮጵያ የህብረተሰብ ጤና ኢንስቲትዩት (EPHI)\n\n'
            '2. **ክሊኒካዊ አገልግሎቶች:**\n'
            '   • **ማሪ ስቶፕስ ኢትዮጵያ (Marie Stopes):** በሁሉም ዋና ዋና ከተሞች የወሊድ መከላከያ፣ ምክር እና ምርመራ ይሰጣሉ።\n'
            '   • **የኢትዮጵያ ቤተሰብ መምሪያ ማህበር (FGAE):** ለወጣቶች ምቹ እና ሚስጥራዊ የሆኑ ክሊኒኮች አሏቸው።\n'
            '   • **የመንግስት ጤና ጣቢያዎች:** ነፃ የኤች.አይ.ቪ ምርመራ፣ ነፃ ኮንዶም፣ PEP እና የSTI ህክምና ይሰጣሉ።',
        followUpQuestions: [
          'የማሪ ስቶፕስ አገልግሎቶች ምን ምን ናቸው?',
          'በጤና ጣቢያ የሚሰጡ ነፃ አገልግሎቶች ምንድን ናቸው?',
          'የድንገተኛ መከላከያ በፋርማሲ ስንት ነው?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'Youth-Friendly Clinics & Hotlines in Ethiopia',
        text: '🏥 **Confidential SRH Services & Helplines in Ethiopia:**\n\n'
            '1. **Toll-Free Youth Helplines:**\n'
            '   • **8335** - National Youth Reproductive Health & HIV hotline (Amharic, Afaan Oromoo, Tigrinya, Somali, English)\n'
            '   • **6788** - National GBV & Survivor Support Hotline\n'
            '   • **952** - Ethiopian Public Health Institute (EPHI)\n\n'
            '2. **Clinical Partners Across Ethiopia:**\n'
            '   • **Marie Stopes Ethiopia (MSE):** Comprehensive contraception, cervical cancer screening, and pregnancy guidance across Addis Ababa, Bahir Dar, Hawassa, Adama, Mekelle, and Dire Dawa.\n'
            '   • **Family Guidance Association of Ethiopia (FGAE):** Specialized youth-friendly drop-in clinics.\n'
            '   • **Public Woreda Health Centers:** Provide free HIV testing, syndromic STI management, PEP within 72 hours, and free condoms.',
        followUpQuestions: [
          'How does the 8335 hotline work?',
          'What are the services provided at FGAE clinics?',
          'What should I bring to a public health center?',
        ],
      );
    }
  }

  static SrhResponse _getDefaultResponse(bool isAmharic) {
    if (isAmharic) {
      return const SrhResponse(
        category: 'ጠቅላላ የጤና መረጃ',
        text: 'ጤና ዋይዝ ስለ ስነ-ተዋልዶ ጤና የተረጋገጠ እና ሚስጥራዊ መረጃ ይሰጣል።\n\n'
            'ስለሚከተሉት ርእሶች በነፃነት መጠየቅ ይችላሉ:\n'
            '• **አጠቃላይ የስነ-ተዋልዶ ፅንሰ-ሀሳብ:** የSRH 5ቱ ምሰሶዎች፣ መብቶች እና የሰውነት ነፃነት\n'
            '• **የመራባት ስነ-ህይወት:** እርግዝና ደረጃ በደረጃ እንዴት እንደሚፈጠር\n'
            '• **የወሊድ መከላከያ ዘዴዎች:** ድንገተኛ እንክብል (Postpill)፣ የ3 ወር መርፌ፣ ጃዴል፣ ሉፕ እና ኮንዶም\n'
            '• **የአባለዘር በሽታዎች እና ኤች.አይ.ቪ:** ምርመራ፣ ምልክቶች፣ PEP (በ72 ሰዓታት ውስጥ) እና PrEP\n'
            '• **የወር አበባ ጤና:** የዑደት 4ቱ ደረጃዎች፣ የወር አበባ ቁርጠት ማስታገሻ፣ የእንቁላል መውጫ ቀናት\n'
            '• **የተሳሳቱ አመለካከቶች እና ሳይንሳዊ እውነታዎች:** በኢትዮጵያ ውስጥ ያሉ የተሳሳቱ ወሬዎች ማስተባበያ\n\n'
            '📞 እንዲሁም ለግል ክሊኒካዊ ምክር በነፃ መስመር **8335** መደወል ይችላሉ።',
        followUpQuestions: [
          'የስነ-ተዋልዶ ጤና ፅንሰ-ሀሳብ ምንድን ነው?',
          'የወሊድ መከላከያ ዘዴዎች በሙሉ ምን ምን ናቸው?',
          'እርግዝና እንዴት ይፈጠራል?',
          'የኤች.አይ.ቪ ምልክቶች ምንድን ናቸው?',
        ],
      );
    } else {
      return const SrhResponse(
        category: 'General SRH Knowledge',
        text: 'TenaWise provides peer-reviewed, confidential reproductive health education tailored for young people.\n\n'
            'You can ask me about:\n'
            '• **Fundamental SRH Concepts:** Definition, 5 Core Pillars, Bodily Autonomy & Rights\n'
            '• **Human Reproduction Biology:** Step-by-step conception, fertilization & implantation\n'
            '• **Contraceptive Comparison:** Emergency pills, Implants, IUDs, Depo-Provera, Condoms\n'
            '• **HIV & STIs:** Pathophysiology, Rapid testing, PEP within 72 hours, PrEP, Syndromic care\n'
            '• **Menstrual Health & Endocrinology:** 4 phases of cycle, hormonal regulation, cramp relief\n'
            '• **Myths vs Science:** Fact-checking widespread cultural misconceptions in Ethiopia\n\n'
            '📞 In Ethiopia, you can also dial **8335** for 100% free, confidential youth counseling.',
        followUpQuestions: [
          'What is sexual and reproductive health?',
          'Compare all birth control methods',
          'How does conception work biologically?',
          'What are common SRH myths in Ethiopia?',
        ],
      );
    }
  }
}
