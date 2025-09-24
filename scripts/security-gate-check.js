#!/usr/bin/env node

/**
 * 🚨 Security Gate Check
 * Validates security analysis results against configurable thresholds
 */

const fs = require('fs').promises;
const path = require('path');

class SecurityGateCheck {
    constructor(options = {}) {
        this.maxCritical = options.maxCritical || 0;
        this.maxHigh = options.maxHigh || 3;
        this.maxMedium = options.maxMedium || 10;
        this.maxLow = options.maxLow || 50;
        this.reportPath = options.reportPath;
    }

    /**
     * Check security gate criteria
     */
    async checkSecurityGate() {
        try {
            console.log('🔍 Checking security gate criteria...');
            
            // Load security report
            const report = await this.loadSecurityReport();
            
            // Count vulnerabilities by severity
            const counts = this.countVulnerabilities(report);
            
            // Check thresholds
            const gateResults = this.checkThresholds(counts);
            
            // Generate summary
            const summary = this.generateSummary(counts, gateResults);
            
            // Output results
            this.outputResults(summary, gateResults);
            
            // Set GitHub Actions output
            this.setGitHubActionsOutput(gateResults);
            
            return gateResults.passed;
            
        } catch (error) {
            console.error('❌ Error checking security gate:', error);
            throw error;
        }
    }

    /**
     * Load security report from file
     */
    async loadSecurityReport() {
        try {
            const reportContent = await fs.readFile(this.reportPath, 'utf8');
            return JSON.parse(reportContent);
        } catch (error) {
            console.error(`❌ Could not load security report from ${this.reportPath}:`, error);
            throw error;
        }
    }

    /**
     * Count vulnerabilities by severity
     */
    countVulnerabilities(report) {
        const counts = {
            critical: 0,
            high: 0,
            medium: 0,
            low: 0,
            total: 0
        };

        // Count from file analysis
        if (report.fileAnalysis) {
            report.fileAnalysis.forEach(analysis => {
                if (analysis.analysis) {
                    try {
                        const parsed = JSON.parse(analysis.analysis);
                        if (parsed.vulnerabilities) {
                            parsed.vulnerabilities.forEach(vuln => {
                                const severity = vuln.severity?.toLowerCase() || 'low';
                                if (counts[severity] !== undefined) {
                                    counts[severity]++;
                                    counts.total++;
                                }
                            });
                        }
                    } catch (e) {
                        // Handle parsing errors
                    }
                }
            });
        }

        // Count from overall analysis
        if (report.overallAnalysis) {
            try {
                const parsed = JSON.parse(report.overallAnalysis);
                if (parsed.critical_issues) counts.critical += parsed.critical_issues;
                if (parsed.high_issues) counts.high += parsed.high_issues;
                if (parsed.medium_issues) counts.medium += parsed.medium_issues;
                if (parsed.low_issues) counts.low += parsed.low_issues;
            } catch (e) {
                // Handle parsing errors
            }
        }

        return counts;
    }

    /**
     * Check thresholds against counts
     */
    checkThresholds(counts) {
        const results = {
            critical: {
                count: counts.critical,
                threshold: this.maxCritical,
                passed: counts.critical <= this.maxCritical
            },
            high: {
                count: counts.high,
                threshold: this.maxHigh,
                passed: counts.high <= this.maxHigh
            },
            medium: {
                count: counts.medium,
                threshold: this.maxMedium,
                passed: counts.medium <= this.maxMedium
            },
            low: {
                count: counts.low,
                threshold: this.maxLow,
                passed: counts.low <= this.maxLow
            }
        };

        results.passed = Object.values(results).every(result => 
            typeof result === 'object' ? result.passed : true
        );

        return results;
    }

    /**
     * Generate summary
     */
    generateSummary(counts, gateResults) {
        return {
            totalVulnerabilities: counts.total,
            severityBreakdown: {
                critical: counts.critical,
                high: counts.high,
                medium: counts.medium,
                low: counts.low
            },
            gateResults: gateResults,
            securityScore: this.calculateSecurityScore(counts),
            riskLevel: this.calculateRiskLevel(counts)
        };
    }

