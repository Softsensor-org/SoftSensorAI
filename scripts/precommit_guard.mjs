#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import { execSync } from 'child_process';
import { minimatch } from 'minimatch';

const ACTIVE_TASK_PATH = '.softsensor/active-task.json';
const MODE_PATH = '.softsensor/mode';

// Colors for output
const colors = {
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  reset: '\x1b[0m'
};

// Get current git branch
function getCurrentBranch() {
  try {
    return execSync('git rev-parse --abbrev-ref HEAD', { encoding: 'utf-8' }).trim();
  } catch {
    return 'main';
  }
}

// Get list of staged files
function getStagedFiles() {
  try {
    const output = execSync('git diff --cached --name-only', { encoding: 'utf-8' });
    return output.trim().split('\n').filter(Boolean);
  } catch {
    return [];
  }
}

// Load active task configuration
async function loadActiveTask() {
  try {
    const content = await fs.readFile(ACTIVE_TASK_PATH, 'utf-8');
    return JSON.parse(content);
  } catch {
    return null;
  }
}

// Load or determine mode
async function getMode() {
  // Check branch prefix first
  const branch = getCurrentBranch();
  if (branch.startsWith('vibe/')) {
    return 'WARN';
  }
  
  // Check mode file
  try {
    const mode = await fs.readFile(MODE_PATH, 'utf-8');
    return mode.trim().toUpperCase();
  } catch {
    // Default to BLOCK mode for safety
    return 'BLOCK';
  }
}

// Check if file matches any glob pattern
function matchesGlobs(file, globs) {
  return globs.some(glob => minimatch(file, glob));
}

// Load contract if specified
async function loadContract(contractId) {
  if (!contractId) return null;
  
  try {
    const contractPath = path.join('contracts', `${contractId}.contract.md`);
    const content = await fs.readFile(contractPath, 'utf-8');
    const match = content.match(/^---\n([\s\S]*?)\n---/);
    
    if (!match) return null;
    
    const yaml = match[1];
    // Simple YAML parsing for allowed_globs and forbidden_globs
    const allowedMatch = yaml.match(/allowed_globs:\s*\n((?:\s*-\s*.+\n)*)/);
    const forbiddenMatch = yaml.match(/forbidden_globs:\s*\n((?:\s*-\s*.+\n)*)/);
    
    const allowed = allowedMatch 
      ? allowedMatch[1].match(/^\s*-\s*(.+)$/gm)?.map(m => m.replace(/^\s*-\s*/, '')) || []
      : [];
    const forbidden = forbiddenMatch
      ? forbiddenMatch[1].match(/^\s*-\s*(.+)$/gm)?.map(m => m.replace(/^\s*-\s*/, '')) || []
      : [];
    
    return { allowed_globs: allowed, forbidden_globs: forbidden };
  } catch {
    return null;
  }
}

async function main() {
  // Load active task
  const activeTask = await loadActiveTask();
  
  // No active task = no check
  if (!activeTask || !activeTask.contract_id) {
    console.log(`${colors.blue}ℹ️  No active task configured - skipping scope check${colors.reset}`);
    process.exit(0);
  }
  
  // Get mode
  const mode = await getMode();
  
  // Load contract if specified
  const contract = await loadContract(activeTask.contract_id);
  
  // Merge globs from active task and contract
  const allowedGlobs = [
    ...(activeTask.allowed_globs || []),
    ...(contract?.allowed_globs || [])
  ];
  const forbiddenGlobs = [
    ...(activeTask.forbidden_globs || []),
    ...(contract?.forbidden_globs || [])
  ];
  
  // Get staged files
  const stagedFiles = getStagedFiles();
  
  if (stagedFiles.length === 0) {
    process.exit(0);
  }
  
  // Check each file
  const violations = [];
  const warnings = [];
  
  for (const file of stagedFiles) {
    // Check forbidden first
    if (forbiddenGlobs.length > 0 && matchesGlobs(file, forbiddenGlobs)) {
      violations.push(`❌ Forbidden: ${file}`);
      continue;
    }
    
    // Check allowed
    if (allowedGlobs.length > 0 && !matchesGlobs(file, allowedGlobs)) {
      const msg = `⚠️  Out of scope: ${file}`;
      if (mode === 'WARN') {
        warnings.push(msg);
      } else {
        violations.push(msg);
      }
    }
  }
  
  // Report results
  console.log(`\n${colors.blue}🔍 Scope Guard (${mode} mode)${colors.reset}`);
  console.log(`   Active contract: ${activeTask.contract_id}`);
  
  if (warnings.length > 0) {
    console.log(`\n${colors.yellow}Warnings:${colors.reset}`);
    warnings.forEach(w => console.log(`   ${w}`));
  }
  
  if (violations.length > 0) {
    console.log(`\n${colors.red}Violations:${colors.reset}`);
    violations.forEach(v => console.log(`   ${v}`));
    
    if (mode === 'BLOCK') {
      console.log(`\n${colors.red}❌ Commit blocked - files are out of scope${colors.reset}`);
      console.log('   To override: use WARN mode or update .softsensor/active-task.json');
      process.exit(1);
    }
  }
  
  if (violations.length === 0 && warnings.length === 0) {
    console.log(`   ${colors.green}✅ All files in scope${colors.reset}`);
  }
  
  process.exit(0);
}

main().catch(error => {
  console.error('Error in pre-commit hook:', error);
  process.exit(1);
});