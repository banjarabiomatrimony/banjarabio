# Proof of Concept (POC)

## 📌 Term Explanation: What is a POC?
A **Proof of Concept (POC)** is a small, experimental exercise designed to verify the technical feasibility of a feature, integration, or design pattern before committing development resources. A POC is typically "throwaway" code built to answer a single question: *"Can this technical mechanism actually work?"*

---

# Case Study: Lambadi Dialect Voice Onboarding & Local Speech-To-Text

| Version | 0.1.0 (Experimental) |
| :--- | :--- |
| **Duration** | 5-Day Sprint |
| **Primary Question** | Can a mobile-first Speech-To-Text API accurately transcribe spoken Lambadi (Banjara) dialects, or do we require manual audio review? |

---

## 1. Context & Hypothesis
BanjaraMatch targets rural communities where Lambadi (which is historically an unwritten oral language, written using Devanagari or regional scripts like Telugu/Kannada) is spoken. 

Our hypothesis was: *An off-the-shelf multilingual STT engine (like Whisper API or Google Speech-to-Text) can parse Lambadi audio sufficiently to match it against a standardized list of Gothras (caste sub-clans) and Talukas, saving our review team hundreds of hours.*

---

## 2. POC Architecture & Flow

To validate this without altering the core Flutter codebase, we created a lightweight sandbox within the repository:

```
┌────────────────────────────────────────────────────────┐
│                        POC FLOW                        │
├────────────────────────────────────────────────────────┤
│ 1. Record Audio (10s Clip)                             │
│       │                                                │
│       ▼                                                │
│ 2. Compress audio using a lightweight on-device library│
│       │                                                │
│       ▼                                                │
│ 3. Send payload to a Google Cloud Speech-to-Text wrapper│
│       │                                                │
│       ▼                                                │
│ 4. Run Levenshtein distance check on output text vs     │
│    the Gothra DB                                       │
└────────────────────────────────────────────────────────┘
```

---

## 3. POC Evaluation & Results

### The Test
We recorded 50 voice samples of different people pronouncing traditional Gothras (e.g., *Rathod, Pawar, Chauhan, Vaditya, Banoth*) in local accents under quiet and noisy environments.

### The Findings
1. **Direct Transcription Failure**: Generic STT failed to spell "Vaditya" or "Banoth" correctly, often transcribing them as random local Hindi or Marathi terms.
2. **Levenshtein Distance Mitigation**: When fuzzy matching (Levenshtein distance threshold = 3) was applied against our preloaded database of 45 Banjara Gothras, accuracy jumped to **88%**.
3. **Noisy Environment Degradation**: Under background farm/traffic noise, accuracy plummeted to **42%**.

---

## 4. Final Recommendation & Decisions
Based on the POC results:
* **Recommendation**: **Do not** build a fully automated transcription system.
* **Hybrid Pivot**: Build a hybrid model where the app auto-suggests the closest Gothra using fuzzy matching of voice files, but stores the raw audio file in Supabase Storage so matches can verify the voice clip themselves (Audio Profile feature).
* **Code Disposal**: The experimental transcription package was excluded from the main branch, leaving the main `lib/` directory clean.
