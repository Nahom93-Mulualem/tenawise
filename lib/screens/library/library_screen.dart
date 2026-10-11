import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';

/// STI & Contraceptive Library screen.
/// 100% English when English is selected; 100% Amharic when Amharic is selected.
/// Responsive layout with live search and category filter chips.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedTab = 0; // 0 = STIs, 1 = Contraceptives
  String _searchQuery = '';
  String _selectedFilter = 'All';

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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppLanguage.isAmharicNotifier,
      builder: (context, isAmharic, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: Text(
              isAmharic ? 'የአባለዘር በሽታዎች እና የወሊድ መከላከያ' : 'STI & Contraception Library',
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
                // Search & Filter header section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      // Search Input
                      TextField(
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: isAmharic
                              ? 'በሽታዎችን ወይም የወሊድ መከላከያ ይፈልጉ...'
                              : 'Search conditions or contraceptives...',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.outline),
                          prefixIcon: const Icon(Icons.search, color: AppColors.outline, size: 20),
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
                      const SizedBox(height: 10),

                      // Category Switcher: STI vs Contraception
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() {
                                  _selectedTab = 0;
                                  _selectedFilter = 'All';
                                }),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 0
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shield_outlined,
                                        size: 16,
                                        color: _selectedTab == 0
                                            ? Colors.white
                                            : AppColors.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isAmharic ? 'የአባለዘር በሽታዎች' : 'STIs',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedTab == 0
                                              ? Colors.white
                                              : AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() {
                                  _selectedTab = 1;
                                  _selectedFilter = 'All';
                                }),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 1
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.medication_outlined,
                                        size: 16,
                                        color: _selectedTab == 1
                                            ? Colors.white
                                            : AppColors.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isAmharic ? 'የወሊድ መከላከያ' : 'Contraception',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedTab == 1
                                              ? Colors.white
                                              : AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Filter Chips
                      _buildFilterChips(isAmharic),
                    ],
                  ),
                ),

                // Scrollable List of Information Cards
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    children: _selectedTab == 0
                        ? _buildStiList(isAmharic)
                        : _buildContraList(isAmharic),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChips(bool isAmharic) {
    final chips = _selectedTab == 0
        ? (isAmharic
            ? ['All', 'ባክቴሪያል', 'ቫይራል', 'የሚድኑ', 'ነፃ ምርመራ']
            : ['All', 'Bacterial', 'Viral', 'Curable', 'Free Testing'])
        : (isAmharic
            ? ['All', 'ኮንዶም', 'ረጅም ጊዜ', 'ድንገተኛ', 'አጭር ጊዜ']
            : ['All', 'Barrier', 'LARC', 'Emergency', 'Short-term']);

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
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

  List<Widget> _buildStiList(bool isAmharic) {
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
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              isAmharic
                  ? 'ምንም መረጃ አልተገኘም።'
                  : 'No matching entries found.',
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
        ),
      ];
    }

    return filtered.map((item) {
      final name = isAmharic ? item['name_am'] : item['name_en'];
      final sub = isAmharic ? item['sub_am'] : item['sub_en'];
      final type = isAmharic ? item['type_am'] : item['type_en'];
      final tag = isAmharic ? item['tag_am'] : item['tag_en'];
      final transmission =
          isAmharic ? item['transmission_am'] : item['transmission_en'];
      final prevention =
          isAmharic ? item['prevention_am'] : item['prevention_en'];
      final access = isAmharic ? item['access_am'] : item['access_en'];

      return Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      );
    }).toList();
  }

  List<Widget> _buildContraList(bool isAmharic) {
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

    return filtered.map((item) {
      final name = isAmharic ? item['name_am'] : item['name_en'];
      final sub = isAmharic ? item['sub_am'] : item['sub_en'];
      final effectiveness =
          isAmharic ? item['effectiveness_am'] : item['effectiveness_en'];
      final details = isAmharic ? item['details_am'] : item['details_en'];
      final access = isAmharic ? item['access_am'] : item['access_en'];

      return Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      );
    }).toList();
  }
}
