#!/usr/bin/env node

/**
 * 🛡️ Bedrock AI Security Analysis Pipeline
 * Integrates with AWS Bedrock Agent for automated security analysis
 */

const { BedrockAgentRuntimeClient, InvokeAgentCommand } = require('@aws-sdk/client-bedrock-agent-runtime');
const fs = require('fs').promises;
const path = require('path');
const { execSync } = require('child_process');

class BedrockSecurityPipeline {
    constructor(options = {}) {
        this.region = options.region || process.env.AWS_REGION || 'us-east-1';
        this.agentId = options.agentId || process.env.BEDROCK_AGENT_ID;
        this.aliasId = options.aliasId || process.env.BEDROCK_AGENT_ALIAS_ID;
        this.client = new BedrockAgentRuntimeClient({ region: this.region });
        
        if (!this.agentId) {
            throw new Error('BEDROCK_AGENT_ID is required');
        }
    }

    /**
     * Analyze code changes for security vulnerabilities
     */
    async analyzeCodeChanges(repository, branch, commit, prNumber = null) {
        console.log(`🔍 Analyzing security for repository: ${repository}`);
        console.log(`📝 Branch: ${branch}, Commit: ${commit}`);
        
        try {
            // Get changed files
            const changedFiles = await this.getChangedFiles(commit, prNumber);
            console.log(`📁 Found ${changedFiles.length} changed files`);
            
            // Analyze each changed file
            const analysisResults = [];
            
            for (const file of changedFiles) {
                if (this.shouldAnalyzeFile(file)) {
                    console.log(`🔍 Analyzing file: ${file}`);
                    const analysis = await this.analyzeFile(file);
                    if (analysis) {
                        analysisResults.push(analysis);
                    }
                }
            }
            
            // Perform overall security analysis
            const overallAnalysis = await this.performOverallAnalysis(repository, branch, commit, analysisResults);
            
            // Generate comprehensive report
            const report = await this.generateSecurityReport({
                repository,
                branch,
                commit,
                prNumber,
                changedFiles,
                fileAnalysis: analysisResults,
                overallAnalysis
            });
            
            return report;
            
        } catch (error) {
            console.error('❌ Error during security analysis:', error);
            throw error;
        }
    }

    /**
     * Get list of changed files
     */
    async getChangedFiles(commit, prNumber = null) {
        try {
            let command;
            
            if (prNumber) {
                // For pull requests, compare with base branch
                command = `git diff --name-only HEAD~1 HEAD`;
            } else {
                // For pushes, get files changed in this commit
                command = `git diff --name-only ${commit}~1 ${commit}`;
            }
            
            const output = execSync(command, { encoding: 'utf8' });
            return output.trim().split('\n').filter(file => file.length > 0);
            
        } catch (error) {
            console.warn('⚠️ Could not get changed files, analyzing all files');
            return await this.getAllFiles();
        }
    }

    /**
     * Get all files in repository
     */
    async getAllFiles() {
        try {
            const output = execSync('find . -type f -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.py" -o -name "*.java" -o -name "*.go" | head -100', { encoding: 'utf8' });
            return output.trim().split('\n').filter(file => file.length > 0);
        } catch (error) {
            console.warn('⚠️ Could not get all files');
            return [];
        }
    }

    /**
     * Check if file should be analyzed
     */
    shouldAnalyzeFile(file) {
        const skipPatterns = [
            'node_modules/',
            '.git/',
            'dist/',
            'build/',
            '.next/',
            'coverage/',
            '.nyc_output/',
            '*.log',
            '*.min.js',
            'package-lock.json',
            'yarn.lock'
        ];
        
        return !skipPatterns.some(pattern => file.includes(pattern));
    }

    /**
     * Analyze individual file for security issues
     */
    async analyzeFile(filePath) {
        try {
            const content = await fs.readFile(filePath, 'utf8');
            
            if (content.length > 100000) { // Skip very large files
                console.log(`⚠️ Skipping large file: ${filePath}`);
                return null;
            }
            
            const prompt = this.buildFileAnalysisPrompt(filePath, content);
            const analysis = await this.invokeBedrockAgent(prompt);
            
            return {
                file: filePath,
                analysis: analysis,
                timestamp: new Date().toISOString()
            };
            
        } catch (error) {
            console.warn(`⚠️ Could not analyze file ${filePath}:`, error.message);
            return null;
        }
    }

