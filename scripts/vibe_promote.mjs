#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import crypto from 'crypto';
import { execSync } from 'child_process';

const SESSION_FILE = path.join('.softsensor', 'session.json');
const ACTIVE_TASK_FILE = path.join('.softsensor', 'active-task.json');
const MODE_FILE = path.join('.softsensor', 'mode');

// Colors for output
const colors = {
  green: '\x1b[32m',
  blue: '\x1b[34m',
  yellow: '\x1b[33m',
  cyan: '\x1b[36m',
  reset: '\x1b[0m'
};

// Generate unique contract ID
function generateContractId() {
  const timestamp = Date.now().toString(36).toUpperCase();
  const random = crypto.randomBytes(2).toString('hex').toUpperCase();
  return `F-${timestamp}-${random}`;
}

// Infer acceptance criteria from files and git diff analysis
async function inferAcceptanceCriteria(files, contractId) {
  const criteria = [];
  const telemetryEvents = [];
  
  // Get heuristic suggestions from git diff analysis
  try {
    const { analyzeGitDiff } = await import('./promotion_heuristics.mjs');
    const baseSha = process.env.BASE_SHA || 'HEAD~1';
    const headSha = process.env.HEAD_SHA || 'HEAD';
    const suggestions = analyzeGitDiff(baseSha, headSha);
    
    // Add suggested criteria from heuristics
    for (const criterion of suggestions.criteria) {
      // Replace <ID> placeholder with actual contract ID
      criterion.tests = criterion.tests.map(t => t.replace('<ID>', contractId));
      criteria.push(criterion);
    }
    
    // Collect telemetry events
    if (suggestions.telemetry && suggestions.telemetry.events) {
      telemetryEvents.push(...suggestions.telemetry.events);
    }
  } catch (error) {
    console.log('   Note: Heuristics analysis skipped (module not found)');
  }
  
  // Original pattern-based criteria
  const patterns = {
    config: files.some(f => f.match(/\.(json|yml|yaml|conf)$/)),
    scripts: files.some(f => f.match(/\.(sh|mjs|js|py)$/)),
    tests: files.some(f => f.includes('test') || f.includes('spec')),
    docs: files.some(f => f.match(/\.(md|txt)$/)),
    workflows: files.some(f => f.includes('.github/workflows'))
  };
  
  let criterionId = criteria.length + 1;
  
  if (patterns.config && !criteria.find(c => c.text.includes('onfiguration'))) {
    criteria.push({
      id: `AC-${criterionId++}`,
      must: 'MUST update configuration',
      text: 'Configuration files are properly formatted and valid',
      tests: [`tests/contract/${contractId}/config.contract.spec.ts`]
    });
  }
  
  if (patterns.scripts && !criteria.find(c => c.text.includes('script'))) {
    criteria.push({
      id: `AC-${criterionId++}`,
      must: 'MUST implement required scripts',
      text: 'Scripts execute without errors and produce expected output',
      tests: [`tests/contract/${contractId}/scripts.contract.spec.ts`]
    });
  }
  
  if (patterns.tests && !criteria.find(c => c.text.includes('test'))) {
    criteria.push({
      id: `AC-${criterionId++}`,
      must: 'MUST pass all tests',
      text: 'New and existing tests pass successfully',
      tests: [`tests/contract/${contractId}/tests.contract.spec.ts`]
    });
  }
  
  if (patterns.docs && !criteria.find(c => c.text.includes('ocumentation'))) {
    criteria.push({
      id: `AC-${criterionId++}`,
      must: 'MUST update documentation',
      text: 'Documentation accurately reflects implementation',
      tests: [`tests/contract/${contractId}/docs.contract.spec.ts`]
    });
  }
  
  if (patterns.workflows && !criteria.find(c => c.text.includes('workflow'))) {
    criteria.push({
      id: `AC-${criterionId++}`,
      must: 'MUST configure CI/CD',
      text: 'GitHub Actions workflows are valid and functional',
      tests: [`tests/contract/${contractId}/ci.contract.spec.ts`]
    });
  }
  
  // Default criterion if no specific patterns found
  if (criteria.length === 0) {
    criteria.push({
      id: 'AC-1',
      must: 'MUST implement core functionality',
      text: 'Feature works as intended without breaking existing functionality',
      tests: [`tests/contract/${contractId}/core.contract.spec.ts`]
    });
  }
  
  return { criteria, telemetryEvents };
}