    /**
     * Calculate security score (0-100)
     */
    calculateSecurityScore(counts) {
        const weights = {
            critical: 40,
            high: 30,
            medium: 20,
            low: 10
        };

        const totalWeightedIssues = 
            (counts.critical * weights.critical) +
            (counts.high * weights.high) +
            (counts.medium * weights.medium) +
            (counts.low * weights.low);

        // Calculate score (higher is better, max 100)
        const maxPossibleIssues = 100; // Adjust based on project size
        const score = Math.max(0, 100 - (totalWeightedIssues / maxPossibleIssues * 100));
        
        return Math.round(score);
    }

    /**
     * Calculate risk level
     */
    calculateRiskLevel(counts) {
        if (counts.critical > 0) return 'Critical';
        if (counts.high > 3) return 'High';
        if (counts.high > 0 || counts.medium > 5) return 'Medium';
        return 'Low';
    }

    /**
     * Output results
     */
    outputResults(summary, gateResults) {
        console.log('\n🛡️ Security Gate Check Results');
        console.log('================================');
        
        console.log(`\n📊 Vulnerability Summary:`);
        console.log(`  Critical: ${summary.severityBreakdown.critical} (threshold: ${this.maxCritical}) ${gateResults.critical.passed ? '✅' : '❌'}`);
        console.log(`  High:     ${summary.severityBreakdown.high} (threshold: ${this.maxHigh}) ${gateResults.high.passed ? '✅' : '❌'}`);
        console.log(`  Medium:   ${summary.severityBreakdown.medium} (threshold: ${this.maxMedium}) ${gateResults.medium.passed ? '✅' : '❌'}`);
        console.log(`  Low:      ${summary.severityBreakdown.low} (threshold: ${this.maxLow}) ${gateResults.low.passed ? '✅' : '❌'}`);
        
        console.log(`\n📈 Security Metrics:`);
        console.log(`  Total Vulnerabilities: ${summary.totalVulnerabilities}`);
        console.log(`  Security Score: ${summary.securityScore}/100`);
        console.log(`  Risk Level: ${summary.riskLevel}`);
        
        console.log(`\n🚨 Gate Status: ${gateResults.passed ? '✅ PASSED' : '❌ FAILED'}`);
        
        if (!gateResults.passed) {
            console.log(`\n❌ Security gate failed! Issues found:`);
            if (!gateResults.critical.passed) {
                console.log(`  - Critical issues: ${gateResults.critical.count} (max allowed: ${gateResults.critical.threshold})`);
            }
            if (!gateResults.high.passed) {
                console.log(`  - High issues: ${gateResults.high.count} (max allowed: ${gateResults.high.threshold})`);
            }
            if (!gateResults.medium.passed) {
                console.log(`  - Medium issues: ${gateResults.medium.count} (max allowed: ${gateResults.medium.threshold})`);
            }
            if (!gateResults.low.passed) {
                console.log(`  - Low issues: ${gateResults.low.count} (max allowed: ${gateResults.low.threshold})`);
            }
        }
    }

    /**
     * Set GitHub Actions output
     */
    setGitHubActionsOutput(gateResults) {
        if (process.env.GITHUB_OUTPUT) {
            const output = `passed=${gateResults.passed}`;
            require('fs').appendFileSync(process.env.GITHUB_OUTPUT, output + '\n');
        }
    }
}

// CLI Interface
async function main() {
    const args = process.argv.slice(2);
    const options = {};
    
    // Parse command line arguments
    for (let i = 0; i < args.length; i++) {
        switch (args[i]) {
            case '--report':
                options.reportPath = args[++i];
                break;
            case '--max-critical':
                options.maxCritical = parseInt(args[++i]);
                break;
            case '--max-high':
                options.maxHigh = parseInt(args[++i]);
                break;
            case '--max-medium':
                options.maxMedium = parseInt(args[++i]);
                break;
            case '--max-low':
                options.maxLow = parseInt(args[++i]);
                break;
        }
    }
    
    if (!options.reportPath) {
        console.error('❌ Error: --report path is required');
        process.exit(1);
    }
    
    try {
        const gateCheck = new SecurityGateCheck(options);
        const passed = await gateCheck.checkSecurityGate();
        
        if (!passed) {
            console.log('\n🚫 Security gate failed. Please fix security issues before proceeding.');
            process.exit(1);
        } else {
            console.log('\n✅ Security gate passed. Proceeding with deployment.');
        }
        
    } catch (error) {
        console.error('❌ Security gate check failed:', error);
        process.exit(1);
    }
}

// Export for use as module
module.exports = SecurityGateCheck;

// Run if called directly
if (require.main === module) {
    main();
}
