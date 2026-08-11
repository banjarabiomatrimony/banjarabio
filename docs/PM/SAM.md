# Serviceable Addressable Market (SAM)

## 📌 Term Explanation: What is SAM?
**Serviceable Addressable Market (SAM)** is the segment of the Total Addressable Market (TAM) that fits your product's geographical reach, business model, and technological requirements. It represents the realistic portion of the market that you can target and serve with your current product capabilities and distribution channels.

---

# Case Study: Sizing BanjaraMatch's Reachable Demographic (SAM)

| Metric | Sizing Estimate |
| :--- | :--- |
| **Primary State Population** | 9.6 Million (Maharashtra, Karnataka, Telangana, AP) |
| **Connected Marriageable Cohort** | 1,250,000 (1.25 Million) |
| **Calculated SAM** | **₹75 Crore (~$9.00 Million USD) per year** |

---

## 1. Defining SAM Parameters for BanjaraMatch
While the total Banjara population is 12 million (TAM), BanjaraMatch cannot realistically reach all of them immediately due to:
1. **Geographic Focus**: Initially focusing only on the four states with high density: Maharashtra, Karnataka, Telangana, and Andhra Pradesh.
2. **Technological Barriers**: Requiring the user to have a smartphone, a stable mobile internet connection (3G/4G/5G), and access to mobile payments (UPI).

---

## 2. SAM Calculation Method

```
Total Banjara Population (12 Million)
      │
      ▼
Filter for Core States (Maharashtra, Karnataka, Telangana, AP) = 80% (9.6 Million)
      │
      ▼
Filter for Marriageable Age Group (18-32 years old) = 20% (1.92 Million)
      │
      ▼
Filter for Smartphone & Mobile Internet Users = 65% (1.25 Million)
```

With **1.25 million connected marriageable individuals** who meet the requirements to download and use the BanjaraMatch Flutter application:

$$\text{SAM} = 1,250,000 \text{ users} \times ₹600 \text{ annual spend} = ₹75 \text{ Crore} \text{ (~$9.00 Million USD)}$$

---

## 3. Business Implications of SAM
* **Product Optimization**: Since our SAM is bounded by smartphone access, we must optimize the application experience for entry-level smartphones. This includes preventing memory-related crashes, blocking ANRs, and utilizing smart local image caching.
* **Payment Integration**: The payment interface must be tailored to UPI (Google Pay, PhonePe) since credit card penetration within our SAM is `< 3%`.
