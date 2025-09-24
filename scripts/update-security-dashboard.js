#!/usr/bin/env node

/**
 * 📊 Update Security Dashboard
 * Updates Grafana dashboard with latest security analysis results
 */

const fs = require('fs').promises;
const path = require('path');

class SecurityDashboardUpdater {
    constructor(options = {}) {
        this.grafanaUrl = options.grafanaUrl || process.env.GRAFANA_URL;
        this.grafanaApiKey = options.grafanaApiKey || process.env.GRAFANA_API_KEY;
        this.dashboardId = options.dashboardId || 'security-dashboard';
        this.reportsPath = options.reportsPath || './reports';
    }

    /**
     * Update security dashboard with latest data
     */
    async updateDashboard() {
        try {
            console.log('📊 Updating security dashboard...');
            
            // Load all security reports
            const reports = await this.loadSecurityReports();
            
            // Process and aggregate data
            const dashboardData = await this.processReports(reports);
            
            // Update Grafana dashboard
            await this.updateGrafanaDashboard(dashboardData);
            
            console.log('✅ Security dashboard updated successfully!');
            
        } catch (error) {
            console.error('❌ Error updating security dashboard:', error);
            throw error;
        }
    }

    /**
     * Load security reports from directory
     */
    async loadSecurityReports() {
        const reports = {};
        
        try {
            const files = await fs.readdir(this.reportsPath);
            
            for (const file of files) {
                if (file.endsWith('.json')) {
                    const filePath = path.join(this.reportsPath, file);
                    const content = await fs.readFile(filePath, 'utf8');
                    
                    if (file.includes('bedrock') || file.includes('security-analysis')) {
                        reports.bedrock = JSON.parse(content);
                    } else if (file.includes('npm-audit')) {
                        reports.npmAudit = JSON.parse(content);
                    } else if (file.includes('eslint')) {
                        reports.eslint = JSON.parse(content);
                    } else if (file.includes('snyk')) {
                        reports.snyk = JSON.parse(content);
                    }
                }
            }
            
        } catch (error) {
            console.warn('⚠️ Could not load reports directory:', error.message);
        }
        
        return reports;
    }

    /**
     * Process reports and create dashboard data
     */
    async processReports(reports) {
        const dashboardData = {
            timestamp: new Date().toISOString(),
            summary: {
                totalVulnerabilities: 0,
                criticalIssues: 0,
                highIssues: 0,
                mediumIssues: 0,
                lowIssues: 0,
                securityScore: 100
            },
            trends: [],
            compliance: {},
            recommendations: []
        };

        // Process Bedrock AI analysis
        if (reports.bedrock) {
            const bedrockData = this.processBedrockReport(reports.bedrock);
            Object.assign(dashboardData.summary, bedrockData.summary);
            dashboardData.recommendations.push(...bedrockData.recommendations);
            dashboardData.compliance = { ...dashboardData.compliance, ...bedrockData.compliance };
        }

        // Process npm audit report
        if (reports.npmAudit) {
            const npmData = this.processNpmAuditReport(reports.npmAudit);
            dashboardData.summary.totalVulnerabilities += npmData.vulnerabilities;
            dashboardData.summary.criticalIssues += npmData.critical;
            dashboardData.summary.highIssues += npmData.high;
            dashboardData.summary.mediumIssues += npmData.medium;
            dashboardData.summary.lowIssues += npmData.low;
        }

        // Process ESLint security report
        if (reports.eslint) {
            const eslintData = this.processEslintReport(reports.eslint);
            dashboardData.summary.totalVulnerabilities += eslintData.vulnerabilities;
            dashboardData.summary.mediumIssues += eslintData.medium;
            dashboardData.summary.lowIssues += eslintData.low;
        }

        // Process Snyk report
        if (reports.snyk) {
            const snykData = this.processSnykReport(reports.snyk);
            dashboardData.summary.totalVulnerabilities += snykData.vulnerabilities;
            dashboardData.summary.criticalIssues += snykData.critical;
            dashboardData.summary.highIssues += snykData.high;
            dashboardData.summary.mediumIssues += snykData.medium;
            dashboardData.summary.lowIssues += snykData.low;
        }

        // Calculate overall security score
        dashboardData.summary.securityScore = this.calculateSecurityScore(dashboardData.summary);

        return dashboardData;
    }

