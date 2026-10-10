import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// STI & Contraceptive Library screen.
/// Offers bilingual, evidence-backed education cards with live search and category filtering.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedTab = 0; // 0 = STIs, 1 = Contraceptives
  String _searchQuery = '';
  String _selectedFilter = 'All';

  // Sample medical dataset for STIs
  final List<Map<String, dynamic>> _stiItems = [
    {
      'name': 'HIV (ኤች.አይ.ቪ)',
      'type': 'Viral',
      'sub': 'Human Immunodeficiency Virus',
      'tag': 'ተቆጣጣሪ ህክምና አለ (ART Available)',
      'curable': false,
      'freeEth': true,
      'transmission': 'ጥንቃቄ የጎደለው ግንኙነት፣ ከተበከለ ደም ወይም ስለታማ እቃዎች፣ እና ከእናት ወደ ልጅ።',
      'prevention': 'ኮንዶም መጠቀም፣ PrEP (ከግንኙነት በፊት)፣ እና PEP (በ72 ሰዓት ውስጥ)።',
      'access': 'በማንኛውም የወረዳ ጤና ጣቢያ፣ ማሪ ስቶፕስ (Marie Stopes)፣ እና FGAE ነፃ የፈጣን ምርመራ ይሰጣል።',
    },
    {
      'name': 'Syphilis (ቂጥኝ)',
      'type': 'Bacterial',
      'sub': 'Treponema pallidum infection',
      'tag': 'ሙሉ በሙሉ ይድናል (100% Curable)',
      'curable': true,
      'freeEth': true,
      'transmission': 'በቀጥታ ቁስል ንክኪ ወይም ጥንቃቄ የጎደለው ግንኙነት።',
      'prevention': 'ኮንዶም አዘውትሮ መጠቀም፣ ቅድመ-ምርመራ ማድረግ።',
      'access': 'በፔኒሲሊን (Penicillin) መርፌ በቀላሉ ይድናል። በሁሉም የመንግስት ጤና ጣቢያዎች ምርመራ አለ።',
    },
    {
      'name': 'Gonorrhea (ጨብጥ)',
      'type': 'Bacterial',
      'sub': 'Neisseria gonorrhoeae',
      'tag': 'ሙሉ በሙሉ ይድናል (Curable with Antibiotics)',
      'curable': true,
      'freeEth': false,
      'transmission': 'ጥንቃቄ በጎደለው ግንኙነት የሚተላለፍ የባክቴሪያ ኢንፌክሽን።',
      'prevention': 'ኮንዶም መጠቀም እና ምልክት ሲታይ ወዲያውኑ መታከም።',
      'access': 'በአንቲባዮቲክስ ይታከማል። ሁለቱም አጋሮች እኩል መታከም አለባቸው።',
    },
    {
      'name': 'HPV (የማህፀን በር ካንሰር አምጪ ቫይረስ)',
      'type': 'Viral',
      'sub': 'Human Papillomavirus',
      'tag': 'ክትባት አለው (Vaccine Available)',
      'curable': false,
      'freeEth': true,
      'transmission': 'በቆዳ ንክኪ እና በግብረ-ስጋ ግንኙነት ይተላለፋል።',
      'prevention': 'የHPV ክትባት መውሰድ (ለታዳጊዎች በነፃ ይሰጣል) እና መደበኛ የማህፀን በር ምርመራ (Pap smear)።',
      'access': 'በጤና ጣቢያዎችና በትምህርት ቤቶች ለልጃገረዶች ነፃ ክትባት ይሰጣል።',
    },
  ];

  // Sample dataset for Contraceptive methods
  final List<Map<String, dynamic>> _contraItems = [
    {
      'name': 'Male & Female Condoms (ኮንዶም)',
      'category': 'Barrier',
      'sub': 'ድርብ ጥበቃ (Dual Protection)',
      'tag': 'STIs + እርግዝናን ይከላከላል',
      'effectiveness': '98% ትክክለኛ አጠቃቀም',
      'duration': 'ለአንድ ጊዜ ብቻ',
      'details': 'ብቸኛው የአባለዘር በሽታዎችን እና ያልተፈለገ እርግዝናን በአንድ ጊዜ የሚከላከል ዘዴ ነው።',
      'access': 'በሁሉም ጤና ጣቢያዎች፣ ማህበራዊ ድርጅቶችና ፋርማሲዎች በነፃ ወይም በዝቅተኛ ዋጋ ይገኛል።',
    },
    {
      'name': 'Implanon / Jadelle (የክንድ ውስጥ እንክብል)',
      'category': 'LARC',
      'sub': 'ረጅም ጊዜ የሚቆይ (Long-acting)',
      'tag': '>99% አስተማማኝ',
      'effectiveness': '>99%',
      'duration': 'ከ3 እስከ 5 ዓመታት',
      'details': 'በክንድ ቆዳ ስር የሚቀበር ትንሽ ፕላስቲክ። የወር አበባ መጠን ሊቀንስ ይችላል። ሲወጣ የመውለድ ችሎታ ወዲያውኑ ይመለሳል።',
      'access': 'በመንግስት ጤና ጣቢያዎች እና በማሪ ስቶፕስ ክሊኒኮች በነፃ ይሰጣል።',
    },
    {
      'name': 'Emergency Pill / Postinor (ድንገተኛ መከላከያ)',
      'category': 'Emergency',
      'sub': 'በ72 ሰዓታት ውስጥ (Within 72 Hours)',
      'tag': 'ለድንገተኛ ጊዜ ብቻ',
      'effectiveness': 'እስከ 95% (በፍጥነት ከተወሰደ)',
      'duration': 'ድንገተኛ ነጠላ መጠን',
      'details': 'ኮንዶም ሲቀደድ ወይም ጥንቃቄ የጎደለው ግንኙነት ሲያጋጥም በ72 ሰዓታት ውስጥ የሚወሰድ። መደበኛ መከላከያ አይደለም።',
      'access': 'በማንኛውም ፋርማሲ ያለ ሀኪም ማዘዣ በነፃነት ይገኛል።',
    },
    {
      'name': 'Depo-Provera (የ3 ወር መርፌ)',
      'category': 'Short-term',
      'sub': 'በየ3 ወሩ የሚደገም',
      'tag': '96% አስተማማኝ',
      'effectiveness': '96%',
      'duration': '3 ወራት',
      'details': 'በየ3 ወሩ በጡንቻ ውስጥ የሚሰጥ መርፌ። ሚስጥራዊ እና ለአጠቃቀም ምቹ ነው።',
      'access': 'በሁሉም የጤና ጣቢያዎች እና ክሊኒኮች በቀላሉ ይገኛል።',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'STI & Contraception Library',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter header section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: AppColors.surface,
            child: Column(
              children: [
                // Search Input
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'በሽታዎችን ወይም የወሊድ መከላከያ ይፈልጉ...',
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                              color: _selectedTab == 0 ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 16,
                                  color: _selectedTab == 0 ? Colors.white : AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'የአባለዘር በሽታዎች (STIs)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedTab == 0 ? Colors.white : AppColors.onSurfaceVariant,
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
                              color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medication_outlined,
                                  size: 16,
                                  color: _selectedTab == 1 ? Colors.white : AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'የወሊድ መከላከያ (Methods)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedTab == 1 ? Colors.white : AppColors.onSurfaceVariant,
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
                _buildFilterChips(),
              ],
            ),
          ),

          // Scrollable List of Information Cards
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: _selectedTab == 0 ? _buildStiList() : _buildContraList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final chips = _selectedTab == 0
        ? ['All', 'Bacterial', 'Viral', 'Curable', 'Free in Ethiopia']
        : ['All', 'Barrier', 'LARC', 'Emergency', 'Short-term'];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = chips[index];
          final isSelected = _selectedFilter == label;
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

  List<Widget> _buildStiList() {
    final filtered = _stiItems.where((item) {
      final matchesSearch = item['name'].toString().toLowerCase().contains(_searchQuery) ||
          item['sub'].toString().toLowerCase().contains(_searchQuery);
      if (!matchesSearch) return false;

      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Bacterial') return item['type'] == 'Bacterial';
      if (_selectedFilter == 'Viral') return item['type'] == 'Viral';
      if (_selectedFilter == 'Curable') return item['curable'] == true;
      if (_selectedFilter == 'Free in Ethiopia') return item['freeEth'] == true;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('ምንም መረጃ አልተገኘም (No matching entries found).'),
          ),
        ),
      ];
    }

    return filtered.map((item) {
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
                          item['name'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        Text(
                          item['sub'],
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
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
                      item['type'],
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer),
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
                    const Icon(Icons.check_circle_outline, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item['tag'],
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'እንዴት ይተላለፋል? ${item['transmission']}',
                style: const TextStyle(fontSize: 12, color: AppColors.onSurface, height: 1.3),
              ),
              const SizedBox(height: 4),
              Text(
                'መከላከያ፡ ${item['prevention']}',
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.3),
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
                    const Icon(Icons.local_hospital, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'በኢትዮጵያ የት ይመረመራል? ${item['access']}',
                        style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
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

  List<Widget> _buildContraList() {
    final filtered = _contraItems.where((item) {
      final matchesSearch = item['name'].toString().toLowerCase().contains(_searchQuery) ||
          item['details'].toString().toLowerCase().contains(_searchQuery);
      if (!matchesSearch) return false;

      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Barrier') return item['category'] == 'Barrier';
      if (_selectedFilter == 'LARC') return item['category'] == 'LARC';
      if (_selectedFilter == 'Emergency') return item['category'] == 'Emergency';
      if (_selectedFilter == 'Short-term') return item['category'] == 'Short-term';
      return true;
    }).toList();

    return filtered.map((item) {
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
                          item['name'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        Text(
                          item['sub'],
                          style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w500),
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
                      item['effectiveness'],
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item['details'],
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4),
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
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'የት ይገኛል? ${item['access']}',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurface, fontWeight: FontWeight.w500),
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