    /**
     * Build prompt for file analysis
     */
    buildFileAnalysisPrompt(filePath, content) {
        const fileExtension = path.extname(filePath);
        const language = this.getLanguageFromExtension(fileExtension);
        
        return `
Analyze this ${language} code file for security vulnerabilities using the FMacDevSecOps knowledge base:

File: ${filePath}
Language: ${language}

Code:
\`\`\`${language}
${content}
\`\`\`

Please provide:
1. **Security Vulnerabilities**: List any security issues found (OWASP Top 10, CWE, etc.)
2. **Severity Levels**: Critical, High, Medium, Low
3. **Remediation Steps**: Specific fixes for each vulnerability
4. **Best Practices**: Security improvements for this code
5. **Compliance**: Any compliance issues (SOC 2, PCI DSS, GDPR, etc.)

Format your response as structured JSON with the following schema:
{
  "file": "${filePath}",
  "language": "${language}",
  "vulnerabilities": [
    {
      "type": "vulnerability_type",
      "severity": "Critical|High|Medium|Low",
      "description": "description",
      "line": line_number,
      "code": "vulnerable_code_snippet",
      "remediation": "fix_suggestion",
      "owasp_category": "OWASP_category",
      "cwe_id": "CWE-ID"
    }
  ],
  "best_practices": ["practice1", "practice2"],
  "compliance_issues": ["issue1", "issue2"],
  "overall_severity": "Critical|High|Medium|Low"
}
        `.trim();
    }

    /**
     * Get language from file extension
     */
    getLanguageFromExtension(extension) {
        const languageMap = {
            '.js': 'javascript',
            '.ts': 'typescript',
            '.jsx': 'javascript',
            '.tsx': 'typescript',
            '.py': 'python',
            '.java': 'java',
            '.go': 'go',
            '.php': 'php',
            '.rb': 'ruby',
            '.cs': 'csharp'
        };
        
        return languageMap[extension] || 'text';
    }

    /**
     * Perform overall security analysis
     */
    async performOverallAnalysis(repository, branch, commit, fileAnalysis) {
        const summary = fileAnalysis.reduce((acc, analysis) => {
            if (analysis.analysis) {
                try {
                    const parsed = JSON.parse(analysis.analysis);
                    if (parsed.vulnerabilities) {
                        parsed.vulnerabilities.forEach(vuln => {
                            acc.vulnerabilities.push({
                                ...vuln,
                                file: analysis.file
                            });
                        });
                    }
                } catch (e) {
                    // If parsing fails, treat as text analysis
                    acc.textAnalysis.push({
                        file: analysis.file,
                        content: analysis.analysis
                    });
                }
            }
            return acc;
        }, { vulnerabilities: [], textAnalysis: [] });

        const prompt = `
Based on the security analysis of ${fileAnalysis.length} files in repository ${repository}, 
provide an overall security assessment:

Branch: ${branch}
Commit: ${commit}

File Analysis Summary:
${JSON.stringify(summary, null, 2)}

Please provide:
1. **Overall Security Score**: 0-100
2. **Critical Issues**: Count and summary
3. **High Priority Issues**: Count and summary
4. **Compliance Status**: SOC 2, PCI DSS, GDPR, etc.
5. **Recommended Actions**: Top 5 priority actions
6. **Risk Assessment**: Overall risk level

Format as JSON:
{
  "security_score": number,
  "critical_issues": number,
  "high_issues": number,
  "medium_issues": number,
  "low_issues": number,
  "compliance_status": {
    "soc2": "Pass|Fail|Partial",
    "pci_dss": "Pass|Fail|Partial",
    "gdpr": "Pass|Fail|Partial"
  },
  "recommended_actions": ["action1", "action2"],
  "risk_level": "Critical|High|Medium|Low",
  "summary": "overall_summary"
}
        `.trim();

        return await this.invokeBedrockAgent(prompt);
    }

