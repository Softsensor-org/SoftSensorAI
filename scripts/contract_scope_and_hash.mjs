#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import crypto from 'crypto';
import { execSync } from 'child_process';
import { minimatch } from 'minimatch';

// Colors for output
const colors = {
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  reset: '\x1b[0m'
};

// Load and parse a contract file
async function loadContract(contractId) {
  try {
    const contractPath = path.join('contracts', `${contractId}.contract.md`);
    const content = await fs.readFile(contractPath, 'utf-8');
    const match = content.match(/^---\n([\s\S]*?)\n---/);
    
    if (!match) {
      throw new Error(`Invalid contract format: ${contractId}`);
    }
    
    const yaml = match[1];
    
    // Parse YAML fields
    const id = yaml.match(/^id:\s*(.+)$/m)?.[1];
    const allowedMatch = yaml.match(/allowed_globs:\s*\n((?:\s*-\s*.+\n)*)/);
    const forbiddenMatch = yaml.match(/forbidden_globs:\s*\n((?:\s*-\s*.+\n)*)/);
    const criteriaMatch = yaml.match(/acceptance_criteria:\s*\n([\s\S]*?)(?=\n[^\s]|\n*$)/);
    
    const allowed = allowedMatch 
      ? allowedMatch[1].match(/^\s*-\s*(.+)$/gm)?.map(m => m.replace(/^\s*-\s*/, '')) || []
      : [];
    const forbidden = forbiddenMatch
      ? forbiddenMatch[1].match(/^\s*-\s*(.+)$/gm)?.map(m => m.replace(/^\s*-\s*/, '')) || []
      : [];
    
    // Parse acceptance criteria for hash computation
    let acceptanceCriteria = [];
    if (criteriaMatch) {
      const criteriaText = criteriaMatch[1];
      const criteria = criteriaText.split(/\n\s*-\s+id:/).filter(Boolean);
      
      for (const criterion of criteria) {
        const id = criterion.match(/^\s*(.+?)$/m)?.[1];
        const must = criterion.match(/must:\s*(.+)$/m)?.[1];
        const text = criterion.match(/text:\s*(.+)$/m)?.[1];
        
        if (id) {
          acceptanceCriteria.push({
            id: id.startsWith('id:') ? id.substring(3).trim() : id.trim(),
            must: must || '',
            text: text || ''
          });
        }
      }
    }
    
    return {
      id,
      allowed_globs: allowed,
      forbidden_globs: forbidden,
      acceptance_criteria: acceptanceCriteria
    };
  } catch (error) {
    console.error(`Failed to load contract ${contractId}:`, error.message);
    return null;
  }
}

// Compute hash for a contract
function computeContractHash(contract) {
  const hashInput = {
    id: contract.id,
    allowed_globs: contract.allowed_globs,
    acceptance_criteria: contract.acceptance_criteria
  };
  const jsonString = JSON.stringify(hashInput, null, 0);
  const hash = crypto.createHash('sha256').update(jsonString).digest('hex');
  return hash.substring(0, 8); // Use first 8 chars for brevity
}

// Get changed files between two commits
function getChangedFiles(baseSha, headSha) {
  try {
    const output = execSync(`git diff --name-only ${baseSha}...${headSha}`, { encoding: 'utf-8' });
    return output.trim().split('\n').filter(Boolean);
  } catch (error) {
    console.error('Failed to get changed files:', error.message);
    return [];
  }
}

// Check if file matches any glob pattern
function matchesGlobs(file, globs) {
  return globs.some(glob => minimatch(file, glob));
}

// Main enforcement function
async function enforceContracts() {
  // Get environment variables
  const contractIds = process.env.CONTRACT_IDS?.trim().split(/\s+/).filter(Boolean) || [];
  const providedHash = process.env.CONTRACT_HASH?.trim();
  const baseSha = process.env.BASE_SHA || 'HEAD~1';
  const headSha = process.env.HEAD_SHA || 'HEAD';
  
  console.log(`\n${colors.blue}📋 Contract Enforcement${colors.reset}`);
  console.log(`   Contracts: ${contractIds.join(', ') || 'none'}`);
  console.log(`   Provided hash: ${providedHash || 'none'}`);
  
  if (contractIds.length === 0) {
    console.log(`\n${colors.yellow}⚠️  No contracts specified${colors.reset}`);
    return;
  }
  
  // Load all referenced contracts
  const contracts = [];
  const hashes = [];
  
  for (const contractId of contractIds) {
    const contract = await loadContract(contractId);
    if (contract) {
      contracts.push(contract);
      const hash = computeContractHash(contract);
      hashes.push(hash);
      console.log(`   Loaded: ${contractId} (hash: ${hash})`);
    } else {
      console.error(`${colors.red}❌ Failed to load contract: ${contractId}${colors.reset}`);
      process.exit(1);
    }
  }
  
  // Verify hash if provided
  if (providedHash) {
    const combinedHash = crypto.createHash('sha256')
      .update(hashes.sort().join(''))
      .digest('hex')
      .substring(0, 8);
    
    if (providedHash !== combinedHash) {
      console.error(`\n${colors.red}❌ Contract hash mismatch${colors.reset}`);
      console.error(`   Expected: ${combinedHash}`);
      console.error(`   Provided: ${providedHash}`);
      console.error('   Contracts may have changed since commit');
      process.exit(1);
    } else {
      console.log(`${colors.green}✅ Contract hash verified${colors.reset}`);
    }
  }
  
  // Get changed files
  const changedFiles = getChangedFiles(baseSha, headSha);
  console.log(`\n${colors.blue}📁 Changed files (${changedFiles.length})${colors.reset}`);
  
  // Combine globs from all contracts (union)
  const allAllowedGlobs = [];
  const allForbiddenGlobs = [];
  
  for (const contract of contracts) {
    allAllowedGlobs.push(...contract.allowed_globs);
    allForbiddenGlobs.push(...contract.forbidden_globs);
  }
  
  // Remove duplicates
  const allowedGlobs = [...new Set(allAllowedGlobs)];
  const forbiddenGlobs = [...new Set(allForbiddenGlobs)];
  
  console.log(`   Allowed patterns: ${allowedGlobs.join(', ') || 'none'}`);
  console.log(`   Forbidden patterns: ${forbiddenGlobs.join(', ') || 'none'}`);
  
  // Check each changed file
  const violations = [];
  
  for (const file of changedFiles) {
    // Check forbidden first
    if (forbiddenGlobs.length > 0 && matchesGlobs(file, forbiddenGlobs)) {
      violations.push(`❌ Forbidden: ${file}`);
      continue;
    }
    
    // Check allowed (if any patterns specified)
    if (allowedGlobs.length > 0 && !matchesGlobs(file, allowedGlobs)) {
      violations.push(`⚠️  Out of scope: ${file}`);
    }
  }
  
  // Report results
  if (violations.length > 0) {
    console.error(`\n${colors.red}Scope violations found:${colors.reset}`);
    violations.forEach(v => console.error(`   ${v}`));
    console.error(`\n${colors.red}❌ Changes exceed contract scope${colors.reset}`);
    process.exit(1);
  } else {
    console.log(`\n${colors.green}✅ All changes within contract scope${colors.reset}`);
  }
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  enforceContracts().catch(error => {
    console.error('Error enforcing contracts:', error);
    process.exit(1);
  });
}