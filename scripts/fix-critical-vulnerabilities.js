// Critical Security Vulnerabilities Fix Script
const fs = require('fs').promises;
const path = require('path');

class SecurityFixer {
    constructor() {
        this.fixes = [];
    }

    async fixCredentialsInScripts() {
        console.log('🔐 Fixing hardcoded credentials...');
        
        const filesToFix = [
            'scripts/setup-env-credentials.bat',
            'scripts/simple-aws-test.js'
        ];

        for (const file of filesToFix) {
            try {
                const content = await fs.readFile(file, 'utf8');
                
                if (content.includes('AKIA2UZBV7QXNP2PQ2ZI')) {
                    console.log(`  ⚠️  Found hardcoded credentials in ${file}`);
                    console.log(`  💡 Recommendation: Remove hardcoded credentials and use environment variables`);
                    
                    this.fixes.push({
                        file: file,
                        issue: 'Hardcoded AWS credentials',
                        recommendation: 'Use environment variables instead',
                        severity: 'CRITICAL'
                    });
                }
            } catch (error) {
                console.log(`  ⚠️  Could not read ${file}: ${error.message}`);
            }
        }
    }

    async checkInputValidation() {
        console.log('🛡️ Checking input validation...');
        
        const apiFile = 'microservices/api/src/server.js';
        try {
            const content = await fs.readFile(apiFile, 'utf8');
            
            if (content.includes('req.body') && !content.includes('express-validator')) {
                console.log(`  ⚠️  Missing input validation in ${apiFile}`);
                console.log(`  💡 Recommendation: Add express-validator middleware`);
                
                this.fixes.push({
                    file: apiFile,
                    issue: 'Missing input validation',
                    recommendation: 'Install and use express-validator',
                    severity: 'HIGH'
                });
            }
        } catch (error) {
            console.log(`  ⚠️  Could not read ${apiFile}: ${error.message}`);
        }
    }

    async checkSecurityHeaders() {
        console.log('🔒 Checking security headers...');
        
        const apiFile = 'microservices/api/src/server.js';
        try {
            const content = await fs.readFile(apiFile, 'utf8');
            
            if (!content.includes('helmet')) {
                console.log(`  ⚠️  Missing security headers in ${apiFile}`);
                console.log(`  💡 Recommendation: Install and configure helmet.js`);
                
                this.fixes.push({
                    file: apiFile,
                    issue: 'Missing security headers',
                    recommendation: 'Install and configure helmet.js',
                    severity: 'MEDIUM'
                });
            }
        } catch (error) {
            console.log(`  ⚠️  Could not read ${apiFile}: ${error.message}`);
        }
    }

    async checkHTTPS() {
        console.log('🔐 Checking HTTPS configuration...');
        
        const apiFile = 'microservices/api/src/server.js';
        try {
            const content = await fs.readFile(apiFile, 'utf8');
            
            if (content.includes('http://') && !content.includes('localhost')) {
                console.log(`  ⚠️  Insecure HTTP connections found in ${apiFile}`);
                console.log(`  💡 Recommendation: Use HTTPS for all external connections`);
                
                this.fixes.push({
                    file: apiFile,
                    issue: 'Insecure HTTP connections',
                    recommendation: 'Replace with HTTPS',
                    severity: 'HIGH'
                });
            }
        } catch (error) {
            console.log(`  ⚠️  Could not read ${apiFile}: ${error.message}`);
        }
    }

    generateFixCommands() {
        console.log('\n🔧 AUTOMATED FIX COMMANDS');
        console.log('==========================');
        
        console.log('\n1. Install security packages:');
        console.log('npm install helmet express-validator joi');
        
        console.log('\n2. Add to microservices/api/package.json dependencies:');
        console.log('"helmet": "^7.0.0"');
        console.log('"express-validator": "^7.0.1"');
        console.log('"joi": "^17.0.0"');
        
        console.log('\n3. Update microservices/api/src/server.js:');
        console.log('// Add at the top');
        console.log('const helmet = require("helmet");');
        console.log('const { body, validationResult } = require("express-validator");');
        console.log('');
        console.log('// Add after app creation');
        console.log('app.use(helmet());');
        console.log('');
        console.log('// Add validation middleware to routes');
        console.log('app.post("/api/data",');
        console.log('  body("data").isLength({ min: 1 }).trim().escape(),');
        console.log('  (req, res) => {');
        console.log('    const errors = validationResult(req);');
        console.log('    if (!errors.isEmpty()) {');
        console.log('      return res.status(400).json({ errors: errors.array() });');
        console.log('    }');
        console.log('    // Process validated data');
        console.log('  }');
        console.log(');');
    }

    generateReport() {
        console.log('\n📊 SECURITY FIX REPORT');
        console.log('======================');
        console.log(`Total issues found: ${this.fixes.length}`);
        
        const bySeverity = this.fixes.reduce((acc, fix) => {
            acc[fix.severity] = (acc[fix.severity] || 0) + 1;
            return acc;
        }, {});
        
        console.log('\nBy Severity:');
        Object.entries(bySeverity).forEach(([severity, count]) => {
            console.log(`  ${severity}: ${count}`);
        });
        
        console.log('\nDetailed Issues:');
        this.fixes.forEach((fix, index) => {
            console.log(`\n${index + 1}. ${fix.issue} (${fix.severity})`);
            console.log(`   File: ${fix.file}`);
            console.log(`   Fix: ${fix.recommendation}`);
        });
    }

    async run() {
        console.log('🔒 CRITICAL SECURITY VULNERABILITIES ANALYSIS');
        console.log('==============================================\n');
        
        await this.fixCredentialsInScripts();
        await this.checkInputValidation();
        await this.checkSecurityHeaders();
        await this.checkHTTPS();
        
        this.generateReport();
        this.generateFixCommands();
        
        console.log('\n✅ ANALYSIS COMPLETE');
        console.log('===================');
        console.log('Review the issues above and implement the recommended fixes.');
        console.log('Run security scan again after implementing fixes.');
    }
}

// Run the security fix analysis
const fixer = new SecurityFixer();
fixer.run().catch(console.error);
