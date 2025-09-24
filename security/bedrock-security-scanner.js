const { BedrockRuntimeClient, InvokeModelCommand } = require('@aws-sdk/client-bedrock-runtime');
const fs = require('fs').promises;
const path = require('path');

class BedrockSecurityScanner {
    constructor(region = 'us-east-1') {
        this.client = new BedrockRuntimeClient({ region });
        this.modelId = 'anthropic.claude-3-sonnet-20240229-v1:0';
    }

    /**
     * Analyze code for security vulnerabilities using AWS Bedrock
     * @param {string} code - The code to analyze
     * @param {string} language - Programming language
     * @returns {Promise<Object>} Security analysis results
     */
    async analyzeCodeSecurity(code, language = 'javascript') {
        const prompt = this.buildSecurityPrompt(code, language);
        
        try {
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
            
            return this.parseSecurityAnalysis(responseBody.content[0].text);
        } catch (error) {
            console.error('Error analyzing code security:', error);
            throw error;
        }
    }

    /**
     * Build security analysis prompt for Bedrock
     */
    buildSecurityPrompt(code, language) {
        return `You are a cybersecurity expert analyzing ${language} code for security vulnerabilities. 

Analyze the following code and identify:
1. Security vulnerabilities (OWASP Top 10)
2. Code injection risks
3. Authentication/authorization issues
4. Data exposure risks
5. Input validation problems
6. Cryptographic weaknesses
7. Dependencies vulnerabilities

Code to analyze:
\`\`\`${language}
${code}
\`\`\`

Provide your analysis in JSON format:
{
  "severity": "HIGH|MEDIUM|LOW",
  "vulnerabilities": [
    {
      "type": "vulnerability type",
      "description": "detailed description",
      "severity": "HIGH|MEDIUM|LOW",
      "line": line_number,
      "recommendation": "how to fix"
    }
  ],
  "overall_score": 85,
  "summary": "overall security assessment"
}`;
    }

    /**
     * Parse Bedrock response into structured format
     */
    parseSecurityAnalysis(text) {
        try {
            // Extract JSON from response text
            const jsonMatch = text.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                return JSON.parse(jsonMatch[0]);
            }
            
            // Fallback parsing if JSON extraction fails
            return {
                severity: 'UNKNOWN',
                vulnerabilities: [],
                overall_score: 0,
                summary: 'Analysis failed - unable to parse response'
            };
        } catch (error) {
            console.error('Error parsing security analysis:', error);
            return {
                severity: 'ERROR',
                vulnerabilities: [],
                overall_score: 0,
                summary: 'Analysis failed - parsing error'
            };
        }
    }

    /**
     * Scan multiple files in a directory
     */
    async scanDirectory(directoryPath, fileExtensions = ['.js', '.ts', '.py', '.java']) {
        const results = {
            total_files: 0,
            scanned_files: 0,
            vulnerabilities_found: 0,
            files: []
        };

        try {
            const files = await this.getFilesRecursively(directoryPath, fileExtensions);
            results.total_files = files.length;

            for (const file of files) {
                try {
                    const content = await fs.readFile(file, 'utf8');
                    const language = this.getLanguageFromExtension(path.extname(file));
                    
                    const analysis = await this.analyzeCodeSecurity(content, language);
                    
                    results.files.push({
                        file: file,
                        language: language,
                        analysis: analysis
                    });
                    
                    results.scanned_files++;
                    results.vulnerabilities_found += analysis.vulnerabilities?.length || 0;
                    
                    console.log(`Scanned: ${file} - ${analysis.vulnerabilities?.length || 0} vulnerabilities found`);
                } catch (error) {
                    console.error(`Error scanning file ${file}:`, error);
                }
            }
        } catch (error) {
            console.error('Error scanning directory:', error);
        }

        return results;
    }

    /**
     * Get all files recursively from directory
     */
    async getFilesRecursively(dir, extensions) {
        const files = [];
        const entries = await fs.readdir(dir, { withFileTypes: true });

        for (const entry of entries) {
            const fullPath = path.join(dir, entry.name);
            
            if (entry.isDirectory() && !entry.name.startsWith('.') && entry.name !== 'node_modules') {
                const subFiles = await this.getFilesRecursively(fullPath, extensions);
                files.push(...subFiles);
            } else if (entry.isFile() && extensions.includes(path.extname(entry.name))) {
                files.push(fullPath);
            }
        }

        return files;
    }

    /**
     * Get programming language from file extension
     */
    getLanguageFromExtension(extension) {
        const languageMap = {
            '.js': 'javascript',
            '.ts': 'typescript',
            '.py': 'python',
            '.java': 'java',
            '.go': 'go',
            '.php': 'php',
            '.rb': 'ruby',
            '.cpp': 'cpp',
            '.c': 'c',
            '.cs': 'csharp'
        };
        return languageMap[extension] || 'unknown';
    }

    /**
     * Generate security report
     */
    async generateReport(scanResults, outputPath = 'security-report.json') {
        const report = {
            timestamp: new Date().toISOString(),
            scan_results: scanResults,
            summary: {
                total_files: scanResults.total_files,
                scanned_files: scanResults.scanned_files,
                vulnerabilities_found: scanResults.vulnerabilities_found,
                high_severity: this.countSeverity(scanResults, 'HIGH'),
                medium_severity: this.countSeverity(scanResults, 'MEDIUM'),
                low_severity: this.countSeverity(scanResults, 'LOW')
            }
        };

        await fs.writeFile(outputPath, JSON.stringify(report, null, 2));
        console.log(`Security report generated: ${outputPath}`);
        return report;
    }

    /**
     * Count vulnerabilities by severity
     */
    countSeverity(scanResults, severity) {
        let count = 0;
        scanResults.files.forEach(file => {
            if (file.analysis.vulnerabilities) {
                count += file.analysis.vulnerabilities.filter(v => v.severity === severity).length;
            }
        });
        return count;
    }
}

module.exports = BedrockSecurityScanner;
