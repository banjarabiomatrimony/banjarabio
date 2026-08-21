/// High-performance Phonetic Transliteration Engine from English (Latin) to Indic Scripts
/// (Devanagari for Marathi/Hindi, Telugu script, Kannada script).
class IndicTransliterator {
  /// Transliterate an English sentence or phrase into the target language script.
  static String transliterate(String text, String language) {
    if (text.isEmpty || language == 'English') return text;

    final script = _getScript(language);
    if (script == null) return text;

    // Split text into tokens while preserving whitespace, punctuation, numbers, and URLs
    final tokenRegex = RegExp(r'([a-zA-Z]+|[^a-zA-Z]+)');
    final matches = tokenRegex.allMatches(text);

    final sb = StringBuffer();
    for (final match in matches) {
      final token = match.group(0)!;
      // If it's a word (letters only) and not a URL/email, transliterate it
      if (RegExp(r'^[a-zA-Z]+$').hasMatch(token)) {
        sb.write(_transliterateWord(token, script));
      } else {
        sb.write(token);
      }
    }

    return sb.toString();
  }

  static _ScriptConfig? _getScript(String language) {
    switch (language.toLowerCase()) {
      case 'marathi':
        return _devanagariMarathi;
      case 'hindi':
        return _devanagariHindi;
      case 'telugu':
        return _telugu;
      case 'kannada':
        return _kannada;
      default:
        return null;
    }
  }

  /// Internal word transliteration logic using longest-prefix greedy matching
  static String _transliterateWord(String rawWord, _ScriptConfig script) {
    final word = rawWord.toLowerCase();
    if (word.isEmpty) return rawWord;

    // Check custom overrides dictionary first (common Indian names & prefixes)
    if (script.commonOverrides.containsKey(word)) {
      return script.commonOverrides[word]!;
    }

    final sb = StringBuffer();
    int i = 0;
    final len = word.length;
    bool previousWasConsonant = false;

    while (i < len) {
      // 1. Check for nasal conjunct shortcut like "nt", "nd", "nk", "mp", "mb"
      // e.g. "banti" -> "b" + "a" + "n" + "t" + "i" -> "बं" + "टी"
      if (i > 0 &&
          (word[i] == 'n' || word[i] == 'm') &&
          (i + 1 < len) &&
          !_isVowel(word[i + 1])) {
        // If preceded by consonant without explicit vowel, or after 'a'
        final nextChar = word[i + 1];
        if (['t', 'd', 'k', 'g', 'p', 'b', 'ch', 'j', 's', 'sh'].contains(nextChar) ||
            (i + 2 <= len && ['th', 'dh', 'kh', 'gh', 'ph', 'bh', 'ch', 'jh', 'sh'].contains(word.substring(i + 1, i + 2.clamp(0, len))))) {
          sb.write(script.anusvara);
          previousWasConsonant = false;
          i++;
          continue;
        }
      }

      // 2. Try matching multi-char consonants (3 chars, then 2 chars, then 1 char)
      String? matchedConsonant;
      int matchedConsonantLen = 0;

      for (int matchLen = 3; matchLen >= 1; matchLen--) {
        if (i + matchLen <= len) {
          final sub = word.substring(i, i + matchLen);
          if (script.consonants.containsKey(sub)) {
            matchedConsonant = script.consonants[sub];
            matchedConsonantLen = matchLen;
            break;
          }
        }
      }

      if (matchedConsonant != null) {
        if (previousWasConsonant) {
          // Virama / Halant joining previous consonant
          sb.write(script.virama);
        }
        sb.write(matchedConsonant);
        previousWasConsonant = true;
        i += matchedConsonantLen;
        continue;
      }

      // 3. Try matching multi-char vowels (3 chars, then 2 chars, then 1 char)
      String? matchedVowelMatra;
      String? matchedVowelInitial;
      int matchedVowelLen = 0;

      for (int matchLen = 3; matchLen >= 1; matchLen--) {
        if (i + matchLen <= len) {
          final sub = word.substring(i, i + matchLen);
          if (script.vowels.containsKey(sub)) {
            matchedVowelMatra = script.vowels[sub]!.matra;
            matchedVowelInitial = script.vowels[sub]!.initial;
            matchedVowelLen = matchLen;
            break;
          }
        }
      }

      if (matchedVowelMatra != null && matchedVowelInitial != null) {
        if (previousWasConsonant) {
          // Apply matra to preceding consonant
          sb.write(matchedVowelMatra);
        } else {
          // Standalone initial vowel
          sb.write(matchedVowelInitial);
        }
        previousWasConsonant = false;
        i += matchedVowelLen;
        continue;
      }

      // 4. Character not mapped directly, append as-is
      sb.write(word[i]);
      previousWasConsonant = false;
      i++;
    }

    return sb.toString();
  }

