#!/usr/bin/env node

/**
 * 📧 Send Security Summary
 * Sends daily/weekly security summary via email or Slack
 */

const fs = require('fs').promises;
const path = require('path');

class SecuritySummarySender {
    constructor(options = {}) {
        this.recipients = options.recipients || process.env.SECURITY_TEAM_EMAIL;
        this.slackWebhook = options.slackWebhook || process.env.SLACK_WEBHOOK_URL;
        this.reportsPath = options.reportsPath || './reports';
        this.summaryType = options.summaryType || 'daily';
    }

    /**
     * Send security summary
     */
    async sendSummary() {
        try {
            console.log(`📧 Sending ${this.summaryType} security summary...`);
            
            // Load and process reports
            const summaryData = await this.generateSummaryData();
            
            // Generate summary content
            const summaryContent = this.generateSummaryContent(summaryData);
            
            // Send via configured channels
            await this.sendNotifications(summaryContent);
            
            console.log('✅ Security summary sent successfully!');
            
        } catch (error) {
            console.error('❌ Error sending security summary:', error);
            throw error;
        }
    }

    /**
     * Generate summary data from reports
     */
    async generateSummaryData() {
        const summaryData = {
            timestamp: new Date().toISOString(),
            period: this.summaryType,
            summary: {
                totalVulnerabilities: 0,
                criticalIssues: 0,
                highIssues: 0,
                mediumIssues: 0,
                lowIssues: 0,
                securityScore: 100,
                newIssues: 0,
                resolvedIssues: 0
            },
            trends: [],
            topVulnerabilities: [],
            recommendations: [],
            compliance: {}
        };

        try {
            const files = await fs.readdir(this.reportsPath);
            const reportFiles = files.filter(file => file.endsWith('.json'));

            for (const file of reportFiles) {
                const filePath = path.join(this.reportsPath, file);
                const content = await fs.readFile(filePath, 'utf8');
                
                if (file.includes('bedrock') || file.includes('security-analysis')) {
                    const bedrockData = JSON.parse(content);
                    this.processBedrockData(bedrockData, summaryData);
                } else if (file.includes('npm-audit')) {
                    const npmData = JSON.parse(content);
                    this.processNpmData(npmData, summaryData);
                } else if (file.includes('eslint')) {
                    const eslintData = JSON.parse(content);
                    this.processEslintData(eslintData, summaryData);
                } else if (file.includes('snyk')) {
                    const snykData = JSON.parse(content);
                    this.processSnykData(snykData, summaryData);
                }
            }

            // Calculate overall metrics
            summaryData.summary.securityScore = this.calculateSecurityScore(summaryData.summary);

        } catch (error) {
            console.warn('⚠️ Could not process all reports:', error.message);
        }

        return summaryData;
    }

    /**
     * Process Bedrock AI analysis data
     */
    processBedrockData(data, summaryData) {
        if (data.fileAnalysis) {
            data.fileAnalysis.forEach(analysis => {
                if (analysis.analysis) {
                    try {
                        const parsed = JSON.parse(analysis.analysis);
                        if (parsed.vulnerabilities) {
                            parsed.vulnerabilities.forEach(vuln => {
                                const severity = vuln.severity?.toLowerCase() || 'low';
                                if (summaryData.summary[`${severity}Issues`] !== undefined) {
                                    summaryData.summary[`${severity}Issues`]++;
                                    summaryData.summary.totalVulnerabilities++;
                                }
                                
                                // Add to top vulnerabilities
                                summaryData.topVulnerabilities.push({
                                    type: vuln.type,
                                    severity: vuln.severity,
                                    file: analysis.file,
                                    description: vuln.description
                                });
                            });
                        }
                    } catch (e) {
                        // Handle parsing errors
                    }
                }
            });
        }

        // Process recommendations
        if (data.recommendations) {
            summaryData.recommendations.push(...data.recommendations);
        }

        // Process compliance
        if (data.compliance) {
            Object.assign(summaryData.compliance, data.compliance);
        }
    }

    /**
     * Process npm audit data
     */
    processNpmData(data, summaryData) {
        if (data.vulnerabilities) {
            Object.values(data.vulnerabilities).forEach(vuln => {
                summaryData.summary.totalVulnerabilities++;
                const severity = vuln.severity?.toLowerCase() || 'low';
                if (summaryData.summary[`${severity}Issues`] !== undefined) {
                    summaryData.summary[`${severity}Issues`]++;
                }
            });
        }
    }

