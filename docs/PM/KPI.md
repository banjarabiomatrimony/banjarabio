# Key Performance Indicators (KPIs)

## 📌 Term Explanation: What is a KPI?
A **Key Performance Indicator (KPI)** is a quantifiable metric used to evaluate the success of an organization, product, feature, or team in meeting critical operational and strategic goals. Unlike general metrics, KPIs are carefully selected to provide direct feedback on performance.

---

# Case Study: BanjaraMatch KPI Dashboard

| Domain | Matrimony Mobile App |
| :--- | :--- |
| **Tracking Cycle** | Weekly / Monthly |
| **Data Sources** | Supabase Analytics, Firebase Crashlytics, Local Logs |

---

## 1. Product Engagement & Quality KPIs

### 📊 DAU/MAU Ratio (Stickiness)
* **What it measures**: The percentage of monthly active users who open the app daily.
* **Target**: **> 45%** (Matrimony apps usually have low stickiness, but our 7-Day Rewards Ladder aims to change this).
* **Formula**: `(Daily Active Users / Monthly Active Users) * 100`

### 📊 Match Conversion Rate (MCR)
* **What it measures**: The efficiency of our matchmaking algorithms.
* **Target**: **15%** of all discovery feed swipes result in a mutual connection.
* **Formula**: `(Mutual Matches / Total Active Profiles) * 100`

### 📊 Audio-First Profile Completion Rate
* **What it measures**: Percentage of new users who upload both a photo and record a voice profile greeting.
* **Target**: **70%** of signups.

---

## 2. Technical Performance & Stability KPIs

### 📊 ANR (Application Not Responding) Rate
* **What it measures**: Frequency of main-thread blocks.
* **Target**: **0.00%** on production releases (monitored via `GlobalWatchdog`).
* **Formula**: `(App sessions experiencing ANR / Total App sessions) * 100`

### 📊 Image Cache Hit Rate (ICHR)
* **What it measures**: Local storage efficiency. By utilizing persistent app document caching instead of repeating network calls to Supabase, we save egress costs and boost scroll speed.
* **Target**: **> 90%** of image requests resolved from local storage.
* **Formula**: `(Local Cache Reads / Total Photo Views) * 100`

---

## 3. Business & Monetization KPIs

### 📊 Customer Acquisition Cost (CAC) vs. Lifetime Value (LTV)
* **What it measures**: Financial sustainability of customer acquisition.
* **Target**: **LTV:CAC Ratio > 4:1**.
* **Goal**: Keep CAC < ₹100 ($1.20) via offline Tanda networks and in-app referrals.

### 📊 Checkout Success Rate
* **What it measures**: Reliability of payment gateways (Razorpay).
* **Target**: **> 95%**.
* **Formula**: `(Successful Razorpay transactions / Initiated checkout sessions) * 100`
