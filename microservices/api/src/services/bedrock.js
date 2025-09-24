const { BedrockRuntimeClient, InvokeModelCommand } = require('@aws-sdk/client-bedrock-runtime');
const logger = require('../utils/logger');
const promClient = require('prom-client');

class BedrockService {
    constructor() {
        this.client = new BedrockRuntimeClient({
            region: process.env.AWS_REGION || 'us-east-1'
        });
        this.modelId = process.env.BEDROCK_MODEL_ID || 'anthropic.claude-3-sonnet-20240229-v1:0';
        
        // Metrics
        this.requestDuration = new promClient.Histogram({
            name: 'bedrock_request_duration_seconds',
            help: 'Duration of Bedrock API requests in seconds',
            labelNames: ['model', 'operation'],
            registers: [promClient.register]
        });
        
        this.requestTotal = new promClient.Counter({
            name: 'bedrock_requests_total',
            help: 'Total number of Bedrock API requests',
            labelNames: ['model', 'operation', 'status'],
            registers: [promClient.register]
        });
        
        this.errorTotal = new promClient.Counter({
            name: 'bedrock_errors_total',
            help: 'Total number of Bedrock API errors',
            labelNames: ['model', 'operation', 'error_type'],
            registers: [promClient.register]
        });
    }

    /**
     * Perform security analysis on code using AWS Bedrock
     * @param {string} code - Code to analyze
     * @param {string} language - Programming language
     * @param {Object} options - Analysis options
     * @returns {Promise<Object>} Security analysis results
     */
    async analyzeCodeSecurity(code, language = 'javascript', options = {}) {
        const timer = this.requestDuration.startTimer({ 
            model: this.modelId, 
            operation: 'analyzeCodeSecurity' 
        });
        
        try {
            const prompt = this.buildSecurityAnalysisPrompt(code, language, options);
            
            const command = new InvokeModelCommand({
                modelId: this.modelId,
                contentType: 'application/json',
                accept: 'application/json',
                body: JSON.stringify({
                    anthropic_version: 'bedrock-2023-05-31',
                    max_tokens: 4000,
                    temperature: 0.1,
                    messages: [{
                        role: 'user',
                        content: prompt
                    }]
                })
            });

            const response = await this.client.send(command);
            const responseBody = JSON.parse(new TextDecoder().decode(response.body));
            
            const analysis = this.parseSecurityAnalysis(responseBody.content[0].text);
            
            this.requestTotal
                .labels(this.modelId, 'analyzeCodeSecurity', 'success')
                .inc();
            
            logger.info('Security analysis completed', {
                language,
                vulnerabilitiesFound: analysis.vulnerabilities?.length || 0,
                severity: analysis.severity,
                modelId: this.modelId
            });
            
            return analysis;
            
        } catch (error) {
            this.requestTotal
                .labels(this.modelId, 'analyzeCodeSecurity', 'error')
                .inc();
            
            this.errorTotal
                .labels(this.modelId, 'analyzeCodeSecurity', error.constructor.name)
                .inc();
            
            logger.error('Security analysis failed', {
                error: error.message,
                language,
                modelId: this.modelId
            });
            
            throw error;
        } finally {
            timer();
        }
    }

    /**
     * Analyze infrastructure configuration for security issues
     * @param {string} config - Infrastructure configuration (Terraform, CloudFormation, etc.)
     * @param {string} type - Configuration type (terraform, cloudformation, kubernetes)
     * @returns {Promise<Object>} Infrastructure security analysis
     */
    async analyzeInfrastructureSecurity(config, type = 'terraform') {
        const timer = this.requestDuration.startTimer({ 
            model: this.modelId, 
            operation: 'analyzeInfrastructureSecurity' 
        });
        
        try {
            const prompt = this.buildInfrastructureSecurityPrompt(config, type);
            
            const command = new InvokeModelCommand({
                modelId: this.modelId,
                contentType: 'application/json',
                accept: 'application/json',
                body: JSON.stringify({
                    anthropic_version: 'bedrock-2023-05-31',
                    max_tokens: 4000,
                    temperature: 0.1,
                    messages: [{
                        role: 'user',
                        content: prompt
                    }]
                })
            });

            const response = await this.client.send(command);
            const responseBody = JSON.parse(new TextDecoder().decode(response.body));
            
            const analysis = this.parseInfrastructureAnalysis(responseBody.content[0].text);
            
            this.requestTotal
                .labels(this.modelId, 'analyzeInfrastructureSecurity', 'success')
                .inc();
            
            logger.info('Infrastructure security analysis completed', {
                type,
                issuesFound: analysis.issues?.length || 0,
                severity: analysis.severity,
                modelId: this.modelId
            });
            
            return analysis;
            
        } catch (error) {
            this.requestTotal
                .labels(this.modelId, 'analyzeInfrastructureSecurity', 'error')
                .inc();
            
            this.errorTotal
                .labels(this.modelId, 'analyzeInfrastructureSecurity', error.constructor.name)
                .inc();
            
            logger.error('Infrastructure security analysis failed', {
                error: error.message,
                type,
                modelId: this.modelId
            });
            
            throw error;
        } finally {
            timer();
        }
    }