    /**
     * Process ESLint data
     */
    processEslintData(data, summaryData) {
        if (Array.isArray(data)) {
            data.forEach(file => {
                if (file.messages) {
                    file.messages.forEach(message => {
                        if (message.ruleId && message.ruleId.includes('security')) {
                            summaryData.summary.totalVulnerabilities++;
                            if (message.severity === 1) {
                                summaryData.summary.mediumIssues++;
                            } else if (message.severity === 2) {
                                summaryData.summary.lowIssues++;
                            }
                        }
                    });
                }
            });
        }
    }

    /**
     * Process Snyk data
     */
    processSnykData(data, summaryData) {
        if (data.vulnerabilities) {
            data.vulnerabilities.forEach(vuln => {
                summaryData.summary.totalVulnerabilities++;
                const severity = vuln.severity?.toLowerCase() || 'low';
                if (summaryData.summary[`${severity}Issues`] !== undefined) {
                    summaryData.summary[`${severity}Issues`]++;
                }
            });
        }
    }

    /**
     * Calculate security score
     */
    calculateSecurityScore(summary) {
        const weights = {
            critical: 40,
            high: 30,
            medium: 20,
            low: 10
        };

        const totalWeightedIssues = 
            (summary.criticalIssues * weights.critical) +
            (summary.highIssues * weights.high) +
            (summary.mediumIssues * weights.medium) +
            (summary.lowIssues * weights.low);

        const maxPossibleIssues = 100;
        const score = Math.max(0, 100 - (totalWeightedIssues / maxPossibleIssues * 100));
        
        return Math.round(score);
    }

    /**
     * Generate summary content
     */
    generateSummaryContent(summaryData) {
        const timestamp = new Date(summaryData.timestamp).toLocaleString();
        const period = summaryData.period.charAt(0).toUpperCase() + summaryData.period.slice(1);
        
        let content = `🛡️ ${period} Security Summary\n\n`;
        content += `📅 **Date:** ${timestamp}\n`;
        content += `🔍 **Analysis Period:** ${period}\n\n`;
        
        // Security Score
        const scoreEmoji = summaryData.summary.securityScore >= 90 ? '🟢' : 
                          summaryData.summary.securityScore >= 70 ? '🟡' : '🔴';
        content += `📊 **Security Score:** ${scoreEmoji} ${summaryData.summary.securityScore}/100\n\n`;
        
        // Vulnerability Summary
        content += `🚨 **Vulnerability Summary:**\n`;
        content += `• 🔴 Critical: ${summaryData.summary.criticalIssues}\n`;
        content += `• 🟠 High: ${summaryData.summary.highIssues}\n`;
        content += `• 🟡 Medium: ${summaryData.summary.mediumIssues}\n`;
        content += `• 🟢 Low: ${summaryData.summary.lowIssues}\n`;
        content += `• **Total:** ${summaryData.summary.totalVulnerabilities}\n\n`;
        
        // Top Vulnerabilities
        if (summaryData.topVulnerabilities.length > 0) {
            content += `🔍 **Top Vulnerabilities:**\n`;
            summaryData.topVulnerabilities
                .slice(0, 5)
                .forEach((vuln, index) => {
                    const severityEmoji = this.getSeverityEmoji(vuln.severity);
                    content += `${index + 1}. ${severityEmoji} ${vuln.type} in ${vuln.file}\n`;
                });
            content += `\n`;
        }
        
        // Recommendations
        if (summaryData.recommendations.length > 0) {
            content += `💡 **Priority Recommendations:**\n`;
            summaryData.recommendations
                .slice(0, 3)
                .forEach((rec, index) => {
                    content += `${index + 1}. ${rec}\n`;
                });
            content += `\n`;
        }
        
        // Compliance Status
        if (Object.keys(summaryData.compliance).length > 0) {
            content += `📜 **Compliance Status:**\n`;
            Object.entries(summaryData.compliance).forEach(([framework, status]) => {
                const statusEmoji = this.getComplianceEmoji(status);
                content += `• ${framework.toUpperCase()}: ${statusEmoji} ${status}\n`;
            });
            content += `\n`;
        }
        
        // Action Required
        if (summaryData.summary.criticalIssues > 0) {
            content += `🚨 **IMMEDIATE ACTION REQUIRED:**\n`;
            content += `${summaryData.summary.criticalIssues} critical security issues need immediate attention!\n\n`;
        } else if (summaryData.summary.highIssues > 0) {
            content += `⚠️ **HIGH PRIORITY:**\n`;
            content += `${summaryData.summary.highIssues} high-priority issues should be addressed soon.\n\n`;
        } else {
            content += `✅ **GOOD SECURITY POSTURE:**\n`;
            content += `No critical or high-priority security issues found.\n\n`;
        }
        
        content += `---\n`;
        content += `*Generated by AI-Powered DevSecOps Security Analysis Pipeline*\n`;
        content += `*Powered by AWS Bedrock with Claude 3.5 Sonnet*\n`;
        
        return content;
    }