    /**
     * Invoke Bedrock Agent
     */
    async invokeBedrockAgent(prompt) {
        try {
            const sessionId = `session-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
            
            const command = new InvokeAgentCommand({
                agentId: this.agentId,
                agentAliasId: this.aliasId || 'TSTALIASID',
                sessionId: sessionId,
                inputText: prompt
            });

            console.log(`🤖 Invoking Bedrock Agent: ${this.agentId}`);
            const response = await this.client.send(command);
            
            // Process streaming response
            let fullResponse = '';
            for await (const chunk of response.completion) {
                if (chunk.chunk?.bytes) {
                    const text = new TextDecoder().decode(chunk.chunk.bytes);
                    fullResponse += text;
                }
            }
            
            return fullResponse;
            
        } catch (error) {
            console.error('❌ Error invoking Bedrock Agent:', error);
            throw error;
        }
    }

    /**
     * Generate comprehensive security report
     */
    async generateSecurityReport(data) {
        const report = {
            metadata: {
                repository: data.repository,
                branch: data.branch,
                commit: data.commit,
                prNumber: data.prNumber,
                timestamp: new Date().toISOString(),
                agentId: this.agentId,
                aliasId: this.aliasId
            },
            summary: {
                totalFilesAnalyzed: data.fileAnalysis.length,
                totalFilesChanged: data.changedFiles.length,
                analysisDuration: 'calculated_later'
            },
            fileAnalysis: data.fileAnalysis,
            overallAnalysis: data.overallAnalysis,
            recommendations: this.extractRecommendations(data),
            compliance: this.extractCompliance(data)
        };

        return report;
    }

    /**
     * Extract recommendations from analysis
     */
    extractRecommendations(data) {
        const recommendations = [];
        
        data.fileAnalysis.forEach(analysis => {
            if (analysis.analysis) {
                try {
                    const parsed = JSON.parse(analysis.analysis);
                    if (parsed.recommended_actions) {
                        recommendations.push(...parsed.recommended_actions);
                    }
                } catch (e) {
                    // Handle text-based analysis
                }
            }
        });
        
        return [...new Set(recommendations)]; // Remove duplicates
    }

    /**
     * Extract compliance information
     */
    extractCompliance(data) {
        const compliance = {
            soc2: 'Unknown',
            pci_dss: 'Unknown',
            gdpr: 'Unknown'
        };
        
        try {
            const overallParsed = JSON.parse(data.overallAnalysis);
            if (overallParsed.compliance_status) {
                Object.assign(compliance, overallParsed.compliance_status);
            }
        } catch (e) {
            // Handle parsing errors
        }
        
        return compliance;
    }

    /**
     * Save report to file
     */
    async saveReport(report, outputPath) {
        await fs.writeFile(outputPath, JSON.stringify(report, null, 2));
        console.log(`📄 Security report saved to: ${outputPath}`);
    }
}

// CLI Interface
async function main() {
    const args = process.argv.slice(2);
    const options = {};
    
    // Parse command line arguments
    for (let i = 0; i < args.length; i++) {
        switch (args[i]) {
            case '--repository':
                options.repository = args[++i];
                break;
            case '--branch':
                options.branch = args[++i];
                break;
            case '--commit':
                options.commit = args[++i];
                break;
            case '--pr-number':
                options.prNumber = args[++i];
                break;
            case '--agent-id':
                options.agentId = args[++i];
                break;
            case '--alias-id':
                options.aliasId = args[++i];
                break;
            case '--output':
                options.output = args[++i];
                break;
            case '--region':
                options.region = args[++i];
                break;
        }
    }
    
    try {
        const pipeline = new BedrockSecurityPipeline(options);
        
        const report = await pipeline.analyzeCodeChanges(
            options.repository,
            options.branch,
            options.commit,
            options.prNumber
        );
        
        if (options.output) {
            await pipeline.saveReport(report, options.output);
        } else {
            console.log(JSON.stringify(report, null, 2));
        }
        
        console.log('✅ Security analysis completed successfully!');
        
    } catch (error) {
        console.error('❌ Security analysis failed:', error);
        process.exit(1);
    }
}

// Export for use as module
module.exports = BedrockSecurityPipeline;

// Run if called directly
if (require.main === module) {
    main();
}
