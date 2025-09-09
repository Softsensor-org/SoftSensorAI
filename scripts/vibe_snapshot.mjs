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
  reset: '\x1b[0m'
};

// Get current diff summary
function getDiffSummary() {
  try {
    const diff = execSync('git diff --stat', { encoding: 'utf-8' });
    const staged = execSync('git diff --cached --stat', { encoding: 'utf-8' });
    return {
      unstaged: diff.trim(),
      staged: staged.trim()
    };
  } catch {
    return { unstaged: '', staged: '' };
  }
}

// Get changed files
function getChangedFiles() {
  try {
    const unstaged = execSync('git diff --name-only', { encoding: 'utf-8' })
      .trim().split('\n').filter(Boolean);
    const staged = execSync('git diff --cached --name-only', { encoding: 'utf-8' })
      .trim().split('\n').filter(Boolean);
    const untracked = execSync('git ls-files --others --exclude-standard', { encoding: 'utf-8' })
      .trim().split('\n').filter(Boolean);
    
    return [...new Set([...unstaged, ...staged, ...untracked])];
  } catch {
    return [];
  }
}

async function createSnapshot(note) {
  // Load session
  let session;
  try {
    const content = await fs.readFile(SESSION_FILE, 'utf-8');
    session = JSON.parse(content);
  } catch {
    console.error('❌ No active vibe session found');
    console.log('   Run "dp vibe start" to begin a session');
    process.exit(1);
  }
  
  if (session.ended_at) {
    console.error('❌ Vibe session has already ended');
    console.log('   Run "dp vibe start" to begin a new session');
    process.exit(1);
  }
  
  console.log(`\n${colors.blue}📸 Creating snapshot${colors.reset}`);
  
  // Create snapshot data
  const timestamp = new Date().toISOString();
  const snapshotId = `snapshot-${session.snapshots.length + 1}`;
  const tagName = `${session.branch}-${snapshotId}`;
  
  const snapshot = {
    id: snapshotId,
    timestamp,
    note: note || '',
    tag: tagName,
    diff_summary: getDiffSummary(),
    changed_files: getChangedFiles()
  };
  
  // Create lightweight tag
  try {
    const message = note ? `Snapshot: ${note}` : `Snapshot at ${timestamp}`;
    execSync(`git tag -a ${tagName} -m "${message}"`, { stdio: 'pipe' });
    console.log(`${colors.green}✅ Created tag: ${tagName}${colors.reset}`);
  } catch (error) {
    console.error(`⚠️  Failed to create tag: ${tagName}`);
  }
  
  // Add snapshot to session
  session.snapshots.push(snapshot);
  await fs.writeFile(SESSION_FILE, JSON.stringify(session, null, 2));
  
  console.log(`${colors.green}✅ Snapshot saved${colors.reset}`);
  if (note) {
    console.log(`   Note: ${note}`);
  }
  console.log(`   Changed files: ${snapshot.changed_files.length}`);
  
  // Show diff summary if there are changes
  if (snapshot.diff_summary.unstaged || snapshot.diff_summary.staged) {
    console.log('\n📊 Diff summary:');
    if (snapshot.diff_summary.staged) {
      console.log('   Staged:');
      console.log('   ' + snapshot.diff_summary.staged.split('\n').join('\n   '));
    }
    if (snapshot.diff_summary.unstaged) {
      console.log('   Unstaged:');
      console.log('   ' + snapshot.diff_summary.unstaged.split('\n').join('\n   '));
    }
  }
}

// Main execution
const note = process.argv.slice(2).join(' ');
createSnapshot(note).catch(error => {
  console.error('Error creating snapshot:', error);
  process.exit(1);
});