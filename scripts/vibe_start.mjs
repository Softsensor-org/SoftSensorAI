#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import { execSync } from 'child_process';

const SOFTSENSOR_DIR = '.softsensor';
const SESSION_FILE = path.join(SOFTSENSOR_DIR, 'session.json');
const MODE_FILE = path.join(SOFTSENSOR_DIR, 'mode');

// Colors for output
const colors = {
  green: '\x1b[32m',
  blue: '\x1b[34m',
  yellow: '\x1b[33m',
  reset: '\x1b[0m'
};

// Convert title to slug
function titleToSlug(title) {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .substring(0, 50);
}

// Get current branch
function getCurrentBranch() {
  try {
    return execSync('git rev-parse --abbrev-ref HEAD', { encoding: 'utf-8' }).trim();
  } catch {
    return 'main';
  }
}

async function startVibeSession(title) {
  if (!title) {
    console.error('❌ Please provide a title for the vibe session');
    console.log('Usage: dp vibe start "exploration title"');
    process.exit(1);
  }

  const slug = titleToSlug(title);
  const branchName = `vibe/${slug}`;
  
  console.log(`\n${colors.blue}🎵 Starting vibe session${colors.reset}`);
  console.log(`   Title: ${title}`);
  console.log(`   Branch: ${branchName}`);
  
  // Ensure .softsensor directory exists
  await fs.mkdir(SOFTSENSOR_DIR, { recursive: true });
  
  // Check for existing session
  try {
    const existingSession = await fs.readFile(SESSION_FILE, 'utf-8');
    const session = JSON.parse(existingSession);
    if (!session.ended_at) {
      console.error(`\n${colors.yellow}⚠️  Active vibe session already exists${colors.reset}`);
      console.log(`   Started: ${session.started_at}`);
      console.log(`   Title: ${session.title}`);
      console.log('   Run "dp vibe end" to close it first');
      process.exit(1);
    }
  } catch {
    // No existing session or file not found - OK to proceed
  }
  
  // Create and checkout branch
  const currentBranch = getCurrentBranch();
  try {
    // Try to create new branch
    execSync(`git checkout -b ${branchName}`, { stdio: 'pipe' });
    console.log(`${colors.green}✅ Created and switched to branch: ${branchName}${colors.reset}`);
  } catch {
    // Branch might already exist, try to checkout
    try {
      execSync(`git checkout ${branchName}`, { stdio: 'pipe' });
      console.log(`${colors.yellow}⚠️  Switched to existing branch: ${branchName}${colors.reset}`);
    } catch (error) {
      console.error(`❌ Failed to create/checkout branch: ${branchName}`);
      process.exit(1);
    }
  }
  
  // Set mode to WARN
  await fs.writeFile(MODE_FILE, 'WARN\n');
  console.log(`${colors.green}✅ Set mode to WARN${colors.reset}`);
  
  // Create session file
  const session = {
    title,
    branch: branchName,
    started_at: new Date().toISOString(),
    intent: title,
    snapshots: [],
    base_branch: currentBranch,
    ended_at: null
  };
  
  await fs.writeFile(SESSION_FILE, JSON.stringify(session, null, 2));
  console.log(`${colors.green}✅ Created session file${colors.reset}`);
  
  console.log(`\n${colors.blue}🚀 Vibe session started!${colors.reset}`);
  console.log('   You can now explore freely with WARN-only guards');
  console.log('   Use "dp vibe snapshot" to save checkpoints');
  console.log('   Use "dp vibe promote" when ready to formalize');
}

// Main execution
const title = process.argv.slice(2).join(' ');
startVibeSession(title).catch(error => {
  console.error('Error starting vibe session:', error);
  process.exit(1);
});