    /**
     * Process Bedrock AI analysis report
     */
    processBedrockReport(report) {
        const data = {
            summary: {
                totalVulnerabilities: 0,
                criticalIssues: 0,
                highIssues: 0,
                mediumIssues: 0,
                lowIssues: 0
            },
            recommendations: [],
            compliance: {}
        };

        // Process file analysis
        if (report.fileAnalysis) {
            report.fileAnalysis.forEach(analysis => {
                if (analysis.analysis) {
                    try {
                        const parsed = JSON.parse(analysis.analysis);
                        if (parsed.vulnerabilities) {
                            parsed.vulnerabilities.forEach(vuln => {
                                const severity = vuln.severity?.toLowerCase() || 'low';
                                if (data.summary[`${severity}Issues`] !== undefined) {
                                    data.summary[`${severity}Issues`]++;
                                    data.summary.totalVulnerabilities++;
                                }
                            });
                        }
                    } catch (e) {
                        // Handle parsing errors
                    }
                }
            });
        }

        // Process overall analysis
        if (report.overallAnalysis) {
            try {
                const parsed = JSON.parse(report.overallAnalysis);
                if (parsed.recommended_actions) {
                    data.recommendations.push(...parsed.recommended_actions);
                }
                if (parsed.compliance_status) {
                    data.compliance = parsed.compliance_status;
                }
            } catch (e) {
                // Handle parsing errors
            }
        }

        return data;
    }

    /**
     * Process npm audit report
     */
    processNpmAuditReport(report) {
        const data = {
            vulnerabilities: 0,
            critical: 0,
            high: 0,
            medium: 0,
            low: 0
        };

        if (report.vulnerabilities) {
            Object.values(report.vulnerabilities).forEach(vuln => {
                data.vulnerabilities++;
                const severity = vuln.severity?.toLowerCase() || 'low';
                if (data[severity] !== undefined) {
                    data[severity]++;
                }
            });
        }

        return data;
    }

    /**
     * Process ESLint security report
     */
    processEslintReport(report) {
        const data = {
            vulnerabilities: 0,
            medium: 0,
            low: 0
        };

        if (Array.isArray(report)) {
            report.forEach(file => {
                if (file.messages) {
                    file.messages.forEach(message => {
                        if (message.ruleId && message.ruleId.includes('security')) {
                            data.vulnerabilities++;
                            if (message.severity === 1) {
                                data.medium++;
                            } else if (message.severity === 2) {
                                data.low++;
                            }
                        }
                    });
                }
            });
        }

        return data;
    }

    /**
     * Process Snyk report
     */
    processSnykReport(report) {
        const data = {
            vulnerabilities: 0,
            critical: 0,
            high: 0,
            medium: 0,
            low: 0
        };

        if (report.vulnerabilities) {
            report.vulnerabilities.forEach(vuln => {
                data.vulnerabilities++;
                const severity = vuln.severity?.toLowerCase() || 'low';
                if (data[severity] !== undefined) {
                    data[severity]++;
                }
            });
        }

        return data;
    }

    /**
     * Calculate overall security score
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
     * Update Grafana dashboard
     */
    async updateGrafanaDashboard(dashboardData) {
        if (!this.grafanaUrl || !this.grafanaApiKey) {
            console.log('⚠️ Grafana credentials not configured, skipping dashboard update');
            return;
        }

        try {
            // Create dashboard payload
            const dashboard = {
                dashboard: {
                    id: null,
                    title: 'DevSecOps Security Dashboard',
                    tags: ['security', 'devsecops', 'bedrock'],
                    timezone: 'browser',
                    panels: this.createDashboardPanels(dashboardData),
                    time: {
                        from: 'now-7d',
                        to: 'now'
                    },
                    refresh: '30s'
                },
                overwrite: true
            };

            // Update dashboard via Grafana API
            const response = await fetch(`${this.grafanaUrl}/api/dashboards/db`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.grafanaApiKey}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(dashboard)
            });

