// Security Vulnerability Analysis Script
const fs = require('fs').promises;
const path = require('path');

class VulnerabilityAnalyzer {
    constructor() {
        this.vulnerabilities = [];
        this.recommendations = [];
    }

    async analyzeCodeFile(filePath) {
        try {
            const content = await fs.readFile(filePath, 'utf8');
            const vulnerabilities = this.findVulnerabilities(content, filePath);
            this.vulnerabilities.push(...vulnerabilities);
            return vulnerabilities;
        } catch (error) {
            console.error(`Error analyzing ${filePath}:`, error.message);
            return [];
        }
    }

    findVulnerabilities(code, filePath) {
        const vulnerabilities = [];
        const lines = code.split('\n');

        lines.forEach((line, index) => {
            const lineNumber = index + 1;
            
            // Check for hardcoded secrets
            if (this.hasHardcodedSecrets(line)) {
                vulnerabilities.push({
                    file: filePath,
                    line: lineNumber,
                    type: 'Hardcoded Secret',
                    severity: 'HIGH',
                    description: 'Hardcoded secret or credential found',
                    recommendation: 'Use environment variables or AWS Secrets Manager'
                });
            }

            // Check for SQL injection vulnerabilities
            if (this.hasSQLInjection(line)) {
                vulnerabilities.push({
                    file: filePath,
                    line: lineNumber,
                    type: 'SQL Injection',
                    severity: 'CRITICAL',
                    description: 'Potential SQL injection vulnerability',
                    recommendation: 'Use parameterized queries or prepared statements'
                });
            }

            // Check for XSS vulnerabilities
            if (this.hasXSSVulnerability(line)) {
                vulnerabilities.push({
                    file: filePath,
                    line: lineNumber,
                    type: 'Cross-Site Scripting (XSS)',
                    severity: 'HIGH',
                    description: 'Potential XSS vulnerability',
                    recommendation: 'Sanitize and validate user input'
                });
            }

            // Check for insecure random number generation
            if (this.hasInsecureRandom(line)) {
                vulnerabilities.push({
                    file: filePath,
                    line: lineNumber,
                    type: 'Insecure Random',
                    severity: 'MEDIUM',
                    description: 'Insecure random number generation',
                    recommendation: 'Use crypto.randomBytes() or crypto.randomUUID()'
                });
            }

            // Check for missing input validation
            if (this.hasMissingValidation(line)) {
                vulnerabilities.push({
                    file: filePath,
                    line: lineNumber,
                    type: 'Missing Input Validation',
                    severity: 'MEDIUM',
                    description: 'Missing input validation',
                    recommendation: 'Add proper input validation and sanitization'
                });
            }

            // Check for insecure HTTP usage
            if (this.hasInsecureHTTP(line)) {
                vulnerabilities.push({
                    file: filePath,
                    line: lineNumber,
                    type: 'Insecure HTTP',
                    severity: 'MEDIUM',
                    description: 'Insecure HTTP connection',
                    recommendation: 'Use HTTPS for all communications'
                });
            }

            // Check for weak encryption
            if (this.hasWeakEncryption(line)) {
                vulnerabilities.push({
                    file: filePath,
                    line: lineNumber,
                    type: 'Weak Encryption',
                    severity: 'HIGH',
                    description: 'Weak or deprecated encryption method',
                    recommendation: 'Use strong encryption algorithms (AES-256, RSA-2048+)'
                });
            }
        });

        return vulnerabilities;
    }

    hasHardcodedSecrets(line) {
        const secretPatterns = [
            /password\s*=\s*['"][^'"]+['"]/i,
            /secret\s*=\s*['"][^'"]+['"]/i,
            /key\s*=\s*['"][^'"]+['"]/i,
            /token\s*=\s*['"][^'"]+['"]/i,
            /api_key\s*=\s*['"][^'"]+['"]/i,
            /access_key\s*=\s*['"][^'"]+['"]/i,
            /AKIA[0-9A-Z]{16}/, // AWS Access Key pattern
            /[a-zA-Z0-9+/]{40}/ // Generic base64 pattern
        ];
        return secretPatterns.some(pattern => pattern.test(line));
    }

