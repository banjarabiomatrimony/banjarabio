import 'package:banjarabio/core/services/pdf/indic_transliterator.dart';

class BiodataTranslations {
  static const Map<String, Map<String, String>> translations = {
    // ═════════════════════════════════════════════════════════════════════════
    // 🇬🇧 ENGLISH
    // ═════════════════════════════════════════════════════════════════════════
    'English': {
      // Sections
      'personal_details': 'Personal Details',
      'education_profession': 'Education & Profession',
      'family_details': 'Family Details',
      'location_contact': 'Location & Contact',
      'partner_expectations': 'Partner Expectations',
      'about_me': 'About Me',
      'Personal Details': 'Personal Details',
      'Education & Profession': 'Education & Profession',
      'Family Details': 'Family Details',
      'Location & Contact': 'Location & Contact',
      'Partner Expectations': 'Partner Expectations',
      'About Me': 'About Me',
      'Candidate Profile Photo': 'CANDIDATE PROFILE PHOTO',
      'Profile Photograph': 'Profile Photograph',
      'biodata': 'BIODATA',
      'Biodata': 'BIODATA',

      // Field Keys
      'full_name': 'Full Name',
      'Full Name': 'Full Name',
      'surname': 'Surname',
      'Surname': 'Surname',
      'age': 'Age',
      'Age': 'Age',
      'height': 'Height',
      'Height': 'Height',
      'gender': 'Gender',
      'Gender': 'Gender',
      'dob': 'Date of Birth',
      'Date of Birth': 'Date of Birth',
      'birth_time': 'Birth Time',
      'Birth Time': 'Birth Time',
      'birth_place': 'Birth Place',
      'Birth Place': 'Birth Place',
      'marital_status': 'Marital Status',
      'Marital Status': 'Marital Status',
      'complexion': 'Complexion',
      'Complexion': 'Complexion',
      'blood_group': 'Blood Group',
      'Blood Group': 'Blood Group',
      'gotra': 'Gor Gotra',
      'Gotra': 'Gor Gotra',
      'Gor Gotra': 'Gor Gotra',
      'caste': 'Caste / Community',
      'Caste': 'Caste / Community',
      'religion': 'Religion',
      'Religion': 'Religion',
      'education': 'Education',
      'Education': 'Education',
      'edu_details': 'Edu. Details',
      'Edu. Details': 'Edu. Details',
      'occupation': 'Occupation',
      'Occupation': 'Occupation',
      'job_details': 'Job Details',
      'Job Details': 'Job Details',
      'annual_income': 'Annual Income',
      'Annual Income': 'Annual Income',
      'company': 'Company',
      'Company': 'Company',
      'father_name': 'Father Name',
      'Father Name': 'Father Name',
      'father_occup': 'Father Occup.',
      'Father Occup.': 'Father Occup.',
      'mother_name': 'Mother Name',
      'Mother Name': 'Mother Name',
      'mother_occup': 'Mother Occup.',
      'Mother Occup.': 'Mother Occup.',
      'family_type': 'Family Type',
      'Family Type': 'Family Type',
      'family_status': 'Family Status',
      'Family Status': 'Family Status',
      'total_siblings': 'Total Siblings',
      'Total Siblings': 'Total Siblings',
      'brothers': 'Brothers',
      'Brothers': 'Brothers',
      'sisters': 'Sisters',
      'Sisters': 'Sisters',
      'native_place': 'Native Place',
      'Native Place': 'Native Place',
      'current_location': 'Current Location',
      'Current Location': 'Current Location',
      'contact_no': 'Contact No.',
      'Contact No.': 'Contact No.',
      'Alt. Contact': 'Alt. Contact',

      // Field Values - Marital Status
      'Never Married': 'Never Married',
      'Unmarried': 'Unmarried',
      'Divorced': 'Divorced',
      'Widowed': 'Widowed',
      'Awaiting Divorce': 'Awaiting Divorce',
      'Separated': 'Separated',

      // Field Values - Gender
      'Male': 'Male',
      'Female': 'Female',

      // Field Values - Complexion
      'Fair': 'Fair',
      'Very Fair': 'Very Fair',
      'Wheatish': 'Wheatish',
      'Dark': 'Dark',

      // Field Values - Family Type & Status
      'Joint': 'Joint Family',
      'Joint Family': 'Joint Family',
      'Nuclear': 'Nuclear Family',
      'Nuclear Family': 'Nuclear Family',
      'Middle Class': 'Middle Class',
      'Upper Middle Class': 'Upper Middle Class',
      'Rich / Affluent': 'Rich / Affluent',
      'Rich': 'Rich / Affluent',
      'Affluent': 'Affluent',

      // Field Values - Occupations
      'Private Job': 'Private Job',
      'Private Sector': 'Private Sector',
      'Private Employee': 'Private Employee',
      'Government Job': 'Government Job',
      'Government Sector': 'Government Sector',
      'Government Employee': 'Government Employee',
      'Business': 'Business',
      'Self Employed': 'Self Employed',
      'Business / Self Employed': 'Business / Self-Employed',
      'Farmer': 'Farmer / Agriculture',
      'Agriculture': 'Farmer / Agriculture',
      'Farming': 'Farmer / Agriculture',
      'Software Engineer': 'Software Engineer',
      'Software Developer': 'Software Developer',
      'IT Professional': 'IT Professional',
      'Engineer': 'Engineer',
      'Civil Engineer': 'Civil Engineer',
      'Mechanical Engineer': 'Mechanical Engineer',
      'Electrical Engineer': 'Electrical Engineer',
      'Doctor': 'Doctor',
      'Medical Professional': 'Medical Professional',
      'Nurse / Nursing': 'Nurse / Nursing',
      'Teacher': 'Teacher',
      'Lecturer': 'Lecturer',
      'Professor': 'Professor',
      'Banker': 'Banker / Banking',
      'Bank Officer': 'Bank Officer',
      'Accountant': 'Accountant',
      'Police': 'Police Service',
      'Police Officer': 'Police Officer',
      'Army': 'Indian Army / Defence',
      'Defence': 'Defence Services',
      'Advocate': 'Advocate / Lawyer',
      'Lawyer': 'Advocate / Lawyer',
      'Homemaker': 'Homemaker',
      'Housewife': 'Housewife',
      'Retired': 'Retired',
      'Student': 'Student',
      'Not Working': 'Not Working',
      'Late': 'Late (Passed Away)',
      'None': 'None',

      // Field Values - Educations
      'Graduate': 'Graduate',
      'Post Graduate': 'Post Graduate',
      'Doctorate': 'Doctorate / Ph.D',
      'Diploma': 'Diploma',
      'Higher Secondary (12th)': '12th Pass',
      'Secondary (10th)': '10th Pass',
      '10th': '10th Pass',
      '12th': '12th Pass',
      'B.Tech': 'B.Tech / B.E',
      'B.E': 'B.E / B.Tech',
      'M.Tech': 'M.Tech / M.E',
      'M.E': 'M.E / M.Tech',
      'MBA': 'MBA',
      'MCA': 'MCA',
      'BCA': 'BCA',
      'B.Sc': 'B.Sc',
      'M.Sc': 'M.Sc',
      'B.Com': 'B.Com',
      'M.Com': 'M.Com',
      'B.A': 'B.A',
      'M.A': 'M.A',
      'MBBS': 'MBBS',
      'MD': 'MD / MS',
      'BAMS': 'BAMS',
      'BHMS': 'BHMS',
      'B.Ed': 'B.Ed',
      'D.Ed': 'D.Ed',
      'LLB': 'LLB',
      'LLM': 'LLM',
      'CA': 'Chartered Accountant (CA)',

      // Branding
      'Download App Line': '#1 Trusted Banjara Matrimony App • Find your life partner',
    },

    // ═════════════════════════════════════════════════════════════════════════
    // 🚩 MARATHI (मराठी)
    // ═════════════════════════════════════════════════════════════════════════
    'Marathi': {
      // Sections
      'personal_details': 'वैयक्तिक माहिती',
      'education_profession': 'शिक्षण आणि व्यवसाय',
      'family_details': 'कौटुंबिक माहिती',
      'location_contact': 'ठिकाण आणि संपर्क',
      'partner_expectations': 'अपेक्षा / पसंती',
      'about_me': 'माझ्याबद्दल',
      'Personal Details': 'वैयक्तिक माहिती',
      'Education & Profession': 'शिक्षण आणि व्यवसाय',
      'Family Details': 'कौटुंबिक माहिती',
      'Location & Contact': 'ठिकाण आणि संपर्क',
      'Partner Expectations': 'अपेक्षा / पसंती',
      'About Me': 'माझ्याबद्दल',
      'Candidate Profile Photo': 'उमेदवाराचे प्रोफाइल छायाचित्र',
      'Profile Photograph': 'उमेदवाराचे छायाचित्र',
      'biodata': 'बायोडाटा',
      'Biodata': 'बायोडाटा',

      // Field Keys
      'full_name': 'पूर्ण नाव',
      'Full Name': 'पूर्ण नाव',
      'surname': 'आडनाव',
      'Surname': 'आडनाव',
      'age': 'वय',
      'Age': 'वय',
      'height': 'उंची',
      'Height': 'उंची',
      'gender': 'लिंग',
      'Gender': 'लिंग',
      'dob': 'जन्म तारीख',
      'Date of Birth': 'जन्म तारीख',
      'birth_time': 'जन्म वेळ',
      'Birth Time': 'जन्म वेळ',
      'birth_place': 'जन्म ठिकाण',
      'Birth Place': 'जन्म ठिकाण',
      'marital_status': 'वैवाहिक स्थिती',
      'Marital Status': 'वैवाहिक स्थिती',
      'complexion': 'वर्ण / रंग',
      'Complexion': 'वर्ण / रंग',
      'blood_group': 'रक्त गट',
      'Blood Group': 'रक्त गट',
      'gotra': 'गोर गोत्र',
      'Gotra': 'गोर गोत्र',
      'Gor Gotra': 'गोर गोत्र',
      'caste': 'जात / समाज',
      'Caste': 'जात / समाज',
      'religion': 'धर्म',
      'Religion': 'धर्म',
      'education': 'शिक्षण',
      'Education': 'शिक्षण',
      'edu_details': 'शिक्षणाबद्दल अधिक माहिती',
      'Edu. Details': 'शिक्षणाचा तपशील',
      'occupation': 'व्यवसाय / नोकरी',
      'Occupation': 'व्यवसाय / नोकरी',
      'job_details': 'कामाचा तपशील',
      'Job Details': 'कामाचा तपशील',
      'annual_income': 'वार्षिक उत्पन्न',
      'Annual Income': 'वार्षिक उत्पन्न',
      'company': 'कंपनी / कार्यालय',
      'Company': 'कंपनी / कार्यालय',
      'father_name': 'वडिलांचे नाव',
      'Father Name': 'वडिलांचे नाव',
      'father_occup': 'वडिलांचा व्यवसाय',
      'Father Occup.': 'वडिलांचा व्यवसाय',
      'mother_name': 'आईचे नाव',
      'Mother Name': 'आईचे नाव',
      'mother_occup': 'आईचा व्यवसाय',
      'Mother Occup.': 'आईचा व्यवसाय',
      'family_type': 'कुटुंबाचा प्रकार',
      'Family Type': 'कुटुंबाचा प्रकार',
      'family_status': 'कौटुंबिक दर्जा',
      'Family Status': 'कौटुंबिक दर्जा',
      'total_siblings': 'एकूण भावंडे',
      'Total Siblings': 'एकूण भावंडे',
      'brothers': 'भाऊ',
      'Brothers': 'भाऊ',
      'sisters': 'बहिणी',
      'Sisters': 'बहिणी',
      'native_place': 'मूळ गाव / तांडा',
      'Native Place': 'मूळ गाव / तांडा',
      'current_location': 'सध्याचे ठिकाण',
      'Current Location': 'सध्याचे ठिकाण',
      'contact_no': 'संपर्क क्रमांक',
      'Contact No.': 'संपर्क क्रमांक',
      'Alt. Contact': 'पर्यायी संपर्क',

      // Field Values - Marital Status
      'Never Married': 'अविवाहित',
      'Unmarried': 'अविवाहित',
      'Divorced': 'घटस्फोटित',
      'Widowed': 'विधवा / विधुर',
      'Awaiting Divorce': 'घटस्फोट प्रक्रिया सुरू',
      'Separated': 'विभक्त',

      // Field Values - Gender
      'Male': 'पुरुष',
      'Female': 'स्त्री',

      // Field Values - Complexion
      'Fair': 'गोरा',
      'Very Fair': 'अति गोरा',
      'Wheatish': 'गहूवर्ण',
      'Dark': 'सावळा',

      // Field Values - Family Type & Status
      'Joint': 'एकत्र कुटुंब',
      'Joint Family': 'एकत्र कुटुंब',
      'Nuclear': 'विभक्त कुटुंब',
      'Nuclear Family': 'विभक्त कुटुंब',
      'Middle Class': 'मध्यमवर्गीय',
      'Upper Middle Class': 'उच्च मध्यमवर्गीय',
      'Rich / Affluent': 'श्रीमंत / संपन्न',
      'Rich': 'श्रीमंत / संपन्न',
      'Affluent': 'संपन्न',

      // Field Values - Occupations
      'Private Job': 'खाजगी नोकरी',
      'Private Sector': 'खाजगी क्षेत्र',
      'Private Employee': 'खाजगी कर्मचारी',
      'Government Job': 'सरकारी नोकरी',
      'Government Sector': 'सरकारी क्षेत्र',
      'Government Employee': 'सरकारी कर्मचारी',
      'Business': 'व्यवसाय',
      'Self Employed': 'स्वयंरोजगार',
      'Business / Self Employed': 'व्यवसाय / स्वयंपूर्ण',
      'Farmer': 'शेतकरी / शेती',
      'Agriculture': 'शेतकरी / शेती',
      'Farming': 'शेती',
      'Software Engineer': 'सॉफ्टवेअर अभियंता',
      'Software Developer': 'सॉफ्टवेअर डेव्हलपर',
      'IT Professional': 'आयटी प्रोफेशनल',
      'Engineer': 'अभियंता',
      'Civil Engineer': 'सिव्हिल अभियंता',
      'Mechanical Engineer': 'मेकॅनिकल अभियंता',
      'Electrical Engineer': 'इलेक्ट्रिकल अभियंता',
      'Doctor': 'डॉक्टर',
      'Medical Professional': 'वैद्यकीय व्यावसायिक',
      'Nurse / Nursing': 'परिचारिका (नर्स)',
      'Teacher': 'शिक्षक / प्राध्यापक',
      'Lecturer': 'व्याख्याता',
      'Professor': 'प्राध्यापक',
      'Banker': 'बँक कर्मचारी',
      'Bank Officer': 'बँक अधिकारी',
      'Accountant': 'लेखापाल (अकाउंटंट)',
      'Police': 'पोलीस सेवा',
      'Police Officer': 'पोलीस अधिकारी',
      'Army': 'भारतीय सैन्य / डिफेन्स',
      'Defence': 'संरक्षण सेवा',
      'Advocate': 'वकील / ॲडव्होकेट',
      'Lawyer': 'वकील / ॲडव्होकेट',
      'Homemaker': 'गृहिणी',
      'Housewife': 'गृहिणी',
      'Retired': 'सेवानिवृत्त',
      'Student': 'विद्यार्थी',
      'Not Working': 'कार्यरत नाही',
      'Late': 'कै. (स्वर्गवासी)',
      'None': 'कोणीही नाही',

      // Field Values - Educations
      'Graduate': 'पदवीधर (Graduate)',
      'Post Graduate': 'पदव्युत्तर (Post Graduate)',
      'Doctorate': 'विद्यावाचस्पती (Ph.D)',
      'Diploma': 'डिप्लोमा (Diploma)',
      'Higher Secondary (12th)': '१२ वी उत्तीर्ण',
      'Secondary (10th)': '१० वी उत्तीर्ण',
      '10th': '१० वी उत्तीर्ण',
      '12th': '१२ वी उत्तीर्ण',
      'B.Tech': 'बी.टेक (B.Tech)',
      'B.E': 'बी.ई (B.E)',
      'M.Tech': 'एम.टेक (M.Tech)',
      'M.E': 'एम.ई (M.E)',
      'MBA': 'एम.बी.ए (MBA)',
      'MCA': 'एम.सी.ए (MCA)',
      'BCA': 'बी.सी.ए (BCA)',
      'B.Sc': 'बी.एस्सी (B.Sc)',
      'M.Sc': 'एम.एस्सी (M.Sc)',
      'B.Com': 'बी.कॉम (B.Com)',
      'M.Com': 'एम.कॉम (M.Com)',
      'B.A': 'बी.ए (B.A)',
      'M.A': 'एम.ए (M.A)',
      'MBBS': 'एम.बी.बी.एस (MBBS)',
      'MD': 'एम.डी / एम.एस (MD/MS)',
      'BAMS': 'बी.ए.एम.एस (BAMS)',
      'BHMS': 'बी.एच.एम.एस (BHMS)',
      'B.Ed': 'बी.एड (B.Ed)',
      'D.Ed': 'डी.एड (D.Ed)',
      'LLB': 'एलएल.बी (LLB)',
      'LLM': 'एलएल.एम (LLM)',
      'CA': 'चार्टर्ड अकाउंटंट (CA)',

      // Gotras (Banjara Community)
      'Rathod': 'राठोड',
      'Pawar': 'पवार',
      'Chavan': 'चव्हाण',
      'Jadhav': 'जाधव',
      'Ade': 'आडे',
      'Banoth': 'बानोत',
      'Bhukya': 'भुक्या',
      'Dharamsoth': 'धरमसोत',
      'Guguloth': 'गुगुलोत',
      'Korra': 'कोर्रा',
      'Kumpawat': 'कुंपावत',
      'Mood': 'मूड',
      'Nayak': 'नायक',
      'Nenavath': 'नेनावत',
      'Sabavath': 'सबावत',
      'Vankudoth': 'वानकुडोत',
      'Badavath': 'बडावत',
      'Karamtot': 'करमतोत',
      'Ramavath': 'रामावत',
      'Megavath': 'मेगावत',
      'Jarapala': 'जरापला',
      'Dhegavath': 'ढेगावत',
      'Kura': 'कुरा',
      'Lavadiya': 'लवाडिया',
      'Bartiya': 'बार्तिया',

      // States & Cities
      'Maharashtra': 'महाराष्ट्र',
      'Karnataka': 'कर्नाटक',
      'Telangana': 'तेलंगणा',
      'Andhra Pradesh': 'आंध्र प्रदेश',
      'Madhya Pradesh': 'मध्य प्रदेश',
      'Gujarat': 'गुजरात',
      'Pune': 'पुणे',
      'Mumbai': 'मुंबई',
      'Nagpur': 'नागपूर',
      'Yavatmal': 'यवतमाळ',
      'Nanded': 'नांदेड',
      'Washim': 'वाशिम',
      'Hingoli': 'हिंगोली',
      'Akola': 'अकोला',
      'Amravati': 'अमरावती',
      'Jalna': 'जालना',
      'Aurangabad': 'छत्रपती संभाजीनगर',
      'Beed': 'बीड',
      'Latur': 'लातूर',
      'Solapur': 'सोलापूर',
      'Kolhapur': 'कोल्हापूर',
      'Sangli': 'सांगली',
      'Satara': 'सातारा',
      'Nashik': 'नाशिक',
      'Thane': 'ठाणे',
      'Hyderabad': 'हैदराबाद',
      'Bangalore': 'बंगळुरू',

      // Branding
      'Download App Line': 'बंजारा समाजाचे #1 विश्वासाचे मॅट्रीमोनी ॲप • तुमचा जीवनसाथी शोधा',
    },

    // ═════════════════════════════════════════════════════════════════════════
    // 🇮🇳 HINDI (हिंदी)
    // ═════════════════════════════════════════════════════════════════════════
    'Hindi': {
      // Sections
      'personal_details': 'व्यक्तिगत विवरण',
      'education_profession': 'शिक्षा और व्यवसाय',
      'family_details': 'पारिवारिक विवरण',
      'location_contact': 'स्थान और संपर्क',
      'partner_expectations': 'जीवनसाथी की अपेक्षाएं',
      'about_me': 'मेरे बारे में',
      'Personal Details': 'व्यक्तिगत विवरण',
      'Education & Profession': 'शिक्षा और व्यवसाय',
      'Family Details': 'पारिवारिक विवरण',
      'Location & Contact': 'स्थान और संपर्क',
      'Partner Expectations': 'जीवनसाथी की अपेक्षाएं',
      'About Me': 'मेरे बारे में',
      'Candidate Profile Photo': 'उम्मीदवार का प्रोफाइल फोटो',
      'Profile Photograph': 'उम्मीदवार का फोटो',
      'biodata': 'बायोडाटा',
      'Biodata': 'बायोडाटा',

      // Field Keys
      'full_name': 'पूरा नाम',
      'Full Name': 'पूरा नाम',
      'surname': 'उपनाम',
      'Surname': 'उपनाम',
      'age': 'आयु',
      'Age': 'आयु',
      'height': 'लंबाई',
      'Height': 'लंबाई',
      'gender': 'लिंग',
      'Gender': 'लिंग',
      'dob': 'जन्म तिथि',
      'Date of Birth': 'जन्म तिथि',
      'birth_time': 'जन्म समय',
      'Birth Time': 'जन्म समय',
      'birth_place': 'जन्म स्थान',
      'Birth Place': 'जन्म स्थान',
      'marital_status': 'वैवाहिक स्थिति',
      'Marital Status': 'वैवाहिक स्थिति',
      'complexion': 'रंग / वर्ण',
      'Complexion': 'रंग / वर्ण',
      'blood_group': 'रक्त समूह',
      'Blood Group': 'रक्त समूह',
      'gotra': 'गोर गोत्र',
      'Gotra': 'गोर गोत्र',
      'Gor Gotra': 'गोर गोत्र',
      'caste': 'जाति / समाज',
      'Caste': 'जाति / समाज',
      'religion': 'धर्म',
      'Religion': 'धर्म',
      'education': 'शिक्षा',
      'Education': 'शिक्षा',
      'edu_details': 'शिक्षा विवरण',
      'Edu. Details': 'शिक्षा विवरण',
      'occupation': 'व्यवसाय / नौकरी',
      'Occupation': 'व्यवसाय / नौकरी',
      'job_details': 'नौकरी का विवरण',
      'Job Details': 'नौकरी का विवरण',
      'annual_income': 'वार्षिक आय',
      'Annual Income': 'वार्षिक आय',
      'company': 'कंपनी / संस्थान',
      'Company': 'कंपनी / संस्थान',
      'father_name': 'पिता का नाम',
      'Father Name': 'पिता का नाम',
      'father_occup': 'पिता का व्यवसाय',
      'Father Occup.': 'पिता का व्यवसाय',
      'mother_name': 'माता का नाम',
      'Mother Name': 'माता का नाम',
      'mother_occup': 'माता का व्यवसाय',
      'Mother Occup.': 'माता का व्यवसाय',
      'family_type': 'परिवार का प्रकार',
      'Family Type': 'परिवार का प्रकार',
      'family_status': 'पारिवारिक स्थिति',
      'Family Status': 'पारिवारिक स्थिति',
      'total_siblings': 'कुल भाई-बहन',
      'Total Siblings': 'कुल भाई-बहन',
      'brothers': 'भाई',
      'Brothers': 'भाई',
      'sisters': 'बहनें',
      'Sisters': 'बहनें',
      'native_place': 'मूल स्थान / टांडा',
      'Native Place': 'मूल स्थान / टांडा',
      'current_location': 'वर्तमान स्थान',
      'Current Location': 'वर्तमान स्थान',
      'contact_no': 'संपर्क नंबर',
      'Contact No.': 'संपर्क नंबर',
      'Alt. Contact': 'वैकल्पिक संपर्क',

      // Field Values - Marital Status
      'Never Married': 'अविवाहित',
      'Unmarried': 'अविवाहित',
      'Divorced': 'तलाकशुदा',
      'Widowed': 'विधवा / विधुर',
      'Awaiting Divorce': 'तलाक प्रतीक्षारत',
      'Separated': 'अलग',

      // Field Values - Gender
      'Male': 'पुरुष',
      'Female': 'महिला',

      // Field Values - Complexion
      'Fair': 'गोरा',
      'Very Fair': 'अति गोरा',
      'Wheatish': 'गेहुंआ',
      'Dark': 'सांवला',

      // Field Values - Family Type & Status
      'Joint': 'संयुक्त परिवार',
      'Joint Family': 'संयुक्त परिवार',
      'Nuclear': 'एकल परिवार',
      'Nuclear Family': 'एकल परिवार',
      'Middle Class': 'मध्यम वर्ग',
      'Upper Middle Class': 'उच्च मध्यम वर्ग',
      'Rich / Affluent': 'सम्पन्न / समृद्ध',
      'Rich': 'सम्पन्न / समृद्ध',
      'Affluent': 'सम्पन्न',

      // Field Values - Occupations
      'Private Job': 'निजी नौकरी',
      'Private Sector': 'निजी क्षेत्र',
      'Private Employee': 'निजी कर्मचारी',
      'Government Job': 'सरकारी नौकरी',
      'Government Sector': 'सरकारी क्षेत्र',
      'Government Employee': 'सरकारी कर्मचारी',
      'Business': 'व्यवसाय',
      'Self Employed': 'स्वरोजगार',
      'Business / Self Employed': 'व्यवसाय / स्वरोजगार',
      'Farmer': 'किसान / कृषि',
      'Agriculture': 'किसान / कृषि',
      'Farming': 'कृषि',
      'Software Engineer': 'सॉफ्टवेयर इंजीनियर',
      'Software Developer': 'सॉफ्टवेयर डेवलपर',
      'IT Professional': 'आईटी पेशेवर',
      'Engineer': 'इंजीनियर',
      'Civil Engineer': 'सिविल इंजीनियर',
      'Mechanical Engineer': 'मैकेनिकल इंजीनियर',
      'Electrical Engineer': 'इलेक्ट्रिकल इंजीनियर',
      'Doctor': 'डॉक्टर',
      'Medical Professional': 'चिकित्सा पेशेवर',
      'Nurse / Nursing': 'नर्स / नर्सिंग',
      'Teacher': 'शिक्षक',
      'Lecturer': 'प्रवक्ता',
      'Professor': 'प्राध्यापक',
      'Banker': 'बैंकर',
      'Bank Officer': 'बैंक अधिकारी',
      'Accountant': 'लेखाकार (अकाउंटेंट)',
      'Police': 'पुलिस सेवा',
      'Police Officer': 'पुलिस अधिकारी',
      'Army': 'भारतीय सेना / रक्षा',
      'Defence': 'रक्षा सेवा',
      'Advocate': 'अधिवक्ता / वकील',
      'Lawyer': 'अधिवक्ता / वकील',
      'Homemaker': 'गृहिणी',
      'Housewife': 'गृहिणी',
      'Retired': 'सेवानिवृत्त',
      'Student': 'छात्र / छात्रा',
      'Not Working': 'कार्यरत नहीं',
      'Late': 'स्वर्गीय',
      'None': 'कोई नहीं',

      // Field Values - Educations
      'Graduate': 'स्नातक (Graduate)',
      'Post Graduate': 'स्नातकोत्तर (Post Graduate)',
      'Doctorate': 'डॉक्टरेट (Ph.D)',
      'Diploma': 'डिप्लोमा (Diploma)',
      'Higher Secondary (12th)': '१२ वीं उत्तीर्ण',
      'Secondary (10th)': '१० वीं उत्तीर्ण',
      '10th': '१० वीं उत्तीर्ण',
      '12th': '१२ वीं उत्तीर्ण',
      'B.Tech': 'बी.टेक (B.Tech)',
      'B.E': 'बी.ई (B.E)',
      'M.Tech': 'एम.टेक (M.Tech)',
      'M.E': 'एम.ई (M.E)',
      'MBA': 'एम.बी.ए (MBA)',
      'MCA': 'एम.सी.ए (MCA)',
      'BCA': 'बी.सी.ए (BCA)',
      'B.Sc': 'बी.एससी (B.Sc)',
      'M.Sc': 'एम.एससी (M.Sc)',
      'B.Com': 'बी.कॉम (B.Com)',
      'M.Com': 'एम.कॉम (M.Com)',
      'B.A': 'बी.ए (B.A)',
      'M.A': 'एम.ए (M.A)',
      'MBBS': 'एम.बी.बी.एस (MBBS)',
      'MD': 'एम.डी / एम.एस (MD/MS)',
      'BAMS': 'बी.ए.एम.एस (BAMS)',
      'BHMS': 'बी.एच.एम.एस (BHMS)',
      'B.Ed': 'बी.एड (B.Ed)',
      'D.Ed': 'डी.एड (D.Ed)',
      'LLB': 'एलएल.बी (LLB)',
      'LLM': 'एलएल.एम (LLM)',
      'CA': 'चार्टर्ड अकाउंटेंट (CA)',

      // Gotras (Banjara Community)
      'Rathod': 'राठौड़',
      'Pawar': 'पवार',
      'Chavan': 'चव्हाण',
      'Jadhav': 'जाधव',
      'Ade': 'आडे',
      'Banoth': 'बानोत',
      'Bhukya': 'भुक्या',
      'Dharamsoth': 'धरमसोत',
      'Guguloth': 'गुगुलोत',
      'Korra': 'कोर्रा',
      'Kumpawat': 'कुंपावत',
      'Mood': 'मूड',
      'Nayak': 'नायक',
      'Nenavath': 'नेनावत',
      'Sabavath': 'सबावत',
      'Vankudoth': 'वानकुदोत',
      'Badavath': 'बडावत',
      'Karamtot': 'करमतोत',
      'Ramavath': 'रामावत',
      'Megavath': 'मेगावत',
      'Jarapala': 'जरापला',
      'Dhegavath': 'ढेगावत',
      'Kura': 'कुरा',
      'Lavadiya': 'लवाडिया',
      'Bartiya': 'बार्तिया',

      // States & Cities
      'Maharashtra': 'महाराष्ट्र',
      'Karnataka': 'कर्नाटक',
      'Telangana': 'तेलंगाना',
      'Andhra Pradesh': 'आंध्र प्रदेश',
      'Madhya Pradesh': 'मध्य प्रदेश',
      'Gujarat': 'गुजरात',
      'Pune': 'पुणे',
      'Mumbai': 'मुंबई',
      'Nagpur': 'नागपुर',
      'Yavatmal': 'यवतमाल',
      'Nanded': 'नांदेड़',
      'Washim': 'वाशिम',
      'Hingoli': 'हिंगोली',
      'Akola': 'अकोला',
      'Amravati': 'अमरावती',
      'Jalna': 'जालना',
      'Aurangabad': 'औरंगाबाद (संभाजीनगर)',
      'Beed': 'बीड',
      'Latur': 'लातूर',
      'Solapur': 'सोलापुर',
      'Hyderabad': 'हैदराबाद',
      'Bangalore': 'बेंगलुरु',

      // Branding
      'Download App Line': 'बंजारा समाज का #1 विश्वसनीय वैवाहिक ऐप • अपना जीवनसाथी खोजें',
    },

    // ═════════════════════════════════════════════════════════════════════════
    // 🏛️ TELUGU (తెలుగు)
    // ═════════════════════════════════════════════════════════════════════════
    'Telugu': {
      // Sections
      'personal_details': 'వ్యక్తిగత వివరాలు',
      'education_profession': 'చదువు మరియు వృత్తి',
      'family_details': 'కుటుంబ వివరాలు',
      'location_contact': 'నివాసం మరియు సంప్రదించండి',
      'partner_expectations': 'భాగస్వామి అంచనాలు',
      'about_me': 'నా గురించి',
      'Personal Details': 'వ్యక్తిగత వివరాలు',
      'Education & Profession': 'చదువు మరియు వృత్తి',
      'Family Details': 'కుటుంబ వివరాలు',
      'Location & Contact': 'నివాసం మరియు సంప్రదించండి',
      'Partner Expectations': 'భాగస్వామి అంచనాలు',
      'About Me': 'నా గురించి',
      'Candidate Profile Photo': 'అభ్యర్థి ప్రొఫైల్ ఫోటో',
      'Profile Photograph': 'అభ్యర్థి ఫోటో',
      'biodata': 'బయోడేటా',
      'Biodata': 'బయోడేటా',

      // Field Keys
      'full_name': 'పూర్తి పేరు',
      'Full Name': 'పూర్తి పేరు',
      'surname': 'ఇంటి పేరు',
      'Surname': 'ఇంటి పేరు',
      'age': 'వయస్సు',
      'Age': 'వయస్సు',
      'height': 'ఎత్తు',
      'Height': 'ఎత్తు',
      'gender': 'లింగం',
      'Gender': 'లింగం',
      'dob': 'పుట్టిన తేదీ',
      'Date of Birth': 'పుట్టిన తేదీ',
      'birth_time': 'పుట్టిన సమయం',
      'Birth Time': 'పుట్టిన సమయం',
      'birth_place': 'పుట్టిన స్థలం',
      'Birth Place': 'పుట్టిన స్థలం',
      'marital_status': 'వైవాహిక స్థితి',
      'Marital Status': 'వైవాహిక స్థితి',
      'complexion': 'రంగు / ఛాయ',
      'Complexion': 'రంగు / ఛాయ',
      'blood_group': 'రక్త వర్గం',
      'Blood Group': 'రక్త వర్గం',
      'gotra': 'గోర్ గోత్రం',
      'Gotra': 'గోర్ గోత్రం',
      'Gor Gotra': 'గోర్ గోత్రం',
      'caste': 'కులం / సమాజం',
      'Caste': 'కులం / సమాజం',
      'religion': 'మతం',
      'Religion': 'మతం',
      'education': 'చదువు',
      'Education': 'చదువు',
      'edu_details': 'చదువు వివరాలు',
      'Edu. Details': 'చదువు వివరాలు',
      'occupation': 'ఉద్యోగం / వృత్తి',
      'Occupation': 'ఉద్యోగం / వృత్తి',
      'job_details': 'ఉద్యోగం వివరాలు',
      'Job Details': 'ఉద్యోగం వివరాలు',
      'annual_income': 'సంవత్సర ఆదాయం',
      'Annual Income': 'సంవత్సర ఆదాయం',
      'company': 'కంపెనీ / కార్యాలయం',
      'Company': 'కంపెనీ / కార్యాలయం',
      'father_name': 'తండ్రి పేరు',
      'Father Name': 'తండ్రి పేరు',
      'father_occup': 'తండ్రి వృత్తి',
      'Father Occup.': 'తండ్రి వృత్తి',
      'mother_name': 'తల్లి పేరు',
      'Mother Name': 'తల్లి పేరు',
      'mother_occup': 'తల్లి వృత్తి',
      'Mother Occup.': 'తల్లి వృత్తి',
      'family_type': 'కుటుంబ రకం',
      'Family Type': 'కుటుంబ రకం',
      'family_status': 'కుటుంబ స్థితి',
      'Family Status': 'కుటుంబ స్థితి',
      'total_siblings': 'మొత్తం తోబుట్టువులు',
      'Total Siblings': 'మొత్తం తోబుట్టువులు',
      'brothers': 'సోదరులు',
      'Brothers': 'సోదరులు',
      'sisters': 'సోదరీమణులు',
      'Sisters': 'సోదరీమణులు',
      'native_place': 'సొంత ఊరు / తండా',
      'Native Place': 'సొంత ఊరు / తండా',
      'current_location': 'ప్రస్తుత నివాసం',
      'Current Location': 'ప్రస్తుత నివాసం',
      'contact_no': 'సంప్రదించే ఫోన్ నంబర్',
      'Contact No.': 'సంప్రదించే ఫోన్ నంబర్',
      'Alt. Contact': 'ప్రత్యామ్నాయ సంప్రదింపు',

      // Field Values - Marital Status
      'Never Married': 'పెళ్లి కాలేదు (అవివాహితుడు)',
      'Unmarried': 'పెళ్లి కాలేదు',
      'Divorced': 'విడాకులు తీసుకున్న',
      'Widowed': 'వితంతువు / విధురుడు',
      'Awaiting Divorce': 'విడాకుల నిరీక్షణ',
      'Separated': 'వేరుగా ఉంటున్నారు',

      // Field Values - Gender
      'Male': 'పురుషుడు',
      'Female': 'స్త్రీ',

      // Field Values - Complexion
      'Fair': 'తెలుపు',
      'Very Fair': 'చాలా తెలుపు',
      'Wheatish': 'గోధుమ రంగు',
      'Dark': 'చామనచాయ',

      // Field Values - Family Type & Status
      'Joint': 'ఉమ్మడి కుటుంబం',
      'Joint Family': 'ఉమ్మడి కుటుంబం',
      'Nuclear': 'చిన్న కుటుంబం',
      'Nuclear Family': 'చిన్న కుటుంబం',
      'Middle Class': 'మధ్యతరగతి',
      'Upper Middle Class': 'ఎగువ మధ్యతరగతి',
      'Rich / Affluent': 'సంపన్న కుటుంబం',
      'Rich': 'సంపన్న కుటుంబం',
      'Affluent': 'సంపన్న',

      // Field Values - Occupations
      'Private Job': 'ప్రైవేట్ ఉద్యోగం',
      'Private Sector': 'ప్రైవేట్ రంగం',
      'Private Employee': 'ప్రైవేట్ ఉద్యోగి',
      'Government Job': 'ప్రభుత్వ ఉద్యోగం',
      'Government Sector': 'ప్రభుత్వ రంగం',
      'Government Employee': 'ప్రభుత్వ ఉద్యోగి',
      'Business': 'వ్యాపారం',
      'Self Employed': 'స్వయం ఉపాధి',
      'Business / Self Employed': 'వ్యాపారం / స్వయం ఉపాధి',
      'Farmer': 'రైతు / వ్యవసాయం',
      'Agriculture': 'రైతు / వ్యవసాయం',
      'Farming': 'వ్యవసాయం',
      'Software Engineer': 'సాఫ్ట్‌వేర్ ఇంజనీర్',
      'Software Developer': 'సాఫ్ట్‌వేర్ డెవలపర్',
      'IT Professional': 'ఐటీ ప్రొఫెషనల్',
      'Engineer': 'ఇంజనీర్',
      'Civil Engineer': 'సివిల్ ఇంజనీర్',
      'Mechanical Engineer': 'మెకానికల్ ఇంజనీర్',
      'Electrical Engineer': 'ఎలక్ట్రికల్ ఇంజనీర్',
      'Doctor': 'డాక్టర్ (వైద్యుడు)',
      'Medical Professional': 'వైద్య రంగం',
      'Nurse / Nursing': 'నర్సు',
      'Teacher': 'ఉపాధ్యాయుడు (టీచర్)',
      'Lecturer': 'లెక్చరర్',
      'Professor': 'ప్రొఫెసర్',
      'Banker': 'బ్యాంక్ ఉద్యోగి',
      'Bank Officer': 'బ్యాంక్ అధికారి',
      'Accountant': 'అకౌంటెంట్',
      'Police': 'పోలీస్ సేవ',
      'Police Officer': 'పోలీస్ అధికారి',
      'Army': 'భారత సైన్యం / డిఫెన్స్',
      'Defence': 'రక్షణ సేవలు',
      'Advocate': 'లాయర్ / న్యాయవాది',
      'Lawyer': 'లాయర్ / న్యాయవాది',
      'Homemaker': 'గృహిణి',
      'Housewife': 'గృహిణి',
      'Retired': 'రిటైర్డ్',
      'Student': 'విద్యార్థి',
      'Not Working': 'పని చేయడం లేదు',
      'Late': 'దివంగత',
      'None': 'ఎవరూ లేరు',

      // Field Values - Educations
      'Graduate': 'డిగ్రీ / గ్రాడ్యుయేట్',
      'Post Graduate': 'పోస్ట్ గ్రాడ్యుయేట్ (పీజీ)',
      'Doctorate': 'పీహెచ్‌డీ (Ph.D)',
      'Diploma': 'డిప్లొమా',
      'Higher Secondary (12th)': 'ఇంటర్మీడియట్ (12వ)',
      'Secondary (10th)': '10వ తరగతి (ఎస్సెస్సీ)',
      '10th': '10వ తరగతి',
      '12th': 'ఇంటర్మీడియట్',
      'B.Tech': 'బి.టెక్ (B.Tech)',
      'B.E': 'బి.ఇ (B.E)',
      'M.Tech': 'ఎం.టెక్ (M.Tech)',
      'M.E': 'ఎం.ఇ (M.E)',
      'MBA': 'ఎం.బి.ఎ (MBA)',
      'MCA': 'ఎం.సి.ఎ (MCA)',
      'BCA': 'బి.సి.ఎ (BCA)',
      'B.Sc': 'బి.ఎస్సీ (B.Sc)',
      'M.Sc': 'ఎం.ఎస్సీ (M.Sc)',
      'B.Com': 'బి.కామ్ (B.Com)',
      'M.Com': 'ఎం.కామ్ (M.Com)',
      'B.A': 'బి.ఎ (B.A)',
      'M.A': 'ఎం.ఎ (M.A)',
      'MBBS': 'ఎంబీబీఎస్ (MBBS)',
      'MD': 'ఎండీ / ఎంఎస్ (MD/MS)',
      'BAMS': 'బి.ఎ.ఎం.ఎస్ (BAMS)',
      'BHMS': 'బి.హెచ్.ఎం.ఎస్ (BHMS)',
      'B.Ed': 'బి.ఎడ్ (B.Ed)',
      'D.Ed': 'డి.ఎడ్ (D.Ed)',
      'LLB': 'ఎల్ఎల్‌బీ (LLB)',
      'LLM': 'ఎల్ఎల్‌ఎం (LLM)',
      'CA': 'చార్టర్డ్ అకౌంటెంట్ (CA)',

      // Gotras (Banjara Community)
      'Rathod': 'రాథోడ్',
      'Pawar': 'పవార్',
      'Chavan': 'చవాన్',
      'Jadhav': 'జాదవ్',
      'Ade': 'ఆడే',
      'Banoth': 'బానోత్',
      'Bhukya': 'భుక్యా',
      'Dharamsoth': 'ధర్మసోత్',
      'Guguloth': 'గుగులోత్',
      'Korra': 'కొర్రా',
      'Kumpawat': 'కుంపావత్',
      'Mood': 'మూడ్',
      'Nayak': 'నాయక్',
      'Nenavath': 'నేనావత్',
      'Sabavath': 'సబావత్',
      'Vankudoth': 'వాంకుడోత్',
      'Badavath': 'బడావత్',
      'Karamtot': 'కరంతోత్',
      'Ramavath': 'రామావత్',
      'Megavath': 'మేగావత్',
      'Jarapala': 'జరపాల',
      'Dhegavath': 'ధేగావత్',
      'Kura': 'కురా',
      'Lavadiya': 'లవాడియా',
      'Bartiya': 'బార్తియా',

      // States & Cities
      'Telangana': 'తెలంగాణ',
      'Andhra Pradesh': 'ఆంధ్రప్రదేశ్',
      'Maharashtra': 'మహారాష్ట్ర',
      'Karnataka': 'కర్ణాಟಕ',
      'Hyderabad': 'హైదరాబాద్',
      'Warangal': 'వరంగల్',
      'Nizamabad': 'నిజామాబాద్',
      'Karimnagar': 'కరీంనగర్',
      'Khammam': 'ఖమ్మం',
      'Mahabubnagar': 'మహబూబ్‌నగర్',
      'Nalgonda': 'నల్గొండ',
      'Adilabad': 'ఆదిలాబాద్',
      'Vijayawada': 'విజయవాడ',
      'Visakhapatnam': 'విశాఖపట్నం',
      'Guntur': 'గుంటూరు',
      'Kurnool': 'కర్నూలు',
      'Tirupati': 'తిరుపతి',
      'Bangalore': 'బెంగళూరు',
      'Pune': 'పుణే',
      'Mumbai': 'ముంబై',

      // Branding
      'Download App Line': '#1 విశ్వసనీయ బంజారా మ్యాట్రిమోనీ యాప్ • మీ జీవిత భాగస్వామిని కనుగొనండి',
    },

    // ═════════════════════════════════════════════════════════════════════════
    // 🌾 KANNADA (ಕನ್ನಡ)
    // ═════════════════════════════════════════════════════════════════════════
    'Kannada': {
      // Sections
      'personal_details': 'ವೈಯಕ್ತಿಕ ವಿವರಗಳು',
      'education_profession': 'ಶಿಕ್ಷಣ ಮತ್ತು ಉದ್ಯೋಗ',
      'family_details': 'ಕುಟುಂಬದ ವಿವರಗಳು',
      'location_contact': 'ಸ್ಥಳ ಮತ್ತು ಸಂಪರ್ಕ',
      'partner_expectations': 'ಜೀವನ ಸಂಗಾತಿಯ ನಿರೀಕ್ಷೆಗಳು',
      'about_me': 'ನನ್ನ ಬಗ್ಗೆ',
      'Personal Details': 'ವೈಯಕ್ತಿಕ ವಿವರಗಳು',
      'Education & Profession': 'ಶಿಕ್ಷಣ ಮತ್ತು ಉದ್ಯೋಗ',
      'Family Details': 'ಕುಟುಂಬದ ವಿವರಗಳು',
      'Location & Contact': 'ಸ್ಥಳ ಮತ್ತು ಸಂಪರ್ಕ',
      'Partner Expectations': 'ಜೀವನ ಸಂಗಾತಿಯ ನಿರೀಕ್ಷೆಗಳು',
      'About Me': 'ನನ್ನ ಬಗ್ಗೆ',
      'Candidate Profile Photo': 'ಅಭ್ಯರ್ಥಿ ಪ್ರೊಫೈಲ್ ಫೋಟೋ',
      'Profile Photograph': 'ಅಭ್ಯರ್ಥಿ ಭಾವಚಿತ್ರ',
      'biodata': 'ಬಯೋಡೇಟಾ',
      'Biodata': 'ಬಯೋಡೇಟಾ',

      // Field Keys
      'full_name': 'ಪೂರ್ಣ ಹೆಸರು',
      'Full Name': 'ಪೂರ್ಣ ಹೆಸರು',
      'surname': 'ಮನೆ ಹೆಸರು / ಉಪನಾಮ',
      'Surname': 'ಮನೆ ಹೆಸರು / ಉಪನಾಮ',
      'age': 'ವಯಸ್ಸು',
      'Age': 'ವಯಸ್ಸು',
      'height': 'ಎತ್ತರ',
      'Height': 'ಎತ್ತರ',
      'gender': 'ಲಿಂಗ',
      'Gender': 'ಲಿಂಗ',
      'dob': 'ಹುಟ್ಟಿದ ದಿನಾಂಕ',
      'Date of Birth': 'ಹುಟ್ಟಿದ ದಿನಾಂಕ',
      'birth_time': 'ಹುಟ್ಟಿದ ಸಮಯ',
      'Birth Time': 'ಹುಟ್ಟಿದ ಸಮಯ',
      'birth_place': 'ಹುಟ್ಟಿದ ಸ್ಥಳ',
      'Birth Place': 'ಹುಟ್ಟಿದ ಸ್ಥಳ',
      'marital_status': 'ವೈವಾಹಿಕ ಸ್ಥಿತಿ',
      'Marital Status': 'ವೈವಾಹಿಕ ಸ್ಥಿತಿ',
      'complexion': 'ಬಣ್ಣ',
      'Complexion': 'ಬಣ್ಣ',
      'blood_group': 'ರಕ್ತದ ಗುಂಪು',
      'Blood Group': 'ರಕ್ತದ ಗುಂಪು',
      'gotra': 'ಗೋರ್ ಗೋತ್ರ',
      'Gotra': 'ಗೋರ್ ಗೋತ್ರ',
      'Gor Gotra': 'ಗೋರ್ ಗೋತ್ರ',
      'caste': 'ಜಾತಿ / ಸಮಾಜ',
      'Caste': 'ಜಾತಿ / ಸಮಾಜ',
      'religion': 'ಧರ್ಮ',
      'Religion': 'ಧರ್ಮ',
      'education': 'ಶಿಕ್ಷಣ',
      'Education': 'ಶಿಕ್ಷಣ',
      'edu_details': 'ಶಿಕ್ಷಣದ ವಿವರಗಳು',
      'Edu. Details': 'ಶಿಕ್ಷಣದ ವಿವರಗಳು',
      'occupation': 'ಉದ್ಯೋಗ / ವೃತ್ತಿ',
      'Occupation': 'ಉದ್ಯೋಗ / ವೃತ್ತಿ',
      'job_details': 'ಉದ್ಯೋಗದ ವಿವರ',
      'Job Details': 'ಉದ್ಯೋಗದ ವಿವರ',
      'annual_income': 'ವಾರ್ಷಿಕ ಆದಾಯ',
      'Annual Income': 'ವಾರ್ಷಿಕ ಆದಾಯ',
      'company': 'ಕಂಪನಿ / ಸಂಸ್ಥೆ',
      'Company': 'ಕಂಪನಿ / ಸಂಸ್ಥೆ',
      'father_name': 'ತಂದೆಯ ಹೆಸರು',
      'Father Name': 'ತಂದೆಯ ಹೆಸರು',
      'father_occup': 'ತಂದೆಯ ಉದ್ಯೋಗ',
      'Father Occup.': 'ತಂದೆಯ ಉದ್ಯೋಗ',
      'mother_name': 'ತಾಯಿಯ ಹೆಸರು',
      'Mother Name': 'ತಾಯಿಯ ಹೆಸರು',
      'mother_occup': 'ತಾಯಿಯ ಉದ್ಯೋಗ',
      'Mother Occup.': 'ತಾಯಿಯ ಉದ್ಯೋಗ',
      'family_type': 'ಕುಟುಂಬದ ಪ್ರಕಾರ',
      'Family Type': 'ಕುಟುಂಬದ ಪ್ರಕಾರ',
      'family_status': 'ಕುಟುಂಬದ ಸ್ಥಿತಿ',
      'Family Status': 'ಕುಟುಂಬದ ಸ್ಥಿತಿ',
      'total_siblings': 'ಒಟ್ಟು ಒಡಹುಟ್ಟಿದವರು',
      'Total Siblings': 'ಒಟ್ಟು ಒಡಹುಟ್ಟಿದವರು',
      'brothers': 'ಸೋದರರು',
      'Brothers': 'ಸೋದರರು',
      'sisters': 'ಸೋದರಿಯರು',
      'Sisters': 'ಸೋದರಿಯರು',
      'native_place': 'ಮೂಲ ಸ್ಥಳ / ತಾಂಡಾ',
      'Native Place': 'ಮೂಲ ಸ್ಥಳ / ತಾಂಡಾ',
      'current_location': 'ಪ್ರಸ್ತುತ ಸ್ಥಳ',
      'Current Location': 'ಪ್ರಸ್ತುತ ಸ್ಥಳ',
      'contact_no': 'ಸಂಪರ್ಕ ಸಂಖ್ಯೆ',
      'Contact No.': 'ಸಂಪರ್ಕ ಸಂಖ್ಯೆ',
      'Alt. Contact': 'ಪರ್ಯಾಯ ಸಂಪರ್ಕ',

      // Field Values - Marital Status
      'Never Married': 'ಅವಿವಾಹಿತ',
      'Unmarried': 'ಅವಿವಾಹಿತ',
      'Divorced': 'ವಿಚ್ಛೇದಿತ',
      'Widowed': 'ವಿಧವೆ / ವಿಧುರ',
      'Awaiting Divorce': 'ವಿಚ್ಛೇದನ ನಿರೀಕ್ಷೆ',
      'Separated': 'ಪ್ರತ್ಯೇಕ',

      // Field Values - Gender
      'Male': 'ಪುರುಷ',
      'Female': 'ಮಹಿಳೆ',

      // Field Values - Complexion
      'Fair': 'ಬೆಳ್ಳಗೆ',
      'Very Fair': 'ಅತ್ಯಂತ ಬೆಳ್ಳಗೆ',
      'Wheatish': 'ಗೋಧಿ ಬಣ್ಣ',
      'Dark': 'ಕಪ್ಪು / ಸಾವಳೆ',

      // Field Values - Family Type & Status
      'Joint': 'ಅವಿಭಕ್ತ ಕುಟುಂಬ',
      'Joint Family': 'ಅವಿಭಕ್ತ ಕುಟುಂಬ',
      'Nuclear': 'ವಿಭಕ್ತ ಕುಟುಂಬ',
      'Nuclear Family': 'ವಿಭಕ್ತ ಕುಟುಂಬ',
      'Middle Class': 'ಮಧ್ಯಮ ವರ್ಗ',
      'Upper Middle Class': 'ಉನ್ನತ ಮಧ್ಯಮ ವರ್ಗ',
      'Rich / Affluent': 'ಶ್ರೀಮಂತ / ಸುಸ್ಥಿತಿ',
      'Rich': 'ಶ್ರೀಮಂತ / ಸುಸ್ಥಿತಿ',
      'Affluent': 'ಸುಸ್ಥಿತಿ',

      // Field Values - Occupations
      'Private Job': 'ಖಾಸಗಿ ಉದ್ಯೋಗ',
      'Private Sector': 'ಖಾಸಗಿ ವಲಯ',
      'Private Employee': 'ಖಾಸಗಿ ನೌಕರ',
      'Government Job': 'ಸರ್ಕಾರಿ ನೌಕರಿ',
      'Government Sector': 'ಸರ್ಕಾರಿ ವಲಯ',
      'Government Employee': 'ಸರ್ಕಾರಿ ನೌಕರ',
      'Business': 'ವ್ಯಾಪಾರ',
      'Self Employed': 'ಸ್ವಯಂ ಉದ್ಯೋಗ',
      'Business / Self Employed': 'ವ್ಯಾಪಾರ / ಸ್ವಯಂ ಉದ್ಯೋಗ',
      'Farmer': 'ರೈತ / ಕೃಷಿ',
      'Agriculture': 'ರೈತ / ಕೃಷಿ',
      'Farming': 'ಕೃಷಿ',
      'Software Engineer': 'ಸಾಫ್ಟ್‌ವೇರ್ ಎಂಜಿನಿಯರ್',
      'Software Developer': 'ಸಾಫ್ಟ್‌ವೇರ್ ಡೆವಲಪರ್',
      'IT Professional': 'ಐಟಿ ವೃತ್ತಿಪರ',
      'Engineer': 'ಎಂಜಿನಿಯರ್',
      'Civil Engineer': 'ಸಿವಿಲ್ ಎಂಜಿನಿಯರ್',
      'Mechanical Engineer': 'ಮೆಕ್ಯಾನಿಕಲ್ ಎಂಜಿನಿಯರ್',
      'Electrical Engineer': 'ಎಲೆಕ್ಟ್ರಿಕಲ್ ಎಂಜಿನಿಯರ್',
      'Doctor': 'ವೈದ್ಯ (ಡಾಕ್ಟರ್)',
      'Medical Professional': 'ವೈದ್ಯಕೀಯ ವೃತ್ತಿ',
      'Nurse / Nursing': 'ಶುಶ್ರೂಷಕಿ (ನರ್ಸ್)',
      'Teacher': 'ಶಿಕ್ಷಕ',
      'Lecturer': 'ಉಪನ್ಯಾಸಕ',
      'Professor': 'ಪ್ರಾಧ್ಯಾಪಕ',
      'Banker': 'ಬ್ಯಾಂಕ್ ಉದ್ಯೋಗಿ',
      'Bank Officer': 'ಬ್ಯಾಂಕ್ ಅಧಿಕಾರಿ',
      'Accountant': 'ಲೆಕ್ಕಪರಿಶೋಧಕ',
      'Police': 'ಪೊಲೀಸ್ ಸೇವೆ',
      'Police Officer': 'ಪೊಲೀಸ್ ಅಧಿಕಾರಿ',
      'Army': 'ಭಾರತೀಯ ಸೇನೆ / ರಕ್ಷಣೆ',
      'Defence': 'ರಕ್ಷಣಾ ಸೇವೆಗಳು',
      'Advocate': 'ವಕೀಲ',
      'Lawyer': 'ವಕೀಲ',
      'Homemaker': 'ಗೃಹಿಣಿ',
      'Housewife': 'ಗೃಹಿಣಿ',
      'Retired': 'ನಿವೃತ್ತ',
      'Student': 'ವಿದ್ಯಾರ್ಥಿ',
      'Not Working': 'ಕೆಲಸ ಮಾಡುತ್ತಿಲ್ಲ',
      'Late': 'ದಿವಂಗತ',
      'None': 'ಯಾರೂ ಇಲ್ಲ',

      // Field Values - Educations
      'Graduate': 'ಪದವೀಧರ (Graduate)',
      'Post Graduate': 'ಸ್ನಾತಕೋತ್ತರ (Post Graduate)',
      'Doctorate': 'ಡಾಕ್ಟರೇಟ್ (Ph.D)',
      'Diploma': 'ಡಿಪ್ಲೊಮಾ',
      'Higher Secondary (12th)': '೧೨ ನೇ ತರಗತಿ (ಪಿಯುಸಿ)',
      'Secondary (10th)': '೧೦ ನೇ ತರಗತಿ (ಎಸ್ಸೆಸ್ಸೆಲ್ಸಿ)',
      '10th': '೧೦ ನೇ ತರಗತಿ',
      '12th': 'ಪಿಯುಸಿ (12th)',
      'B.Tech': 'ಬಿ.ಟೆಕ್ (B.Tech)',
      'B.E': 'ಬಿ.ಇ (B.E)',
      'M.Tech': 'ಎಂ.ಟೆಕ್ (M.Tech)',
      'M.E': 'ಎಂ.ಇ (M.E)',
      'MBA': 'ಎಂ.ಬಿ.ಎ (MBA)',
      'MCA': 'ಎಂ.ಸಿ.ಎ (MCA)',
      'BCA': 'ಬಿ.ಸಿ.ಎ (BCA)',
      'B.Sc': 'ಬಿ.ಎಸ್ಸಿ (B.Sc)',
      'M.Sc': 'ಎಂ.ಎಸ್ಸಿ (M.Sc)',
      'B.Com': 'ಬಿ.ಕಾಂ (B.Com)',
      'M.Com': 'ಎಂ.ಕಾಂ (M.Com)',
      'B.A': 'ಬಿ.ಎ (B.A)',
      'M.A': 'ಎಂ.ಎ (M.A)',
      'MBBS': 'ಎಂಬಿಬಿಎಸ್ (MBBS)',
      'MD': 'ಎಂಡಿ / ಎಂಎಸ್ (MD/MS)',
      'BAMS': 'ಬಿ.ಎ.ಎಂ.ಎಸ್ (BAMS)',
      'BHMS': 'ಬಿ.ಎಚ್.ಎಂ.ಎಸ್ (BHMS)',
      'B.Ed': 'ಬಿ.ಎಡ್ (B.Ed)',
      'D.Ed': 'ಡಿ.ಎಡ್ (D.Ed)',
      'LLB': 'ಎಲ್‌ಎಲ್‌ಬಿ (LLB)',
      'LLM': 'ಎಲ್‌ಎಲ್‌ಎಂ (LLM)',
      'CA': 'ಚಾರ್ಟರ್ಡ್ ಅಕೌಂಟೆಂಟ್ (CA)',

      // Gotras (Banjara Community)
      'Rathod': 'ರಾಥೋಡ್',
      'Pawar': 'ಪವಾರ್',
      'Chavan': 'ಚವಾಣ್',
      'Jadhav': 'ಜಾಧವ್',
      'Ade': 'ಆಡೆ',
      'Banoth': 'ಬಾನೋತ್',
      'Bhukya': 'ಭುಕ್ಯಾ',
      'Dharamsoth': 'ಧರ್ಮಸೋತ್',
      'Guguloth': 'ಗುಗುಲೋತ್',
      'Korra': 'ಕೊರ್ರಾ',
      'Kumpawat': 'ಕುಂಪಾವತ್',
      'Mood': 'ಮೂಡ್',
      'Nayak': 'ನಾಯಕ್',
      'Nenavath': 'ನೇನಾವತ್',
      'Sabavath': 'ಸಬಾವತ್',
      'Vankudoth': 'ವಾಂಕುಡೋತ್',
      'Badavath': 'ಬಡಾವತ್',
      'Karamtot': 'ಕರಮ್‌ತೋತ್',
      'Ramavath': 'ರಾಮಾವತ್',
      'Megavath': 'ಮೇಗಾವತ್',
      'Jarapala': 'ಜರಪಾಲ',
      'Dhegavath': 'ಧೇಗಾವತ್',
      'Kura': 'ಕುರಾ',
      'Lavadiya': 'ಲವಾಡಿಯಾ',
      'Bartiya': 'ಬಾರ್ತಿಯಾ',

      // States & Cities
      'Karnataka': 'ಕರ್ನಾಟಕ',
      'Maharashtra': 'ಮಹಾರಾಷ್ಟ್ರ',
      'Telangana': 'ತೆಲಂಗಾಣ',
      'Andhra Pradesh': 'ಆಂಧ್ರಪ್ರದೇಶ',
      'Bangalore': 'ಬೆಂಗಳೂರು',
      'Kalaburagi': 'ಕಲಬುರಗಿ',
      'Gulbarga': 'ಕಲಬುರಗಿ',
      'Bidar': 'ಬೀದರ್',
      'Yadgir': 'ಯಾದಗಿರಿ',
      'Raichur': 'ರಾಯಚೂರು',
      'Bellary': 'ಬಳ್ಳಾರಿ',
      'Vijayapura': 'ವಿಜಯಪುರ',
      'Bijapur': 'ವಿಜಯಪುರ',
      'Belagavi': 'ಬೆಳಗಾವಿ',
      'Belgaum': 'ಬೆಳಗಾವಿ',
      'Bagalkot': 'ಬಾಗಲಕೋಟೆ',
      'Hubli': 'ಹುಬ್ಬಳ್ಳಿ',
      'Dharwad': 'ಧಾರವಾಡ',
      'Hyderabad': 'ಹೈದರಾಬಾದ್',
      'Pune': 'ಪುಣೆ',
      'Mumbai': 'ಮುಂಬೈ',

      // Branding
      'Download App Line': '#1 ನಂಬಿಕಸ್ಥ ಬಂಜಾರಾ ಮ್ಯಾಟ್ರಿಮೋನಿ ಆಪ್ • ನಿಮ್ಮ ಜೀವನ ಸಂಗಾತಿಯನ್ನು ಹುಡುಕಿ',
    },
  };