  static bool _isVowel(String char) {
    return ['a', 'e', 'i', 'o', 'u'].contains(char);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCRIPT DEFINITIONS
  // ═════════════════════════════════════════════════════════════════════════

  // 1. DEVANAGARI (MARATHI)
  static const _ScriptConfig _devanagariMarathi = _ScriptConfig(
    virama: '्',
    anusvara: 'ं',
    commonOverrides: {
      // Names & Banjara Gotras
      'banti': 'बंटी',
      'bunty': 'बंटी',
      'rathod': 'राठोड',
      'pawar': 'पवार',
      'chavan': 'चव्हाण',
      'jadhav': 'जाधव',
      'ade': 'आडे',
      'banoth': 'बानोत',
      'bhukya': 'भुक्या',
      'guguloth': 'गुगुलोत',
      'korra': 'कोर्रा',
      'nayak': 'नायक',
      'ramesh': 'रमेश',
      'suresh': 'सुरेश',
      'ganesh': 'गणेश',
      'kavita': 'कविता',
      'sunita': 'सुनीता',
      'sneha': 'स्नेहा',
      'rahul': 'राहुल',
      'pooja': 'पूजा',
      'puja': 'पूजा',
      'santosh': 'संतोष',
      'prakash': 'प्रकाश',
      'vikram': 'विक्रम',
      'anil': 'अनिल',
      'vijay': 'विजय',
      'mahesh': 'महेश',
      'ashok': 'अशोक',
      'kiran': 'किरण',
      'deepak': 'दीपक',
      'rajesh': 'राजेश',
      'amit': 'अमित',
      'nitin': 'नितीन',
      'sachin': 'सचिन',
      'akash': 'आकाश',
      'nisha': 'निशा',
      'neha': 'नेहा',
      'divya': 'दिव्या',
      'anjali': 'अंजली',
      'rani': 'राणी',
      'lakshmi': 'लक्ष्मी',
      'laxmi': 'लक्ष्मी',
      'radha': 'राधा',
      'gayatri': 'गायत्री',
      'sharda': 'शारदा',
      'geeta': 'गीता',
      'gita': 'गीता',
      'seema': 'सीमा',
      'sima': 'सीमा',
      'rekha': 'रेखा',
      'meena': 'मीना',
      'mina': 'मीना',
      'tanda': 'तांडा',
      'sevalal': 'सेवालाल',
      // Partner Expectations & About Me Vocabulary
      'educated': 'सुशिक्षित',
      'well': 'सु',
      'family': 'कुटुंब',
      'partner': 'जोडीदार',
      'looking': 'अपेक्षा',
      'vegetarian': 'शाकाहारी',
      'nonveg': 'मांसाहारी',
      'caring': 'काळजीवाहू',
      'simple': 'साधे',
      'understanding': 'समजूतदार',
      'nature': 'स्वभाव',
      'values': 'संस्कार',
      'traditional': 'पारंपरिक',
      'modern': 'आधुनिक',
      'settled': 'सुस्थितीत',
      'good': 'चांगले',
      'height': 'उंची',
      'age': 'वय',
      'engineer': 'अभियंता',
      'doctor': 'डॉक्टर',
      'teacher': 'शिक्षक',
      'business': 'व्यवसाय',
      'farmer': 'शेतकरी',
      'farming': 'शेती',
      'service': 'नोकरी',
      'job': 'नोकरी',
      'pune': 'पुणे',
      'mumbai': 'मुंबई',
      'hyderabad': 'हैदराबाद',
      'bangalore': 'बंगळुरू',
      'nagpur': 'नागपूर',
      'yavatmal': 'यवतमाळ',
      'nanded': 'नांदेड',
      'washim': 'वाशिम',
      'hingoli': 'हिंगोली',
      'jalna': 'जालना',
      'aurangabad': 'छत्रपती संभाजीनगर',
      'beed': 'बीड',
      'latur': 'लातूर',
      'solapur': 'सोलापूर',
      'kalaburagi': 'कलबुर्गी',
      'gulbarga': 'गुलबर्गा',
      'bidar': 'बिदर',
      'yadgir': 'यादगीर',
      'raichur': 'रायचूर',
      'adilabad': 'आदिलाबाद',
      'nizamabad': 'निझामाबाद',
      'warangal': 'वारंगळ',
      'khammam': 'खम्मम',
      'mahabubnagar': 'महबूबनगर',
    },
    consonants: {
      'ksh': 'क्ष',
      'dny': 'ज्ञ',
      'jny': 'ज्ञ',
      'gy': 'ज्ञ',
      'shh': 'ष',
      'sh': 'श',
      'chh': 'छ',
      'ch': 'च',
      'kh': 'ख',
      'gh': 'घ',
      'jh': 'झ',
      'th': 'थ',
      'dh': 'ध',
      'ph': 'फ',
      'bh': 'भ',
      'k': 'क',
      'g': 'ग',
      'j': 'ज',
      'z': 'झ',
      't': 'त',
      'd': 'द',
      'n': 'न',
      'p': 'प',
      'f': 'फ',
      'b': 'ब',
      'm': 'म',
      'y': 'य',
      'r': 'र',
      'l': 'ल',
      'v': 'व',
      'w': 'व',
      's': 'स',
      'h': 'ह',
    },
    vowels: {
      'aa': _VowelPair('आ', 'ा'),
      'ee': _VowelPair('ई', 'ी'),
      'ii': _VowelPair('ई', 'ी'),
      'oo': _VowelPair('ऊ', 'ू'),
      'uu': _VowelPair('ऊ', 'ू'),
      'ai': _VowelPair('ऐ', 'ै'),
      'au': _VowelPair('औ', 'ौ'),
      'ou': _VowelPair('औ', 'ौ'),
      'a': _VowelPair('अ', ''),
      'i': _VowelPair('इ', 'ि'),
      'u': _VowelPair('उ', 'ु'),
      'e': _VowelPair('ए', 'े'),
      'o': _VowelPair('ओ', 'ो'),
    },
  );

  // 2. DEVANAGARI (HINDI)
  static const _ScriptConfig _devanagariHindi = _ScriptConfig(
    virama: '्',
    anusvara: 'ं',
    commonOverrides: {
      // Names & Banjara Gotras
      'banti': 'बंटी',
      'bunty': 'बंटी',
      'rathod': 'राठौड़',
      'pawar': 'पवार',
      'chavan': 'चव्हाण',
      'jadhav': 'जाधव',
      'ade': 'आडे',
      'banoth': 'बानोत',
      'bhukya': 'भुक्या',
      'guguloth': 'गुगुलोत',
      'korra': 'कोर्रा',
      'nayak': 'नायक',
      'ramesh': 'रमेश',
      'suresh': 'सुरेश',
      'ganesh': 'गणेश',
      'kavita': 'कविता',
      'sunita': 'सुनीता',
      'sneha': 'स्नेहा',
      'rahul': 'राहुल',
      'pooja': 'पूजा',
      'puja': 'पूजा',
      'santosh': 'संतोष',
      'prakash': 'प्रकाश',
      'vikram': 'विक्रम',
      'anil': 'अनिल',
      'vijay': 'विजय',
      'mahesh': 'महेश',
      'ashok': 'अशोक',
      'kiran': 'किरण',
      'deepak': 'दीपक',
      'rajesh': 'राजेश',
      'amit': 'अमित',
      'nitin': 'नितिन',
      'sachin': 'सचिन',
      'akash': 'आकाश',
      'nisha': 'निशा',
      'neha': 'नेहा',
      'divya': 'दिव्या',
      'anjali': 'अंजलि',
      'rani': 'रानी',
      'lakshmi': 'लक्ष्मी',
      'laxmi': 'लक्ष्मी',
      'radha': 'राधा',
      'gayatri': 'गायत्री',
      'sharda': 'शारदा',
      'geeta': 'गीता',
      'gita': 'गीता',
      'seema': 'सीमा',
      'sima': 'सीमा',
      'rekha': 'रेखा',
      'meena': 'मीना',
      'mina': 'मीना',
      'tanda': 'टांडा',
      'sevalal': 'सेवालाल',
      // Partner Expectations & About Me Vocabulary
      'educated': 'सुशिक्षित',
      'well': 'सु',
      'family': 'परिवार',
      'partner': 'जीवनसाथी',
      'looking': 'अपेक्षा',
      'vegetarian': 'शाकाहारी',
      'nonveg': 'मांसाहारी',
      'caring': 'परवाह करने वाला',
      'simple': 'सरल',
      'understanding': 'समझदार',
      'nature': 'स्वभाव',
      'values': 'संस्कार',
      'traditional': 'पारंपरिक',
      'modern': 'आधुनिक',
      'settled': 'सुव्यवस्थित',
      'good': 'अच्छा',
      'height': 'लंबाई',
      'age': 'आयु',
      'engineer': 'इंजीनियर',
      'doctor': 'डॉक्टर',
      'teacher': 'शिक्षक',
      'business': 'व्यवसाय',
      'farmer': 'किसान',
      'farming': 'कृषि',
      'service': 'नौकरी',
      'job': 'नौकरी',
      'pune': 'पुणे',
      'mumbai': 'मुंबई',
      'hyderabad': 'हैदराबाद',
      'bangalore': 'बेंगलुरु',
      'nagpur': 'नागपुर',
      'yavatmal': 'यवतमाल',
      'nanded': 'नांदेड़',
      'washim': 'वाशिम',
      'hingoli': 'हिंगोली',
      'jalna': 'जालना',
      'aurangabad': 'औरंगाबाद',
      'beed': 'बीड',
      'latur': 'लातूर',
      'solapur': 'सोलापुर',
      'kalaburagi': 'कलबुर्गी',
      'gulbarga': 'गुलबर्गा',
      'bidar': 'बीदर',
      'yadgir': 'यादगीर',
      'raichur': 'रायचूर',
      'adilabad': 'आदिलाबाद',
      'nizamabad': 'निजामाबाद',
      'warangal': 'वारंगल',
      'khammam': 'खम्मम',
      'mahabubnagar': 'महबूबनगर',
    },
    consonants: {
      'ksh': 'क्ष',
      'dny': 'ज्ञ',
      'jny': 'ज्ञ',
      'gy': 'ज्ञ',
      'shh': 'ष',
      'sh': 'श',
      'chh': 'छ',
      'ch': 'च',
      'kh': 'ख',
      'gh': 'घ',
      'jh': 'झ',
      'th': 'थ',
      'dh': 'ध',
      'ph': 'फ',
      'bh': 'भ',
      'k': 'क',
      'g': 'ग',
      'j': 'ज',
      'z': 'झ',
      't': 'त',
      'd': 'द',
      'n': 'न',
      'p': 'प',
      'f': 'फ',
      'b': 'ब',
      'm': 'म',
      'y': 'य',
      'r': 'र',
      'l': 'ल',
      'v': 'व',
      'w': 'व',
      's': 'स',
      'h': 'ह',
    },
    vowels: {
      'aa': _VowelPair('आ', 'ा'),
      'ee': _VowelPair('ई', 'ी'),
      'ii': _VowelPair('ई', 'ी'),
      'oo': _VowelPair('ऊ', 'ू'),
      'uu': _VowelPair('ऊ', 'ू'),
      'ai': _VowelPair('ऐ', 'ै'),
      'au': _VowelPair('औ', 'ौ'),
      'ou': _VowelPair('औ', 'ौ'),
      'a': _VowelPair('अ', ''),
      'i': _VowelPair('इ', 'ि'),
      'u': _VowelPair('उ', 'ु'),
      'e': _VowelPair('ए', 'े'),
      'o': _VowelPair('ओ', 'ो'),
    },
  );

  // 3. TELUGU SCRIPT
  static const _ScriptConfig _telugu = _ScriptConfig(
    virama: '్',
    anusvara: 'ం',
    commonOverrides: {
      // Names & Banjara Gotras
      'banti': 'బంటీ',
      'bunty': 'బంటీ',
      'rathod': 'రాథోడ్',
      'pawar': 'పవార్',
      'chavan': 'చవాన్',
      'jadhav': 'జాదవ్',
      'ade': 'ఆడే',
      'banoth': 'బానోత్',
      'bhukya': 'భుక్యా',
      'guguloth': 'గుగులోత్',
      'korra': 'కొర్రా',
      'nayak': 'నాయక్',
      'ramesh': 'రమేష్',
      'suresh': 'సురేష్',
      'ganesh': 'గణేష్',
      'kavita': 'కవిత',
      'sunita': 'సునీత',
      'sneha': 'స్నేహ',
      'rahul': 'రాహుల్',
      'pooja': 'పూజ',
      'puja': 'పూజ',
      'santosh': 'సంతోష్',
      'prakash': 'ప్రకాష్',
      'vikram': 'విక్రమ్',
      'anil': 'అనిల్',
      'vijay': 'విజయ్',
      'mahesh': 'మహేష్',
      'ashok': 'అశోక్',
      'kiran': 'కిరణ్',
      'deepak': 'దీపక్',
      'rajesh': 'రాజేష్',
      'amit': 'అమిత్',
      'nitin': 'నితిన్',
      'sachin': 'సచిన్',
      'akash': 'ఆకాష్',
      'nisha': 'నిషా',
      'neha': 'నేహా',
      'divya': 'దివ్య',
      'anjali': 'అంజలి',
      'rani': 'రాణి',
      'lakshmi': 'లక్ష్మి',
      'laxmi': 'లక్ష్మి',
      'radha': 'రాధ',
      'gayatri': 'గాయత్రి',
      'sharda': 'శారద',
      'geeta': 'గీత',
      'gita': 'గీత',
      'seema': 'సీమ',
      'sima': 'సీమ',
      'rekha': 'రేఖ',
      'meena': 'మీనా',
      'mina': 'మీనా',
      'tanda': 'తండా',
      'sevalal': 'సేవాలాల్',
      // Partner Expectations & About Me Vocabulary
      'educated': 'సుశిక్షితులు',
      'family': 'కుటుంబం',
      'partner': 'జీవిత భాగస్వామి',
      'looking': 'కోరుకుంటున్నారు',
      'vegetarian': 'శాకాహారి',
      'nonveg': 'మాంసాహారి',
      'caring': 'శ్రద్ధగల',
      'simple': 'సాదాసీదా',
      'understanding': 'అర్థం చేసుకునే',
      'nature': 'స్వభావం',
      'values': 'విలువలు',
      'traditional': 'సాంప్రదాయ',
      'modern': 'ఆధునిక',
      'settled': 'స్థిరపడిన',
      'good': 'మంచి',
      'height': 'ఎత్తు',
      'age': 'వయస్సు',
      'engineer': 'ఇంజనీర్',
      'doctor': 'డాక్టర్',
      'teacher': 'ఉపాధ్యాయుడు',
      'business': 'వ్యాపారం',
      'farmer': 'రైతు',
      'farming': 'వ్యవసాయం',
      'service': 'ఉద్యోగం',
      'job': 'ఉద్యోగం',
      'hyderabad': 'హైదరాబాద్',
      'bangalore': 'బెంగళూరు',
      'pune': 'పుణే',
      'mumbai': 'ముంబై',
      'warangal': 'వరంగల్',
      'nizamabad': 'నిజామాబాద్',
      'karimnagar': 'కరీంనగర్',
      'khammam': 'ఖమ్మం',
      'mahabubnagar': 'మహబూబ్‌నగర్',
      'nalgonda': 'నల్గొండ',
      'adilabad': 'ఆదిలాబాద్',
    },
    consonants: {
      'ksh': 'క్ష',
      'dny': 'జ్ఞ',
      'jny': 'జ్ఞ',
      'gy': 'జ్ఞ',
      'shh': 'ష',
      'sh': 'శ',
      'chh': 'ఛ',
      'ch': 'చ',
      'kh': 'ఖ',
      'gh': 'ఘ',
      'jh': 'ఝ',
      'th': 'థ',
      'dh': 'ధ',
      'ph': 'ఫ',
      'bh': 'భ',
      'k': 'క',
      'g': 'గ',
      'j': 'జ',
      'z': 'ఝ',
      't': 'త',
      'd': 'ద',
      'n': 'న',
      'p': 'ప',
      'f': 'ఫ',
      'b': 'బ',
      'm': 'మ',
      'y': 'య',
      'r': 'ర',
      'l': 'ల',
      'v': 'వ',
      'w': 'వ',
      's': 'స',
      'h': 'హ',
    },
    vowels: {
      'aa': _VowelPair('ఆ', 'ా'),
      'ee': _VowelPair('ఈ', 'ీ'),
      'ii': _VowelPair('ఈ', 'ీ'),
      'oo': _VowelPair('ఊ', 'ూ'),
      'uu': _VowelPair('ఊ', 'ూ'),
      'ai': _VowelPair('ఐ', 'ై'),
      'au': _VowelPair('ఔ', 'ౌ'),
      'ou': _VowelPair('ఔ', 'ౌ'),
      'a': _VowelPair('అ', ''),
      'i': _VowelPair('ఇ', 'ి'),
      'u': _VowelPair('ఉ', 'ు'),
      'e': _VowelPair('ఏ', 'ే'),
      'o': _VowelPair('ఓ', 'ో'),
    },
  );

  // 4. KANNADA SCRIPT
  static const _ScriptConfig _kannada = _ScriptConfig(
    virama: '್',
    anusvara: 'ಂ',
    commonOverrides: {
      // Names & Banjara Gotras
      'banti': 'ಬಂಟಿ',
      'bunty': 'ಬಂಟಿ',
      'rathod': 'ರಾಥೋಡ್',
      'pawar': 'ಪವಾರ್',
      'chavan': 'ಚವಾಣ್',
      'jadhav': 'ಜಾಧವ್',
      'ade': 'ಆಡೆ',
      'banoth': 'ಬಾನೋತ್',
      'bhukya': 'ಭುಕ್ಯಾ',
      'guguloth': 'ಗುಗುಲೋತ್',
      'korra': 'ಕೊರ್ರಾ',
      'nayak': 'ನಾಯಕ್',
      'ramesh': 'ರಮೇಶ್',
      'suresh': 'ಸುರೇಶ್',
      'ganesh': 'ಗಣೇಶ್',
      'kavita': 'ಕವಿತಾ',
      'sunita': 'ಸುನೀತಾ',
      'sneha': 'ಸ್ನೇಹಾ',
      'rahul': 'ರಾಹುಲ್',
      'pooja': 'ಪೂಜಾ',
      'puja': 'ಪೂಜಾ',
      'santosh': 'ಸಂತೋಷ್',
      'prakash': 'ಪ್ರಕಾಶ್',
      'vikram': 'ವಿಕ್ರಮ್',
      'anil': 'ಅನಿಲ್',
      'vijay': 'ವಿಜಯ್',
      'mahesh': 'ಮಹೇಶ್',
      'ashok': 'ಅಶೋಕ್',
      'kiran': 'ಕಿರಣ್',
      'deepak': 'ದೀಪಕ್',
      'rajesh': 'ರಾಜೇಶ್',
      'amit': 'ಅಮಿತ್',
      'nitin': 'ನಿತಿನ್',
      'sachin': 'ಸಚಿನ್',
      'akash': 'ಆಕಾಶ್',
      'nisha': 'ನಿಶಾ',
      'neha': 'ನೇಹಾ',
      'divya': 'ದಿವ್ಯ',
      'anjali': 'ಅಂಜಲಿ',
      'rani': 'ರಾಣಿ',
      'lakshmi': 'ಲಕ್ಷ್ಮಿ',
      'laxmi': 'ಲಕ್ಷ್ಮಿ',
      'radha': 'ರಾಧಾ',
      'gayatri': 'ಗಾಯತ್ರಿ',
      'sharda': 'ಶಾರದಾ',
      'geeta': 'ಗೀತಾ',
      'gita': 'ಗೀತಾ',
      'seema': 'ಸೀಮಾ',
      'sima': 'ಸೀಮಾ',
      'rekha': 'ರೇಖಾ',
      'meena': 'ಮೀನಾ',
      'mina': 'ಮೀನಾ',
      'tanda': 'ತಾಂಡಾ',
      'sevalal': 'ಸೇವಾಲಾಲ್',
      // Partner Expectations & About Me Vocabulary
      'educated': 'ಸುಶಿಕ್ಷಿತ',
      'family': 'ಕುಟುಂಬ',
      'partner': 'ಜೀವನ ಸಂಗಾತಿ',
      'looking': 'ನಿರೀಕ್ಷೆ',
      'vegetarian': 'ಶಾಕಾಹಾರಿ',
      'nonveg': 'ಮಾಂಸಾಹಾರಿ',
      'caring': 'ಕಾಳಜಿಯುಳ್ಳ',
      'simple': 'ಸರಳ',
      'understanding': 'ತಿಳುವಳಿಕೆಯುಳ್ಳ',
      'nature': 'ಸ್ವಭಾವ',
      'values': 'ಸಂಸ್ಕಾರ',
      'traditional': 'ಸಾಂಪ್ರದಾಯಿಕ',
      'modern': 'ಆಧುನಿಕ',
      'settled': 'ಸ್ಥಿರಗೊಂಡ',
      'good': 'ಉತ್ತಮ',
      'height': 'ಎತ್ತರ',
      'age': 'ವಯಸ್ಸು',
      'engineer': 'ಎಂಜಿನಿಯರ್',
      'doctor': 'ವೈದ್ಯ',
      'teacher': 'ಶಿಕ್ಷಕ',
      'business': 'ವ್ಯಾಪಾರ',
      'farmer': 'ರೈತ',
      'farming': 'ಕೃಷಿ',
      'service': 'ಉದ್ಯೋಗ',
      'job': 'ಉದ್ಯೋಗ',
      'bangalore': 'ಬೆಂಗಳೂರು',
      'kalaburagi': 'ಕಲಬುರಗಿ',
      'gulbarga': 'ಕಲಬುರಗಿ',
      'bidar': 'ಬೀದರ್',
      'yadgir': 'ಯಾದಗಿರಿ',
      'raichur': 'ರಾಯಚೂರು',
      'bellary': 'ಬಳ್ಳಾರಿ',
      'vijayapura': 'ವಿಜಯಪುರ',
      'bijapur': 'ವಿಜಯಪುರ',
      'belagavi': 'ಬೆಳಗಾವಿ',
      'belgaum': 'ಬೆಳಗಾವಿ',
      'hubli': 'ಹುಬ್ಬಳ್ಳಿ',
      'dharwad': 'ಧಾರವಾಡ',
      'hyderabad': 'ಹೈದರಾಬಾದ್',
      'pune': 'ಪುಣೆ',
      'mumbai': 'ಮುಂಬೈ',
    },
    consonants: {
      'ksh': 'ಕ್ಷ',
      'dny': 'ಜ್ಞ',
      'jny': 'ಜ್ಞ',
      'gy': 'ಜ್ಞ',
      'shh': 'ಷ',
      'sh': 'ಶ',
      'chh': 'ಛ',
      'ch': 'ಚ',
      'kh': 'ಖ',
      'gh': 'ಘ',
      'jh': 'ಝ',
      'th': 'ಥ',
      'dh': 'ಧ',
      'ph': 'ಫ',
      'bh': 'ಭ',
      'k': 'ಕ',
      'g': 'ಗ',
      'j': 'ಜ',
      'z': 'ಝ',
      't': 'ತ',
      'd': 'ದ',
      'n': 'ನ',
      'p': 'ಪ',
      'f': 'ಫ',
      'b': 'ಬ',
      'm': 'ಮ',
      'y': 'ಯ',
      'r': 'ರ',
      'l': 'ಲ',
      'v': 'ವ',
      'w': 'ವ',
      's': 'ಸ',
      'h': 'ಹ',
    },
    vowels: {
      'aa': _VowelPair('ಆ', 'ಾ'),
      'ee': _VowelPair('ಈ', 'ೀ'),
      'ii': _VowelPair('ಈ', 'ೀ'),
      'oo': _VowelPair('ಊ', 'ೂ'),
      'uu': _VowelPair('ಊ', 'ೂ'),
      'ai': _VowelPair('ಐ', 'ೈ'),
      'au': _VowelPair('ಔ', 'ೌ'),
      'ou': _VowelPair('ಔ', 'ೌ'),
      'a': _VowelPair('ಅ', ''),
      'i': _VowelPair('ಇ', 'ಿ'),
      'u': _VowelPair('ಉ', 'ು'),
      'e': _VowelPair('ಏ', 'ೇ'),
      'o': _VowelPair('ಓ', 'ೋ'),
    },
  );
}

class _ScriptConfig {
  final String virama;
  final String anusvara;
  final Map<String, String> commonOverrides;
  final Map<String, String> consonants;
  final Map<String, _VowelPair> vowels;

  const _ScriptConfig({
    required this.virama,
    required this.anusvara,
    required this.commonOverrides,
    required this.consonants,
    required this.vowels,
  });
}

class _VowelPair {
  final String initial;
  final String matra;

  const _VowelPair(this.initial, this.matra);
}
