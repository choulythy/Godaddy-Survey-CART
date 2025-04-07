## 🌳 Classification Tree: GoDaddy Customer Advocacy

The goal of this model is to **predict how likely a customer is to recommend GoDaddy**, using survey data from 2,006 respondents. Customers were segmented into:

- **Advocates**
- **Moderates**
- **Detractors**

---

### 🧹 Data Preprocessing

- Extracted raw data from the `"Data"` sheet in Excel.
- Selected survey questions: Q2, Q5, Q5a–Q5d, Q6, Q9, Q11–Q14, Q25.
- **Nullified** Q5a–Q5d for respondents whose website purpose wasn't "Commercial."
- Replaced coded missing values:  
  - `-7` and `-9` → `"Inapplicable"`  
  - `-8` → `"Prefer not to answer"`
- Merged numerical responses with **text labels** from the `"Values"` sheet.
- Cleaned label formatting (e.g., `(1) Yes` → `Yes`).
- Converted numeric fields to `numeric` type and categorical fields to `factors` for modeling.

---

We developed a **Classification Tree (CART)** to understand and predict advocacy behavior.

![CART Tree Visualization](https://github.com/choulythy/Godaddy-Survey-CART/blob/main/Screenshot%202025-04-07%20at%204.17.33%20in%20the%20afternoon.png)

### 🔍 Key Insights
- **Customer Care Rating** and **Website Importance** were the top predictors.
- Customers who rated **customer care as "Excellent"** and **website as "Very Important"** were highly likely to be **Advocates**.
- Customers who rated **customer care as "Fair" or "Poor"** were typically **Detractors**.

### 📊 Model Summary
- **Predicted Breakdown**:
  - Advocates: 40%
  - Moderates: 54%
  - Detractors: 7%

- **Accuracy**: 60.35%  
  *(vs. 42.39% benchmark)*

- **Sensitivity**:
  - Advocates: 65.19%
  - Moderates: 68.82%
  - Detractors: 30.14%

- **Specificity**:
  - Advocates: 75.31%
  - Moderates: 59.74%
  - Detractors: 98.17%

### 💡 Business Implications
- 🛠 **Improve Customer Care** to drive more Advocates.
- 🌐 **Website experience matters** most for those already satisfied with support.
- ⚠️ **Engage Fair/Poor rating customers** early to prevent churn.