    /**
     * Generate security recommendations based on scan results
     * @param {Array} findings - Security findings
     * @returns {Promise<Object>} Security recommendations
     */
    async generateSecurityRecommendations(findings) {
        const timer = this.requestDuration.startTimer({ 
            model: this.modelId, 
            operation: 'generateSecurityRecommendations' 
        });
        
        try {
            const prompt = this.buildRecommendationsPrompt(findings);
            
            const command = new InvokeModelCommand({
                modelId: this.modelId,
                contentType: 'application/json',
                accept: 'application/json',
                body: JSON.stringify({
                    anthropic_version: 'bedrock-2023-05-31',
                    max_tokens: 4000,
                    temperature: 0.1,
                    messages: [{
                        role: 'user',
                        content: prompt
                    }]
                })
            });

            const response = await this.client.send(command);
            const responseBody = JSON.parse(new TextDecoder().decode(response.body));
            
            const recommendations = this.parseRecommendations(responseBody.content[0].text);
            
            this.requestTotal
                .labels(this.modelId, 'generateSecurityRecommendations', 'success')
                .inc();
            
            logger.info('Security recommendations generated', {
                findingsCount: findings.length,
                recommendationsCount: recommendations.recommendations?.length || 0,
                modelId: this.modelId
            });
            
            return recommendations;
            
        } catch (error) {
            this.requestTotal
                .labels(this.modelId, 'generateSecurityRecommendations', 'error')
                .inc();
            
            this.errorTotal
                .labels(this.modelId, 'generateSecurityRecommendations', error.constructor.name)
                .inc();
            
            logger.error('Security recommendations generation failed', {
                error: error.message,
                findingsCount: findings.length,
                modelId: this.modelId
            });
            
            throw error;
        } finally {
            timer();
        }
    }

    /**
     * Health check for Bedrock service
     * @returns {Promise<boolean>} Service health status
     */
    async healthCheck() {
        try {
            // Simple test request to verify Bedrock connectivity
            const command = new InvokeModelCommand({
                modelId: this.modelId,
                contentType: 'application/json',
                accept: 'application/json',
                body: JSON.stringify({
                    anthropic_version: 'bedrock-2023-05-31',
                    max_tokens: 10,
                    temperature: 0.1,
                    messages: [{
                        role: 'user',
                        content: 'Hello'
                    }]
                })
            });

            await this.client.send(command);
            return true;
        } catch (error) {
            logger.error('Bedrock health check failed', { error: error.message });
            return false;
        }
    }

    /**
     * Build security analysis prompt for Bedrock
     */
    buildSecurityAnalysisPrompt(code, language, options) {
        return `You are a cybersecurity expert analyzing ${language} code for security vulnerabilities.

Analyze the following code and identify:
1. Security vulnerabilities (OWASP Top 10)
2. Code injection risks (SQL, NoSQL, Command, LDAP, etc.)
3. Authentication/authorization issues
4. Data exposure risks
5. Input validation problems
6. Cryptographic weaknesses
7. Dependencies vulnerabilities
8. Configuration security issues
9. Logging and monitoring gaps
10. Privacy concerns (GDPR, CCPA)

Code to analyze:
\`\`\`${language}
${code}
\`\`\`

Provide your analysis in JSON format:
{
  "severity": "CRITICAL|HIGH|MEDIUM|LOW|INFO",
  "vulnerabilities": [
    {
      "id": "unique-id",
      "type": "vulnerability type",
      "description": "detailed description",
      "severity": "CRITICAL|HIGH|MEDIUM|LOW|INFO",
      "line": line_number,
      "column": column_number,
      "recommendation": "how to fix",
      "references": ["url1", "url2"],
      "cwe": "CWE-ID",
      "owasp": "OWASP category"
    }
  ],
  "overall_score": 85,
  "summary": "overall security assessment",
  "compliance": {
    "owasp_top_10": ["A01", "A02"],
    "cwe_top_25": ["CWE-79", "CWE-89"],
    "standards": ["PCI-DSS", "SOC2"]
  }
}`;
    }

