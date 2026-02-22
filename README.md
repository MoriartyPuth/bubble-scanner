# 🫧 Bubble-Scanner
**A Lightweight, High-Speed API Reconnaissance & Vulnerability Scavenger**

![Language](https://img.shields.io/badge/Language-Bash-green?style=for-the-badge&logo=gnu-bash)
![Category](https://img.shields.io/badge/Category-Threat--Hunting-blue?style=for-the-badge)
![Security](https://img.shields.io/badge/Vulnerability-Scanner-red?style=for-the-badge)

<img width="718" height="281" alt="Screenshot 2026-02-18 013405" src="https://github.com/user-attachments/assets/6f20bbc3-d4d8-43b5-a0d1-c80c52d53494" />

## 📋 Overview
`Bubble-Scanner` is a custom-engineered automation script designed for rapid attack surface discovery and proactive threat hunting. Unlike generic fuzzers, `Bubble-Scanner` is built with an **event-driven architecture** that triggers deep-scan subroutines the moment an active endpoint is discovered.

It was the primary engine used to identify a critical **PII leak** in a government-tier API, effectively automating the discovery of misconfigured endpoints that bypassed standard administrative hardening.

---

## 🛠️ Labs & Testing
This tool was used as a real-world benchmark for the:

* ✅ **[CSS-GDIN](https://github.com/MoriartyPuth/CSS-GDIN-Security-Case-Study)**.

Tested & Verified Against:

* ✅ **[TestVuln Hub](https://github.com/MoriartyPuth/SQLi-to-DB-Exfiltration-Lab)**.
* ✅ **[Pickle Rick Lab](https://github.com/MoriartyPuth/Pickle-Rick-Lab)**.
* ✅ **[N7 Lab](https://github.com/MoriartyPuth/N7-Lab)**.

---

## ⚙️ Technical Deep Dive

### 1. **The Event-Driven "Bubble-Dive" Engine**
The core logic resides in the `bubble_dive` function. When the fuzzer receives an `HTTP 200 OK` response, it immediately halts the primary fuzzing thread to execute a specialized security audit of that specific URL.

* **Logic Flow:** Path Discovery → HTTP Status Validation → Immediate Source Inspection → Vulnerability Probing.
* **Optimization:** Features a 2-second connection timeout per request to ensure the script remains performant even when encountering firewalls or latent services.

### 2. **Secret Scavenging (Regex-Based)**
The `scan_source_code` module acts as a "greedy" scraper, hunting for assignment patterns within the HTML/JavaScript source code.
* **Target Patterns:** Identifies `password=`, `api_key=`, `db_pass=`, `secret`, and `token`.
* **Preview Mode:** To maintain terminal clarity, it slices and displays the first 100 characters of a leak while logging the full string to the secure loot directory.

### 3. **RCE & SQLi Mapping**
* **Upload Vector Hunting:** The script parses the DOM specifically for `type="file"`. This automates the identification of entry points for potential Remote Code Execution (RCE) via web shell uploads.
* **SQL Injection Probing:** Implements "quick-hit" testing by injecting escape characters (`'`) into URL parameters. If the server returns database-specific syntax errors (MySQL, PostgreSQL, etc.), the URL is flagged for immediate manual verification.

---

## 📂 The "Loot" Architecture
`Bubble-Bash` automates the reporting process by creating a structured, timestamped directory (`./bubble_loot_[TIMESTAMP]`) for every session:

| File | Technical Description |
| :--- | :--- |
| `final_report.txt` | A human-readable chronological log of all successful hits and audit findings. |
| `leaked_secrets.txt` | Extracted credentials and sensitive strings identified via regex patterns. |
| `rce_targets.txt` | A prioritized list of URLs containing active file upload forms. |
| `sqli_urls.txt` | Endpoints that exhibited positive reactions to SQL injection probes. |

---

## 🚀 Getting Started

### **Installation**
Clone the repository and modify execution permissions:
```bash
git clone (https://github.com/MoriartyPuth/bubble-scanner)
cd bubble-scanner
chmod +x bubble_scanner.sh
```
### **Requirements**

- bash (Tested on Kali Linux / Ubuntu)

- curl

- dirb wordlists (Default path: /usr/share/wordlists/dirb/common.txt)

### **Usage**
To run a basic scan against a target:
```
./bubble_scanner.sh https://example-target.com
```
## ⚖️ Ethics & Disclaimer

Bubble-Scanner is intended for authorized security testing and educational purposes only. Using this tool against targets without prior written consent is illegal. The developer assumes no liability for misuse or damage caused by this program.