// Create contract markdown
function createContractMarkdown(contractId, session, globs, criteria, telemetryEvents = []) {
  const yaml = `---
id: ${contractId}
title: ${session.title}
status: in_progress
owner: developer
version: 0.1.0
allowed_globs:
${globs.map(g => `  - ${g}`).join('\n')}
forbidden_globs:
  - src/**
acceptance_criteria:
${criteria.map(c => `  - id: ${c.id}
    must: ${typeof c.must === 'boolean' ? c.must : c.must}
    text: ${c.text}${c.suggested ? '\n    suggested: true' : ''}
    tests:
${c.tests.map(t => `      - ${t.replace('F-*', contractId)}`).join('\n')}`).join('\n')}${telemetryEvents.length > 0 ? `\ntelemetry:\n  events:\n${telemetryEvents.map(e => `    - ${e}`).join('\n')}` : ''}
checkpoints:
  - id: CP-1
    date: ${new Date().toISOString().split('T')[0]}
    status: started
    notes: Auto-generated from vibe session
---

# ${contractId}: ${session.title}

## Overview
This contract was auto-generated from a vibe exploration session.

**Session Details:**
- Started: ${session.started_at}
- Ended: ${session.ended_at || 'In progress'}
- Snapshots: ${session.snapshots.length}
- Files changed: ${session.impact?.files_changed || 'Unknown'}

## Intent
${session.intent}

## Scope
The following directories/files are included in this contract:
${globs.map(g => `- \`${g}\``).join('\n')}

## Implementation Notes
${session.snapshots.length > 0 ? `
### Snapshots taken during exploration:
${session.snapshots.map(s => `- **${s.id}** (${s.timestamp}): ${s.note || 'No note'}`).join('\n')}
` : 'No snapshots were taken during the exploration.'}

## Testing Strategy
Test scaffolds have been generated for each acceptance criterion. Implement these tests to verify the contract requirements are met.

## Next Steps
1. Review and refine the acceptance criteria
2. Implement the test cases in \`tests/contract/${contractId}/\`
3. Ensure all tests pass
4. Update status to 'achieved' when complete`;

  return yaml;
}

// Create test scaffold
function createTestScaffold(contractId, criterionName, criterion) {
  return `import { describe, it, expect } from '@jest/globals';

/**
 * Contract: ${contractId}
 * Criterion: ${criterion.id} - ${criterion.must}
 * 
 * ${criterion.text}
 */
describe('${contractId} - ${criterionName}', () => {
  it('should satisfy ${criterion.id}: ${criterion.must}', () => {
    // TODO: Implement test for: ${criterion.text}
    
    // Example assertion - replace with actual test
    expect(true).toBe(true);
  });
  
  // Add more specific test cases as needed
  it.todo('should handle edge cases');
  it.todo('should validate configuration');
  it.todo('should produce expected output');
});`;
}