  /// Smart Translate: Translates single keys, full sentences, compound values,
  /// dates, heights, incomes, and comma-separated tokens.
  static String translate(String input, String language) {
    if (input.isEmpty || input == '-' || language == 'English') {
      return input;
    }

    final trimmed = input.trim();
    final langMap = translations[language] ?? translations['English']!;

    // 1. Direct dictionary match (case-insensitive)
    final normalized = trimmed.toLowerCase();
    for (final entry in langMap.entries) {
      if (entry.key.toLowerCase() == normalized) {
        return entry.value;
      }
    }

    // 2. Comma-separated compound text (e.g. "Pune, Maharashtra" or "B.Tech, Computer Science")
    if (trimmed.contains(',')) {
      final parts = trimmed.split(',');
      final translatedParts = parts.map((part) => translate(part.trim(), language)).toList();
      return translatedParts.join(', ');
    }

    // 3. Slash-separated compound text (e.g. "Farmer / Agriculture" or "Joint / Nuclear")
    if (trimmed.contains('/')) {
      final parts = trimmed.split('/');
      final translatedParts = parts.map((part) => translate(part.trim(), language)).toList();
      return translatedParts.join(' / ');
    }

    // 4. Height formatting (e.g. "5 ft 6 in" or "5'6" or "5 ft 6 in (168 cm)")
    final heightRegex = RegExp(r'''(\d+)\s*(?:ft|feet|'|ft\.)\s*(\d+)?\s*(?:in|inches|"|in\.)?''', caseSensitive: false);
    final heightMatch = heightRegex.firstMatch(trimmed);
    if (heightMatch != null) {
      final ft = heightMatch.group(1) ?? '';
      final inches = heightMatch.group(2) ?? '0';
      switch (language) {
        case 'Marathi':
          return '$ft फूट $inches इंच';
        case 'Hindi':
          return '$ft फीट $inches इंच';
        case 'Telugu':
          return '$ft అడుగులు $inches అంగుళాలు';
        case 'Kannada':
          return '$ft ಅಡಿ $inches ಇಂಚು';
      }
    }

    // 5. Income / Salary formatting (e.g. "5 - 7 Lakh" or "₹5,00,000 - ₹7,00,000" or "5 Lakhs")
    if (trimmed.toLowerCase().contains('lakh') || trimmed.toLowerCase().contains('per year') || trimmed.toLowerCase().contains('per annum')) {
      var result = trimmed;
      switch (language) {
        case 'Marathi':
          result = result
              .replaceAll(RegExp(r'Lakhs?', caseSensitive: false), 'लाख')
              .replaceAll(RegExp(r'per year|per annum|p\.a\.', caseSensitive: false), 'प्रति वर्ष')
              .replaceAll(' - ', ' ते ');
          return result;
        case 'Hindi':
          result = result
              .replaceAll(RegExp(r'Lakhs?', caseSensitive: false), 'लाख')
              .replaceAll(RegExp(r'per year|per annum|p\.a\.', caseSensitive: false), 'प्रति वर्ष');
          return result;
        case 'Telugu':
          result = result
              .replaceAll(RegExp(r'Lakhs?', caseSensitive: false), 'లక్షలు')
              .replaceAll(RegExp(r'per year|per annum|p\.a\.', caseSensitive: false), 'సంవత్సరానికి');
          return result;
        case 'Kannada':
          result = result
              .replaceAll(RegExp(r'Lakhs?', caseSensitive: false), 'ಲಕ್ಷ')
              .replaceAll(RegExp(r'per year|per annum|p\.a\.', caseSensitive: false), 'ವರ್ಷಕ್ಕೆ');
          return result;
      }
    }

    // 6. Time formatting (e.g. "06:30 AM" or "02:15 PM")
    if (trimmed.toUpperCase().endsWith('AM') || trimmed.toUpperCase().endsWith('PM')) {
      final isAM = trimmed.toUpperCase().endsWith('AM');
      final timeDigits = trimmed.replaceAll(RegExp(r'[a-zA-Z\s]'), '');
      switch (language) {
        case 'Marathi':
          return isAM ? 'सकाळी $timeDigits' : 'दुपारी $timeDigits';
        case 'Hindi':
          return isAM ? 'सुबह $timeDigits' : 'दोपहर $timeDigits';
        case 'Telugu':
          return isAM ? 'ఉదయం $timeDigits' : 'మధ్యాహ్నం $timeDigits';
        case 'Kannada':
          return isAM ? 'ಬೆಳಿಗ್ಗೆ $timeDigits' : 'ಮಧ್ಯಾಹ್ನ $timeDigits';
      }
    }

    // 7. Sibling formatting (e.g. "1 Brother (Married)" or "0" or "None")
    if (trimmed == '0' || trimmed.toLowerCase() == 'none' || trimmed.toLowerCase() == 'no') {
      switch (language) {
        case 'Marathi':
          return 'कोणीही नाही';
        case 'Hindi':
          return 'कोई नहीं';
        case 'Telugu':
          return 'ఎవరూ లేరు';
        case 'Kannada':
          return 'ಯಾರೂ ಇಲ್ಲ';
      }
    }

    // 8. If the text still contains English alphabetic words (such as Candidate Name,
    // Father Name, Mother Name, Native Places, custom remarks),
    // phonetically transliterate into the target script (Devanagari / Telugu / Kannada)
    if (RegExp(r'[a-zA-Z]').hasMatch(trimmed) &&
        !trimmed.startsWith('http') &&
        !trimmed.contains('@')) {
      return IndicTransliterator.transliterate(trimmed, language);
    }

    // Fallback: return original string if no translation rule matches
    return trimmed;
  }

  /// Maps language code or name to standard language name
  static String fromLocale(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'mr':
      case 'marathi':
        return 'Marathi';
      case 'hi':
      case 'hindi':
        return 'Hindi';
      case 'te':
      case 'telugu':
        return 'Telugu';
      case 'kn':
      case 'kannada':
        return 'Kannada';
      default:
        return 'English';
    }
  }

  /// Maps standard language name to ISO code
  static String toLocaleCode(String languageName) {
    switch (languageName.toLowerCase()) {
      case 'marathi':
        return 'mr';
      case 'hindi':
        return 'hi';
      case 'telugu':
        return 'te';
      case 'kannada':
        return 'kn';
      default:
        return 'en';
    }
  }
}