    /**
     * Send notifications via configured channels
     */
    async sendNotifications(content) {
        // Send email if recipients configured
        if (this.recipients) {
            await this.sendEmail(content);
        }
        
        // Send Slack notification if webhook configured
        if (this.slackWebhook) {
            await this.sendSlackNotification(content);
        }
        
        // Save to file if no other channels configured
        if (!this.recipients && !this.slackWebhook) {
            await this.saveToFile(content);
        }
    }

    /**
     * Send email notification
     */
    async sendEmail(content) {
        try {
            // Simple email sending via SMTP or email service
            console.log(`📧 Sending email to: ${this.recipients}`);
            console.log('📧 Email content preview:');
            console.log(content.substring(0, 200) + '...');
            
            // TODO: Implement actual email sending (nodemailer, AWS SES, etc.)
            console.log('✅ Email sent successfully (simulated)');
            
        } catch (error) {
            console.error('❌ Error sending email:', error);
            throw error;
        }
    }

    /**
     * Send Slack notification
     */
    async sendSlackNotification(content) {
        try {
            const payload = {
                text: content,
                username: 'DevSecOps Security Bot',
                icon_emoji: ':shield:',
                channel: '#security'
            };

            const response = await fetch(this.slackWebhook, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            });

            if (!response.ok) {
                throw new Error(`Slack API error: ${response.status} ${response.statusText}`);
            }

            console.log('✅ Slack notification sent successfully');

        } catch (error) {
            console.error('❌ Error sending Slack notification:', error);
            throw error;
        }
    }

    /**
     * Save summary to file
     */
    async saveToFile(content) {
        const filename = `security-summary-${new Date().toISOString().split('T')[0]}.txt`;
        const filepath = path.join(this.reportsPath, filename);
        
        await fs.writeFile(filepath, content);
        console.log(`📄 Summary saved to: ${filepath}`);
    }

    /**
     * Get severity emoji
     */
    getSeverityEmoji(severity) {
        const emojiMap = {
            'critical': '🔴',
            'high': '🟠',
            'medium': '🟡',
            'low': '🟢'
        };
        return emojiMap[severity?.toLowerCase()] || '⚪';
    }

    /**
     * Get compliance emoji
     */
    getComplianceEmoji(status) {
        const emojiMap = {
            'pass': '✅',
            'fail': '❌',
            'partial': '⚠️'
        };
        return emojiMap[status?.toLowerCase()] || '❓';
    }
}

// CLI Interface
async function main() {
    const args = process.argv.slice(2);
    const options = {};
    
    // Parse command line arguments
    for (let i = 0; i < args.length; i++) {
        switch (args[i]) {
            case '--recipients':
                options.recipients = args[++i];
                break;
            case '--slack-webhook':
                options.slackWebhook = args[++i];
                break;
            case '--reports-path':
                options.reportsPath = args[++i];
                break;
            case '--summary-type':
                options.summaryType = args[++i];
                break;
        }
    }
    
    try {
        const sender = new SecuritySummarySender(options);
        await sender.sendSummary();
        
    } catch (error) {
        console.error('❌ Security summary sending failed:', error);
        process.exit(1);
    }
}

// Export for use as module
module.exports = SecuritySummarySender;

// Run if called directly
if (require.main === module) {
    main();
}
