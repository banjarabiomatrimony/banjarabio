/// Location master data for BanjaraBio app
/// Contains State -> District -> Taluka hierarchical data
/// Initially focused on Maharashtra with key districts
library;
import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/data/location_translations.dart';

class LocationData {
  /// List of all available states
  static const List<String> states = [
    'Maharashtra',
    'Karnataka',
    'Andhra Pradesh',
    'Telangana',
    'Madhya Pradesh',
    'Gujarat',
    'Rajasthan',
  ];

  /// Districts mapped by state
  static const Map<String, List<String>> districts = {
    'Maharashtra': [
      'Ahmednagar',
      'Akola',
      'Amravati',
      'Aurangabad',
      'Beed',
      'Bhandara',
      'Buldhana',
      'Chandrapur',
      'Dhule',
      'Gadchiroli',
      'Gondia',
      'Hingoli',
      'Jalgaon',
      'Jalna',
      'Kolhapur',
      'Latur',
      'Mumbai City',
      'Mumbai Suburban',
      'Nagpur',
      'Nanded',
      'Nandurbar',
      'Nashik',
      'Osmanabad',
      'Palghar',
      'Parbhani',
      'Pune',
      'Raigad',
      'Ratnagiri',
      'Sangli',
      'Satara',
      'Sindhudurg',
      'Solapur',
      'Thane',
      'Wardha',
      'Washim',
      'Yavatmal',
    ],
    'Karnataka': [
      'Bagalkot',
      'Ballari',
      'Belagavi',
      'Bengaluru Rural',
      'Bengaluru Urban',
      'Bidar',
      'Chamarajanagar',
      'Chikkaballapur',
      'Chikkamagaluru',
      'Chitradurga',
      'Dakshina Kannada',
      'Davanagere',
      'Dharwad',
      'Gadag',
      'Hassan',
      'Haveri',
      'Kalaburagi',
      'Kodagu',
      'Kolar',
      'Koppal',
      'Mandya',
      'Mysuru',
      'Raichur',
      'Ramanagara',
      'Shivamogga',
      'Tumakuru',
      'Udupi',
      'Uttara Kannada',
      'Vijayapura',
      'Yadgir',
    ],
    'Andhra Pradesh': [
      'Anantapur',
      'Chittoor',
      'East Godavari',
      'Guntur',
      'Krishna',
      'Kurnool',
      'Nellore',
      'Prakasam',
      'Srikakulam',
      'Visakhapatnam',
      'Vizianagaram',
      'West Godavari',
      'YSR Kadapa',
    ],
    'Telangana': [
      'Adilabad',
      'Hyderabad',
      'Karimnagar',
      'Khammam',
      'Mahbubnagar',
      'Medak',
      'Nalgonda',
      'Nizamabad',
      'Rangareddy',
      'Warangal',
    ],
    'Madhya Pradesh': [
      'Bhopal',
      'Indore',
      'Jabalpur',
      'Gwalior',
      'Ujjain',
      'Sagar',
      'Dewas',
      'Satna',
      'Ratlam',
      'Rewa',
      'Chhindwara',
      'Burhanpur',
      'Khandwa',
      'Bhind',
      'Morena',
      'Shivpuri',
      'Vidisha',
      'Damoh',
      'Hoshangabad',
    ],
    'Gujarat': [
      'Ahmedabad',
      'Amreli',
      'Anand',
      'Aravalli',
      'Banaskantha',
      'Bharuch',
      'Bhavnagar',
      'Botad',
      'Chhota Udaipur',
      'Dahod',
      'Gandhinagar',
      'Gir Somnath',
      'Jamnagar',
      'Junagadh',
      'Kheda',
      'Kutch',
      'Mahisagar',
      'Mehsana',
      'Morbi',
      'Narmada',
      'Navsari',
      'Panchmahal',
      'Patan',
      'Porbandar',
      'Rajkot',
      'Sabarkantha',
      'Surat',
      'Surendranagar',
      'Tapi',
      'Vadodara',
      'Valsad',
    ],
    'Rajasthan': [
      'Ajmer',
      'Alwar',
      'Banswara',
      'Baran',
      'Barmer',
      'Bharatpur',
      'Bhilwara',
      'Bikaner',
      'Bundi',
      'Chittorgarh',
      'Churu',
      'Dausa',
      'Dholpur',
      'Dungarpur',
      'Hanumangarh',
      'Jaipur',
      'Jaisalmer',
      'Jalore',
      'Jhalawar',
      'Jhunjhunu',
      'Jodhpur',
      'Karauli',
      'Kota',
      'Nagaur',
      'Pali',
      'Pratapgarh',
      'Rajsamand',
      'Sawai Madhopur',
      'Sikar',
      'Sirohi',
      'Sri Ganganagar',
      'Tonk',
      'Udaipur',
    ],
  };

