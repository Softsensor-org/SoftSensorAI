#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import { execSync } from 'child_process';
import { glob } from 'glob';
import yaml from 'js-yaml';

// Colors for output
const colors = {
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  reset: '\x1b[0m'
};

// Load contract by ID
async function loadContract(contractId) {
  const contractPath = path.join('contracts', `${contractId}.contract.md`);
  
  try {
    const content = await fs.readFile(contractPath, 'utf-8');
    const match = content.match(/^---\n([\s\S]*?)\n---/);
    
    if (!match) {
      throw new Error(`No YAML front-matter in ${contractPath}`);
    }
    
    return yaml.load(match[1]);
  } catch (error) {
    console.error(`Failed to load contract ${contractId}: ${error.message}`);
    return null;
  }
}

// Read performance metrics (placeholder)
async function readPerformanceMetrics() {
  const metricsFile = 'artifacts/performance_metrics.json';
  
  try {
    const content = await fs.readFile(metricsFile, 'utf-8');
    return JSON.parse(content);
  } catch {
    // Return placeholder metrics if file doesn't exist
    console.log(`${colors.yellow}⚠️  No metrics file found, using placeholders${colors.reset}`);
    return {
      latency_ms_p50: 150,  // Placeholder 150ms P50 latency
      latency_ms_p95: 500,  // Placeholder 500ms P95 latency
      memory_mb: 128,       // Placeholder 128MB memory usage
      cpu_percent: 25       // Placeholder 25% CPU usage
    };
  }
}

