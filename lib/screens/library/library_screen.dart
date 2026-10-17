import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../core/widgets/tactile_card.dart';

/// STI & Contraceptive Library screen.
/// 100% English when English is selected; 100% Amharic when Amharic is selected.
/// Supports smooth horizontal swipe gestures between all 4 categories:
/// STIs, Contraception, Menstrual Health, and Sexual Health.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late PageController _pageController;
  int _selectedTab = 0; // 0=STIs, 1=Contraception, 2=Menstrual, 3=Sexual Health
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTab = index;
      _selectedFilter = 'All';
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showDetailSheet(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String category,
    required List<Map<String, String>> sections,
    required bool isAmharic,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    ...sections.map((sec) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sec['heading']!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sec['body']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurface,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_in_talk, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isAmharic
                                  ? 'ተጨማሪ ሚስጥራዊ መረጃ ይፈልጋሉ? በነፃ የጤና ስልክ መስመር 8335 ይደውሉ።'
                                  : 'Need confidential counseling? Call free youth helpline 8335.',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 1. STIs Dataset
  final List<Map<String, dynamic>> _stiItems = [
    {
      'name_en': 'HIV',
      'name_am': 'ኤች.አይ.ቪ (HIV)',
      'type_en': 'Viral',
      'type_am': 'ቫይራል',
      'sub_en': 'Human Immunodeficiency Virus',
      'sub_am': 'የሰውነት በሽታ የመከላከል አቅም የሚያዳክም ቫይረስ',
      'tag_en': 'ART Treatment Available',
      'tag_am': 'ተቆጣጣሪ ህክምና አለ (ART)',
      'curable': false,
      'freeEth': true,
      'transmission_en':
          'Unprotected sexual contact, contaminated blood or sharps, and mother-to-child during pregnancy.',
      'transmission_am':
          'ጥንቃቄ የጎደለው ግንኙነት፣ ከተበከለ ደም ወይም ስለታማ እቃዎች፣ እና ከእናት ወደ ልጅ።',
      'prevention_en':
          'Consistent condom use, PrEP (before exposure), and PEP (within 72 hours).',
      'prevention_am':
          'ኮንዶም መጠቀም፣ PrEP (ከግንኙነት በፊት)፣ እና PEP (በ72 ሰዓት ውስጥ)።',
      'access_en':
          'Free and confidential rapid testing is available at all public health centers, Marie Stopes, and FGAE clinics.',
      'access_am':
          'በማንኛውም የወረዳ ጤና ጣቢያ፣ ማሪ ስቶፕስ (Marie Stopes)፣ እና FGAE ነፃ የፈጣን ምርመራ ይሰጣል።',
    },
    {
      'name_en': 'Syphilis',
      'name_am': 'ቂጥኝ (Syphilis)',
      'type_en': 'Bacterial',
      'type_am': 'ባክቴሪያል',
      'sub_en': 'Treponema pallidum infection',
      'sub_am': 'ትሬፖኔማ ፓሊደም የባክቴሪያ ኢንፌክሽን',
      'tag_en': '100% Curable with Antibiotics',
      'tag_am': 'ሙሉ በሙሉ ይድናል',
      'curable': true,
      'freeEth': true,
      'transmission_en':
          'Direct contact with infectious sores or unprotected sexual intercourse.',
      'transmission_am': 'በቀጥታ ቁስል ንክኪ ወይም ጥንቃቄ የጎደለው ግንኙነት።',
      'prevention_en':
          'Consistent condom use and routine screening during wellness checkups.',
      'prevention_am': 'ኮንዶም አዘውትሮ መጠቀም፣ ቅድመ-ምርመራ ማድረግ።',
      'access_en':
          'Easily treated and cured with penicillin injections at all public health centers.',
      'access_am':
          'በፔኒሲሊን (Penicillin) መርፌ በቀላሉ ይድናል። በሁሉም የመንግስት ጤና ጣቢያዎች ምርመራ አለ።',
    },
    {
      'name_en': 'Gonorrhea',
      'name_am': 'ጨብጥ (Gonorrhea)',
      'type_en': 'Bacterial',
      'type_am': 'ባክቴሪያል',
      'sub_en': 'Neisseria gonorrhoeae infection',
      'sub_am': 'የባክቴሪያ ኢንፌክሽን',
      'tag_en': 'Curable with Antibiotics',
      'tag_am': 'በአንቲባዮቲክስ ይድናል',
      'curable': true,
      'freeEth': false,
      'transmission_en':
          'Unprotected vaginal, anal, or oral sexual contact.',
      'transmission_am': 'ጥንቃቄ በጎደለው ግንኙነት የሚተላለፍ የባክቴሪያ ኢንፌክሽን።',
      'prevention_en':
          'Condom use and prompt dual-partner treatment upon notice of symptoms.',
      'prevention_am': 'ኮንዶም መጠቀም እና ምልክት ሲታይ ወዲያውኑ መታከም።',
      'access_en':
          'Treated with prescribed antibiotics. Both sexual partners must be treated simultaneously.',
      'access_am':
          'በአንቲባዮቲክስ ይታከማል። ሁለቱም አጋሮች እኩል መታከም አለባቸው።',
    },
    {
      'name_en': 'HPV',
      'name_am': 'የማህፀን በር ካንሰር አምጪ ቫይረስ (HPV)',
      'type_en': 'Viral',
      'type_am': 'ቫይራል',
      'sub_en': 'Human Papillomavirus',
      'sub_am': 'ሂውማን ፓፒሎማቫይረስ',
      'tag_en': 'Preventive Vaccine Available',
      'tag_am': 'ክትባት አለው',
      'curable': false,
      'freeEth': true,
      'transmission_en':
          'Intimate skin-to-skin contact during sexual activity.',
      'transmission_am': 'በቆዳ ንክኪ እና በግብረ-ስጋ ግንኙነት ይተላለፋል።',
      'prevention_en':
          'HPV vaccination (administered to adolescents) and routine screening.',
      'prevention_am':
          'የHPV ክትባት መውሰድ (ለታዳጊዎች በነፃ ይሰጣል) እና መደበኛ የማህፀን በር ምርመራ።',
      'access_en':
          'Free vaccines provided for young females in Ethiopian schools and local health posts.',
      'access_am':
          'በጤና ጣቢያዎችና በትምህርት ቤቶች ለልጃገረዶች ነፃ ክትባት ይሰጣል።',
    },
  ];

  // 2. Contraception Dataset
  final List<Map<String, dynamic>> _contraItems = [
    {
      'name_en': 'Male & Female Condoms',
      'name_am': 'ኮንዶም (Condoms)',
      'category_en': 'Barrier',
      'category_am': 'ድርብ ጥበቃ',
      'sub_en': 'Dual Protection',
      'sub_am': 'ድርብ ጥበቃ',
      'tag_en': 'Prevents STIs & Pregnancy',
      'tag_am': 'STIs + እርግዝናን ይከላከላል',
      'effectiveness_en': '98% (Correct Use)',
      'effectiveness_am': '98% ትክክለኛ አጠቃቀም',
      'details_en':
          'The only contraceptive method that simultaneously shields against both STIs and unintended pregnancy.',
      'details_am':
          'ብቸኛው የአባለዘር በሽታዎችን እና ያልተፈለገ እርግዝናን በአንድ ጊዜ የሚከላከል ዘዴ ነው።',
      'access_en':
          'Widely accessible for free or minimal fee at public health centers, youth facilities, and pharmacies.',
      'access_am':
          'በሁሉም ጤና ጣቢያዎች፣ ማህበራዊ ድርጅቶችና ፋርማሲዎች በነፃ ወይም በዝቅተኛ ዋጋ ይገኛል።',
    },
    {
      'name_en': 'Implanon / Jadelle',
      'name_am': 'የክንድ ውስጥ እንክብል (Implanon)',
      'category_en': 'LARC',
      'category_am': 'ረጅም ጊዜ',
      'sub_en': 'Long-acting Reversible (3-5 Years)',
      'sub_am': 'ረጅም ጊዜ የሚቆይ',
      'tag_en': '>99% Reliable',
      'tag_am': '>99% አስተማማኝ',
      'effectiveness_en': '>99%',
      'effectiveness_am': '>99%',
      'details_en':
          'A tiny flexible rod inserted beneath the skin of the upper arm. Provides multi-year protection. Fertility returns immediately upon removal.',
      'details_am':
          'በክንድ ቆዳ ስር የሚቀበር ትንሽ ፕላስቲክ። የወር አበባ መጠን ሊቀንስ ይችላል። ሲወጣ የመውለድ ችሎታ ወዲያውኑ ይመለሳል።',
      'access_en':
          'Available free of charge at government health centers and Marie Stopes clinics.',
      'access_am':
          'በመንግስት ጤና ጣቢያዎች እና በማሪ ስቶፕስ ክሊኒኮች በነፃ ይሰጣል።',
    },
    {
      'name_en': 'Emergency Contraceptive Pill',
      'name_am': 'ድንገተኛ መከላከያ (Postinor)',
      'category_en': 'Emergency',
      'category_am': 'ድንገተኛ',
      'sub_en': 'Within 72 Hours',
      'sub_am': 'በ72 ሰዓታት ውስጥ',
      'tag_en': 'Emergency Use Only',
      'tag_am': 'ለድንገተኛ ጊዜ ብቻ',
      'effectiveness_en': 'Up to 95%',
      'effectiveness_am': 'እስከ 95%',
      'details_en':
          'Used following unprotected sex or barrier mishap within 72 hours (3 days). Not a substitute for regular contraception.',
      'details_am':
          'ኮንዶም ሲቀደድ ወይም ጥንቃቄ የጎደለው ግንኙነት ሲያጋጥም በ72 ሰዓታት ውስጥ የሚወሰድ። መደበኛ መከላከያ አይደለም።',
      'access_en':
          'Obtainable over the counter at any local pharmacy without a doctor prescription.',
      'access_am':
          'በማንኛውም ፋርማሲ ያለ ሀኪም ማዘዣ በነፃነት ይገኛል።',
    },
    {
      'name_en': 'Depo-Provera',
      'name_am': 'የ3 ወር መርፌ (Depo-Provera)',
      'category_en': 'Short-term',
      'category_am': 'አጭር ጊዜ',
      'sub_en': 'Injectable Every 3 Months',
      'sub_am': 'በየ3 ወሩ የሚደገም',
      'tag_en': '96% Effective',
      'tag_am': '96% አስተማማኝ',
      'effectiveness_en': '96%',
      'effectiveness_am': '96%',
      'details_en':
          'An intramuscular injection received once every 3 months. Confidential and convenient.',
      'details_am':
          'በየ3 ወሩ በጡንቻ ውስጥ የሚሰጥ መርፌ። ሚስጥራዊ እና ለአጠቃቀም ምቹ ነው።',
      'access_en':
          'Readily provided at public health centers and reproductive health clinics.',
      'access_am':
          'በሁሉም የጤና ጣቢያዎች እና ክሊኒኮች በቀላሉ ይገኛል።',
    },
  ];

  // 3. Menstrual Health Dataset
  final List<Map<String, dynamic>> _menstrualItems = [
    {
      'name_en': 'Dysmenorrhea (Menstrual Cramps)',
      'name_am': 'የወር አበባ ቁርጠት (Dysmenorrhea)',
      'category_en': 'Symptoms',
      'category_am': 'ምልክቶች',
      'sub_en': 'Uterine Muscle Contraction',
      'sub_am': 'የማህፀን መኮማተር ህመም',
      'tag_en': 'Natural & Manageable',
      'tag_am': 'ተፈጥሯዊ እና የሚታከም',
      'details_en':
          'Cramps occur when the uterus contracts to shed its lining, triggered by prostaglandins. Mild to moderate cramps are normal.',
      'details_am':
          'በማህፀን መኮማተር ምክንያት የሚከሰት የተለመደ የህመም ስሜት ነው። ሞቅ ያለ ውሃ መጠጣትና ሙቀት መስጠት ህመሙን ይቀንሳል።',
      'action_en':
          'Apply a warm heating pad to lower abdomen, stay hydrated, engage in light walking, and consult a clinic if pain is debilitating.',
      'action_am':
          'ሆድ ላይ የሞቀ ውሃ ከረጢት ማድረግ፣ በቂ እረፍት መውሰድ እና ህመሙ ከመጠን በላይ ከሆነ ሀኪም ማማከር ይመከራል።',
    },
    {
      'name_en': 'PMS & Mood Changes',
      'name_am': 'የቅድመ-ወር አበባ ምልክቶች (PMS)',
      'category_en': 'Hormonal',
      'category_am': 'ሆርሞናል',
      'sub_en': 'Luteal Phase Progesterone Shifts',
      'sub_am': 'ከወር አበባ በፊት የሚከሰት',
      'tag_en': 'Premenstrual Syndrome',
      'tag_am': 'የስሜት መለዋወጥ',
      'details_en':
          'Emotional fluctuations, bloating, breast tenderness, and fatigue occurring 5-11 days prior to menstruation due to changing hormone levels.',
      'details_am':
          'ከወር አበባ መምጣት ጥቂት ቀናት በፊት የሚከሰት የድካም፣ የሆድ መነፋት እና የስሜት መለዋወጥ ነው። ሆርሞኖች ሲቀያየሩ ይከሰታል።',
      'action_en':
          'Maintain regular sleep schedules, reduce caffeine and high-salt intake, and practice gentle relaxation exercises.',
      'action_am':
          'በቂ እንቅልፍ መተኛት፣ ጨውና ቡና መቀነስ እንዲሁም ቀላል እንቅስቃሴ ማድረግ ምልክቶቹን ያቃልላል።',
    },
    {
      'name_en': 'Menstrual Hygiene Management',
      'name_am': 'የወር አበባ ንፅህና አጠባበቅ',
      'category_en': 'Hygiene',
      'category_am': 'ንፅህና',
      'sub_en': 'Infection Prevention & Care',
      'sub_am': 'ኢንፌክሽንን መከላከል',
      'tag_en': 'Crucial Health Practice',
      'tag_am': 'መሰረታዊ የጤና ልማድ',
      'details_en':
          'Maintaining proper cleanliness prevents bacterial vaginosis and urinary tract infections. Use clean, breathable materials.',
      'details_am':
          'ንፅህናን በአግባቡ አለመጠበቅ ለተለያዩ ባክቴሪያል ኢንፌክሽኖች ሊያጋልጥ ይችላል። ንጹህ መከላከያዎችን መጠቀም አስፈላጊ ነው።',
      'action_en':
          'Change sanitary pads every 4-6 hours, wash with plain warm water without harsh perfumed soaps, and dry reusable cloths thoroughly in sunlight.',
      'action_am':
          'ሞዴስን በየ4-6 ሰዓቱ መቀየር፣ በንጹህ ውሃ መታጠብ እንዲሁም ሽታ ያላቸው ሳሙናዎችን አለመጠቀም።',
    },
  ];

  // 4. Sexual Health & Relationships Dataset
  final List<Map<String, dynamic>> _sexualHealthItems = [
    {
      'name_en': 'Consent & Boundaries',
      'name_am': 'ፈቃደኝነት እና የግል ወሰን (Consent)',
      'category_en': 'Relationships',
      'category_am': 'ግንኙነት',
      'sub_en': 'Mutual Respect & Communication',
      'sub_am': 'የጋራ መከባበር',
      'tag_en': 'Fundamental Right',
      'tag_am': 'መሰረታዊ መብት',
      'details_en':
          'Consent must be freely given, reversible, informed, enthusiastic, and specific. Silence or peer pressure is never consent.',
      'details_am':
          'ማንኛውም ግንኙነት በሁለቱም ወገን ሙሉ ፈቃደኝነት እና መከባበር ላይ የተመሰረተ መሆን አለበት። ጫና ወይም ማስገደድ ፈቃደኝነት አይደለም።',
      'action_en':
          'Communicate openly with your partner about personal comfort levels. You always have the right to say no at any time.',
      'action_am':
          'ስለራስዎ ወሰን በግልጽ ይነጋገሩ። በማንኛውም ሰዓት ያለ ፍርሃት "አይሆንም" የማለት ሙሉ መብት አለዎት።',
    },
    {
      'name_en': 'STI & Pregnancy Myth Busting',
      'name_am': 'የተሳሳቱ አመለካከቶች እና እውነታዎች',
      'category_en': 'Myths',
      'category_am': 'እውነታዎች',
      'sub_en': 'Evidence vs Rumors',
      'sub_am': 'ሳይንሳዊ እውነታዎች',
      'tag_en': 'Evidence-Based',
      'tag_am': 'በማስረጃ የተደገፈ',
      'details_en':
          'Myth: Washing after sex prevents pregnancy. Truth: Sperm enters the cervix within seconds. Myth: Antibiotics before sex prevent STIs. Truth: Antibiotics do not prevent infection.',
      'details_am':
          'የተሳሳተ እሳቤ፡ ግንኙነት ካደረጉ በኋላ መታጠብ እርግዝናን ይከላከላል (ሀሰት)። ከግንኙነት በፊት መድኃኒት መውሰድ በሽታን ይከላከላል (ሀሰት)።',
      'action_en':
          'Always rely on clinical methods (condoms, modern contraception) rather than unverified cultural myths.',
      'action_am':
          'ከተሳሳቱ ወሬዎች ይልቅ በሳይንሳዊ መንገድ የተረጋገጡ የመከላከያ ዘዴዎችን (ኮንዶም እና ዘመናዊ የወሊድ መከላከያዎችን) ይጠቀሙ።',
    },
    {
      'name_en': 'Emotional Wellbeing & Safety',
      'name_am': 'የስነ-ልቦና ጤና እና ደህንነት',
      'category_en': 'Wellbeing',
      'category_am': 'ስነ-ልቦና',
      'sub_en': 'Mental Health & Stigma Reduction',
      'sub_am': 'የአእምሮ ጤና',
      'tag_en': 'Youth-Friendly Support',
      'tag_am': 'የወጣቶች ደህንነት',
      'details_en':
          'Anxiety about sexual health and stigma can cause severe emotional stress. Seeking healthcare is a responsible and mature step.',
      'details_am':
          'ስለ ወሲባዊ ጤና መጨነቅ ወይም መፍራት የተለመደ ነው። የጤና ምርመራ ማድረግና መረጃ መፈለግ ብልህነት እንጂ የሚያሳፍር ነገር አይደለም።',
      'action_en':
          'Confide in trained youth-friendly healthcare counselors. Remember you can call the free youth helpline at 8335.',
      'action_am':
          'ምስጢራቸው የተጠበቀ የጤና ባለሙያዎችን ያማክሩ። በነፃ የስልክ መስመር 8335 ደውለው ማናገር ይችላሉ።',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppLanguage.isAmharicNotifier,
      builder: (context, isAmharic, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: Text(
              isAmharic ? 'የጤና መረጃ ቤተ-መጽሐፍት' : 'Health Knowledge Library',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top Search Bar
                StaggeredEntrance(
                  index: 0,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: TextField(
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: isAmharic
                            ? 'በርዕስ፣ ምልክት ወይም መድሃኒት ይፈልጉ...'
                            : 'Search conditions, symptoms, or methods...',
                        hintStyle:
                            const TextStyle(fontSize: 13, color: AppColors.outline),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.outline, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surfaceContainerLowest,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // 4-Category Swipeable Tab Bar
                StaggeredEntrance(
                  index: 1,
                  child: _buildSwipeableTabBar(isAmharic),
                ),

                // Dynamic Filter Chips
                StaggeredEntrance(
                  index: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: _buildFilterChips(isAmharic),
                  ),
                ),

                // Swipeable PageView Container
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _selectedTab = index;
                        _selectedFilter = 'All';
                      });
                    },
                    children: [
                      _buildStiList(isAmharic),
                      _buildContraList(isAmharic),
                      _buildMenstrualList(isAmharic),
                      _buildSexualHealthList(isAmharic),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Compact horizontal category tab bar with active indicator
  Widget _buildSwipeableTabBar(bool isAmharic) {
    final tabs = isAmharic
        ? [
            {'icon': Icons.shield_outlined, 'label': 'STIs'},
            {'icon': Icons.medication_outlined, 'label': 'የወሊድ መከላከያ'},
            {'icon': Icons.water_drop_outlined, 'label': 'የወር አበባ ጤና'},
            {'icon': Icons.favorite_outline, 'label': 'የጾታ ጤና'},
          ]
        : [
            {'icon': Icons.shield_outlined, 'label': 'STIs'},
            {'icon': Icons.medication_outlined, 'label': 'Contraception'},
            {'icon': Icons.water_drop_outlined, 'label': 'Menstrual'},
            {'icon': Icons.favorite_outline, 'label': 'Sexual Health'},
          ];

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          final tab = tabs[index];
          return Expanded(
            child: InkWell(
              onTap: () => _onTabSelected(index),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 14,
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        tab['label'] as String,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFilterChips(bool isAmharic) {
    List<String> chips;
    if (_selectedTab == 0) {
      chips = isAmharic
          ? ['All', 'ባክቴሪያል', 'ቫይራል', 'የሚድኑ', 'ነፃ ምርመራ']
          : ['All', 'Bacterial', 'Viral', 'Curable', 'Free Testing'];
    } else if (_selectedTab == 1) {
      chips = isAmharic
          ? ['All', 'ኮንዶም', 'ረጅም ጊዜ', 'ድንገተኛ', 'አጭር ጊዜ']
          : ['All', 'Barrier', 'LARC', 'Emergency', 'Short-term'];
    } else if (_selectedTab == 2) {
      chips = isAmharic
          ? ['All', 'ምልክቶች', 'ሆርሞናል', 'ንፅህና']
          : ['All', 'Symptoms', 'Hormonal', 'Hygiene'];
    } else {
      chips = isAmharic
          ? ['All', 'ግንኙነት', 'እውነታዎች', 'ስነ-ልቦና']
          : ['All', 'Relationships', 'Myths', 'Wellbeing'];
    }

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = chips[index];
          final isSelected = _selectedFilter == label ||
              (_selectedFilter == 'All' && index == 0);

          return FilterChip(
            selected: isSelected,
            label: Text(label),
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.onSurface,
            ),
            backgroundColor: AppColors.surfaceContainerLowest,
            selectedColor: AppColors.secondary,
            showCheckmark: false,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onSelected: (_) => setState(() => _selectedFilter = label),
          );
        },
      ),
    );
  }

  // Page 0: STIs
  Widget _buildStiList(bool isAmharic) {
    final filtered = _stiItems.where((item) {
      final name = isAmharic ? item['name_am'] : item['name_en'];
      final sub = isAmharic ? item['sub_am'] : item['sub_en'];
      final matchesSearch = name.toString().toLowerCase().contains(_searchQuery) ||
          sub.toString().toLowerCase().contains(_searchQuery);
      if (!matchesSearch) return false;

      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Bacterial' || _selectedFilter == 'ባክቴሪያል') {
        return item['type_en'] == 'Bacterial';
      }
      if (_selectedFilter == 'Viral' || _selectedFilter == 'ቫይራል') {
        return item['type_en'] == 'Viral';
      }
      if (_selectedFilter == 'Curable' || _selectedFilter == 'የሚድኑ') {
        return item['curable'] == true;
      }
      if (_selectedFilter == 'Free Testing' || _selectedFilter == 'ነፃ ምርመራ') {
        return item['freeEth'] == true;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState(isAmharic);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final name = isAmharic ? item['name_am'] : item['name_en'];
        final sub = isAmharic ? item['sub_am'] : item['sub_en'];
        final type = isAmharic ? item['type_am'] : item['type_en'];
        final tag = isAmharic ? item['tag_am'] : item['tag_en'];
        final transmission =
            isAmharic ? item['transmission_am'] : item['transmission_en'];
        final prevention =
            isAmharic ? item['prevention_am'] : item['prevention_en'];
        final access = isAmharic ? item['access_am'] : item['access_en'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: StaggeredEntrance(
            index: (index + 3).clamp(0, 8),
            child: TactileCard(
              onTap: () {
                _showDetailSheet(
                  context,
                  title: name,
                  subtitle: sub,
                  category: type,
                  isAmharic: isAmharic,
                  sections: [
                    {'heading': isAmharic ? 'የህክምና ሁኔታ' : 'Clinical Status', 'body': tag},
                    {'heading': isAmharic ? 'እንዴት ይተላለፋል?' : 'Transmission Mode', 'body': transmission},
                    {'heading': isAmharic ? 'መከላከያ ዘዴዎች' : 'Prevention & Safe Practice', 'body': prevention},
                    {'heading': isAmharic ? 'በኢትዮጵያ የት ይመረመራል?' : 'Testing & Care in Ethiopia', 'body': access},
                  ],
                );
              },
              borderRadius: BorderRadius.circular(16),
              color: AppColors.surfaceContainerLowest,
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              sub,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 16, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${isAmharic ? 'እንዴት ይተላለፋል? ' : 'Transmission: '}$transmission',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurface,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isAmharic ? 'መከላከያ፡ ' : 'Prevention: '}$prevention',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.local_hospital,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${isAmharic ? 'በኢትዮጵያ የት ይመረመራል? ' : 'Testing in Ethiopia: '}$access',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Page 1: Contraception
  Widget _buildContraList(bool isAmharic) {
    final filtered = _contraItems.where((item) {
      final name = isAmharic ? item['name_am'] : item['name_en'];
      final details = isAmharic ? item['details_am'] : item['details_en'];
      final matchesSearch =
          name.toString().toLowerCase().contains(_searchQuery) ||
              details.toString().toLowerCase().contains(_searchQuery);
      if (!matchesSearch) return false;

      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Barrier' || _selectedFilter == 'ኮንዶም') {
        return item['category_en'] == 'Barrier';
      }
      if (_selectedFilter == 'LARC' || _selectedFilter == 'ረጅም ጊዜ') {
        return item['category_en'] == 'LARC';
      }
      if (_selectedFilter == 'Emergency' || _selectedFilter == 'ድንገተኛ') {
        return item['category_en'] == 'Emergency';
      }
      if (_selectedFilter == 'Short-term' || _selectedFilter == 'አጭር ጊዜ') {
        return item['category_en'] == 'Short-term';
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState(isAmharic);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final name = isAmharic ? item['name_am'] : item['name_en'];
        final sub = isAmharic ? item['sub_am'] : item['sub_en'];
        final effectiveness =
            isAmharic ? item['effectiveness_am'] : item['effectiveness_en'];
        final details = isAmharic ? item['details_am'] : item['details_en'];
        final access = isAmharic ? item['access_am'] : item['access_en'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: StaggeredEntrance(
            index: (index + 3).clamp(0, 8),
            child: TactileCard(
              onTap: () {
                _showDetailSheet(
                  context,
                  title: name,
                  subtitle: sub,
                  category: effectiveness,
                  isAmharic: isAmharic,
                  sections: [
                    {'heading': isAmharic ? 'ውጤታማነት' : 'Effectiveness Rate', 'body': effectiveness},
                    {'heading': isAmharic ? 'ዝርዝር መረጃ' : 'Method Description', 'body': details},
                    {'heading': isAmharic ? 'በኢትዮጵያ የት ይገኛል?' : 'Availability in Ethiopia', 'body': access},
                  ],
                );
              },
              borderRadius: BorderRadius.circular(16),
              color: AppColors.surfaceContainerLowest,
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              sub,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          effectiveness,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    details,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${isAmharic ? 'የት ይገኛል? ' : 'Where to access: '}$access',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Page 2: Menstrual Health
  Widget _buildMenstrualList(bool isAmharic) {
    final filtered = _menstrualItems.where((item) {
      final name = isAmharic ? item['name_am'] : item['name_en'];
      final details = isAmharic ? item['details_am'] : item['details_en'];
      final matchesSearch =
          name.toString().toLowerCase().contains(_searchQuery) ||
              details.toString().toLowerCase().contains(_searchQuery);
      if (!matchesSearch) return false;

      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Symptoms' || _selectedFilter == 'ምልክቶች') {
        return item['category_en'] == 'Symptoms';
      }
      if (_selectedFilter == 'Hormonal' || _selectedFilter == 'ሆርሞናል') {
        return item['category_en'] == 'Hormonal';
      }
      if (_selectedFilter == 'Hygiene' || _selectedFilter == 'ንፅህና') {
        return item['category_en'] == 'Hygiene';
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState(isAmharic);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final name = isAmharic ? item['name_am'] : item['name_en'];
        final sub = isAmharic ? item['sub_am'] : item['sub_en'];
        final tag = isAmharic ? item['tag_am'] : item['tag_en'];
        final details = isAmharic ? item['details_am'] : item['details_en'];
        final action = isAmharic ? item['action_am'] : item['action_en'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: StaggeredEntrance(
            index: (index + 3).clamp(0, 8),
            child: TactileCard(
              onTap: () {
                _showDetailSheet(
                  context,
                  title: name,
                  subtitle: sub,
                  category: tag,
                  isAmharic: isAmharic,
                  sections: [
                    {'heading': isAmharic ? 'የስነ-ህይወት ምድብ' : 'Cycle Category', 'body': tag},
                    {'heading': isAmharic ? 'ዝርዝር ማብራሪያ' : 'Explanation', 'body': details},
                    {'heading': isAmharic ? 'የሚመከሩ እርምጃዎች' : 'Recommended Care', 'body': action},
                  ],
                );
              },
              borderRadius: BorderRadius.circular(16),
              color: AppColors.surfaceContainerLowest,
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              sub,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    details,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.tips_and_updates_outlined,
                            size: 16, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${isAmharic ? 'የእርምጃ ምክር፡ ' : 'Self-Care Action: '}$action',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Page 3: Sexual Health & Relationships
  Widget _buildSexualHealthList(bool isAmharic) {
    final filtered = _sexualHealthItems.where((item) {
      final name = isAmharic ? item['name_am'] : item['name_en'];
      final details = isAmharic ? item['details_am'] : item['details_en'];
      final matchesSearch =
          name.toString().toLowerCase().contains(_searchQuery) ||
              details.toString().toLowerCase().contains(_searchQuery);
      if (!matchesSearch) return false;

      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Relationships' || _selectedFilter == 'ግንኙነት') {
        return item['category_en'] == 'Relationships';
      }
      if (_selectedFilter == 'Myths' || _selectedFilter == 'እውነታዎች') {
        return item['category_en'] == 'Myths';
      }
      if (_selectedFilter == 'Wellbeing' || _selectedFilter == 'ስነ-ልቦና') {
        return item['category_en'] == 'Wellbeing';
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState(isAmharic);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final name = isAmharic ? item['name_am'] : item['name_en'];
        final sub = isAmharic ? item['sub_am'] : item['sub_en'];
        final tag = isAmharic ? item['tag_am'] : item['tag_en'];
        final details = isAmharic ? item['details_am'] : item['details_en'];
        final action = isAmharic ? item['action_am'] : item['action_en'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: StaggeredEntrance(
            index: (index + 3).clamp(0, 8),
            child: TactileCard(
              onTap: () {
                _showDetailSheet(
                  context,
                  title: name,
                  subtitle: sub,
                  category: tag,
                  isAmharic: isAmharic,
                  sections: [
                    {'heading': isAmharic ? 'ምድብ' : 'Category', 'body': tag},
                    {'heading': isAmharic ? 'ማብራሪያ' : 'Core Guidance', 'body': details},
                    {'heading': isAmharic ? 'ምክርና ድጋፍ' : 'Advice & Support', 'body': action},
                  ],
                );
              },
              borderRadius: BorderRadius.circular(16),
              color: AppColors.surfaceContainerLowest,
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              sub,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    details,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.favorite_outline,
                            size: 16, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${isAmharic ? 'የእውቀት ነጥብ፡ ' : 'Key Takeaway: '}$action',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isAmharic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          isAmharic
              ? 'ምንም መረጃ አልተገኘም።'
              : 'No matching entries found.',
          style: const TextStyle(color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}