  /// Talukas mapped by district
  /// Contains key talukas for major districts
  static const Map<String, List<String>> talukas = {
    // Maharashtra - Ahmednagar
    'Ahmednagar': [
      'Ahmednagar', 'Akole', 'Jamkhed', 'Karjat', 'Kopargaon', 'Nagar', 'Nevasa', 
      'Parner', 'Pathardi', 'Rahata', 'Rahuri', 'Sangamner', 'Shevgaon', 'Shrigonda', 'Shrirampur'
    ],
    // Karnataka - Bengaluru Urban
    'Bengaluru Urban': [
      'Bengaluru North', 'Bengaluru South', 'Bengaluru East', 'Anekal', 'Yelahanka'
    ],
    // Andhra Pradesh - Visakhapatnam
    'Visakhapatnam': [
      'Visakhapatnam Rural', 'Gajuwaka', 'Anandapuram', 'Padmanabham', 'Bheemunipatnam'
    ],
    // Madhya Pradesh - Bhopal
    'Bhopal': [
      'Bhopal City', 'Huzur', 'Berasia'
    ],
    // Maharashtra - Aurangabad
    'Aurangabad': [
      'Aurangabad',
      'Gangapur',
      'Kannad',
      'Khuldabad',
      'Paithan',
      'Phulambri',
      'Sillod',
      'Soegaon',
      'Vaijapur',
    ],
    // Maharashtra - Beed
    'Beed': [
      'Ambejogai',
      'Ashti',
      'Beed',
      'Dharur',
      'Georai',
      'Kaij',
      'Manjlegaon',
      'Parli',
      'Patoda',
      'Shirur Kasar',
      'Wadwani',
    ],
    // Maharashtra - Jalgaon
    'Jalgaon': [
      'Amalner',
      'Bhadgaon',
      'Bhusawal',
      'Bodwad',
      'Chalisgaon',
      'Chopda',
      'Dharangaon',
      'Erandol',
      'Jalgaon',
      'Jamner',
      'Muktainagar',
      'Pachora',
      'Parola',
      'Raver',
      'Yawal',
    ],
    // Maharashtra - Latur
    'Latur': [
      'Ahmadpur',
      'Ausa',
      'Chakur',
      'Deoni',
      'Jalkot',
      'Latur',
      'Nilanga',
      'Renapur',
      'Shirur Anantpal',
      'Udgir',
    ],
    // Maharashtra - Nanded
    'Nanded': [
      'Ardhapur',
      'Bhokar',
      'Biloli',
      'Deglur',
      'Dharmabad',
      'Hadgaon',
      'Himayatnagar',
      'Kandhar',
      'Kinwat',
      'Loha',
      'Mahur',
      'Mudkhed',
      'Mukhed',
      'Naigaon',
      'Nanded',
      'Umri',
    ],
    // Maharashtra - Nashik
    'Nashik': [
      'Baglan',
      'Chandwad',
      'Deola',
      'Dindori',
      'Igatpuri',
      'Kalwan',
      'Malegaon',
      'Nandgaon',
      'Nashik',
      'Niphad',
      'Peint',
      'Sinnar',
      'Surgana',
      'Trimbakeshwar',
      'Yeola',
    ],
    // Maharashtra - Osmanabad
    'Osmanabad': [
      'Bhum',
      'Kalamb',
      'Lohara',
      'Osmanabad',
      'Paranda',
      'Tuljapur',
      'Umarga',
      'Washi',
    ],
    // Maharashtra - Parbhani
    'Parbhani': [
      'Gangakhed',
      'Jintur',
      'Manwath',
      'Palam',
      'Parbhani',
      'Pathri',
      'Purna',
      'Sailu',
      'Sonpeth',
    ],
    // Maharashtra - Pune
    'Pune': [
      'Ambegaon',
      'Baramati',
      'Bhor',
      'Daund',
      'Haveli',
      'Indapur',
      'Junnar',
      'Khed',
      'Maval',
      'Mulshi',
      'Pune City',
      'Purandar',
      'Shirur',
      'Velhe',
    ],
    // Maharashtra - Solapur
    'Solapur': [
      'Akkalkot',
      'Barshi',
      'Karmala',
      'Madha',
      'Malshiras',
      'Mangalvedhe',
      'Mohol',
      'North Solapur',
      'Pandharpur',
      'Sangola',
      'South Solapur',
    ],
    // Maharashtra - Kolhapur
    'Kolhapur': [
      'Ajra',
      'Bavda',
      'Bhudargad',
      'Chandgad',
      'Gadhinglaj',
      'Hatkanangle',
      'Kagal',
      'Karvir',
      'Panhala',
      'Radhanagari',
      'Shahuwadi',
      'Shirol',
    ],
    // Maharashtra - Satara
    'Satara': [
      'Jaoli',
      'Karad',
      'Khandala',
      'Khatav',
      'Koregaon',
      'Mahabaleshwar',
      'Man',
      'Patan',
      'Phaltan',
      'Satara',
      'Wai',
    ],
    // Maharashtra - Sangli
    'Sangli': [
      'Atpadi',
      'Jat',
      'Kadegaon',
      'Kavathemahankal',
      'Khanapur',
      'Miraj',
      'Palus',
      'Shirala',
      'Tasgaon',
      'Walwa',
    ],
    // Maharashtra - Nagpur
    'Nagpur': [
      'Bhiwapur',
      'Hingna',
      'Kamptee',
      'Katol',
      'Kuhi',
      'Mauda',
      'Nagpur Rural',
      'Nagpur Urban',
      'Narkhed',
      'Parseoni',
      'Ramtek',
      'Savner',
      'Umred',
    ],
    // Maharashtra - Amravati
    'Amravati': [
      'Achalpur',
      'Amravati',
      'Anjangaon Surji',
      'Bhatkuli',
      'Chandurbazar',
      'Chandur Railway',
      'Chikhaldara',
      'Daryapur',
      'Dharni',
      'Dhamangaon Railway',
      'Morshi',
      'Nandgaon Khandeshwar',
      'Teosa',
      'Warud',
    ],
    // Maharashtra - Yavatmal
    'Yavatmal': [
      'Arni',
      'Babulgaon',
      'Darwha',
      'Digras',
      'Ghatanji',
      'Kalamb',
      'Kelapur',
      'Mahagaon',
      'Maregaon',
      'Ner',
      'Pusad',
      'Ralegaon',
      'Umarkhed',
      'Wani',
      'Yavatmal',
      'Zari Jamni',
    ],
    // Maharashtra - Buldhana
    'Buldhana': [
      'Buldana',
      'Chikhli',
      'Deulgaon Raja',
      'Jalgaon Jamod',
      'Khamgaon',
      'Lonar',
      'Malkapur',
      'Mehkar',
      'Motala',
      'Nandura',
      'Sangrampur',
      'Shegaon',
      'Sindkhed Raja',
    ],
    // Maharashtra - Akola
    'Akola': [
      'Akola',
      'Akot',
      'Balapur',
      'Barshitakli',
      'Murtijapur',
      'Patur',
      'Telhara',
    ],
    // Maharashtra - Washim
    'Washim': [
      'Karanja',
      'Malegaon',
      'Mangrulpir',
      'Manora',
      'Risod',
      'Washim',
    ],
    // Maharashtra - Hingoli
    'Hingoli': ['Aundha Nagnath', 'Basmath', 'Hingoli', 'Kalamnuri', 'Sengaon'],
    // Maharashtra - Jalna
    'Jalna': [
      'Ambad',
      'Badnapur',
      'Bhokardan',
      'Ghansawangi',
      'Jafrabad',
      'Jalna',
      'Mantha',
      'Partur',
    ],
    // Karnataka - Belagavi
    'Belagavi': [
      'Athani',
      'Bailhongal',
      'Belagavi',
      'Chikodi',
      'Gokak',
      'Hukkeri',
      'Khanapur',
      'Raibag',
      'Ramdurg',
      'Saundatti',
    ],
    // Karnataka - Kalaburagi
    'Kalaburagi': [
      'Afzalpur',
      'Aland',
      'Chincholi',
      'Chittapur',
      'Gulbarga',
      'Jevargi',
      'Sedam',
    ],
    // Karnataka - Bidar
    'Bidar': ['Aurad', 'Basavakalyan', 'Bhalki', 'Bidar', 'Humnabad'],
    // Karnataka - Vijayapura
    'Vijayapura': [
      'Bagewadi',
      'Basavana Bagewadi',
      'Bijapur',
      'Indi',
      'Muddebihal',
      'Sindgi',
    ],
    // Generic fallback for other districts
    'Mumbai City': ['Mumbai City'],
    'Mumbai Suburban': ['Andheri', 'Bandra', 'Borivali', 'Kurla', 'Mulund'],
    'Thane': [
      'Bhiwandi',
      'Kalyan',
      'Murbad',
      'Shahapur',
      'Thane',
      'Ulhasnagar',
    ],
    'Palghar': [
      'Dahanu',
      'Jawhar',
      'Palghar',
      'Talasari',
      'Vasai',
      'Vikramgad',
      'Wada',
    ],
    'Raigad': [
      'Alibag',
      'Karjat',
      'Khalapur',
      'Mahad',
      'Mangaon',
      'Murud',
      'Panvel',
      'Pen',
      'Poladpur',
      'Roha',
      'Shrivardhan',
      'Sudhagad',
      'Tala',
      'Uran',
    ],
    // Telangana
    'Hyderabad': [
      'Ameerpet', 'Khairatabad', 'Musheerabad', 'Amberpet', 'Himayatnagar', 'Golconda', 'Charminar'
    ],
    'Rangareddy': [
      'Gachibowli', 'Kukatpally', 'Serilingampally', 'Rajendranagar', 'Saroornagar', 'Uppal',
      'Chevella', 'Ibrahimpatnam', 'Maheshwaram', 'Malkajgiri', 'Medchal', 'Shamshabad', 'Vikarabad'
    ],
    // Gujarat
    'Ahmedabad': [
      'Ahmedabad City', 'Bavla', 'Daskroi', 'Detroj-Rampura', 'Dhandhuka', 'Dholka', 'Mandal', 'Sanand', 'Viramgam'
    ],
    'Surat': [
      'Bardoli',
      'Chorasi',
      'Kamrej',
      'Mahuva',
      'Mandvi',
      'Mangrol',
      'Olpad',
      'Palsana',
      'Surat City',
      'Umarpada',
    ],
    'Vadodara': [
      'Dabhoi',
      'Karjan',
      'Padra',
      'Savli',
      'Shinor',
      'Vadodara City',
      'Vaghodia',
    ],
    // Rajasthan
    'Jaipur': [
      'Jaipur City', 'Sanganer', 'Amer', 'Bassi', 'Chaksu', 'Chomu', 'Dudu', 'Phagi', 'Jamwa Ramgarh', 'Kotputli', 'Shahpura', 'Viratnagar'
    ],
    'Jodhpur': [
      'Balesar',
      'Bilara',
      'Bhopalgarh',
      'Jodhpur',
      'Luni',
      'Mandor',
      'Osian',
      'Phalodi',
      'Shergarh',
    ],
    'Udaipur': [
      'Bhinder',
      'Girwa',
      'Gogunda',
      'Jhadol',
      'Kherwara',
      'Kotra',
      'Lasadiya',
      'Mavli',
      'Rishabhdev',
      'Salumber',
      'Sarada',
      'Udaipur',
      'Vallabhnagar',
    ],
  };