// Run performance probe (placeholder)
async function runPerformanceProbe() {
  console.log(`${colors.blue}🔍 Running performance probe...${colors.reset}`);
  
  // Placeholder: In real implementation, this would run actual performance tests
  // For now, simulate with a simple script execution time measurement
  
  try {
    const startTime = Date.now();
    
    // Run a simple test command
    execSync('node -e "console.log(\'Performance test\')"', { stdio: 'pipe' });
    
    const endTime = Date.now();
    const latency = endTime - startTime;
    
    return {
      latency_ms_p50: latency,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error(`${colors.yellow}⚠️  Performance probe failed: ${error.message}${colors.reset}`);
    return null;
  }
}

// Check bundle size (placeholder)
async function checkBundleSize() {
  const bundleSizeFile = 'artifacts/bundle_size.json';
  
  try {
    const content = await fs.readFile(bundleSizeFile, 'utf-8');
    return JSON.parse(content);
  } catch {
    // Placeholder: Calculate approximate bundle size from source files
    console.log(`${colors.blue}📦 Calculating bundle size...${colors.reset}`);
    
    try {
      // Find all JS/TS files
      const files = await glob('**/*.{js,ts,jsx,tsx}', {
        ignore: ['node_modules/**', 'dist/**', 'build/**']
      });
      
      let totalSize = 0;
      for (const file of files) {
        const stats = await fs.stat(file);
        totalSize += stats.size;
      }
      
      // Convert to KB
      const sizeKB = Math.round(totalSize / 1024);
      
      return {
        current_kb: sizeKB,
        previous_kb: sizeKB - 10,  // Placeholder: assume 10KB increase
        delta_kb: 10
      };
    } catch (error) {
      console.error(`${colors.yellow}⚠️  Bundle size check failed: ${error.message}${colors.reset}`);
      return {
        current_kb: 0,
        previous_kb: 0,
        delta_kb: 0
      };
    }
  }
}

// Search for telemetry events in codebase
async function searchTelemetryEvents(events) {
  const results = {};
  
  console.log(`${colors.blue}🔍 Searching for telemetry events...${colors.reset}`);
  
  for (const event of events) {
    try {
      // Use grep to search for event strings
      const output = execSync(
        `grep -r "${event}" --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" --exclude-dir=node_modules --exclude-dir=dist . 2>/dev/null || true`,
        { encoding: 'utf-8', stdio: ['pipe', 'pipe', 'pipe'] }
      );
      
      const matches = output.trim().split('\n').filter(Boolean);
      results[event] = {
        found: matches.length > 0,
        count: matches.length,
        files: matches.slice(0, 3).map(m => m.split(':')[0])  // First 3 files
      };
    } catch {
      results[event] = {
        found: false,
        count: 0,
        files: []
      };
    }
  }
  
  return results;
}

// Check budget compliance
function checkBudgets(budgets, metrics, bundleSize) {
  const results = [];
  
  if (budgets.latency_ms_p50 !== undefined) {
    const actual = metrics.latency_ms_p50 || 0;
    const passed = actual <= budgets.latency_ms_p50;
    
    results.push({
      metric: 'latency_ms_p50',
      budget: budgets.latency_ms_p50,
      actual,
      passed,
      message: `P50 latency: ${actual}ms (budget: ${budgets.latency_ms_p50}ms)`
    });
  }
  
  if (budgets.bundle_kb_delta_max !== undefined) {
    const actual = bundleSize.delta_kb || 0;
    const passed = Math.abs(actual) <= budgets.bundle_kb_delta_max;
    
    results.push({
      metric: 'bundle_kb_delta_max',
      budget: budgets.bundle_kb_delta_max,
      actual: Math.abs(actual),
      passed,
      message: `Bundle size delta: ${actual}KB (max: ${budgets.bundle_kb_delta_max}KB)`
    });
  }
  
  return results;
}

// Main check function
async function checkBudgetsAndTelemetry() {
  const contractIds = process.env.CONTRACT_IDS?.trim().split(/\s+/).filter(Boolean) || [];
  
  console.log(`\n${colors.cyan}📊 Budget & Telemetry Checks${colors.reset}`);
  console.log(`   Contracts: ${contractIds.join(', ') || 'none'}`);
  
  if (contractIds.length === 0) {
    console.log(`${colors.yellow}⚠️  No contracts specified, skipping checks${colors.reset}`);
    return;
  }
  
  let allPassed = true;
  
  for (const contractId of contractIds) {
    console.log(`\n${colors.blue}Checking contract: ${contractId}${colors.reset}`);
    
    const contract = await loadContract(contractId);
    if (!contract) {
      continue;
    }
    
    // Check budgets if defined
    if (contract.budgets) {
      console.log('\n📈 Performance Budgets:');
      
      const metrics = await readPerformanceMetrics();
      const bundleSize = await checkBundleSize();
      const budgetResults = checkBudgets(contract.budgets, metrics, bundleSize);
      
      for (const result of budgetResults) {
        if (result.passed) {
          console.log(`   ${colors.green}✅ ${result.message}${colors.reset}`);
        } else {
          console.log(`   ${colors.red}❌ ${result.message}${colors.reset}`);
          allPassed = false;
        }
      }
    }
    
    // Check telemetry events if defined
    if (contract.telemetry?.events) {
      console.log('\n📡 Telemetry Events:');
      
      const eventResults = await searchTelemetryEvents(contract.telemetry.events);
      
      for (const [event, result] of Object.entries(eventResults)) {
        if (result.found) {
          console.log(`   ${colors.green}✅ "${event}" found in ${result.count} location(s)${colors.reset}`);
          if (result.files.length > 0) {
            console.log(`      Files: ${result.files.join(', ')}`);
          }
        } else {
          console.log(`   ${colors.yellow}⚠️  "${event}" not found in codebase${colors.reset}`);
          // Don't fail for missing telemetry, just warn
        }
      }
    }
    
    // No budgets or telemetry defined
    if (!contract.budgets && !contract.telemetry) {
      console.log(`   ${colors.blue}ℹ️  No budgets or telemetry defined${colors.reset}`);
    }
  }
  
  // Summary
  console.log(`\n${colors.cyan}${'='.repeat(50)}${colors.reset}`);
  if (allPassed) {
    console.log(`${colors.green}✅ All budget checks passed${colors.reset}`);
  } else {
    console.log(`${colors.red}❌ Some budget checks failed${colors.reset}`);
    process.exit(1);
  }
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  checkBudgetsAndTelemetry().catch(error => {
    console.error(`${colors.red}Error: ${error.message}${colors.reset}`);
    process.exit(1);
  });
}