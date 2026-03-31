# Enterprise Serverless URL Shortener

A **fully serverless URL shortener** built on AWS, designed for **enterprise-grade deployments**. Users can shorten URLs, track click counts, and manage links—all **serverless**, **scalable**, and **multi-environment ready**.

---

## 🔹 Features

- **Serverless Architecture:** AWS Lambda + API Gateway handle all backend logic.  
- **DynamoDB Backend:** Stores short URLs, original URLs, and click counts.  
- **Frontend Hosting:** S3 + CloudFront for fast, global static website delivery.  
- **Multi-Environment Support:** Dev, Prod environments via Terraform variables.  
- **CI/CD Automation:** Build, package, and deploy using GitHub Actions or `deploy.sh`.  
- **Centralized Configuration:** `.env` file manages AWS keys, API URLs, and table names.  
- **Analytics Ready:** Tracks clicks per short URL with DynamoDB updates.  

---

## 🔹 What This Project Does

1. Users submit a **long URL** via the frontend or API.  
2. The **create_url Lambda** generates a unique short code and stores it in DynamoDB.  
3. The frontend or API returns the **shortened URL** (e.g., `https://yourdomain.com/abc123`).  
4. When someone visits the short URL, the **redirect_url Lambda** fetches the original URL, increments the click count, and redirects the user.  
5. Optional: Custom domains, click analytics, and multi-environment deployment.

---

## 🔹 Project Structure
```

enterprise-url-shortener/
│
├── deploy.sh           <-- auto-package & deploy script
├── terraform/          <-- Terraform infra (DynamoDB, Lambda, API, S3, CloudFront)
├── lambda/             <-- Lambda functions + requirements
├── frontend/           <-- Static website
├── .env                <-- Environment variables
├── .gitignore
└── README.md

````

---

## 🔹 Environment Configuration (`.env`)

Create a `.env` file in the project root:


# AWS
AWS_REGION=ap-south-1
AWS_ACCESS_KEY_ID=YOUR_REAL_KEY
AWS_SECRET_ACCESS_KEY=YOUR_REAL_SECRET

# Terraform
TF_VAR_project_name=enterprise-url-shortener
TF_VAR_aws_region=ap-south-1

# DynamoDB Table
TABLE_NAME=enterprise-url-shortener-table

# API Gateway Base URL
API_BASE=https://replace-with-your-api-id.execute-api.ap-south-1.amazonaws.com

# Optional
CUSTOM_DOMAIN=example.com
ENABLE_ANALYTICS=true

## 🔹 CI/CD (GitHub Actions)

1. Set GitHub repository secrets:
   - `AWS_ACCESS_KEY`
   - `AWS_SECRET_KEY`
   - `AWS_REGION`

2. Push code to the `main` branch.

3. GitHub Actions will:
   - Package Lambda functions
   - Run Terraform
   - Deploy infrastructure automatically

---

## 🔹 Architecture

```
Frontend (S3/CloudFront)
        │
        ▼
API Gateway (HTTP API)
        │
        ▼
Lambda Functions
 ┌───────────────┐  ┌───────────────┐
 │ create_url    │  │ redirect_url  │
 └───────────────┘  └───────────────┘
        │                  │
        ▼                  ▼
   DynamoDB Table (URLs & clicks)
```

* **Frontend:** Users enter URLs and receive shortened links.
* **Create Lambda:** Generates short code and stores it in DynamoDB.
* **Redirect Lambda:** Redirects users and updates click counts.
* **DynamoDB:** Central storage for URLs and analytics.
* **CloudFront:** Serves frontend globally.
* **Optional Custom Domain:** Configurable via Terraform variable.

---

## 🔹 Quick API Usage

**1. Create a Short URL**

* **Endpoint:** `POST /create`
* **Body:** JSON `{ "url": "https://example.com/long-url" }`
* **Response:**

```json
{
  "short_url": "https://yourdomain.com/abc123"
}
```

**2. Redirect to Original URL**

* **Endpoint:** `GET /{short_code}`
* **Example:** `GET /abc123` → redirects to `https://example.com/long-url`
* **Click Tracking:** DynamoDB updates `clicks` automatically.

---

## 🔹 Frontend Usage

1. Open `index.html` (served via CloudFront).
2. Enter the long URL in the input box.
3. Click **Shorten** → receives the short URL.
4. Click or share the URL → redirects to original URL.

**Example Screenshot (placeholder):**
![Frontend Screenshot](https://via.placeholder.com/600x300?text=URL+Shortener+Frontend)

---

## 🔹 Example Terraform Outputs

After deployment, Terraform will output:

```
dynamodb_table = enterprise-url-shortener-table
create_lambda  = enterprise-url-shortener-create
redirect_lambda = enterprise-url-shortener-redirect
api_url = https://xxxxxx.execute-api.ap-south-1.amazonaws.com
frontend_url = https://xxxxxx.cloudfront.net
```

---

## 🔹 Technologies Used

* AWS Lambda (Python 3.9)
* DynamoDB
* API Gateway (HTTP API)
* S3 + CloudFront
* Terraform
* GitHub Actions / CodeBuild
* Python `boto3` SDK

---