    /**
     * Build infrastructure security prompt
     */
    buildInfrastructureSecurityPrompt(config, type) {
        return `You are a DevSecOps expert analyzing ${type} infrastructure configuration for security issues.

Analyze the following ${type} configuration and identify:
1. Network security issues
2. Access control problems
3. Data encryption gaps
4. Logging and monitoring issues
5. Compliance violations
6. Resource exposure risks
7. IAM misconfigurations
8. Storage security issues
9. Compute security problems
10. Service security gaps

Configuration to analyze:
\`\`\`${type}
${config}
\`\`\`

Provide your analysis in JSON format:
{
  "severity": "CRITICAL|HIGH|MEDIUM|LOW|INFO",
  "issues": [
    {
      "id": "unique-id",
      "type": "issue type",
      "description": "detailed description",
      "severity": "CRITICAL|HIGH|MEDIUM|LOW|INFO",
      "resource": "resource name",
      "recommendation": "how to fix",
      "references": ["url1", "url2"],
      "compliance": ["PCI-DSS", "SOC2"]
    }
  ],
  "overall_score": 75,
  "summary": "overall security assessment"
}`;
    }

    /**
     * Build recommendations prompt
     */
    buildRecommendationsPrompt(findings) {
        return `You are a DevSecOps expert providing security recommendations based on scan findings.

Based on the following security findings, provide prioritized recommendations:

Findings:
${JSON.stringify(findings, null, 2)}

Provide recommendations in JSON format:
{
  "priority": "HIGH|MEDIUM|LOW",
  "recommendations": [
    {
      "id": "unique-id",
      "title": "recommendation title",
      "description": "detailed description",
      "priority": "HIGH|MEDIUM|LOW",
      "effort": "LOW|MEDIUM|HIGH",
      "impact": "LOW|MEDIUM|HIGH",
      "implementation": "step-by-step implementation",
      "references": ["url1", "url2"],
      "related_findings": ["finding-id-1", "finding-id-2"]
    }
  ],
  "summary": "overall recommendations summary",
  "next_steps": ["action1", "action2", "action3"]
}`;
    }

    /**
     * Parse security analysis response
     */
    parseSecurityAnalysis(text) {
        try {
            const jsonMatch = text.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                return JSON.parse(jsonMatch[0]);
            }
            
            return {
                severity: 'UNKNOWN',
                vulnerabilities: [],
                overall_score: 0,
                summary: 'Analysis failed - unable to parse response'
            };
        } catch (error) {
            logger.error('Failed to parse security analysis', { error: error.message });
            return {
                severity: 'ERROR',
                vulnerabilities: [],
                overall_score: 0,
                summary: 'Analysis failed - parsing error'
            };
        }
    }

    /**
     * Parse infrastructure analysis response
     */
    parseInfrastructureAnalysis(text) {
        try {
            const jsonMatch = text.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                return JSON.parse(jsonMatch[0]);
            }
            
            return {
                severity: 'UNKNOWN',
                issues: [],
                overall_score: 0,
                summary: 'Analysis failed - unable to parse response'
            };
        } catch (error) {
            logger.error('Failed to parse infrastructure analysis', { error: error.message });
            return {
                severity: 'ERROR',
                issues: [],
                overall_score: 0,
                summary: 'Analysis failed - parsing error'
            };
        }
    }

    /**
     * Parse recommendations response
     */
    parseRecommendations(text) {
        try {
            const jsonMatch = text.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                return JSON.parse(jsonMatch[0]);
            }
            
            return {
                priority: 'UNKNOWN',
                recommendations: [],
                summary: 'Recommendations generation failed - unable to parse response'
            };
        } catch (error) {
            logger.error('Failed to parse recommendations', { error: error.message });
            return {
                priority: 'ERROR',
                recommendations: [],
                summary: 'Recommendations generation failed - parsing error'
            };
        }
    }
}

module.exports = new BedrockService();