  /// Get districts for a given state
  static List<String> getDistricts(String state) {
    return districts[state] ?? [];
  }

  /// Get talukas for a given district
  static List<String> getTalukas(String district) {
    return talukas[district] ?? [];
  }

  /// Format location for display: "Taluka, District, State"
  static String formatLocation({
    String? taluka,
    String? district,
    String? state,
    String? village,
  }) {
    final parts = <String>[];
    if (village != null && village.isNotEmpty) parts.add(village);
    if (taluka != null && taluka.isNotEmpty) parts.add(taluka);
    if (district != null && district.isNotEmpty) parts.add(district);
    if (state != null && state.isNotEmpty) parts.add(state);
    return parts.join(', ');
  }

  /// Get localized name for a location (State, District, or Taluka)
  static String getLocalizedName(String? name, BuildContext context) {
    if (name == null || name.isEmpty) return '';
    if (name == 'All India') return AppLocalizations.of(context)?.allIndia ?? 'All India';
    final locale = Localizations.localeOf(context).languageCode;
    return LocationTranslations.get(name, locale);
  }

  /// Get localized full location (e.g. "Taluka, District")
  static String getLocalizedFullLocation(String? location, BuildContext context) {
    if (location == null || location.isEmpty) return '';
    if (location.contains(', ')) {
      final parts = location.split(', ');
      final localizedParts = parts.map((p) => getLocalizedName(p, context)).toList();
      return localizedParts.join(', ');
    }
    return getLocalizedName(location, context);
  }
}