    hasSQLInjection(line) {
        const sqlPatterns = [
            /SELECT.*\+.*['"]/i,
            /INSERT.*\+.*['"]/i,
            /UPDATE.*\+.*['"]/i,
            /DELETE.*\+.*['"]/i,
            /\$\{.*\}.*SELECT/i,
            /\$\{.*\}.*INSERT/i,
            /\$\{.*\}.*UPDATE/i,
            /\$\{.*\}.*DELETE/i
        ];
        return sqlPatterns.some(pattern => pattern.test(line));
    }

    hasXSSVulnerability(line) {
        const xssPatterns = [
            /innerHTML\s*=/i,
            /document\.write/i,
            /eval\s*\(/i,
            /setTimeout\s*\(.*['"]/i,
            /setInterval\s*\(.*['"]/i
        ];
        return xssPatterns.some(pattern => pattern.test(line));
    }

    hasInsecureRandom(line) {
        const insecurePatterns = [
            /Math\.random/i,
            /Date\.now/i
        ];
        return insecurePatterns.some(pattern => pattern.test(line));
    }

    hasMissingValidation(line) {
        const validationPatterns = [
            /req\.body\./,
            /req\.query\./,
            /req\.params\./
        ];
        return validationPatterns.some(pattern => pattern.test(line)) && 
               !line.includes('validate') && 
               !line.includes('sanitize');
    }

    hasInsecureHTTP(line) {
        return /http:\/\//.test(line) && !line.includes('localhost') && !line.includes('127.0.0.1');
    }

    hasWeakEncryption(line) {
        const weakPatterns = [
            /MD5/i,
            /SHA1/i,
            /DES/i,
            /RC4/i
        ];
        return weakPatterns.some(pattern => pattern.test(line));
    }

    async scanDirectory(directory) {
        const files = await this.getJSFiles(directory);
        console.log(`🔍 Scanning ${files.length} files in ${directory}...`);
        
        for (const file of files) {
            const vulnerabilities = await this.analyzeCodeFile(file);
            if (vulnerabilities.length > 0) {
                console.log(`  📄 ${file}: ${vulnerabilities.length} vulnerabilities found`);
            }
        }
    }

    async getJSFiles(directory) {
        const files = [];
        try {
            const entries = await fs.readdir(directory, { withFileTypes: true });
            
            for (const entry of entries) {
                const fullPath = path.join(directory, entry.name);
                
                if (entry.isDirectory() && !entry.name.startsWith('.') && entry.name !== 'node_modules') {
                    const subFiles = await this.getJSFiles(fullPath);
                    files.push(...subFiles);
                } else if (entry.isFile() && (entry.name.endsWith('.js') || entry.name.endsWith('.ts'))) {
                    files.push(fullPath);
                }
            }
        } catch (error) {
            console.error(`Error reading directory ${directory}:`, error.message);
        }
        
        return files;
    }

    generateReport() {
        const report = {
            timestamp: new Date().toISOString(),
            totalVulnerabilities: this.vulnerabilities.length,
            vulnerabilitiesByType: this.groupByType(),
            vulnerabilitiesBySeverity: this.groupBySeverity(),
            vulnerabilities: this.vulnerabilities,
            recommendations: this.generateRecommendations()
        };

        return report;
    }

    groupByType() {
        const groups = {};
        this.vulnerabilities.forEach(vuln => {
            groups[vuln.type] = (groups[vuln.type] || 0) + 1;
        });
        return groups;
    }

    groupBySeverity() {
        const groups = {};
        this.vulnerabilities.forEach(vuln => {
            groups[vuln.severity] = (groups[vuln.severity] || 0) + 1;
        });
        return groups;
    }

    generateRecommendations() {
        const recommendations = [
            'Implement proper input validation and sanitization',
            'Use environment variables for all secrets and credentials',
            'Replace hardcoded secrets with AWS Secrets Manager',
            'Use parameterized queries to prevent SQL injection',
            'Implement proper error handling without information disclosure',
            'Use HTTPS for all external communications',
            'Replace weak encryption with strong algorithms',
            'Implement proper authentication and authorization',
            'Add security headers to all HTTP responses',
            'Regular security code reviews and testing'
        ];
        return recommendations;
    }
}

// Main execution
async function main() {
    console.log('🔒 Security Vulnerability Analysis');
    console.log('===================================\n');

    const analyzer = new VulnerabilityAnalyzer();

    // Scan different directories
    const directories = [
        'microservices',
        'scripts',
        'security'
    ];

    for (const directory of directories) {
        try {
            await analyzer.scanDirectory(directory);
        } catch (error) {
            console.log(`⚠️  Could not scan ${directory}: ${error.message}`);
        }
    }

    // Generate and display report
    const report = analyzer.generateReport();
    
    console.log('\n📊 VULNERABILITY SUMMARY');
    console.log('========================');
    console.log(`Total Vulnerabilities: ${report.totalVulnerabilities}`);
    console.log('\nBy Type:');
    Object.entries(report.vulnerabilitiesByType).forEach(([type, count]) => {
        console.log(`  ${type}: ${count}`);
    });
    
    console.log('\nBy Severity:');
    Object.entries(report.vulnerabilitiesBySeverity).forEach(([severity, count]) => {
        console.log(`  ${severity}: ${count}`);
    });

    if (report.vulnerabilities.length > 0) {
        console.log('\n🚨 DETAILED FINDINGS');
        console.log('===================');
        
        report.vulnerabilities.forEach((vuln, index) => {
            console.log(`\n${index + 1}. ${vuln.type} (${vuln.severity})`);
            console.log(`   File: ${vuln.file}`);
            console.log(`   Line: ${vuln.line}`);
            console.log(`   Description: ${vuln.description}`);
            console.log(`   Recommendation: ${vuln.recommendation}`);
        });
    }

    console.log('\n💡 RECOMMENDATIONS');
    console.log('==================');
    report.recommendations.forEach((rec, index) => {
        console.log(`${index + 1}. ${rec}`);
    });

    // Save report
    const reportPath = 'security-reports/vulnerability-analysis.json';
    await fs.writeFile(reportPath, JSON.stringify(report, null, 2));
    console.log(`\n📄 Detailed report saved to: ${reportPath}`);
}

// Run the analysis
main().catch(console.error);