            if (!response.ok) {
                throw new Error(`Grafana API error: ${response.status} ${response.statusText}`);
            }

            console.log('✅ Grafana dashboard updated successfully');

        } catch (error) {
            console.error('❌ Error updating Grafana dashboard:', error);
            throw error;
        }
    }

    /**
     * Create dashboard panels
     */
    createDashboardPanels(dashboardData) {
        const panels = [
            {
                id: 1,
                title: 'Security Score',
                type: 'stat',
                targets: [
                    {
                        expr: dashboardData.summary.securityScore,
                        refId: 'A'
                    }
                ],
                fieldConfig: {
                    defaults: {
                        color: {
                            mode: 'thresholds'
                        },
                        thresholds: {
                            steps: [
                                { color: 'red', value: 0 },
                                { color: 'yellow', value: 70 },
                                { color: 'green', value: 90 }
                            ]
                        }
                    }
                },
                gridPos: { h: 8, w: 6, x: 0, y: 0 }
            },
            {
                id: 2,
                title: 'Vulnerability Breakdown',
                type: 'piechart',
                targets: [
                    {
                        expr: dashboardData.summary.criticalIssues,
                        legendFormat: 'Critical',
                        refId: 'A'
                    },
                    {
                        expr: dashboardData.summary.highIssues,
                        legendFormat: 'High',
                        refId: 'B'
                    },
                    {
                        expr: dashboardData.summary.mediumIssues,
                        legendFormat: 'Medium',
                        refId: 'C'
                    },
                    {
                        expr: dashboardData.summary.lowIssues,
                        legendFormat: 'Low',
                        refId: 'D'
                    }
                ],
                gridPos: { h: 8, w: 6, x: 6, y: 0 }
            },
            {
                id: 3,
                title: 'Total Vulnerabilities',
                type: 'stat',
                targets: [
                    {
                        expr: dashboardData.summary.totalVulnerabilities,
                        refId: 'A'
                    }
                ],
                gridPos: { h: 4, w: 6, x: 12, y: 0 }
            }
        ];

        return panels;
    }

    /**
     * Save dashboard data to file (fallback if Grafana not available)
     */
    async saveDashboardData(dashboardData) {
        const outputPath = path.join(this.reportsPath, 'dashboard-data.json');
        await fs.writeFile(outputPath, JSON.stringify(dashboardData, null, 2));
        console.log(`📄 Dashboard data saved to: ${outputPath}`);
    }
}

// CLI Interface
async function main() {
    const args = process.argv.slice(2);
    const options = {};
    
    // Parse command line arguments
    for (let i = 0; i < args.length; i++) {
        switch (args[i]) {
            case '--bedrock-report':
                options.bedrockReport = args[++i];
                break;
            case '--npm-report':
                options.npmReport = args[++i];
                break;
            case '--eslint-report':
                options.eslintReport = args[++i];
                break;
            case '--snyk-report':
                options.snykReport = args[++i];
                break;
            case '--grafana-url':
                options.grafanaUrl = args[++i];
                break;
            case '--grafana-api-key':
                options.grafanaApiKey = args[++i];
                break;
            case '--reports-path':
                options.reportsPath = args[++i];
                break;
        }
    }
    
    try {
        const updater = new SecurityDashboardUpdater(options);
        await updater.updateDashboard();
        
    } catch (error) {
        console.error('❌ Dashboard update failed:', error);
        process.exit(1);
    }
}

// Export for use as module
module.exports = SecurityDashboardUpdater;

// Run if called directly
if (require.main === module) {
    main();
}
