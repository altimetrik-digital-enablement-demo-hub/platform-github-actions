const fs = require('fs');
const path = require('path');

async function generateSummary() {
  const summary = [];
  let securityScans = [];
  
  // Header
  summary.push('# ☕ Java CI/CD Summary');
  summary.push('');
  
  try {
    if (fs.existsSync('artifacts')) {
      // Quick Status Table
      summary.push('## 📊 Pipeline Status');
      summary.push('');
      
      // Determine status based on available artifacts
      const hasTests = fs.existsSync('artifacts/test-summary') || fs.existsSync('artifacts/test-results');
      const hasLint = fs.existsSync('artifacts/custom-lint-summary');
      const hasBuild = fs.existsSync('artifacts/java-package');
      
      // Security Scans
      if (fs.existsSync('artifacts')) {
        const artifactDirs = fs.readdirSync('artifacts');
        artifactDirs.forEach(dir => {
          if (dir.includes('trivy') || dir.includes('grype') || dir.includes('security')) {
            securityScans.push(dir);
          }
        });
      }
      const hasSecurity = securityScans.length > 0;
      
      summary.push('| Stage | Status | Details |');
      summary.push('|-------|--------|---------|');
      
      // Tests
      if (hasTests && fs.existsSync('artifacts/test-summary/test-summary.txt')) {
        const testContent = fs.readFileSync('artifacts/test-summary/test-summary.txt', 'utf8');
        const totalTests = testContent.match(/Total Tests: (\d+)/)?.[1] || '?';
        const failedTests = testContent.match(/Failed Tests: (\d+)/)?.[1] || '?';
        const status = failedTests === '0' ? '✅ PASSED' : '❌ FAILED';
        summary.push(`| 🧪 Tests | ${status} | ${totalTests} tests, ${failedTests} failed |`);
      } else {
        summary.push('| 🧪 Tests | ⚠️ Not Found | - |');
      }
      
      // Linting
      if (hasLint && fs.existsSync('artifacts/custom-lint-summary/lint-summary.txt')) {
        const lintContent = fs.readFileSync('artifacts/custom-lint-summary/lint-summary.txt', 'utf8');
        const status = lintContent.includes('PASSED') ? '✅ PASSED' : '❌ FAILED';
        const errors = lintContent.match(/Errors: (\d+)/)?.[1] || '0';
        summary.push(`| 🔍 Linting | ${status} | ${errors} errors |`);
      } else {
        summary.push('| 🔍 Linting | ⚠️ Not Found | - |');
      }
      
      // Build
      if (hasBuild) {
        const jarFiles = fs.readdirSync('artifacts/java-package', { recursive: true })
          .filter(file => file.endsWith('.jar') || file.endsWith('.war') || file.endsWith('.ear'));
        summary.push(`| 📦 Build | ✅ Completed | ${jarFiles.length} artifact(s) |`);
      } else {
        summary.push('| 📦 Build | ⚠️ Not Found | - |');
      }
      
      // Security
      summary.push(`| 🔒 Security | ${hasSecurity ? '✅ Completed' : '⚠️ Not Found'} | ${securityScans.length} scan(s) |`);
      
      summary.push('');
      
      // Coverage Summary (if available)
      if (fs.existsSync('artifacts/coverage-report/jacoco.csv')) {
        try {
          const csvContent = fs.readFileSync('artifacts/coverage-report/jacoco.csv', 'utf8');
          const lines = csvContent.split('\n');
          if (lines.length > 1) {
            const data = lines[1].split(',');
            if (data.length >= 9) {
              const lineCovered = parseInt(data[8]) || 0;
              const lineMissed = parseInt(data[7]) || 0;
              const totalLines = lineCovered + lineMissed;
              if (totalLines > 0) {
                const coveragePercent = Math.round((lineCovered * 100) / totalLines);
                summary.push(`## 📈 Coverage: ${coveragePercent}% (${lineCovered}/${totalLines} lines)`);
                summary.push('');
              }
            }
          }
        } catch (e) {
          // Ignore coverage parsing errors
        }
      }
      
      // Build Artifacts Summary
      if (hasBuild) {
        const jarFiles = fs.readdirSync('artifacts/java-package', { recursive: true })
          .filter(file => file.endsWith('.jar') || file.endsWith('.war') || file.endsWith('.ear'));
        
        if (jarFiles.length > 0) {
          summary.push('## 📦 Generated Artifacts');
          jarFiles.forEach(file => {
            try {
              const filePath = path.join('artifacts/java-package', file);
              const stats = fs.statSync(filePath);
              const sizeInMB = (stats.size / (1024 * 1024)).toFixed(1);
              summary.push(`- \`${file}\` (${sizeInMB} MB)`);
            } catch (err) {
              summary.push(`- \`${file}\``);
            }
          });
          summary.push('');
        }
      }
      
    } else {
      summary.push('## ⚠️ No artifacts found');
      summary.push('No build artifacts were generated or downloaded.');
      summary.push('');
    }
    
    // Footer
    summary.push('---');
    summary.push(`*Generated on ${new Date().toISOString()}*`);
    
  } catch (error) {
    summary.push('## ❌ Error generating summary');
    summary.push(`Error: ${error.message}`);
  }
  
  // Write to GITHUB_STEP_SUMMARY
  const summaryContent = summary.join('\n');
  fs.writeFileSync(process.env.GITHUB_STEP_SUMMARY, summaryContent);
  
  console.log('✅ Java CI/CD summary generated successfully');
}

generateSummary().catch(console.error); 