async function promoteVibeSession() {
  // Load session
  let session;
  try {
    const content = await fs.readFile(SESSION_FILE, 'utf-8');
    session = JSON.parse(content);
  } catch {
    console.error('❌ No vibe session found');
    console.log('   Run "dp vibe start" to begin a session');
    process.exit(1);
  }
  
  if (!session.ended_at) {
    console.log(`${colors.yellow}⚠️  Vibe session is still active${colors.reset}`);
    console.log('   Running "dp vibe end" first to generate impact report...\n');
    
    // Run vibe end to generate impact report
    try {
      execSync('node scripts/vibe_end.mjs', { stdio: 'inherit' });
      // Reload session after end
      const content = await fs.readFile(SESSION_FILE, 'utf-8');
      session = JSON.parse(content);
    } catch (error) {
      console.error('Failed to end vibe session');
      process.exit(1);
    }
  }
  
  console.log(`\n${colors.cyan}🚀 Promoting vibe session to contract${colors.reset}`);
  console.log(`   Title: ${session.title}`);
  
  // Generate contract ID
  const contractId = generateContractId();
  console.log(`   Contract ID: ${contractId}`);
  
  // Use suggested globs or infer from changed files
  const globs = session.impact?.suggested_globs || ['scripts/**', 'tests/**'];
  console.log(`   Allowed globs: ${globs.length} patterns`);
  
  // Get changed files for criteria inference
  const changedFiles = session.impact?.directories?.map(d => d) || [];
  const { criteria, telemetryEvents } = await inferAcceptanceCriteria(changedFiles, contractId);
  console.log(`   Acceptance criteria: ${criteria.length} generated`);
  if (telemetryEvents && telemetryEvents.length > 0) {
    console.log(`   Telemetry events: ${telemetryEvents.length} detected`);
  }
  
  // Create contract file
  const contractPath = path.join('contracts', `${contractId}.contract.md`);
  const contractContent = createContractMarkdown(contractId, session, globs, criteria, telemetryEvents || []);
  
  await fs.mkdir('contracts', { recursive: true });
  await fs.writeFile(contractPath, contractContent);
  console.log(`${colors.green}✅ Created contract: ${contractPath}${colors.reset}`);
  
  // Create test scaffolds
  const testDir = path.join('tests', 'contract', contractId);
  await fs.mkdir(testDir, { recursive: true });
  
  // Generate scaffolds for heuristic-suggested tests
  try {
    const { analyzeGitDiff, generateTestScaffold: generateHeuristicScaffold } = await import('./promotion_heuristics.mjs');
    const suggestions = analyzeGitDiff(process.env.BASE_SHA || 'HEAD~1', process.env.HEAD_SHA || 'HEAD');
    for (const testInfo of suggestions.tests) {
      const testPath = path.join(testDir, testInfo.file);
      const scaffold = generateHeuristicScaffold(testInfo, contractId);
      await fs.writeFile(testPath, scaffold);
      console.log(`${colors.green}✅ Created test scaffold: ${testPath}${colors.reset}`);
    }
  } catch (error) {
    // Fall through to original test generation
  }
  
  const testTypes = {
    'config': criteria.find(c => c.text.includes('onfiguration')),
    'scripts': criteria.find(c => c.text.includes('script')),
    'tests': criteria.find(c => c.text.includes('test')),
    'docs': criteria.find(c => c.text.includes('ocumentation')),
    'ci': criteria.find(c => c.text.includes('CI') || c.text.includes('workflow')),
    'core': criteria.find(c => c.text.includes('core') || c.text.includes('functionality'))
  };
  
  for (const [name, criterion] of Object.entries(testTypes)) {
    if (criterion) {
      const testPath = path.join(testDir, `${name}.contract.spec.ts`);
      const testContent = createTestScaffold(contractId, name, criterion);
      await fs.writeFile(testPath, testContent);
      console.log(`${colors.green}✅ Created test scaffold: ${testPath}${colors.reset}`);
    }
  }
  
  // Update active-task.json
  const activeTask = {
    contract_id: contractId,
    allowed_globs: globs,
    forbidden_globs: ['src/**']
  };
  
  await fs.writeFile(ACTIVE_TASK_FILE, JSON.stringify(activeTask, null, 2));
  console.log(`${colors.green}✅ Updated active task${colors.reset}`);
  
  // Switch mode to BLOCK
  await fs.writeFile(MODE_FILE, 'BLOCK\n');
  console.log(`${colors.green}✅ Switched mode to BLOCK${colors.reset}`);
  
  console.log(`\n${colors.cyan}📋 Contract ${contractId} created!${colors.reset}`);
  console.log('\nNext steps:');
  console.log('1. Review the contract in contracts/' + contractId + '.contract.md');
  console.log('2. Refine acceptance criteria as needed');
  console.log('3. Implement tests in tests/contract/' + contractId + '/');
  console.log('4. Run "npm run contracts:validate" to verify');
  console.log('5. Commit with Contract-Id: ' + contractId);
}

// Main execution
promoteVibeSession().catch(error => {
  console.error('Error promoting vibe session:', error);
  process.exit(1);
});