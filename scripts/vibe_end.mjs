#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import { execSync } from 'child_process';

const SESSION_FILE = path.join('.softsensor', 'session.json');

// Colors for output
const colors = {
  green: '\x1b[32m',
  blue: '\x1b[34m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  reset: '\x1b[0m'
};

// Get all changed files since session start
function getAllChangedFiles(baseBranch) {
  try {
    const files = execSync(`git diff --name-only ${baseBranch}...HEAD`, { encoding: 'utf-8' })
      .trim().split('\n').filter(Boolean);
    return files;
  } catch {
    return [];
  }
}

// Group files by directory
function groupFilesByDirectory(files) {
  const groups = {};
  for (const file of files) {
    const dir = path.dirname(file);
    if (!groups[dir]) {
      groups[dir] = [];
    }
    groups[dir].push(path.basename(file));
  }
  return groups;
}

// Analyze file patterns
function analyzePatterns(files) {
  const patterns = {
    test_files: files.filter(f => f.includes('test') || f.includes('spec')),
    config_files: files.filter(f => f.match(/\.(json|yml|yaml|conf|config)$/)),
    script_files: files.filter(f => f.match(/\.(sh|mjs|js|py)$/)),
    doc_files: files.filter(f => f.match(/\.(md|txt|rst)$/)),
    source_files: files.filter(f => f.match(/\.(ts|tsx|jsx)$/))
  };
  
  return patterns;
}

async function endVibeSession() {
  // Load session
  let session;
  try {
    const content = await fs.readFile(SESSION_FILE, 'utf-8');
    session = JSON.parse(content);
  } catch {
    console.error('❌ No active vibe session found');
    process.exit(1);
  }
  
  if (session.ended_at) {
    console.error('❌ Vibe session has already ended');
    console.log(`   Ended at: ${session.ended_at}`);
    process.exit(1);
  }
  
  console.log(`\n${colors.blue}🏁 Ending vibe session${colors.reset}`);
  console.log(`   Title: ${session.title}`);
  console.log(`   Started: ${session.started_at}`);
  console.log(`   Snapshots: ${session.snapshots.length}`);
  
  // Get all changed files
  const changedFiles = getAllChangedFiles(session.base_branch);
  const fileGroups = groupFilesByDirectory(changedFiles);
  const patterns = analyzePatterns(changedFiles);
  
  // Generate impact report
  console.log(`\n${colors.blue}📊 Impact Report${colors.reset}`);
  console.log(`   Total files changed: ${changedFiles.length}`);
  
  if (changedFiles.length > 0) {
    console.log('\n📁 Files by directory:');
    for (const [dir, files] of Object.entries(fileGroups)) {
      console.log(`   ${colors.yellow}${dir}/${colors.reset}`);
      for (const file of files.slice(0, 5)) {
        console.log(`     - ${file}`);
      }
      if (files.length > 5) {
        console.log(`     ... and ${files.length - 5} more`);
      }
    }
    
    console.log('\n📈 File patterns:');
    if (patterns.test_files.length > 0) {
      console.log(`   Test files: ${patterns.test_files.length}`);
    }
    if (patterns.config_files.length > 0) {
      console.log(`   Config files: ${patterns.config_files.length}`);
    }
    if (patterns.script_files.length > 0) {
      console.log(`   Script files: ${patterns.script_files.length}`);
    }
    if (patterns.doc_files.length > 0) {
      console.log(`   Documentation: ${patterns.doc_files.length}`);
    }
    if (patterns.source_files.length > 0) {
      console.log(`   Source files: ${patterns.source_files.length}`);
    }
    
    // Suggest allowed globs
    const suggestedGlobs = new Set();
    for (const dir of Object.keys(fileGroups)) {
      if (dir === '.') {
        changedFiles.filter(f => !f.includes('/')).forEach(f => suggestedGlobs.add(f));
      } else {
        suggestedGlobs.add(`${dir}/**`);
      }
    }
    
    console.log(`\n${colors.green}💡 Suggested allowed_globs for contract:${colors.reset}`);
    for (const glob of Array.from(suggestedGlobs).sort()) {
      console.log(`   - ${glob}`);
    }
  }
  
  // Update session with end time
  session.ended_at = new Date().toISOString();
  session.impact = {
    files_changed: changedFiles.length,
    directories: Object.keys(fileGroups),
    patterns,
    suggested_globs: Array.from(suggestedGlobs || [])
  };
  
  await fs.writeFile(SESSION_FILE, JSON.stringify(session, null, 2));
  
  console.log(`\n${colors.green}✅ Vibe session ended${colors.reset}`);
  console.log('   Session data saved to .softsensor/session.json');
  console.log('   Run "dp vibe promote" to create a contract from this exploration');
}

// Main execution
endVibeSession().catch(error => {
  console.error('Error ending vibe session:', error);
  process.exit(1);
});